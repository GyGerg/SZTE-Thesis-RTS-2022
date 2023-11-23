class_name UnitGD extends RigidBody3D

@export_group("PID Controllers", "pid_controller")
@export_subgroup("Linear PID", "_vel_pid")
@export var _vel_pid_side:PidController
@export var _vel_pid_height:PidController
@export var _vel_pid_backward:PidController ## forward is NEGATIVE z

@export_subgroup("Angular PID", "_ang_pid")
@export var _ang_pid_pitch:PidController
@export var _ang_pid_yaw:PidController
@export var _ang_pid_roll:PidController

@export_group("Angular Speed Limits", "_ang_lim")
@export_range(-PI,PI) var _ang_lim_roll:float = deg_to_rad(30)
@export_range(-PI,PI) var _ang_lim_pitch:float = deg_to_rad(90)
@export_range(-PI,PI) var _ang_lim_yaw:float = deg_to_rad(90)

var target : Vector3
var last_forward : Vector3
@export var force : float
@export var rot_force : float

enum UnitControlMode
{
	Follow,
	Arrive,
	Player
}

var curr_update_period : int = 0
@export var control_mode : UnitControlMode = UnitControlMode.Follow

var _is_selected : bool = false :
	set(val):
		if not (val is bool) or _is_selected == val:
			return
		if _is_selected != val:
			if val:
				add_to_group("selected_units")
			else:
				remove_from_group("selected_units")
		_is_selected = val

# Called when the node enters the scene tree for the first time.
func _ready():
	last_forward = _get_forward(transform)
	await get_tree().create_timer(0).timeout
	target = global_position - transform.basis.z
	angular_velocity = Vector3.ZERO
	pass # Replace with function body.


func _physics_process(delta):
	if target.distance_squared_to(global_position) > 2*2:
#		_do_move_stuff(delta,target)
		_do_rotate_stuff(delta,target)
		pass
	else:
		_do_move_stuff(delta,global_position-(linear_velocity*delta),true)
		_do_rotate_stuff(delta,global_position-transform.basis.z)
		pass
	last_forward = _get_forward(global_transform)
	curr_update_period+=1

func _do_move_stuff(delta:float, target:Vector3, side_enabled := false):
## valami doc
	var target_local := to_local(target)
#	print("local target: ", target_local)
	var lin_vel := to_local(global_position+linear_velocity)
#	print("lin vel: ",lin_vel )
	var desired_velocity := target_local.z#minf(target_local.z,0)
	var side_target:Vector2 = Vector2.ZERO if not side_enabled else Vector2(target_local.x,target_local.y)
	var mov := Vector3(
		_vel_pid_side.Update(lin_vel.x,side_target.x,delta) as float,
		_vel_pid_height.Update(lin_vel.y,side_target.y,delta) as float,
		_vel_pid_backward.Update(lin_vel.z,desired_velocity,delta) as float,
	)
#	print("mov: ", mov)
	apply_central_force(transform.basis.x*mov.x*force)
	apply_central_force(transform.basis.y*mov.y*force)
	apply_central_force(transform.basis.z*mov.z*force)
	
func _get_rot_euler(tform:Transform3D):
	return tform.basis.get_euler()
func _ang_diff(curr:float,tgt:float) -> float:
	var cdeg := rad_to_deg(curr)
	var tdeg := rad_to_deg(tgt)
	
	var diffdeg := fmod(cdeg-tdeg+540,360)-180
	return deg_to_rad(diffdeg)

func _get_forward(tform:Transform3D) -> Vector3:
	return -tform.basis.z
func _get_right(tform:Transform3D) -> Vector3:
	return tform.basis.x
func _get_up(tform:Transform3D) -> Vector3:
	return tform.basis.y
## must provide ur mom as param
##
## haha xd
func _force_stabilize_rotation() -> void:
	angular_velocity = Vector3.ZERO
	
	
func _stabilize_rotation(delta:float,target_fwd_angles:Vector3):
	var ang_vel := angular_velocity
	if not angular_velocity.x == 0:
		apply_torque(Vector3.RIGHT * (-angular_velocity.x))
	if not angular_velocity.y == 0:
		apply_torque(Vector3.UP * (-angular_velocity.y))
	if not angular_velocity.z == 0:
		apply_torque(Vector3.FORWARD * (-angular_velocity.z))
	pass
	
func _match_pitch(delta:float,target_fwd:Vector3) -> void:
	var fwd := _get_forward(global_transform)
	var up := _get_up(global_transform)
	var right := _get_right(global_transform)
	var local_angle := fwd.signed_angle_to(target_fwd,right) + angular_velocity.x*delta
	if local_angle == 0:
		return
	else:
		apply_torque(right*(_ang_lim_pitch * rot_force*delta*signf(local_angle)))
		pass
