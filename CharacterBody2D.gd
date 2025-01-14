extends CharacterBody2D

# Movement constants
const SPEED = 300

# Zoom constants
const ZOOM_SPEED = 0.1  # How much to zoom per scroll
const MIN_ZOOM = .1  # Minimum zoom (closer to player)
const MAX_ZOOM = 2.0  # Maximum zoom (farther from player)
const ZOOM_SMOOTHNESS = 5.0  # Higher values make zooming faster

# Shooting constants
@export var ability_scene = preload("res://Ability.gd") 
#@export var ultimate_ability_scene = preload("res://ultimate.gd")  # Path to the ultimate ability script
#var ultimate_ability # Load the Ability script
@onready var protagonist = $Protagonist
@onready var handshooting = $handshooting

# Variables
var target_zoom = Vector2(1, 1)  # The zoom level we are transitioning to
var ability  # Instance of the ability class
var dir = "down"
var is_shooting = false
var shoot_timer = 0.0
var is_sin = true;
var is_casting_ult = false;

func _ready():
	ability = ability_scene.new()
	add_child(ability)
	#ultimate_ability = ultimate_ability_scene.new()

func _physics_process(delta):
	if is_casting_ult:
		return
	var mouse_position = get_global_mouse_position()
	var angle_to_mouse = (mouse_position - global_position).angle()
	protagonist.rotation = 0
	if self.velocity.length() < 0.1 and not is_shooting:
	# Idle animations
		if dir == "upright":
			protagonist.animation = "upright_idle"
		elif dir == "upleft":
			protagonist.animation = "upleft_idle"
		elif dir == "downright":
			protagonist.animation = "downright_idle"
		elif dir == "downleft":
			protagonist.animation = "downleft_idle"
		elif dir == "right":
			protagonist.animation = "right_idle"
		elif dir == "left":
			protagonist.animation = "left_idle"
		elif dir == "up":
			protagonist.animation = "up_idle"
		else:
			protagonist.animation = "idle"
		protagonist.play()
	elif not is_shooting:  # If the character is moving
	# Run animations
		if self.velocity.x > 0 and self.velocity.y > 0:
			dir = "downright"
			play_animation("run_downright")
		elif self.velocity.x > 0 and self.velocity.y < 0:
			dir = "upright"
			play_animation("run_upright")
		elif self.velocity.x < 0 and self.velocity.y > 0:
			dir = "downleft"
			play_animation("run_downleft")
		elif self.velocity.x < 0 and self.velocity.y < 0:
			dir = "upleft"
			play_animation("run_upleft")
		elif abs(self.velocity.x) > abs(self.velocity.y):
			if self.velocity.x > 0:
				dir = "right"
				play_animation("run_right")
			else:
				dir = "left"
				play_animation("run_left")
		else:
			if self.velocity.y > 0:
				dir = "down"
				play_animation("run_down")
			else:
				dir = "up"
				play_animation("run_up")
		#if angle_to_mouse > -PI / 4 and angle_to_mouse <= PI / 4:
			#play_animation("run_right")
			#dir = "right"
		#elif angle_to_mouse > PI / 4 and angle_to_mouse <= 3 * PI / 4:
			#play_animation("run_down")
			#dir = "down"
		#elif angle_to_mouse > -3 * PI / 4 and angle_to_mouse <= -PI / 4:
			#play_animation("run_up")
			#dir = "up"
		#else:
			#play_animation("run_left")
			#dir = "left"

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		self.velocity = direction * SPEED
	else:
		self.velocity = Vector2.ZERO

	move_and_slide()

	# Smoothly interpolate the zoom level
	$Camera2D.zoom = $Camera2D.zoom.lerp(target_zoom, ZOOM_SMOOTHNESS * delta)
	
	# Shooting logic
	#handshooting.rotation = angle_to_mouse+135
	var shoot_direction = ""
	var person_direction = ""
	var spawn_position
	if (-PI / 8 <= angle_to_mouse) and (angle_to_mouse < PI / 8):
	# Right
		person_direction = "right"
	elif (PI / 8 <= angle_to_mouse) and (angle_to_mouse < 3 * PI / 8):
	# Down-right
		person_direction = "downright"
		shoot_direction = "down"
		handshooting.rotation = angle_to_mouse-deg_to_rad(90)
		if is_shooting:
			protagonist.rotation = (angle_to_mouse-deg_to_rad(90))/12
		handshooting.position = Vector2(.5, -11.5)
		handshooting.offset = Vector2(9.375, 146.875)
		handshooting.scale = Vector2(.16, .16)
		handshooting.z_index = 3
		call_deferred("check_shooting", person_direction, shoot_direction, mouse_position)
	elif (3 * PI / 8 <= angle_to_mouse) and (angle_to_mouse < 5 * PI / 8):
	# Down
		person_direction = "down"
	elif (5 * PI / 8 <= angle_to_mouse) and (angle_to_mouse < 7 * PI / 8):
	# Down-left
		person_direction = "downleft"
		shoot_direction = "down"
		handshooting.rotation = angle_to_mouse-deg_to_rad(90)
		if is_shooting:
			protagonist.rotation = (angle_to_mouse-deg_to_rad(90))/12
		handshooting.position = Vector2(.5, -11.5)
		handshooting.offset = Vector2(9.375, 146.875)
		handshooting.scale = Vector2(.16, .16)
		handshooting.z_index = 3
		call_deferred("check_shooting", person_direction, shoot_direction, mouse_position)
	elif (angle_to_mouse >= 7 * PI / 8) or (angle_to_mouse < -7 * PI / 8):
	# Left
		person_direction = "left"
	elif (-7 * PI / 8 <= angle_to_mouse) and (angle_to_mouse < -5 * PI / 8):
	# Up-left
		person_direction = "upleft"
		shoot_direction = "up"
		handshooting.rotation = angle_to_mouse+deg_to_rad(90)
		if is_shooting:
			protagonist.rotation = (angle_to_mouse+deg_to_rad(90))/6
		handshooting.position = Vector2(0, -4)
		handshooting.offset = Vector2(1.042, -178.125)
		handshooting.scale = Vector2(.12, .12)
		handshooting.z_index = 1
		call_deferred("check_shooting", person_direction, shoot_direction, mouse_position)
	elif (-5 * PI / 8 <= angle_to_mouse) and (angle_to_mouse < -3 * PI / 8):
	# Up
		person_direction = "up"
	elif (-3 * PI / 8 <= angle_to_mouse) and (angle_to_mouse < -PI / 8):
	# Up-right
		person_direction = "upright"
		shoot_direction = "up"
		handshooting.rotation = angle_to_mouse+deg_to_rad(90)
		if is_shooting:
			protagonist.rotation = (angle_to_mouse+deg_to_rad(90))/6
		handshooting.position = Vector2(0, -4)
		handshooting.offset = Vector2(1.042, -178.125)
		handshooting.scale = Vector2(.12, .12)
		handshooting.z_index = 1
		call_deferred("check_shooting", person_direction, shoot_direction, mouse_position)

	if (-PI / 8 <= angle_to_mouse) and (angle_to_mouse < PI / 8):
		shoot_direction = "right"
		handshooting.rotation = angle_to_mouse
		if is_shooting:
			protagonist.rotation = angle_to_mouse/6
		handshooting.position = Vector2(0, -5.5)
		handshooting.offset = Vector2(146.875, 5.208)
		handshooting.scale = Vector2(.12, .12)
		handshooting.z_index = 3
		call_deferred("check_shooting", person_direction, shoot_direction, mouse_position)
	elif angle_to_mouse > PI / 4 and angle_to_mouse <= 3 * PI / 4:
		shoot_direction = "down"
		handshooting.rotation = angle_to_mouse-deg_to_rad(90)
		if is_shooting:
			protagonist.rotation = (angle_to_mouse-deg_to_rad(90))/12
		handshooting.position = Vector2(.5, -11.5)
		handshooting.offset = Vector2(9.375, 146.875)
		handshooting.scale = Vector2(.16, .16)
		handshooting.z_index = 3
		call_deferred("check_shooting", person_direction, shoot_direction, mouse_position)
	elif angle_to_mouse > -3 * PI / 4 and angle_to_mouse <= -PI / 4:
		shoot_direction = "up"
		handshooting.rotation = angle_to_mouse+deg_to_rad(90)
		if is_shooting:
			protagonist.rotation = (angle_to_mouse+deg_to_rad(90))/6
		handshooting.position = Vector2(0, -4)
		handshooting.offset = Vector2(1.042, -178.125)
		handshooting.scale = Vector2(.12, .12)
		handshooting.z_index = 1
		call_deferred("check_shooting", person_direction, shoot_direction, mouse_position)
	elif (angle_to_mouse >= 7 * PI / 8) or (angle_to_mouse < -7 * PI / 8):
		shoot_direction = "left"
		var normalized_angle = wrapf(angle_to_mouse - deg_to_rad(180), -PI, PI)
		handshooting.rotation = normalized_angle
		if is_shooting:
			protagonist.rotation = normalized_angle / 12
		handshooting.position = Vector2(-1.5, -5.5)
		handshooting.offset = Vector2(-128.125, 5.208)
		handshooting.scale = Vector2(.12, .12)
		handshooting.z_index = 3
		call_deferred("check_shooting", person_direction, shoot_direction, mouse_position)

	# Decrease the shoot timer
	if shoot_timer > 0.0:
		shoot_timer -= delta
	if Input.is_action_just_pressed("ultimate") and ability.can_use_ult:
		use_ultimate()
	if Input.is_action_just_pressed("dash"):
		use_dash()

