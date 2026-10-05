extends SceneTree

func _initialize() -> void:
    run.call_deferred()

func key(code: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    root.push_input(event, true)
    await process_frame
    event.pressed = false
    root.push_input(event, true)

func capture(name: String) -> void:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var folder := OS.get_environment("V006_CAPTURE_DIR")
    if folder.is_empty():
        folder = "user://visual_checks"
    DirAccess.make_dir_recursive_absolute(folder)
    root.get_texture().get_image().save_png(folder.path_join(name + ".png"))

func run() -> void:
    var main = load("res://scenes/Main.tscn").instantiate()
    root.add_child(main)
    await process_frame
    await physics_frame
    await key(KEY_F1)
    await capture("command_toast")
    await key(KEY_ESCAPE)
    await capture("test_menu")
    for viewport_size in [Vector2i(640, 480), Vector2i(320, 240)]:
        root.size = viewport_size
        await process_frame
        await process_frame
        main.test_menu._layout()
        await process_frame
        var logical_size := root.get_visible_rect().size
        var rect: Rect2 = main.test_menu.panel.get_global_rect()
        if rect.position.x < 0 or rect.position.y < 0 or rect.end.x > logical_size.x + 1 or rect.end.y > logical_size.y + 1:
            push_error("Menu exceeds viewport at %s: %s" % [viewport_size, rect])
            quit(1)
            return
        await capture("test_menu_%d" % viewport_size.x)
    root.size = Vector2i(960, 600)
    await key(KEY_ESCAPE)
    main.switch_area("lab")
    await capture("systems_lab")
    await key(KEY_F4)
    await capture("test_footprints")
    main.queue_free()
    await process_frame
    print("TEST AREAS VISUAL: PASS")
    quit()
