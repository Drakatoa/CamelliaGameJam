extends CharacterBody2D

# Abstract BossEnemy class
class_name BossEnemy

@export var max_health = 1000   # Maximum health of the boss
var current_health = max_health  # Current health of the boss
var is_dying = false  # Is the boss currently dying?
@export var damage = 50  # The damage the boss does to the player



func set_health(new_health: int):
	max_health = new_health

# Abstract function to handle the boss attack logic (to be overridden)
func attack():
	pass

# Abstract function to handle the boss's special abilities or behaviors (to be overridden)
func special_ability():
	pass

# Called when the boss is damaged
func take_damage(amount: int) -> void:
	if is_dying:
		return  # If the boss is dying, it cannot take damage
	
	current_health -= amount
	print("Boss takes", amount, "damage. Current health:", current_health)
	
	if current_health <= 0 and !is_dying:
		die()

# Called to initiate the dying process
func die() -> void:
	if is_dying:
		return
	
	is_dying = true
	print("Boss is dying!")
	
	# Trigger any animations or effects for dying here
	# e.g., play death animation
	# $AnimationPlayer.play("die")
	
	# Call an abstract function or signal to notify when the boss dies
	on_dying()

# Abstract method or signal to be called when the boss dies
func on_dying() -> void:
	# This can be overridden by a subclass to handle specific death behavior
	pass

# _ready is called when the node is added to the scene.
func _ready():
	print("Boss is ready with health:", max_health)
	
	# Set up any other initialization (e.g., spawn minions, set up attacks)
	# Example: $AttackTimer.start()
