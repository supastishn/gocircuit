extends Node3D
const SPEED: float = 1.0
func _process(delta: float) -> void:
	var cam_movement: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("left"):
		cam_movement.x -= 1.0
	if Input.is_action_pressed("right"):
		cam_movement.x += 1.0
		'''
	if Input.is_action_pressed("up"):
		cam_movement.y += 1.0
	if Input.is_action_pressed("down"):
		cam_movement.y -= 1.0
'''	
	if Input.is_action_pressed("forward"):
		cam_movement.z -= 1.0
	if Input.is_action_pressed("backward"):
		cam_movement.z += 1.0
	if cam_movement != Vector3.ZERO:
		cam_movement = cam_movement.normalized()
		# I kinda forgot matrix multiplication was not commutative kekw
		cam_movement = $Camera.basis * cam_movement
		cam_movement *= SPEED
		$Camera.position += cam_movement
