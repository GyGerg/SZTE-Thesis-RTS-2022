using Godot;
using System;
using System.Runtime.CompilerServices;
using ThesisRTS.AI;

public partial class RotateComponent : Node
{

	private Quaternion _targetRotation = Quaternion.Identity;
	public Quaternion TargetRotation
	{
		get => _targetRotation;
		set
		{
			var eul = value.GetEuler();
			fuckIsThis = 0f;
			// eul.Z = 0;
			_targetRotation = Quaternion.FromEuler(eul);
			// if (_targetRotation.Dot(Parent.Basis.GetRotationQuaternion()) > 0.1f)
			// 	ProcessMode = ProcessModeEnum.Inherit;
		}
	}

	[Export] public Node3D Parent { get; set; }
	[Export(PropertyHint.Range, "0,180")] private float snapLimit = 5;
	public AgentAngularVelocityLimits _angularLimits { get; set; }
	private float _currentAngularVelocity = 0f;
	private float _acceleration = 0f;
	private float _deceleration = 0f;
	private Vector3 _lastAxis = Vector3.Zero;
	private Quaternion _lastRotation = Quaternion.Identity;
	
	

	private float fuckIsThis = 0f;

	public RotateComponent(Node3D parent, Quaternion targetRotation, AgentAngularVelocityLimits angularLimits)
	{
		Parent = parent;
		TargetRotation = targetRotation;
		_angularLimits = angularLimits;
	}
	public RotateComponent(Node3D parent, AgentAngularVelocityLimits angularLimits) : this(parent,parent.Basis.GetRotationQuaternion(), angularLimits)
	{}
	public RotateComponent()
	{}
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		_acceleration = 0.0f;
		_deceleration = 0.0f;
		Parent ??= GetParent<Node3D>();
	}

	float Vector3ToAngle(in Vector3 vec)
	{
		return Mathf.Atan2(vec.X, vec.Z);
	}
	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _PhysicsProcess(double delta)
	{
		return;
		float targetAngle = (TargetRotation.Inverse()*Parent.GlobalTransform.Basis.GetRotationQuaternion()).GetAngle();
		ref float angularVelocity = ref (Parent as Unit)!.angularVelocity;
		if (targetAngle == 0)
		{
			angularVelocity = 0;
			return;
		}
		
		float rotation = Mathf.Wrap(targetAngle, -Mathf.Pi, Mathf.Pi);
		float rotationSize = Mathf.Abs(rotation);

		var limitRad = Mathf.DegToRad(snapLimit);
		
		if (Mathf.RadToDeg(rotationSize) <= snapLimit)
		{
			angularVelocity = 0;
			return;
		}

		var desiredRotation = angularVelocity * (rotation / rotationSize);

		var (axis, angle) = CalculateAngleAndAxisForTransform(Parent.Transform);
		
		if (!axis.IsNormalized())
			axis = axis.Normalized();
		
		var angularAcceleration = (desiredRotation - angularVelocity);
		var limitedAccel = Mathf.Abs(angularAcceleration);

		if (limitedAccel > _angularLimits.AngularAccelerationMax)
			angularAcceleration *= _angularLimits.AngularAccelerationMax / limitedAccel;
		
		// GD.Print("AngVel: ", angularVelocity);
		angularVelocity += angularAcceleration*(float)delta;
		
		var limitedVelocity = Mathf.Abs(angularVelocity);
		if (limitedVelocity > _angularLimits.AngularSpeedMax)
			angularVelocity *= _angularLimits.AngularSpeedMax / limitedVelocity;
		
		// if (axis.Length() > 0 && limitedVelocity > 0)
		// {
		// 	Parent.GlobalRotate(axis, angularVelocity*(float)delta);
		// }
	}
	
	public (Vector3 axis, float angle) CalculateAngleAndAxisForTransform(in Transform3D transform)
	{
		var desiredRotation = TargetRotation;
		var quatChange = desiredRotation * transform.Basis.GetRotationQuaternion().Inverse();
		
		#region TheMaaath
		float angle = 2f * MathF.Acos(quatChange.W);
		// var axis = angle == 0
		// 	? Vector3.Zero
		// 	: (1f / MathF.Sin(angle / 2)) * new Vector3(quatChange.X, quatChange.Y, quatChange.Z);
		#endregion
		
		var axis = quatChange.GetAxis();
		// var angle = transform.Basis.GetEuler().AngleTo(TargetRotation.GetEuler());
		return (axis, angle);
	}
	
	[MethodImpl(MethodImplOptions.AggressiveInlining)]
	public Vector3 AxisBetweenQuaternions(Quaternion a, Quaternion b)
	{
		var quat = a.Inverse() * b;
		return quat.GetAxis();
	}

	public Vector3 CalculateTorque(in Transform3D transform) =>
		CalculateAngleAndAxisForTransform(transform).axis.Normalized();
}
