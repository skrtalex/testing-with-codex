extends CanvasLayer

func _ready():
    print("DebugConsole ready")

func _on_Gunshot_pressed():
    var p = get_parent()
    if p:
        p.change_paranoia(20)

func _on_Alone_pressed():
    var p = get_parent()
    if p:
        p.change_paranoia(10)

func _on_Pills_pressed():
    var p = get_parent()
    if p:
        p.change_paranoia(-20)

func _on_Tea_pressed():
    var p = get_parent()
    if p:
        p.change_paranoia(-10)

func _on_DarkForest_toggled(pressed: bool):
    var p = get_parent()
    if p:
        p.dark_forest = pressed
        if pressed:
            var lush = get_node_or_null("Panel/VBoxContainer/Lush Green")
            if lush:
                lush.button_pressed = false
            p.lush_green = false

func _on_LushGreen_toggled(pressed: bool):
    var p = get_parent()
    if p:
        p.lush_green = pressed
        if pressed:
            var dark = get_node_or_null("Panel/VBoxContainer/Dark Forest")
            if dark:
                dark.button_pressed = false
            p.dark_forest = false
