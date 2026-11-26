extends Node2D

signal dodged(direction: String) # Emits "LEFT" or "RIGHT"

@export var center_x: float = 640.0
@export var left_edge_x: float = 120.0
@export var right_edge_x: float = 1160.0
@export var use_viewport_edges: bool = false
@export var edge_padding: float = 120.0

@export var dodge_offset: float = 160.0
@export var dash_duration: float = 0.08
@export var hold_time: float = 0.14
@export var return_duration: float = 0.10
@export var ghost_interval: float = 0.02
@export var ghost_lifetime: float = 0.16
@export var ghost_color: Color = Color(0.34, 0.0, 0.015, 0.6)

@onready var sprite: Sprite2D = $Sprite2D

var current_lane: String = "CENTER" # "LEFT", "CENTER", or "RIGHT"
var active_tween: Tween
var ghost_timer: float = 0.0
var is_dashing: bool = false


func _ready() -> void:
	if use_viewport_edges:
		var vp_width: float = get_viewport_rect().size.x
		center_x = vp_width * 0.5
		left_edge_x = edge_padding
		right_edge_x = vp_width - edge_padding
		
	position.x = center_x
	rotation_degrees = 0.0
		
func _process(delta: float) -> void:
	if not is_dashing:
		return
		
	ghost_timer -= delta
	if ghost_timer <= 0.0:
		ghost_timer = ghost_interval
		_spawn_afterimage()		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dodge-left"):
		dodge("LEFT")
	elif event.is_action_pressed("dodge-right"):
		dodge("RIGHT")


func dodge(direction: String) -> void:
	current_lane = direction
	rotation_degrees = 0.0

	var target_x := center_x
	if direction == "LEFT":
		target_x = left_edge_x
	elif direction == "RIGHT":
		target_x = right_edge_x

	if active_tween and active_tween.is_valid():
		active_tween.kill()

	is_dashing = true
	ghost_timer = 0.0
	_spawn_afterimage()	

	active_tween = create_tween()
	active_tween.tween_property(self, "position:x", target_x, dash_duration)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	active_tween.tween_callback(func() -> void:
		is_dashing = false
		)
	active_tween.tween_interval(hold_time)
	active_tween.tween_property(self, "position:x", center_x, return_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	active_tween.finished.connect(func() -> void:
		current_lane = "CENTER"
		)
	
	dodged.emit(direction)

func _spawn_afterimage() -> void:
	if sprite == null or sprite.texture == null:
		return
		
	var ghost := Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.region_enabled = sprite.region_enabled
	ghost.region_rect = sprite.region_rect
	ghost.flip_h = sprite.flip_h
	ghost.flip_v = sprite.flip_v
	ghost.centered = sprite.centered
	ghost.offset = sprite.offset
	ghost.scale = sprite.scale
	ghost.modulate = sprite.modulate
	
	get_tree().current_scene.add_child(ghost)
	ghost.global_position = sprite.global_position
	ghost.global_rotation = sprite.global_rotation
	
	var fade_tween := ghost.create_tween()
	fade_tween.tween_property(ghost, "modulate:a", 0.0, ghost_lifetime)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fade_tween.finished.connect(ghost.queue_free)
