class_name PlanetStats extends Resource
enum PlanetType {
	EarthLike=1,
	Volcanic=2,
	Ocean=4,
	Barren=8,
	Exotic=16,
	Artificial=32,
}

const _EARTH_LIKE_VALUE := "Earth-Like:1"
const _VOLCANIC_VALUE := "Volcanic:2"
const _OCEAN_VALUE := "Ocean:4"
const _BARREN_VALUE := "Barren:8"
const _EXOTIC_VALUE := "Exotic:16"
const _ARTIFICIAL_VALUE := "Artificial:32"
const _ALL_PLANET_VALUE := "All:63"
@export_range(0,4) var num_of_moons:int = 1
@export var star_color:Color
@export var planet_type:PlanetType = PlanetType.EarthLike
