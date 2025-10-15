extends CharacterBody3D

var direction : Vector3 = Vector3.BACK

var stafeDir : Vector3 = Vector3.ZERO
var strafe : Vector3 = Vector3.ZERO
var aimTurn : float  = 0

var movementSpeed : float = 0
var standFOV : float = 70.0
var walkSpeed : float = 2
var walkFOV : float = 72.0
var runSpeed : float = 7
var runFOV : float  = 80.0

var aimSpeed : float = 4

var tween : Tween
var acceleration = 6
var aimAngularacceleration = 50
var angularAcceleration = 7
 
var currentAimAngular

var gravity : float = 30
@onready var horizontal : Node3D= $CameraRoot/Horizontal
@onready var playerBody : Node3D = $Armature_002
@onready var camera : Camera3D = $CameraRoot/Horizontal/Vertical/SpringArm3D/Camera3D
@onready var animTree : AnimationTree = $Armature_002/AnimationTree
@onready var camAnimTree : AnimationTree = $Armature_002/CamAnimTree
@onready var skeletonIK3D : SkeletonIK3D= $Armature_002/Skeleton3D/SkeletonIK3D
@onready var aimDelayTimer : Timer = $AimDelayTimer


var isRolling : bool = false

@export var sprintToggle : bool = true
@export var rollMutiplier : float = 3
@export var jumpMagnitude : float = 17

var sprinting : bool = false
var heightCheck : float = 0 

func _ready():
	currentAimAngular = angularAcceleration

func _input(event):
	if event is InputEventMouseMotion:
		aimTurn = -event.relative.x * 0.015
	
	if sprintToggle:
		if event.is_action_pressed("Sprint"):
			sprinting = false if sprinting else true
	else:
		sprinting = Input.is_action_pressed("Sprint")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		heightCheck = velocity.y
	else:
		if heightCheck < -20:
			TriggerRoll()
		heightCheck = 0
	
	if skeletonIK3D.interpolation < 0.01:
		skeletonIK3D.interpolation = 0.01
		skeletonIK3D.stop()
	
	if skeletonIK3D.interpolation > 0.7 and animTree.get("parameters/Transition/current_state") == "aiming":
		currentAimAngular = aimAngularacceleration
	#print(skeletonIK3D.interpolation)
	
	if Input.is_action_pressed("Aim"):
		animTree.set("parameters/Transition/transition_request", "aiming")
		
		if camAnimTree.get("parameters/Transition/current_state") == "NotAiming":
			camAnimTree.set("parameters/Transition/transition_request", "Aim" )
		if not isRolling:
			skeletonIK3D.start()
			skeletonIK3D.interpolation = lerp(skeletonIK3D.interpolation, 1.0, (currentAimAngular - 4) * delta)
	else:
		animTree.set("parameters/Transition/transition_request", "notAiming")
		if camAnimTree.get("parameters/Transition/current_state") == "Aim":
			camAnimTree.set("parameters/Transition/transition_request", "NotAiming")
		
		if skeletonIK3D.is_running():
			currentAimAngular = angularAcceleration
			skeletonIK3D.interpolation = lerp(skeletonIK3D.interpolation, 0.0, angularAcceleration * delta)	
	

	if Input.is_action_pressed("Forward") or Input.is_action_pressed("Backward") or Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		var horizontalRotation = horizontal.global_transform.basis.get_euler().y
		var leftRightStrength : float = Input.get_action_strength("Left") - Input.get_action_strength("Right")
		var forwardBackwardStrength : float = Input.get_action_strength("Forward") - Input.get_action_strength("Backward")
		direction = Vector3(leftRightStrength, 0, forwardBackwardStrength)
		stafeDir = direction.normalized()
		direction = direction.rotated(Vector3.UP, horizontalRotation).normalized()
		
		if Input.is_action_just_pressed("Roll") and not animTree.get("parameters/RollingShot/active") and is_on_floor():
			isRolling = true
			skeletonIK3D.stop()
			skeletonIK3D.interpolation = 0
			currentAimAngular = angularAcceleration
			TriggerRoll()
		elif not animTree.get("parameters/RollingShot/active"):
			isRolling = false
		
		if animTree.get("parameters/Transition/current_state") == "aiming":
			movementSpeed = aimSpeed
		elif sprinting:
			movementSpeed = runSpeed
			TransitionFOVCamera(runFOV)
		else:
			movementSpeed = walkSpeed
			TransitionFOVCamera(walkFOV)
	else:
		stafeDir = Vector3.ZERO
		movementSpeed = 0
		TransitionFOVCamera(standFOV)
		
		if animTree.get("parameters/Transition/current_state") == "aiming":
			direction = horizontal.global_transform.basis.z  
	
	if animTree.get("parameters/RollingShot/active"):
		var currentRotation = playerBody.transform.basis.get_rotation_quaternion()
		var newVelocity : Vector3 = currentRotation * animTree.get_root_motion_position() / delta * rollMutiplier 
		velocity.x = newVelocity.x
		velocity.z = newVelocity.z
		velocity.y -= get_floor_normal().y 
	else:
		if animTree.get("parameters/Transition/current_state") == "aiming":
			#skeletonIK3D.start()
			pass
		velocity.x = lerp(velocity.x, -direction.x * movementSpeed , delta * acceleration)
		velocity.z = lerp(velocity.z, -direction.z * movementSpeed , delta * acceleration)
		BlendAnimation(delta)
		AimAnimBlend(delta)
		
		
		if is_on_floor():
			if Input.is_action_just_pressed("Jump"):
				velocity.y = jumpMagnitude
		
		#Snap Model to the camera when aiming
		if animTree.get("parameters/Transition/transition_request") == "aiming":
			playerBody.rotation.y = lerp_angle(playerBody.rotation.y, horizontal.global_transform.basis.get_euler().y + PI, delta * currentAimAngular)
		else:
			playerBody.rotation.y = lerp_angle(playerBody.rotation.y, atan2(-direction.x, -direction.z), delta * angularAcceleration )
		
		
	
	move_and_slide()

