class_name PlanetStats extends Resource

enum PlanetType {
	EarthLike=1,
	Volcanic=2,
	Ocean=4,
	Barren=8,
	Exotic=16,
	Artificial=32,
}

const SYSTEM_NAMES : Array[String] = [
	"Nomek",
	"Solaris",
	"Atlantea",
	"Xyris",
	"Sebunov",
	"Tabraetis",
	"Maepra",
	"Yanoth",
]
const PLANET_NUM : Array[String] = ["I","II","III","IV","V"]

const EARTH_LIKE_VALUE := "Earth-Like:1"
const VOLCANIC_VALUE := "Volcanic:2"
const OCEAN_VALUE := "Ocean:4"
const BARREN_VALUE := "Barren:8"
const EXOTIC_VALUE := "Exotic:16"
const ARTIFICIAL_VALUE := "Artificial:32"
const ALL_VALUE := "All:63"
const PLANET_TYPE_VALUES : Array[String] = [
	EARTH_LIKE_VALUE,
	VOLCANIC_VALUE,
	OCEAN_VALUE,
	BARREN_VALUE,
	EXOTIC_VALUE,
	ARTIFICIAL_VALUE,
	ALL_VALUE
]
@export var name:String = "Planet Name"
@export_range(0,4) var num_of_moons:int = 1
@export var star_color:Color
@export_range(1,255) var star_scale:int = 3
@export var planet_type:PlanetType = PlanetType.EarthLike

func _to_string():
	return "%s -- Planet type: %s, star color: %s, num of moons: %s" % [name, str(planet_type),star_color,num_of_moons]

func to_bytes() -> PackedByteArray:
	var arr := PackedByteArray()
	var name_arr := name.to_utf8_buffer()
	arr.resize(20+1+1+1)
	var offs := 0
	print(var_to_bytes(star_color).size())
	arr.encode_var(offs,star_color)
	offs+=20
	arr.encode_u8(offs,num_of_moons)
	offs+=1
	arr.encode_u8(offs,planet_type)
	offs+=1
	arr.encode_u8(offs,star_scale)
	offs+=1
	arr.append_array(name_arr)
	return arr

static func from_bytes(bytes:PackedByteArray) -> PlanetStats:
	var ps := PlanetStats.new()
	var offs := 0
	ps.star_color = bytes.decode_var(offs)
	offs += 20
	ps.num_of_moons = bytes.decode_u8(offs)
	offs += 1
	ps.planet_type = bytes.decode_u8(offs)
	offs+=1
	ps.star_scale = bytes.decode_u8(offs)
	offs+=1
	ps.name = bytes.slice(offs).get_string_from_utf8()
	return ps
