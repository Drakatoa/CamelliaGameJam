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
@onready var protagonist = $Protagonist
@onready var handshooting = $handshooting

# Variables
var target_zoom = Vector2(1, 1)  # The zoom level we are transitioning to
var ability  # Instance of the ability class
var dir = "down"
var is_shooting = false
var shoot_timer = 0.0

func _ready():
	ability = ability_scene.new()
	add_child(ability)

func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	var angle_to_mouse = (mouse_position - global_position).angle()
	if self.velocity.length() < 0.1 and not is_shooting:
		if dir == "right":
			protagonist.animation = "right_idle"
		elif dir == "left":
			protagonist.animation = "left_idle"
		elif dir == "up":
			protagonist.animation = "up_idle"
		else:
			protagonist.animation = "idle"
		protagonist.play()
	elif not is_shooting:  # If the character is moving
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
	handshooting.rotation = angle_to_mouse+135
	var shoot_direction = ""
	if angle_to_mouse > -PI / 4 and angle_to_mouse <= PI / 4:
		shoot_direction = "right"
		handshooting.position.x = 2.5
		handshooting.position.y = 10
		handshooting.z_index = 3
	elif angle_to_mouse > PI / 4 and angle_to_mouse <= 3 * PI / 4:
		shoot_direction = "down"
		handshooting.position.x = 2
		handshooting.position.y = 9.5
		handshooting.z_index = 3
	elif angle_to_mouse > -3 * PI / 4 and angle_to_mouse <= -PI / 4:
		shoot_direction = "up"
		handshooting.position.x = .5
		handshooting.position.y = -12
		handshooting.z_index = 1
	else:
		shoot_direction = "left"
		handshooting.position.x = -12.5
		handshooting.position.y = -1
		handshooting.z_index = 3
	if Input.is_action_pressed("shoot"):
		if shoot_timer <= 0.0:  # Only shoot if timer allows
			is_shooting = true
			protagonist.animation = "shooting_" + shoot_direction
			protagonist.play()
			
			handshooting.animation = "shoot_" + shoot_direction
			handshooting.play()
			
			shoot_projectile(mouse_position)
			shoot_timer = ability.cooldown_time  # Reset the cooldown timer
	else:
		is_shooting = false  # Reset shooting state when button is released
		handshooting.animation = "default"
		handshooting.play()

	# Decrease the shoot timer
	if shoot_timer > 0.0:
		shoot_timer -= delta

func play_animation(animation_name: String):
	if protagonist.animation != animation_name:
		protagonist.animation = animation_name
		protagonist.play()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_zoom -= Vector2(ZOOM_SPEED, ZOOM_SPEED)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_zoom += Vector2(ZOOM_SPEED, ZOOM_SPEED)

			target_zoom.x = clamp(target_zoom.x, MIN_ZOOM, MAX_ZOOM)
			target_zoom.y = clamp(target_zoom.y, MIN_ZOOM, MAX_ZOOM)

func shoot_projectile(mouse_position):
	# Spawn position is slightly in front of the player
	if ability.can_use:
		var spawn_position = global_position + Vector2(0, -10)  # Adjust as needed
		#var mouse_position = get_global_mouse_position()
		var direction = (mouse_position - global_position).normalized()  # Direction towards the mouse
		ability.use_ability(self, spawn_position, direction)
