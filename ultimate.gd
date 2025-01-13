extends Node2D

@export var duration = 78.0/24.0  # Duration for the ultimate to remain active
@export var damage = 50  # Damage dealt by the ultimate

func _ready():
	# Play an animation or effect if needed
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("ultimate")  # Replace "ultimate" with the animation name

	# Remove the ultimate after its duration
	await get_tree().create_timer(duration).timeout
	queue_free()

func _on_body_entered(body):
	# Handle collision with enemies
	if body.is_in_group("enemies"):
		body.take_damage(damage)  # Deal damage to the enemy
