extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var texture = load("res://icon.svg")
	$Sprite2D.texture = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
