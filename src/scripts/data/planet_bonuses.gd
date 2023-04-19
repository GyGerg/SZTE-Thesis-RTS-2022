class_name PlanetBonus extends Resource



@export var bonus:PlanetBonusType

## gonna be added to a "base_modifier" float, treat it as a percentage
@export var bonus_value:float=0.15
func _to_string():
	var planet_types := planet_type_flag_to_enum_arr()
	"Planet bonus for %s: %s" % [planet_types,bonus]
@export_flags(PlanetStats.EARTH_LIKE_VALUE,
PlanetStats.VOLCANIC_VALUE,
PlanetStats.OCEAN_VALUE,
PlanetStats.BARREN_VALUE,
PlanetStats.EXOTIC_VALUE,
PlanetStats.ARTIFICIAL_VALUE,
PlanetStats.ALL_VALUE) var planet_type: int

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
