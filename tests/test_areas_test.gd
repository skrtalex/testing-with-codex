extends SceneTree

var failures := 0

func _initialize() -> void:
    run.call_deferred()

func check(value: bool, description: String) -> void:
    if not value:
        failures += 1
        push_error("TEST FAILED: " + description)

func key(code: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    root.push_input(event, true)
    await process_frame
    event.pressed = false
    root.push_input(event, true)
    await process_frame

func run() -> void:
    var main = load("res://scenes/Main.tscn").instantiate()
    root.add_child(main)
    await process_frame
    await physics_frame
    check(main.toast_label.text.is_empty(), "startup has no command toast")
    await key(KEY_F1)
    check(main.player.infinite_stamina and main.toast_label.text == "Infinite Stamina ON", "F1 routes once and shows state")
    await key(KEY_F2)
    check(main.player.current_skin == 1 and main.toast_label.text == "Skin 2 / 9", "F2 replaces toast")
    await create_timer(1.1).timeout
    check(main.toast_label.text.is_empty(), "toast expires")
    await key(KEY_I)
    await key(KEY_ESCAPE)
    check(not main.inventory_ui.is_open and not main.test_menu.is_open, "Esc closes inventory first")
    await key(KEY_ESCAPE)
    check(paused and main.test_menu.is_open, "menu pauses world")
    await key(KEY_I)
    check(not main.inventory_ui.is_open, "inventory cannot open behind menu")
    await key(KEY_F1)
    check(not main.player.infinite_stamina, "debug shortcuts work while paused")
    await create_timer(1.1).timeout
    check(main.toast_label.text.is_empty(), "toast expires while paused")
    await key(KEY_ESCAPE)
    check(not paused, "resume unpauses world")
    var chest: TestChest = main.area_root.get_node("TestChest")
    chest.inventory.remove_items(0, 3)
    main.inventory.add_items("pear", 7)
    var old_world: Node2D = main.area_root
    main.player.position = Vector2(480, 8)
    await process_frame
    check(main.current_area == "lab", "top opening travels to lab")
    check(main.player.position == Vector2(480, 540), "arrival clear of trigger")
    await process_frame
    check(main.current_area == "lab", "no immediate return loop")
    var lab_world: Node2D = main.area_root
    main.player.position = Vector2(480, 530)
    await process_frame
    main.player.position = Vector2(480, 590)
    await process_frame
    check(main.current_area == "movement", "bottom opening returns")
    check(main.area_root == old_world and chest.inventory.slot(0).quantity == 5, "chest world preserved")
    check(main.inventory.slot(0).quantity == 7, "inventory retained across travel")
    main._debug_command("reset")
    check(main.area_root == old_world, "reset needs confirmation")
    main._debug_command("reset")
    check(main.area_root != old_world, "confirmed reset replaces current world")
    check(main.areas.lab == lab_world and main.inventory.slot(0).quantity == 7, "reset preserves other area and player")
    main.queue_free()
    await process_frame
    print("TEST AREAS: %d failure(s)" % failures)
    quit(1 if failures else 0)
