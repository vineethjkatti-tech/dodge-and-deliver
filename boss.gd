extends Node2D

signal telegraph_started(side: String) # pick left or right
signal attack_landed(side: String) # runs when the telegraph window ends

@export var telegraph_duration: float = 0.70
@export var cooldown_duration: float = 0.65
@export var idle_color: Color = Color(0.93, 0.39, 0.23)     # #ED643A
@export var telegraph_color: Color = Color(1.0, 0.75, 0.0) # #FFBF00
@export var strike_color: Color = Color(0.99, 0.94, 9.94) # #FCEFEF

@onready var body_visual: CanvasItem = $Sprite2D
@onready var telegraph_left = $TelegraphLeft
@onready var telegraph_right = $TelegraphRight

var state: String = "IDLE" # "IDLE", "TELEGRAPH", "STRIKE"
var attack_side: String = "NONE" # "LEFT", "RIGHT"
var _timer: float = 0.0

func _ready() -> void:
	randomize()
	_hide_telegraphs()
	_enter_cooldown(0.8)
	
func _process(delta: float) -> void:
	if state == "IDLE":
		_timer -= delta
		if _timer <= 0.0:
			_execute_strike()
	elif state == "TELEGRAPH":
		_timer -= delta
		if _timer <= 0:
			_execute_strike()
	elif state == "STRIKE":
		_timer -= delta
		if _timer <= 0.0:
			_execute_strike()
			
func _start_telegraph() -> void:
	attack_side = "LEFT" if randi() % 2 == 0 else "RIGHT"
	state = "TELEGRAPH"
	_timer = telegraph_duration
	
	_hide_telegraphs()
	if attack_side == "LEFT" and telegraph_left:
		telegraph_left.visible = true
	elif attack_side == "RIGHT" and telegraph_right:
		telegraph_right.visible = true
		
	if body_visual:
		body_visual.moulate = true
		
	telegraph_started.emit(attack_side)
	
func _execute_strike() -> void:
	state = "STRIKE"
	_timer = 0.18
	_hide_telegraphs()

	if body_visual:
		body_visual.modulate = strike_color

	attack_landed.emit(attack_side)
	
func _enter_cooldown(wait_time: float) -> void:
	state = "IDLE"
	attack_side = "NONE"
	_timer = wait_time
	_hide_telegraphs()

	if body_visual:
		body_visual.modulate = idle_color

# to hide the telegraph right when the left one is on and vice versa
func _hide_telegraphs() -> void:
	if telegraph_left:
		telegraph_right.visible = false
	if telegraph_right:
		telegraph_left.visible = false
	
			
			
		
		
		
		
		
		
		
		
		
		
		
