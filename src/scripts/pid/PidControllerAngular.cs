using Godot;

namespace SZTEThesisRTS2022.scripts.pid;

[GlobalClass]
public partial class PidControllerAngular : PidController
{
    private float AngleDifference(float source, float target)
    {
        float srcDeg = Mathf.RadToDeg(source);
        float targetDeg = Mathf.RadToDeg(target);
        float degDiff = ((srcDeg - targetDeg) + 540 % 360) - 180;
        return Mathf.DegToRad(degDiff);
    }

    public override float Update(float current, float target, float delta)
    {
        float error = AngleDifference(target, current);
        float P = CalculateP(error);
        float I = CalculateI(error,delta);

        float err_rate_of_change = AngleDifference(error, _prev_error) / delta;
        _prev_error = error;

        float val_rate_of_change = AngleDifference(current, _last_value) / delta;
        _last_value = current;

        float derivative_measure = 0.0f;
        if(_derivative_initialized)
        {
            if(derivativeMeasurement == DerivativeMeasurement.Velocity)
            {
                derivative_measure = -val_rate_of_change;
            }
            else
            {
                derivative_measure = err_rate_of_change;
            }
        }
        else
        {
            _derivative_initialized = true;
        }

        float D = derivativeGain * derivative_measure;

        float result = P + I + D;

        return Mathf.Clamp(result, outputMin, outputMax);
    }
}