class_name FruitTree
extends HarvestablePlant

func _ready() -> void:
    super._ready()
    visual_node = get_node("Canopy") as Node2D
