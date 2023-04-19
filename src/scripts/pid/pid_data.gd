class_name PidData extends Resource

enum DerivativeMeasurement {
	VELOCITY,
	ERROR_RATE_OF_CHANGE
}

@export_range(0.0,200.0) var _max_val :float  = 0.3
@export var derivative_measurement := DerivativeMeasurement.VELOCITY


@export_group("Gain values")
@export var proportional_gain:float = 0.01
@export var integral_gain:float = 2
@export var derivative_gain:float = 0

@export_group("Output limits", "_output")
@export var _output_max := 1.0
@export var _output_min := -1.0

func get_pid_values() -> Dictionary:
	return {
		"_maxVal":_max_val,
		"_derivativeMeasurement":derivative_measurement,
		"ProportionalGain":proportional_gain,
		"IntegralGain":integral_gain,
		"DerivativeGain":derivative_gain,
		"OutputMax":_output_max,
		"OutputMin":_output_min
	}
