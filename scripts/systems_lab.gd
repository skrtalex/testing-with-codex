extends Node2D

func _draw() -> void:
    draw_rect(Rect2(45, 115, 405, 330), Color("b4c88c"))
    draw_rect(Rect2(510, 115, 405, 330), Color("8fa873"))
    var font := ThemeDB.fallback_font
    for entry in [
        [Vector2(80, 145), "COOKING · RESERVED"],
        [Vector2(550, 145), "COMBAT · RESERVED"],
        [Vector2(80, 180), "Ingredient storage / counter / stove markers"],
        [Vector2(550, 180), "Target markers / obstacles / open arena"],
        [Vector2(330, 475), "Cooking and combat are not implemented yet"],
        [Vector2(370, 495), "↓ Movement & items · Scene 1"]
    ]:
        draw_string(font, entry[0], entry[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("253522"))
    # Floor markers deliberately have no interaction or solid collision.
    for pos in [Vector2(180, 270), Vector2(320, 270)]:
        draw_rect(Rect2(pos - Vector2(42, 28), Vector2(84, 56)), Color("8b7657"), false, 3)
    for pos in [Vector2(600, 270), Vector2(710, 270), Vector2(820, 270)]:
        draw_circle(pos, 20, Color("c8b995"), false, 3)
        draw_line(pos - Vector2(12, 0), pos + Vector2(12, 0), Color("6f5946"), 2)
        draw_line(pos - Vector2(0, 12), pos + Vector2(0, 12), Color("6f5946"), 2)
