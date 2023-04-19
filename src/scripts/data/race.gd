class_name Race extends Resource

@export var name : StringName
@export var icon : Texture
@export_multiline var description : String
@export var planet_bonuses: Array[PlanetBonus]

var __israce:bool=true # for c# compat

func _to_string():
	"Race: %s\n\t%s" % [name,planet_bonuses]
