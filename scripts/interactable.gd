class_name Interactable
extends StaticBody2D

var interaction_offset := Vector2.ZERO
var interaction_label := "Interact"

func _ready() -> void:
    add_to_group("interactables")

func interaction_point() -> Vector2:
    return global_position + interaction_offset * global_scale

func can_interact(_actor: Node2D) -> bool:
    return true

func interact(_actor: Node2D) -> void:
    pass
