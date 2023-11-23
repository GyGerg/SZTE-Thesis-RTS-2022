class_name Planet extends Resource


var position:Vector3
var stats:PlanetStats

@export var position_2d : Vector2 :
	get: return Vector2(position.x,position.z)

func _init(position:Vector3,stats:PlanetStats):
	self.position=position
	self.stats=stats
	
func radius() -> float: return stats.star_scale / 2
func to_bytes() -> PackedByteArray:
	var arr := PackedByteArray()
	arr.resize(16)
	arr.encode_var(0,position)
	arr.append_array(stats.to_bytes())
	return arr

static func from_bytes(bytes:PackedByteArray) -> Planet:
	return Planet.new(
		bytes.decode_var(0),
		PlanetStats.from_bytes(bytes.slice(16))
	)
