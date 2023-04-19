using Godot;
using System;
using ThesisRTS.AI;
using ThesisRTS.AI.behaviors;


public enum UnitControlMode
{
	Follow,
	Arrive,
	Player
}
[GodotClassName(nameof(Unit))]
public partial class Unit : RigidBody3D, IComparable<Unit>, IEquatable<Unit>, IAgentLinearVelocity, IAgentAngularVelocity
{
	private bool _isSelected = false;
	[Export(PropertyHint.ResourceType, "PidController")]
	private Resource _trialPidData;

	private static readonly StringName pidController = "PidController";
	private static readonly StringName PidGetValues = "get_pid_values";

	[Export] public RotateComponent? RotateComponent { get; private set; }
	public Vector3 _target;
	[Export] private UnitControlMode controlMode = UnitControlMode.Follow;

	private Vector3 _velocity = Vector3.Zero;
	private Vector3 _approxUp = Vector3.Up;

	private float targetVelocityLength = 0f;

	private Vector3 _lastRotationAxis = Vector3.Zero;
	
	public float angularVelocity = 0;
	private Quaternion _angular_velocity = Quaternion.Identity;
	public Vector3 Target
	{
		get => _target;
		set
		{
			_target = value;
		}
	}

	public bool IsSelected
	{
		get => _isSelected;
		set
		{
			if (_isSelected == value)
				return;
			_isSelected = value;
			if (value)
			{
				AddToGroup("selected_units");
			}
			else
			{
				var circ = GetNode("select_circle");
				RemoveFromGroup("selected_units");
				RemoveChild(circ);
				circ.QueueFree();
			}
		}
	}

	[Export]
	public int Team
	{
		get;
		private set;
	}
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		_velocity = Vector3.Zero;
		if(RotateComponent is {})
			RotateComponent._angularLimits = new AgentAngularVelocityLimits(AngularSpeedMax, AngularAccelerationMax);
		
