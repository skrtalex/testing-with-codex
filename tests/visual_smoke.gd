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
    root.push_input(event, true)
    await process_frame
    event = InputEventKey.new()
    event.keycode = code
    event.pressed = false
    root.push_input(event, true)
    await process_frame

func click(button: Button, double_click := false) -> void:
    var center := button.get_global_rect().get_center()
    var hover := InputEventMouseMotion.new()
    hover.position = center
    root.push_input(hover, true)
    await process_frame
    var event := InputEventMouseButton.new()
    event.button_index = MOUSE_BUTTON_LEFT
    event.position = center
    event.pressed = true
    event.double_click = double_click
    root.push_input(event, true)
    await process_frame
    event = InputEventMouseButton.new()
    event.button_index = MOUSE_BUTTON_LEFT
    event.position = center
    event.pressed = false
    root.push_input(event, true)
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
    await click(chest_grid.get_child(0), true)
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
    await click(player_grid.get_child(apple_slot), true)
    if chest.inventory.slot(0).get("quantity", 0) != 8:
        push_error("Visual smoke: return transfer failed")
        quit(1)
        return
    await drag(main.inventory_ui.slot_buttons[16], main.inventory_ui.slot_buttons[24].get_global_rect().get_center())
    if not chest.inventory.slot(0).is_empty() or chest.inventory.slot(8).get("quantity", 0) != 8:
        push_error("Visual smoke: chest reordering drag failed")
        quit(1)
        return
    await drag(main.inventory_ui.slot_buttons[24], main.inventory_ui.slot_buttons[1].get_global_rect().get_center())
    if not chest.inventory.slot(8).is_empty() or main.inventory.slot(1).get("item_id", "") != "apple_red":
        push_error("Visual smoke: chest to player drag failed")
        quit(1)
        return
    await drag(main.inventory_ui.slot_buttons[1], main.inventory_ui.slot_buttons[17].get_global_rect().get_center())
    if chest.inventory.slot(1).get("item_id", "") != "apple_red" or main.inventory.slot(1).get("item_id", "") != "orange":
        push_error("Visual smoke: cross-inventory drag swap failed")
        quit(1)
        return
    await drag(main.inventory_ui.slot_buttons[1], Vector2(5, 5))
    if main.inventory.slot(1).get("item_id", "") != "orange":
        push_error("Visual smoke: outside drop lost stack")
        quit(1)
        return
    await click(main.inventory_ui.slot_buttons[1])
    await click(main.inventory_ui.slot_buttons[18])
    if chest.inventory.slot(2).get("item_id", "") != "orange" or main.inventory.slot(1).get("item_id", "") != "pear":
        push_error("Visual smoke: cross-inventory click swap failed")
        quit(1)
        return
    await capture("drag_and_click_inventory")
    main.inventory.add_items("apple_red", 19)
    await drag(main.inventory_ui.slot_buttons[17], main.inventory_ui.slot_buttons[2].get_global_rect().get_center())
    if main.inventory.slot(2).get("quantity", 0) != 20 or chest.inventory.slot(1).get("quantity", 0) != 7:
        push_error("Visual smoke: partial drag merge lost remainder")
        quit(1)
        return
    await drag(main.inventory_ui.slot_buttons[17], main.inventory_ui.slot_buttons[2].get_global_rect().get_center())
    if chest.inventory.slot(1).get("quantity", 0) != 7:
        push_error("Visual smoke: full target changed source")
        quit(1)
        return
    await key(KEY_ESCAPE)
    root.size = Vector2i(640, 480)
    await key(KEY_E)
    await capture("chest_small_window")
    await key(KEY_ESCAPE)
    await key(KEY_I)
    await capture("player_only_small_window")
    await drag(main.inventory_ui.slot_buttons[1], main.inventory_ui.slot_buttons[3].get_global_rect().get_center())
    if not main.inventory.slot(1).is_empty() or main.inventory.slot(3).get("item_id", "") != "pear":
        push_error("Visual smoke: player-only reordering failed")
        quit(1)
        return
    await drag(main.inventory_ui.slot_buttons[3], main.inventory_ui.slot_buttons[4].get_global_rect().get_center(), true)
    if main.inventory_ui.is_open or main.inventory.slot(3).get("item_id", "") != "pear" or not main.inventory.slot(4).is_empty():
        push_error("Visual smoke: closing during drag moved items")
        quit(1)
        return
    print("RENDERED INPUT SMOKE: PASS")
    main.queue_free()
    await process_frame
    quit()

func drag(button: Button, destination: Vector2, cancel := false) -> void:
    var start := button.get_global_rect().get_center()
    var hover := InputEventMouseMotion.new()
    hover.position = start
    root.push_input(hover, true)
    await process_frame
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_LEFT
    press.position = start
    press.pressed = true
    root.push_input(press, true)
    await process_frame
    var previous := start
    for point in [start + Vector2(15, 0), destination]:
        var motion := InputEventMouseMotion.new()
        motion.position = point
        motion.relative = point - previous
        motion.button_mask = MOUSE_BUTTON_MASK_LEFT
        root.push_input(motion, true)
        previous = point
        await process_frame
    if not root.gui_is_dragging():
        push_error("Visual smoke: native drag did not start")
    if cancel:
        await key(KEY_ESCAPE)
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.position = destination
    release.pressed = false
    root.push_input(release, true)
    await process_frame
    await process_frame
