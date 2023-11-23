using Godot;

namespace SZTEThesisRTS2022.scripts.pid;

[GlobalClass]
public partial class PidController : Resource
{
    [Export] public float proportionalGain;
    /// komment helye
    [Export] public float integralGain;
    [Export] public float derivativeGain;

    [Export] public float integralMax;
    [Export] public float outputMax;
    [Export] public float outputMin;

    [Export] protected DerivativeMeasurement derivativeMeasurement;

    private float _integral;
    protected float _last_value;
    protected float _prev_error;
    protected bool _derivative_initialized = false;

    protected float CalculateP(float error) => proportionalGain * error;

    protected float CalculateI(float error, float delta)
    {
        _integral = Mathf.Clamp(_integral + error * delta, -integralMax, integralMax);
        return integralGain * _integral;
    }
    
    /// <summary>
    /// Valami update szöveg
    /// </summary>
    /// <param name="current"></param>
    /// <param name="target"></param>
    /// <param name="delta"></param>
    /// <returns></returns>
    public virtual float Update(float current, float target, float delta)
    {
        float error = target - current;
        float P = CalculateP(error);
        float I = CalculateI(error,delta);

        float errRateOfChange = (error-_prev_error) / delta;
        _prev_error = error;

        float valRateOfChange = (current - _last_value) / delta;
        _last_value = current;

        float derivativeMeasure = 0.0f;
        if(_derivative_initialized)
        {
            if(derivativeMeasurement == DerivativeMeasurement.Velocity)
            {
                derivativeMeasure = -valRateOfChange;
            }
            else
            {
                derivativeMeasure = errRateOfChange;
            }
        }
        else
        {
            _derivative_initialized = true;
        }

        float D = derivativeGain * derivativeMeasure;

        float result = P + I + D;

        return Mathf.Clamp(result, outputMin, outputMax);
    }
}

public enum DerivativeMeasurement
{
    Velocity,
    ErrorRateOfChange
}