func _match_roll(delta:float,target_up := Vector3.UP):
	var fwd := _get_forward(global_transform)
	var up := _get_up(global_transform)
	var right := _get_right(global_transform)
	var local_angle := up.signed_angle_to(target_up,fwd) + angular_velocity.z*delta
	if local_angle == 0:
		return
	else:
		apply_torque(fwd*(_ang_lim_roll * rot_force*delta*signf(local_angle)))
	pass
func _match_yaw(delta:float,target_right:Vector3):
	var fwd := _get_forward(global_transform)
	var up := _get_up(global_transform)
	var right := _get_right(global_transform)
	var local_angle := right.signed_angle_to(target_right,up) + angular_velocity.y*delta
	if local_angle == 0:
		return
	else:
		apply_torque(up*(_ang_lim_yaw * rot_force*delta*signf(local_angle)))
	pass

func _quat_get_torque(qt:Quaternion, invalid_angle_callback:Callable = func():pass) -> Vector3:
	var angle = 2*acos(qt.w)
	if angle < 0.1:
		invalid_angle_callback.call()
		return Vector3.ZERO
	var axis := (1/sin(angle/2))*Vector3(qt.x,qt.y,qt.z)
	return axis*angle
	
func _do_rotate_stuff(delta:float,target:Vector3):
	var ang_vel := angular_velocity
	var ang_len := ang_vel.length()
	if ang_len == 0:
		ang_vel = Vector3.ZERO
	else:
		var looking_at_ang_vel := transform.rotated(ang_vel.normalized(),ang_len)
		var quat_diff := Quaternion(transform.basis).inverse() * Quaternion(looking_at_ang_vel.basis)
		ang_vel = _quat_get_torque(quat_diff)
	print("ang_vel: ",ang_vel)
	var curr_rot_trans := global_transform
	var fwd := _get_forward(curr_rot_trans)
	var right := _get_right(curr_rot_trans)
	var up := _get_up(curr_rot_trans)
	var target_rot_trans := transform.looking_at(target, up)
	
#	var quat_diff := Quaternion(global_transform.basis).inverse() * Quaternion(target_rot_trans.basis)
	var quat_diff := Quaternion(fwd,_get_forward(target_rot_trans))
	
	var angle := 2*acos(quat_diff.w)
	print("angle: ",angle)
	if absf(angle) < .5:
#		if ang_len > 0.2:
#			print("stabilizing rotation")
#			_stabilize_rotation(delta,Vector3.ZERO)
		if ang_len > 0 and absf(angle) < 0.1:
			print("force stabilize")
#			_force_stabilize_rotation()
#			return
	var axis:Vector3=(1/sin(angle/2))*Vector3(quat_diff.x,quat_diff.y,quat_diff.z)
	var vec3_diff := axis
	vec3_diff.z = 0
	vec3_diff = vec3_diff.normalized()*angle
	print("vec diff: ",vec3_diff)
#	apply_torque(transform.basis*values*delta*rot_force*mass)
	print(curr_update_period)
	
	match curr_update_period:
		0:
			if angle != 0:
				apply_torque(transform.basis.x*_ang_pid_pitch.Update(ang_vel.x,vec3_diff.x,delta)*delta*rot_force*mass)
			pass
		1:
			if angle != 0:
				apply_torque(transform.basis.y*_ang_pid_yaw.Update(ang_vel.y,vec3_diff.y,delta)*delta*rot_force*mass)
			pass
		2:
			if absf(ang_vel.x) < 0.2 and absf(ang_vel.y) < 0.2:
				apply_torque(transform.basis.z*_ang_pid_roll.Update(rotation.z,0,delta)*delta*rot_force*mass)
			pass
		_:
			print("reseting curr update period")
			curr_update_period = -1
			pass
	return
	if angle != 0:
		var pitch_yaw := Vector2(
			_ang_pid_pitch.Update(ang_vel.x,vec3_diff.x,delta),
			_ang_pid_yaw.Update(ang_vel.y,vec3_diff.y,delta)
		)
		apply_torque(transform.basis.x*pitch_yaw.x*delta*rot_force*mass)
		apply_torque(transform.basis.y*pitch_yaw.y*delta*rot_force*mass)
	var pitch_yaw_curr := Vector2(ang_vel.x,ang_vel.y).abs()
	if pitch_yaw_curr.x < 0.2 and pitch_yaw_curr.y < 0.2:
		var roll_val : float = _ang_pid_roll.Update(rotation.z,0,delta)
		apply_torque(transform.basis.z*roll_val*delta*rot_force*mass)
	
	
	
func set_target(val:Vector3):
	target = val
	print("SET TARGET TO ", target)
