extends CanvasLayer

func _ready():
    print("DebugConsole ready")
    var panel = get_node_or_null("Panel")
    if panel:
        var vbox = panel.get_node_or_null("VBoxContainer")
        if vbox:
            vbox.get_node("Gunshot").pressed.connect(_on_gunshot)
            vbox.get_node("Alone").pressed.connect(_on_alone)
            vbox.get_node("CalmingPills").pressed.connect(_on_pills)
            vbox.get_node("WarmTea").pressed.connect(_on_tea)
            vbox.get_node("DarkForest").toggled.connect(_on_dark_forest)
            vbox.get_node("LushGreen").toggled.connect(_on_lush_green)
        else:
            print("VBoxContainer not found")
    else:
        print("Panel not found")

func _on_gunshot():
    var parent = get_parent()
    if parent:
        parent.change_paranoia(20)
        print("Gunshot button pressed")

func _on_alone():
    var parent = get_parent()
    if parent:
        parent.change_paranoia(10)
        print("Alone button pressed")

func _on_pills():
    var parent = get_parent()
    if parent:
        parent.change_paranoia(-20)
        print("Calming pills button pressed")

func _on_tea():
    var parent = get_parent()
    if parent:
        parent.change_paranoia(-10)
        print("Warm tea button pressed")

func _on_dark_forest(button_pressed: bool):
    var parent = get_parent()
    if parent:
        parent.dark_forest = button_pressed
        if button_pressed:
            parent.lush_green = false
            var cb = $Panel/VBoxContainer/LushGreen
            if cb:
                cb.button_pressed = false
    print("Dark forest toggled: ", button_pressed)

func _on_lush_green(button_pressed: bool):
    var parent = get_parent()
    if parent:
        parent.lush_green = button_pressed
        if button_pressed:
            parent.dark_forest = false
            var cb = $Panel/VBoxContainer/DarkForest
            if cb:
                cb.button_pressed = false
    print("Lush green toggled: ", button_pressed)
