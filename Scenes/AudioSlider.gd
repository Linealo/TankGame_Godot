extends HSlider

@export var BUS_name: String
var BUS_index: int

func _ready():
	BUS_index = AudioServer.get_bus_index(BUS_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(BUS_index))
	
func _on_value_changed(value: float):
	AudioServer.set_bus_volume_db(BUS_index, linear_to_db(value))
