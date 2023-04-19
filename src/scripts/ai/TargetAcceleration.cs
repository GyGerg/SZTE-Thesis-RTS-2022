using System;
using Godot;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ThesisRTS.AI
{
    internal struct TargetAcceleration
    {
        public Vector3 Linear { get; set; } = Vector3.Zero;
        public float Angular { get; set; } = 0f;

        public TargetAcceleration(Vector3 linear, float angular)
        {
            Linear = linear;
            Angular = angular;
        }

        public void SetZero()
        {
            Linear = Vector3.Zero;
            Angular = 0f;
        }
        

        public void AddScaledAccel(TargetAcceleration accel, float scalar)
        {
            Linear += accel.Linear * (float)scalar;
            Angular += accel.Angular * scalar;
        }

        public float GetMagnitudeSquared() => Linear.LengthSquared() + (Angular * Angular);

        public float GetMagnitude() => Mathf.Sqrt(GetMagnitudeSquared());
    }
}
