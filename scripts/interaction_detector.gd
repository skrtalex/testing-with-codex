class_name InteractionDetector
extends Node

var actor: DemoPlayer
var reach := 52.0
var half_width := 24.0
var blocked := false

func closest_target() -> Interactable:
    var closest: Interactable = null
    var closest_distance := INF
    var facing := actor.last_facing.normalized()
    var world_scale := absf(actor.global_scale.x)
    for node in get_tree().get_nodes_in_group("interactables"):
        var target := node as Interactable
        if target == null or not target.can_interact(actor):
            continue
        var offset := target.interaction_point() - actor.global_position
        var forward := offset.dot(facing)
        var sideways := absf(offset.cross(facing))
        if forward <= 0.0 or offset.length() > reach * world_scale or sideways > half_width * world_scale:
            continue
        # A nearby object beyond a wall is not a valid target.
        var query := PhysicsRayQueryParameters2D.create(actor.global_position, target.interaction_point(), 1, [actor.get_rid()])
        var hit := actor.get_world_2d().direct_space_state.intersect_ray(query)
        if not hit.is_empty() and hit["collider"] != target:
            continue
        if offset.length_squared() < closest_distance:
            closest_distance = offset.length_squared()
            closest = target
    return closest

func try_interact() -> void:
    if blocked:
        return
    var target := closest_target()
    if target != null:
        target.interact(actor)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
        try_interact()
        get_viewport().set_input_as_handled()
