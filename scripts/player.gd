extends CharacterBody3D

@export var mouse_sensitivity := 0.0025
var camera_distance := 5.5
var yaw := 0.0
var pitch := -0.18
var walking_time := 0.0
var active := false
var model: Node3D
var pivot: Node3D
var arm: SpringArm3D
var camera: Camera3D
var limbs: Array[Node3D] = []

func _ready() -> void:
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.8
	collision.shape = capsule
	collision.position.y = 0.9
	add_child(collision)
	model = Node3D.new()
	add_child(model)
	Geometry.sphere(model, Vector3(0, 1.14, 0), Vector3(0.66, 0.8, 0.4), Color("4e9fbb"))
	Geometry.sphere(model, Vector3(0, 1.76, 0), Vector3.ONE * 0.43, Color("f6c6a6"))
	Geometry.sphere(model, Vector3(0, 1.9, 0.03), Vector3(0.46, 0.25, 0.46), Color("514457"))
	for x in [-0.085, 0.085]:
		Geometry.sphere(model, Vector3(x, 1.78, -0.205), Vector3(0.035, 0.045, 0.02), Color("34394d"))
	for x in [-0.19, 0.19]:
		var leg := Node3D.new()
		model.add_child(leg)
		leg.position = Vector3(x, 0.83, 0)
		Geometry.box(leg, Vector3(0.22, 0.65, 0.24), Vector3(0, -0.32, 0), Color("384660"))
		Geometry.box(leg, Vector3(0.25, 0.16, 0.36), Vector3(0, -0.7, -0.04), Color("f4e8d5"))
		limbs.append(leg)
	for x in [-0.4, 0.4]:
		var limb := Node3D.new()
		model.add_child(limb)
		limb.position = Vector3(x, 1.43, 0)
		Geometry.box(limb, Vector3(0.16, 0.5, 0.18), Vector3(0, -0.24, 0), Color("f6c6a6"))
		limbs.append(limb)
	var bird := preload("res://scenes/bird.tscn").instantiate()
	model.add_child(bird)
	bird.position = Vector3(0.39, 1.66, 0)
	pivot = Node3D.new()
	add_child(pivot)
	pivot.position.y = 1.45
	arm = SpringArm3D.new()
	pivot.add_child(arm)
	arm.spring_length = camera_distance
	arm.margin = 0.25
	var camera_shape := SphereShape3D.new()
	camera_shape.radius = 0.2
	arm.shape = camera_shape
	arm.add_excluded_object(get_rid())
	camera = Camera3D.new()
	camera.fov = 65
	arm.add_child(camera)
	camera.current = true

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clampf(pitch - event.relative.y * mouse_sensitivity, -0.85, 0.35)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = maxf(2.5, camera_distance - 0.4)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = minf(9.0, camera_distance + 0.4)

func _physics_process(delta: float) -> void:
	pivot.rotation.y = lerp_angle(pivot.rotation.y, yaw, 1.0 - exp(-16.0 * delta))
	pivot.rotation.x = lerp_angle(pivot.rotation.x, pitch, 1.0 - exp(-16.0 * delta))
	arm.spring_length = lerpf(arm.spring_length, camera_distance, 1.0 - exp(-10.0 * delta))
	if not active:
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input.x, 0, input.y).rotated(Vector3.UP, yaw)
	var speed := 6.5 if Input.is_action_pressed("sprint") else 3.5
	velocity.x = move_toward(velocity.x, direction.x * speed, 18.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, 18.0 * delta)
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = 7.0
	move_and_slide()
	if direction.length_squared() > 0.01:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(-direction.x, -direction.z), 1.0 - exp(-12.0 * delta))
	var moving := Vector2(velocity.x, velocity.z).length()
	walking_time += delta * (10.0 if speed > 4.0 else 7.0)
	for i in limbs.size():
		limbs[i].rotation.x = sin(walking_time + (PI if i % 2 else 0.0)) * minf(moving / 6.0, 0.55) * (1.0 if i < 2 else -0.6)
	if position.y < -10:
		position = Vector3(0, 2, 8)
		velocity = Vector3.ZERO
