extends SceneTree

var failures := 0

func check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error("TEST FAILED: " + message)

func _initialize() -> void:
    run.call_deferred()

func run() -> void:
    var catalog := ItemCatalog.new()
    check(catalog.definitions.size() == 42, "all selected fruit variants registered")
    for id in catalog.definitions:
        check(catalog.icon(id) != null, "icon loads: " + id)
        check(catalog.stack_limit(id) == 20, "stack limit: " + id)
    var source := ItemInventory.new(catalog, 2)
    var destination := ItemInventory.new(catalog, 1)
    check(source.add_items("apple_red", 45) == 40, "capacity limits addition")
    check(source.slot(0)["quantity"] == 20 and source.slot(1)["quantity"] == 20, "stack splitting")
    check(source.available_capacity("apple_red") == 0, "full capacity query")
    check(source.add_items("unknown", 1) == 0, "unknown item rejected")
    check(destination.add_items("apple_red", 17) == 17, "destination prefilled")
    check(source.transfer_stack(0, destination) == 3, "partial transfer")
    check(source.slot(0)["quantity"] == 17, "source remainder retained")
    check(source.transfer_stack(0, destination) == 0, "full transfer rejected")
    check(destination.remove_items(0, 99) == 20, "removal bounded by quantity")
    check(destination.slot(0).is_empty(), "removed slot emptied")
    check(source.remove_items(1, 20) == 20, "stack removal")
    check(source.move_stack(0, 1), "move to empty slot")
    check(source.slot(0).is_empty(), "old slot emptied")
    source.add_items("pear", 5)
    check(source.move_stack(0, 1), "swap different items")
    check(source.slot(1)["item_id"] == "pear", "swap preserves item IDs")
    var merge := ItemInventory.new(catalog, 2)
    merge.add_items("pear", 25)
    merge.remove_items(0, 10)
    check(merge.move_stack(1, 0), "merge matching stacks")
    check(merge.slot(0)["quantity"] == 15 and merge.slot(1).is_empty(), "merge conserves items")
    check(not merge.move_stack(-1, 0), "invalid move rejected")

    var cross := ItemInventory.new(catalog, 2)
    var other := ItemInventory.new(catalog, 2)
    cross.add_items("apple_red", 19)
    other.add_items("pear", 8)
    check(cross.move_to_slot(0, other, 0), "cross-inventory swap")
    check(cross.slot(0)["item_id"] == "pear" and other.slot(0)["item_id"] == "apple_red", "swap preserves both stacks")
    cross.add_items("apple_red", 7)
    check(cross.move_to_slot(1, other, 0), "cross-inventory partial merge")
    check(cross.slot(1)["quantity"] == 6 and other.slot(0)["quantity"] == 20, "merge leaves source remainder")
    check(not cross.move_to_slot(1, other, 0), "full target merge rejected")
    check(cross.move_to_slot(1, other, 1), "targeted move to empty destination")
    check(cross.slot(1).is_empty() and other.slot(1)["quantity"] == 6, "move conserves quantity")

    var scene := load("res://scenes/Main.tscn") as PackedScene
    var main = scene.instantiate()
    root.add_child(main)
    await process_frame
    await physics_frame
    check(main.config["balance_version"] == "0.0.0.6", "version bumped")
    var trees := get_nodes_in_group("interactables").filter(func(n): return n is FruitTree)
    check(trees.size() == 11, "all existing trees interactable")
    var tree := trees[8] as FruitTree
    var player := main.player as DemoPlayer
    var detector := main.interaction_detector as InteractionDetector
    player.position = tree.position + Vector2(0, 46)
    player.last_facing = Vector2.UP
    await physics_frame
    check(detector.closest_target() == tree, "front-facing tree selected")
    player.last_facing = Vector2.DOWN
    check(detector.closest_target() == null, "tree behind player excluded")
    player.last_facing = Vector2.UP
    var assigned := tree.drop_item_id
    var drop_count := [0]
    tree.drop_requested.connect(func(id, quantity, _pos):
        check(id == assigned, "assigned fruit retained")
        drop_count[0] += quantity)
    detector.try_interact()
    check(not tree.can_interact(player), "cooldown prevents spam")
    detector.try_interact()
    await create_timer(0.45).timeout
    check(drop_count[0] >= 1 and drop_count[0] <= 3, "random configured drop range")
    check(is_zero_approx(tree.get_node("Canopy").position.x), "shake returns canopy to origin")
    check(tree.get_node("CollisionShape2D").shape.size == Vector2(14, 18), "trunk collision preserved")
    var drops := main.get_children().filter(func(n): return n is WorldPickup)
    check(drops.size() == drop_count[0], "drops exist as world objects")
    if not drops.is_empty():
        var pickup := drops[0] as WorldPickup
        check(pickup.sprite.texture == catalog.icon(assigned) or pickup.sprite.texture.resource_path == catalog.icon(assigned).resource_path, "world icon matches definition")
        var full := ItemInventory.new(catalog, 1)
        full.add_items(assigned, 19)
        pickup.inventory = full
        pickup.quantity = 3
        check(pickup.try_pickup() == 1, "partial world pickup")
        check(pickup.quantity == 2 and not pickup.is_queued_for_deletion(), "world remainder survives")
        check(pickup.try_pickup() == 0 and pickup.quantity == 2, "full inventory cannot destroy pickup")
        full.remove_items(0, 20)
        check(pickup.try_pickup() == 2 and pickup.is_queued_for_deletion(), "successful pickup removes world object")
    var chest := main.get_node("TestChest") as TestChest
    check(chest.inventory.size() == 32, "exactly 32 chest slots")
    player.position = chest.position + Vector2(0, 35)
    player.last_facing = Vector2.UP
    await physics_frame
    check(detector.closest_target() == chest, "chest selected through common detector")
    detector.try_interact()
    check(main.inventory_ui.is_open and main.inventory_ui.chest_inventory == chest.inventory, "interaction opens transfer UI")
    check(player.inventory_open, "movement blocked while UI open")
    var before := chest.inventory.slot(0)
    main.inventory_ui._slot_double_clicked(chest.inventory, 0)
    check(chest.inventory.slot(0).is_empty(), "click chest to player transfer")
    check(main.inventory.slot(0) == before, "player receives stack")
    main.inventory_ui._slot_double_clicked(main.inventory, 0)
    check(main.inventory.slot(0).is_empty() and chest.inventory.slot(0) == before, "click player to chest transfer")
    main.inventory_ui.close()
    chest.interact(player)
    check(chest.inventory.slot(0) == before, "chest persists across reopen")
    main.inventory_ui.close()
    var key := InputEventKey.new()
    key.keycode = KEY_I
    key.pressed = true
    main.inventory_ui._input(key)
    check(main.inventory_ui.is_open and main.inventory_ui.chest_inventory == null, "I opens player inventory")
    main.inventory_ui._input(key)
    check(not main.inventory_ui.is_open and not player.inventory_open, "I closes inventory")
    for i in range(player.get_skin_count()):
        player._apply_skin(i)
        check(player.character_sprite.texture != null, "skin loads: %d" % i)
    player._apply_skin(0)
    player.stamina = player.max_stamina
    player.dash_cooldown_left = 0
    player._try_dash()
    check(player.dash_time_left > 0 and player.stamina == player.max_stamina - player.dash_cost, "dash and stamina retained")
    player._on_terrain_entered(main.get_node("BushTerrain"))
    check(is_equal_approx(player.terrain_multiplier, 0.75), "terrain slowing retained")
    # Exercise scaling and modal layout with both a large and small viewport.
    for viewport_size in [Vector2i(1280, 720), Vector2i(640, 480)]:
        root.size = viewport_size
        main._update_layout()
        chest.interact(player)
        await process_frame
        await process_frame
        check(main.inventory_ui.panel.size.x * main.inventory_ui.panel.scale.x < viewport_size.x, "transfer panel fits viewport")
        check(tree.z_index == roundi(main.to_global(Vector2(0, float(tree.get_meta("sort_y")))).y), "tree and player use consistent scaled Y sorting")
        main.inventory_ui.close()
    print("VERTICAL SLICE TESTS: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
    main.queue_free()
    await process_frame
    quit(0 if failures == 0 else 1)
