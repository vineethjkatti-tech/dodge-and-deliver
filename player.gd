extends Node2D

signal dodged(direction: String) # Emits "LEFT" or "RIGHT"

@export var center_x: float = 640.0
@export var dodge_offset: float = 160.0
@export var dodge_tilt_deg: float = 12.0
@export var dodge_duration: float = 0.12
@export var return_delay: float = 0.25

@onready var sprite: Sprite2D = $Sprite2D

var current_lane: String = "CENTER" # "LEFT", "CENTER", or "RIGHT"
var active_tween: Tween


func _ready() -> void:
	position.x = center_x


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dodge-left"):
		dodge("LEFT")
	elif event.is_action_pressed("dodge-right"):
		dodge("RIGHT")


func dodge(direction: String) -> void:
	current_lane = direction

	var target_x := center_x
	var target_tilt := 0.0

	if direction == "LEFT":
		target_x = center_x - dodge_offset
		target_tilt = -dodge_tilt_deg
	elif direction == "RIGHT":
		target_x = center_x + dodge_offset
		target_tilt = dodge_tilt_deg

	if active_tween and active_tween.is_valid():
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(self, "position:x", target_x, dodge_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(self, "rotation_degrees", target_tilt, dodge_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Snap back toward center after a short beat so the player is ready for the next input
	active_tween.chain()
	active_tween.set_parallel(true)
	active_tween.tween_property(self, "position:x", center_x, dodge_duration)\
		.set_delay(return_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(self, "rotation_degrees", 0.0, dodge_duration)\
		.set_delay(return_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	active_tween.finished.connect(func() -> void:
		current_lane = "CENTER"
	)

	dodged.emit(direction)


func play_hurt_reaction() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	current_lane = "CENTER"
	active_tween = create_tween()
	active_tween.tween_property(sprite, "modulate", Color(1.0, 0.35, 0.35), 0.06)
	active_tween.tween_property(sprite, "modulate", Color.WHITE, 0.14)
	active_tween.parallel().tween_property(self, "position:x", center_x, 0.12)
	active_tween.parallel().tween_property(self, "rotation_degrees", 0.0, 0.12)
