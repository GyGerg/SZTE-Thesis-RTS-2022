class_name PlanetBonus extends Resource

@export_flags(PlanetStats._EARTH_LIKE_VALUE, 
	PlanetStats._VOLCANIC_VALUE, 
	PlanetStats._OCEAN_VALUE, 
	PlanetStats._BARREN_VALUE, 
	PlanetStats._EXOTIC_VALUE,
	PlanetStats._ARTIFICIAL_VALUE,
	PlanetStats._ALL_PLANET_VALUE) var planet_type: int

@export var bonus:PlanetBonusType

## gonna be added to a "base_modifier" float, treat it as a percentage
@export var bonus_value:float=0.15
func _to_string():
	var planet_types := planet_type_flag_to_enum_arr()
	"Planet bonus for %s: %s" % [planet_types,bonus]


func planet_type_flag_to_enum_arr() -> Array[PlanetStats.PlanetType]:
	var ret:Array[PlanetStats.PlanetType] = []
	for type_name in PlanetStats.PlanetType:
		var bit_flag_value:int = int(pow(2,PlanetStats.PlanetType[type_name]))
		if planet_type & bit_flag_value:
			ret.append(type_name)
	return ret

enum PlanetBonusType {
	Population,
	Income,
	ResearchSpeed,
	ProductionSpeed,
}
