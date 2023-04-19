using Godot;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ThesisRTS.AI
{
    internal class SteeringBehavior
    {
        public bool IsEnabled { get; set; } = true;
        public SteeringAgent Agent { get; }

        public SteeringBehavior(SteeringAgent agent)
        {
            this.Agent = agent;
        }

        public void CalculateSteering(ref TargetAcceleration accel)
        {
            if (IsEnabled)
                CalculateSteeringOverride(ref accel);
            else
                accel.SetZero();
                
        }
        protected virtual void CalculateSteeringOverride(ref TargetAcceleration accel) => accel.SetZero();
    }
}
