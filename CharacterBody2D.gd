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
@onready var animated_sprite = $Protagonist

# Variables
var target_zoom = Vector2(1, 1)  # The zoom level we are transitioning to
var ability  # Instance of the ability class
var dir = "down"
var is_shooting = false
var shoot_timer = 0.0

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
	# Calculate the angle between the character and the mouse
	var mouse_position = get_global_mouse_position()
	var angle_to_mouse = (mouse_position - global_position).angle()
	# Determine direction based on the angle
	if self.velocity.length() < 0.1:  # If the character is not moving
		if dir == "right":
			$Protagonist.animation = "right_idle"
		elif dir == "left":
			$Protagonist.animation = "left_idle"
		elif dir == "up":
			$Protagonist.animation = "up_idle"
		else:
			$Protagonist.animation = "idle"
		$Protagonist.play()
	else:  # If the character is moving
		if angle_to_mouse > -PI / 4 and angle_to_mouse <= PI / 4:
			play_animation("run_right")
			dir = "right"
		elif angle_to_mouse > PI / 4 and angle_to_mouse <= 3 * PI / 4:
			play_animation("run_down")
			dir = "down"
		elif angle_to_mouse > -3 * PI / 4 and angle_to_mouse <= -PI / 4:
			play_animation("run_up")
			dir = "up"
		else:
			play_animation("run_left")
			dir = "left"

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		self.velocity = direction * SPEED
	else:
		self.velocity = Vector2.ZERO

	move_and_slide()

	# Smoothly interpolate the zoom level
	$Camera2D.zoom = $Camera2D.zoom.lerp(target_zoom, ZOOM_SMOOTHNESS * delta)
	
	# Shooting logic
	if Input.is_action_pressed("shoot"):
		if shoot_timer <= 0.0:  # Only shoot if timer allows
			shoot_projectile()
			shoot_timer = ability.cooldown_time  # Reset the cooldown timer
	else:
		is_shooting = false  # Reset shooting state when button is released

	# Decrease the shoot timer
	if shoot_timer > 0.0:
		shoot_timer -= delta

func play_animation(animation_name: String):
	if $Protagonist.animation != animation_name:
		$Protagonist.animation = animation_name
		$Protagonist.play()

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

	## Start shooting when "shoot" is pressed
	#if Input.is_action_pressed("shoot"):
		#is_shooting = true
	## Stop shooting when "shoot" is released
	#if Input.is_action_released("shoot"):
		#is_shooting = false

func shoot_projectile():
	# Spawn position is slightly in front of the player
	if ability.can_use:
		var spawn_position = global_position + Vector2(0, -10)  # Adjust as needed
		var mouse_position = get_global_mouse_position()
		var direction = mouse_position - global_position  # Direction towards the mouse
		ability.use_ability(self, spawn_position, direction)
