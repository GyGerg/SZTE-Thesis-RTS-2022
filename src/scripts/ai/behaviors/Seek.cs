using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Godot;

namespace ThesisRTS.AI.behaviors
{
    internal class Seek : SteeringBehavior
    {
        public readonly ILocation target;
        public Seek(SteeringAgent agent, ILocation target) : base(agent)
        {
            this.target = target;
        }
        
        protected override void CalculateSteeringOverride(ref TargetAcceleration accel)
        {
            accel.Linear = (target.Position - Agent.Location.Position).Normalized() * Agent.LinearLimits.LinearAccelerationMax;
        }

        public (Vector3 axis, float angle) CalculateAngleAndAxisForTransform(in Transform3D transform)
        {
            var desiredRotation = transform.LookingAt(target.Position, Vector3.Up).Basis.GetRotationQuaternion();
            var quatChange = target.Orientation.Inverse() * desiredRotation;
            var angle = 2 * Mathf.Acos(quatChange.W);
            var axis = angle == 0
                ? Vector3.Zero
                : (1f / Mathf.Sin(angle / 2f)) * new Vector3(quatChange.X, quatChange.Y, quatChange.Z);
            return (axis, angle);
        }

        public Vector3 CalculateTorque(in Transform3D transform) =>
            CalculateAngleAndAxisForTransform(transform).axis.Normalized();
    }
}
