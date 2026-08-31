extends CharacterBody2D
class_name Player
## Attach to a CharacterBody2D. Needs a CollisionShape2D child, and a
## Sprite2D child named "Sprite2D" whose Texture is your spritesheet with
## Hframes/Vframes set so each cell = one frame index.

@export var player_id: int = 1              # 1 or 2 — used to sort/identify players
@export var speed: float = 220.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1600.0
@export var max_fall_speed: float = 900.0
@export var coyote_time: float = 0.8        # grace period to jump after leaving a ledge
@export var jump_buffer_time: float = 0.12   # grace period if jump pressed just before landing

@export var idle_frames: Array[int] = [0, 1]
@export var walk_frames: Array[int] = [2, 3, 4]
@export var air_frame: int = 5
@export var idle_fps: float = 5.0
@export var walk_fps: float = 10.0
@export var active_outline_material: ShaderMaterial  # e.g. white_pixel_outline.tres

var is_active: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

var _current_anim: String = "idle"   # "idle", "walk", or "air"
var _anim_frame_index: int = 0
var _anim_timer: float = 0.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")


func _ready() -> void:
	add_to_group("players")
	PlayerManager.register_player(self)


func _physics_process(delta: float) -> void:
	if is_active:
		_process_active(delta)
	else:
		_process_frozen(delta)


func _process_active(delta: float) -> void:
	# --- Gravity ---
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time

	# --- Horizontal movement (accel/friction gives it a smooth, weighty feel) ---
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
		if sprite:
			sprite.flip_h = input_dir < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	_update_animation(delta)

	# --- Jump buffering + coyote time so jumps feel forgiving ---
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# --- Variable jump height: release early to cut the jump short ---
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

	move_and_slide()


func _process_frozen(_delta: float) -> void:
	# Frozen players ignore gravity and input entirely and hold their exact
	# position AND exact current animation frame — we simply stop calling
	# _update_animation() here, so whatever frame was showing at the
	# moment of swap stays put. We also deliberately DON'T call
	# move_and_slide() — the body still exists in the physics world as a
	# solid obstacle, so the active player can stand on it like a platform.
	velocity = Vector2.ZERO


func _update_animation(delta: float) -> void:
	if not sprite:
		return

	if not is_on_floor():
		if _current_anim != "air":
			_current_anim = "air"
			_anim_timer = 0.0
		sprite.frame = air_frame
		return

	var anim_name := "walk" if abs(velocity.x) > 10.0 else "idle"
	if anim_name != _current_anim:
		_current_anim = anim_name
		_anim_frame_index = 0
		_anim_timer = 0.0

	var frames := walk_frames if _current_anim == "walk" else idle_frames
	var fps := walk_fps if _current_anim == "walk" else idle_fps
	if frames.is_empty() or fps <= 0.0:
		return

	_anim_timer += delta
	var frame_duration := 1.0 / fps
	while _anim_timer >= frame_duration:
		_anim_timer -= frame_duration
		_anim_frame_index = (_anim_frame_index + 1) % frames.size()

	sprite.frame = frames[_anim_frame_index]


func set_active(active: bool) -> void:
	is_active = active
	velocity = Vector2.ZERO
	if sprite:
		sprite.material = active_outline_material if active else null
