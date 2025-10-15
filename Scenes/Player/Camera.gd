extends Node3D

var valueCamRotationHorizontal : float = 0
var valueCamRotationVertical : float = 0

var camVerticalMin : float = -55
var camVerticalMax : float = 75
var hSensitivity : float = 0.1
var vSensitivity : float = 0.1

var hAcceleration : float = 10
var vAcceleration : float = 10

@onready var camRotationHorizontal : Node3D = $Horizontal
@onready var camRotationVertical : Node3D = $Horizontal/Vertical

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		valueCamRotationHorizontal += -event.relative.x * hSensitivity
		valueCamRotationVertical += -event.relative.y * vSensitivity
		
func _physics_process(delta):
	valueCamRotationVertical = clamp(valueCamRotationVertical, camVerticalMin, camVerticalMax)
	camRotationHorizontal.rotation_degrees.y = lerp(camRotationHorizontal.rotation_degrees.y, valueCamRotationHorizontal , delta * hAcceleration)
	camRotationVertical.rotation_degrees.x = lerp(camRotationVertical.rotation_degrees.x, valueCamRotationVertical , delta * vAcceleration)