func TriggerRoll():
	playerBody.rotation.y = atan2(-direction.x, -direction.z)
	animTree.set("parameters/RollingShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func TransitionFOVCamera(fov : float):
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.tween_property(camera, "fov", fov, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
func BlendAnimation(_delta):
		#https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbDEtbkdmUVBwQVFUT3lMcVdJd3YxX2VjTFBkUXxBQ3Jtc0tucUo0ZkhSanlUeXF3LXJkNGg0a2tzWllocTBjV3JXUjNnLWVZWWhLY29vVnhwSGh3Z1h2WTJZa1hLclBIb1dmbnhPdGcyY1Jza0M4X0xjbllPSU1NOGxDLTRZVmN6dFNHT2lHVU1peVJZVnZfd3J6VQ&q=https%3A%2F%2Fwww.desmos.com%2Fcalculator%2Fwnajovy5pc&v=yB-hyOlABfc
		var walkBlend = (velocity.length() - walkSpeed) / walkSpeed
		var runBlend = (velocity.length() - walkSpeed) / (runSpeed - walkSpeed)
		if velocity.length() <= walkSpeed:
			animTree.set("parameters/MovementBlend/blend_position", walkBlend)
		else:
			animTree.set("parameters/MovementBlend/blend_position", runBlend)

func AimAnimBlend(delta):
	strafe = lerp(strafe, stafeDir + Vector3.RIGHT * aimTurn, delta * acceleration)
	animTree.set("parameters/StrafeBlend/blend_position", Vector2(-strafe.x, strafe.z)) 
	aimTurn = 0



#func TransitionAnimation(movementStateID : float, animSpeed : float):
	#if tween:
		#tween.kill()
		#
	#tween = create_tween()
	#tween.tween_property(animTree, "parameters/MovementBlend/blend_position", movementStateID, 0.15)
	#tween.parallel().tween_property(animTree, "parameters/MovementAnimationSpeed/scale" , animSpeed, 0.7)
