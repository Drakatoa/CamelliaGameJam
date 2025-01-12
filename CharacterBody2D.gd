extends CharacterBody2D

# Movement constants
const SPEED = 300

# Zoom constants
const ZOOM_SPEED = 0.1  # How much to zoom per scroll
const MIN_ZOOM = .1  # Minimum zoom (closer to player)
const MAX_ZOOM = 2.0  # Maximum zoom (farther from player)
const ZOOM_SMOOTHNESS = 5.0  # Higher values make zooming faster

# Shooting constants
@export var ability_scene = preload("res://Ability.gd")  # Load the Ability script
@onready var animated_sprite = $AnimatedSprite2D

# Variables
var target_zoom = Vector2(1, 1)  # The zoom level we are transitioning to
var ability  # Instance of the ability class
var dir = "down"

func _ready():
	
	# Initialize the ability
	ability = ability_scene.new()
	add_child(ability)

func _physics_process(delta):
	# Player movement
	#print(self.velocity)
	#print(Vector2.ZERO)
	#print("Velocity:", self.velocity)
	#print("Length:", self.velocity.length())
	#print("Current animation:", $AnimatedSprite2D.animation)

	if self.velocity.length() < 0.1:  # If the character is not moving
		if dir == "right":
			$AnimatedSprite2D.animation = "right_idle"
		elif dir == "left":
			$AnimatedSprite2D.animation = "left_idle"
		elif dir == "up":
			$AnimatedSprite2D.animation = "up_idle"
		else:
			$AnimatedSprite2D.animation = "idle"
		$AnimatedSprite2D.play()
		#print("Playing idle")
	else:
		if abs(self.velocity.x) > abs(self.velocity.y):
			if self.velocity.x > 0:
				if $AnimatedSprite2D.animation != "run_right":
					dir = "right"
					$AnimatedSprite2D.animation = "run_right"
					$AnimatedSprite2D.play()
			else:
				if $AnimatedSprite2D.animation != "run_left":
					dir = "left"
					$AnimatedSprite2D.animation = "run_left"
					$AnimatedSprite2D.play()
		else:
			if self.velocity.y > 0:
				if $AnimatedSprite2D.animation != "run_down":
					dir = "down"
					$AnimatedSprite2D.animation = "run_down"
					$AnimatedSprite2D.play()
			else:
				if $AnimatedSprite2D.animation != "run_up":
					dir = "up"
					$AnimatedSprite2D.animation = "run_up"
					$AnimatedSprite2D.play()
	#else:
		# Handle other animations, e.g., "run"
		#if animated_sprite.animation != "run":
			#animated_sprite.animation = "run"
			#animated_sprite.play()
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		self.velocity = direction * SPEED
	else:
		self.velocity = Vector2.ZERO

	move_and_slide()

	# Smoothly interpolate the zoom level
	$Camera2D.zoom = $Camera2D.zoom.lerp(target_zoom, ZOOM_SMOOTHNESS * delta)

func _input(event):
	# Zooming with mouse wheel
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				# Zoom in
				target_zoom -= Vector2(ZOOM_SPEED, ZOOM_SPEED)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				# Zoom out
				target_zoom += Vector2(ZOOM_SPEED, ZOOM_SPEED)

			# Clamp the target zoom to stay within limits
			target_zoom.x = clamp(target_zoom.x, MIN_ZOOM, MAX_ZOOM)
			target_zoom.y = clamp(target_zoom.y, MIN_ZOOM, MAX_ZOOM)

	# Shooting projectiles
	if Input.is_action_just_pressed("shoot"):
		shoot_projectile()

func shoot_projectile():
	# Spawn position is slightly in front of the player
	var spawn_position = global_position + Vector2(0, -10)  # Adjust as needed
	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - global_position  # Direction towards the mouse
	ability.use_ability(self, spawn_position, direction)
