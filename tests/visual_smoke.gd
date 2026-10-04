extends SceneTree

# Run with a rendering backend. V006_CAPTURE_DIR selects an external output folder.
func _initialize() -> void:
    run.call_deferred()

func capture(name: String) -> void:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var folder := OS.get_environment("V006_CAPTURE_DIR")
    if folder.is_empty():
        folder = "user://visual_checks"
    DirAccess.make_dir_recursive_absolute(folder)
    root.get_texture().get_image().save_png(folder.path_join(name + ".png"))

func key(code: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    root.push_input(event)
    await process_frame
    event = InputEventKey.new()
    event.keycode = code
    event.pressed = false
    root.push_input(event)
    await process_frame

func click(button: Button) -> void:
    var center := button.get_global_rect().get_center()
    var event := InputEventMouseButton.new()
    event.button_index = MOUSE_BUTTON_LEFT
    event.position = center
    event.pressed = true
    root.push_input(event)
    await process_frame
    event = InputEventMouseButton.new()
    event.button_index = MOUSE_BUTTON_LEFT
    event.position = center
    event.pressed = false
    root.push_input(event)
    await process_frame

func run() -> void:
    var main = load("res://scenes/Main.tscn").instantiate()
    root.add_child(main)
    await process_frame
    await physics_frame
    var player: DemoPlayer = main.player
    var trees := get_nodes_in_group("interactables").filter(func(n): return n is FruitTree)
    var tree := trees[8] as FruitTree
    player.position = tree.position + Vector2(0, 46)
    player.last_facing = Vector2.UP
    await physics_frame
    await key(KEY_E)
    await create_timer(0.1).timeout
    await capture("tree_shaking")
    await create_timer(0.3).timeout
    await capture("fruit_on_ground")
    # Walk over one drop, exercising the same proximity pickup path as gameplay.
    var drops: Array = main.get_children().filter(func(n): return n is WorldPickup)
    if not drops.is_empty():
        player.position = drops[0].position
    await create_timer(0.8).timeout
    await key(KEY_I)
    await capture("player_inventory")
    await key(KEY_I)
    var chest := main.get_node("TestChest") as TestChest
    player.position = chest.position + Vector2(0, 35)
    player.last_facing = Vector2.UP
    await physics_frame
    await key(KEY_E)
    await capture("chest_open")
    # Real viewport mouse events, rather than directly invoking transfer logic.
    var chest_grid := main.inventory_ui.content.get_child(5) as GridContainer
    await click(chest_grid.get_child(0))
    if not chest.inventory.slot(0).is_empty():
        push_error("Visual smoke: chest click did not transfer")
        quit(1)
        return
    await capture("chest_transferred")
    var player_grid := main.inventory_ui.content.get_child(3) as GridContainer
    var apple_slot := -1
    for i in range(main.inventory.size()):
        if main.inventory.slot(i).get("item_id", "") == "apple_red":
            apple_slot = i
    if apple_slot < 0:
        push_error("Visual smoke: transferred apple missing")
        quit(1)
        return
    await click(player_grid.get_child(apple_slot))
    if chest.inventory.slot(0).get("quantity", 0) != 8:
        push_error("Visual smoke: return transfer failed")
        quit(1)
        return
    await key(KEY_ESCAPE)
    root.size = Vector2i(640, 480)
    await key(KEY_E)
    await capture("chest_small_window")
    await key(KEY_ESCAPE)
    print("RENDERED INPUT SMOKE: PASS")
    main.queue_free()
    await process_frame
    quit()
