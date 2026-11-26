extends TextureButton

@export var hover_scale := Vector2(1.05, 1.05)
@export var anim_time := 0.08

var _tween: Tween

func _ready() -> void:
	pivot_offset = size / 2.0
	resized.connect(_on_resized)
	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)
	
func _on_resized() -> void:
	pivot_offset = size / 2.0
	
func _on_hover_enter() -> void:
	_animate_scale(Vector2.ONE)
	
func _on_hover_exit() -> void:
	_animate_scale(Vector2.ONE)
	
func _animate_scale(target: Vector2) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", target, anim_time)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	