		var timer = GetTree().CreateTimer(0);
		timer.Timeout += () =>
		{
			Target = GlobalPosition - Transform.Basis.Z;
		};

	}

	public (Vector3 axis, float angle) CalculateAngleAndAxisForTransform(in Quaternion current, in Quaternion target)
	{
		var desiredRotation = target;
		var quatChange = current.Inverse() * desiredRotation;
		var angle = 2f * Mathf.Acos(quatChange.W);
		var axis = angle == 0
			? Vector3.Zero
			: (1f / Mathf.Sin(angle / 2)) * new Vector3(quatChange.X, quatChange.Y, quatChange.Z);
		return (axis, angle);
	}
	public (Vector3 axis, float angle) CalculateAngleAndAxisForTransform(in Transform3D transform, in Transform3D target)
	{
		return CalculateAngleAndAxisForTransform(new Quaternion(transform.Basis),
			new Quaternion(transform.LookingAt(target.Origin, Vector3.Up).Basis));
	}

	

	public Vector3 CalculateTorque(in Transform3D transform, in Transform3D target) =>
		CalculateAngleAndAxisForTransform(transform, target).axis.Normalized();

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _PhysicsProcess(double delta)
	{

		var currentRot = GlobalTransform.Basis.GetRotationQuaternion().Normalized();
		var targetRot = GlobalTransform
			.LookingAt(_target-(Transform.Basis.Z*0.1f), Vector3.Up).Orthonormalized().Basis
			.GetRotationQuaternion()
			.Normalized();
		
		var targetTransform = GlobalTransform
			.LookingAt(_target - (Transform.Basis.Z * 0.1f), Vector3.Up).Orthonormalized();
		
		var (axis, angle) = CalculateAngleAndAxisForTransform(GlobalTransform, targetTransform);
		var torque = axis.Normalized();
		GD.Print(Name, " Torque: ", torque);
		
		Vector3 Forward() => -Transform.Basis.Z.Normalized();
		
		if (Mathf.Abs(angle) > 0)
		{
			var vect = Transform.Basis.Z.Cross(GlobalPosition - _target)
			           * AngularAccelerationMax * Mass;
			if (AngularVelocity.LengthSquared() > 0)
			{
				var rotated = Forward().Rotated(AngularVelocity.Normalized(), AngularVelocity.Length());
				var angleToRotated = Forward().AngleTo(rotated);
				var angleAbs = Mathf.Abs(angleToRotated);
				if (angleAbs > AngularSpeedMax)
				{
					ApplyTorque(-vect * (AngularSpeedMax / angleAbs));
					// vect *= AngularSpeedMax / angleAbs;
				}
			}
			ApplyTorque(vect);
		}

		var q = new Quaternion(Transform.Basis.Y, Vector3.Up);
		ApplyTorque(new Vector3(q.X,q.Y,q.Z)*10);

	}

	private void ApplyOrientationSteering(float angularAcceleration, float delta, Vector3 axis)
	{
		var velocity = Mathf.Clamp(angularVelocity + angularAcceleration*delta, -AngularSpeedMax, AngularSpeedMax);
		GlobalRotate(axis,velocity);
	}

	private static Quaternion ClampQuaternion(Quaternion q, Vector3 bounds)
	{
		q.X /= q.W;
		q.Y /= q.W;
		q.Z /= q.W;
		q.W = 1.0f;

		float angleX = 2.0f * Mathf.RadToDeg(Mathf.Atan(q.X));
		angleX = Mathf.Clamp(angleX, -bounds.X, bounds.X);
		q.X = Mathf.Tan(0.5f * Mathf.DegToRad(angleX));
		
		float angleY = 2.0f * Mathf.RadToDeg(Mathf.Atan(q.Y));
		angleY = Mathf.Clamp(angleY, -bounds.Y, bounds.Y);
		q.Y = Mathf.Tan(0.5f * Mathf.DegToRad(angleY));
		
		float angleZ = 2.0f * Mathf.RadToDeg(Mathf.Atan(q.Z));
		angleZ = Mathf.Clamp(angleZ, -bounds.Z, bounds.Z);
		q.Z = Mathf.Tan(0.5f * Mathf.DegToRad(angleZ));
		
		return q.Normalized();
	}

	public (Vector3 velocity, Vector3 steering) Follow(Vector3 velocity, Vector3 globalPosition, 
		Vector3 targetPosition, float maxSpeed, float mass)
	{
		const float maxForce = 0.1f;
		Vector3 desiredVelocity = (targetPosition - globalPosition).Normalized()*maxSpeed;
		
		Vector3 steerDirection = desiredVelocity - velocity;
		Vector3 steerForce = steerDirection;
		Vector3 steering = (steerForce/* / mass*/)*maxForce;
		
		return (velocity, steering);
	}
	
	

	private (Vector3 velocity, Vector3 steering) Arrive(Vector3 velocity, Vector3 globalPosition,
		Vector3 targetPosition, float maxSpeed, float mass, float slowRadius = 20f)
	{
		float distance = globalPosition.DistanceTo(targetPosition);
		Vector3 desiredVelocity = (targetPosition - globalPosition).Normalized()*maxSpeed;

		if (distance < slowRadius)
		{
			desiredVelocity *= (distance / slowRadius);
		}
		
		var steering = (desiredVelocity - velocity)/* / mass*/;

		return (velocity, steering);
	}

	public override void _Process(double delta)
	{
		// Translate(Vector3.Forward*(float)delta);
	}

	public override int GetHashCode()
	{
		return HashCode.Combine(GetInstanceId());
	}

	public int CompareTo(Unit? other)
    {
		return Mathf.Sign(other?.GetInstanceId() ?? 0 - GetInstanceId());
    }

    public override bool Equals(object? other)
    {
	    return other is Unit && Equals(other);
    }

    public bool Equals(Unit? other)
    {
		return other is not null && other.GetInstanceId() == GetInstanceId();
    }
    
	[ExportGroup("Agent Limits")]
	[Export(PropertyHint.Range,"0.5,5")] private double boundingRadius = 1f;
    [ExportSubgroup("Linear Velocity")]
    [Export] public float ZeroLinearSpeedThreshold { get; set; }


    [Export]
    public float LinearSpeedMax { get; set; }

    [Export] public float LinearAccelerationMax { get; set; }

    [ExportSubgroup("Angular Velocity")] private float _angularSpeedMax;
    [Export(PropertyHint.Range, "0f,360f")] public float AngularSpeedMax
    {
	    get => _angularSpeedMax;
	    set
	    {
			_angularSpeedMax = Mathf.DegToRad(value);
	    } 
    }

    private float _angularAccelerationMax;
    // Maximum acceleration, provided in degrees (converted to Radians under the hood)
    [Export(PropertyHint.Range, "0f,360f")] public float AngularAccelerationMax
    {
	    get => _angularAccelerationMax;
	    set
	    {
			_angularAccelerationMax = Mathf.DegToRad(value);
	    } 
    }
    
}