func use_dash():
	print()

func check_shooting(person_direction, shoot_direction, mouse_position):
	if Input.is_action_pressed("shoot"):
		if shoot_timer <= 0.0:  # Only shoot if timer allows
			is_shooting = true
			protagonist.animation = "shooting_" + person_direction
			protagonist.play()
			handshooting.animation = "shoot_" + shoot_direction
			handshooting.play()
			#handshooting.call_deferred("play", "shoot_" + shoot_direction)
			
			shoot_projectile(mouse_position)
			shoot_timer = ability.primary_cooldown_time  # Reset the cooldown timer
	else:
		is_shooting = false  # Reset shooting state when button is released
		handshooting.animation = "default"
		handshooting.play()

func use_ultimate():
	# Use the ultimate ability
	var spawn_position = get_global_mouse_position()  # The position where the ultimate is spawned
	is_casting_ult = true
	protagonist.animation = "default"
	protagonist.play()
	$ultcast.visible = true
	$ultcast.animation = "ultcast"
	$ultcast.play()
	await get_tree().create_timer(1.25).timeout
	ability.use_ult(self, spawn_position)
	await get_tree().create_timer((59.0/24.0)-1.25).timeout
	$ultcast.visible = false
	$ultcast.animation = "default"
	$ultcast.play()
	dir = "down"
	is_casting_ult=false

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
	
	if ability.can_use_primary:
		var spawn_position
		var offset_distance = 70 
		var angle_to_mouse = (mouse_position - global_position).angle()
		var offset = Vector2(cos(angle_to_mouse), sin(angle_to_mouse)) * offset_distance
		if is_sin:
			spawn_position = global_position + Vector2(0, -10) + offset
		else:
			spawn_position = global_position + Vector2(0, -10) + offset
		#var mouse_position = get_global_mouse_position()
		var direction = (mouse_position - global_position).normalized()  # Direction towards the mouse
		ability.use_ability(self, spawn_position, direction, is_sin)
		is_sin = not is_sin
