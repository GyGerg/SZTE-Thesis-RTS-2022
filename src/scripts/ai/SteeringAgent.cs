using Godot;

namespace ThesisRTS.AI
{
    internal partial class SteeringAgent : RefCounted
    {
        public AgentLinearVelocityLimits LinearLimits { get; private set; }
        public AgentAngularVelocityLimits AngularLimits { get; private set; }

        public Vector3 LinearVelocity { get; set; }
        public Quaternion AngularVelocity { get; set; }

        public double BoundingRadius { get; private set; }

        public Location Location;

        public SteeringAgent(AgentLinearVelocityLimits linearLimits, AgentAngularVelocityLimits angularLimits, Vector3 linearVelocity, Quaternion angularVelocity, double boundingRadius, Vector3 position, Quaternion orientation)
        {
            LinearLimits = linearLimits;
            AngularLimits = angularLimits;
            LinearVelocity = linearVelocity;
            AngularVelocity = angularVelocity;
            BoundingRadius = boundingRadius;

            Location = new Location(position, orientation);
        }

        public SteeringAgent(AgentLinearVelocityLimits linearLimits, AgentAngularVelocityLimits angularLimits,
            Vector3 linearVelocity, Quaternion angularVelocity, double boundingRadius)
            : this(linearLimits, angularLimits, linearVelocity, angularVelocity, boundingRadius, Vector3.Zero,
                Quaternion.Identity)
        { }
    }

    public interface IAgentLinearVelocity
    {
        [ExportCategory("Agent Linear Velocity Limits")]
        [Export] public float ZeroLinearSpeedThreshold { get; set; }
        [Export] public float LinearSpeedMax { get; set; }
        [Export] public float LinearAccelerationMax { get; set; }
    }

    public interface IAgentAngularVelocity
    {
        [Export]public float AngularSpeedMax { get; set; }
        [Export]public float AngularAccelerationMax { get; set; }
    }
    
    [GodotClassName(nameof(AgentLinearVelocityLimits))]
    public partial class AgentLinearVelocityLimits : Resource
    {
        [ExportCategory("Agent Linear Velocity Limits")] public float ZeroLinearSpeedThreshold { get; set; }
        [Export] public float LinearSpeedMax { get; set; }
        [Export] public float LinearAccelerationMax { get; set; }

        public AgentLinearVelocityLimits(float zeroLinearSpeedThreshold, float linearSpeedMax,
            float linearAccelerationMax)
        {
            ZeroLinearSpeedThreshold = zeroLinearSpeedThreshold;
            LinearSpeedMax = linearSpeedMax;
            LinearAccelerationMax = linearAccelerationMax;
            
        }
        public AgentLinearVelocityLimits() : this(0f,0f,0f)
        {}
    }
    [GodotClassName(nameof(AgentAngularVelocityLimits))]
    public partial class AgentAngularVelocityLimits : Resource
    {
        [Export]public float AngularSpeedMax { get; set; }
        [Export]public float AngularAccelerationMax { get; set; }

        public AgentAngularVelocityLimits(float angularSpeedMax, float angularAccelerationMax)
        {
            AngularSpeedMax = angularSpeedMax;
            AngularAccelerationMax = angularAccelerationMax;
        }
        public AgentAngularVelocityLimits() : this(0f,0f)
        {}
    }
}
