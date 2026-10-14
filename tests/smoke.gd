extends SceneTree

var failures := 0
var checks := 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error(description)

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func _run() -> void:
	var game := preload("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(paused and game.menu.visible, "Main menu pauses the world")
	game.start_button.pressed.emit()
	await frames(60)
	var player: CharacterBody3D = game.player
	check(not paused and player.active and not game.menu.visible, "Start button activates gameplay")
	check(player.is_on_floor(), "Player lands on street collision")
	check(player.model.get_node("ShoulderBird") != null, "Separate shoulder bird scene is attached")
	var origin := player.position
	Input.action_press("move_forward")
	await frames(60)
	Input.action_release("move_forward")
	var walk_distance := origin.z - player.position.z
	check(walk_distance > 2.5 and walk_distance < 4.2, "W walks forward at expected speed")
	await frames(20)
	origin = player.position
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await frames(60)
	Input.action_release("move_forward")
	Input.action_release("sprint")
	check(origin.z - player.position.z > walk_distance * 1.5, "Sprint increases travel distance")
	await frames(25)
	origin = player.position
	Input.action_press("jump")
	await frames(2)
	Input.action_release("jump")
	await frames(15)
	check(player.position.y > origin.y + 0.7, "Space launches a jump")
	await frames(70)
	check(player.is_on_floor(), "Jump returns to floor")
	player.position = Vector3(0, 0.1, 8.5)
	player.velocity = Vector3.ZERO
	Input.action_press("move_left")
	await frames(180)
	Input.action_release("move_left")
	check(player.position.x > -7.4 and player.position.x < -6.0, "Building collision prevents walking through facade")
	player.position = Vector3(-6.8, 0.2, 10)
	player.velocity = Vector3.ZERO
	player.yaw = PI / 2
	await frames(90)
	check(player.arm.get_hit_length() < player.camera_distance - 0.5, "Spring arm retracts against building")
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(80, 50)
	var old_yaw: float = player.yaw
	player._unhandled_input(motion)
	if DisplayServer.get_name() != "headless":
		check(player.yaw < old_yaw, "Mouse motion changes camera yaw")
	else:
		print("SKIP: Captured mouse input requires a display")
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	player._unhandled_input(wheel)
	check(player.camera_distance < 5.5, "Mouse wheel adjusts camera distance")
	player.position = Vector3(0, 0.2, -17)
	player.velocity = Vector3.ZERO
	player.yaw = 0
	await frames(5)
	check(not game.prompt.text.is_empty(), "Interaction prompt appears near viewpoint")
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	game._unhandled_input(interact)
	check(game.message.text.contains("Love rests"), "E interaction displays seaside note")
	var pause := InputEventAction.new()
	pause.action = "pause"
	pause.pressed = true
	game._unhandled_input(pause)
	origin = player.position
	await frames(10)
	check(paused and game.menu.visible and player.position == origin, "Escape pauses gameplay and shows menu")
	game._unhandled_input(pause)
	check(not paused and not game.menu.visible, "Escape resumes gameplay")
	player.position = Vector3(0, 0.2, 7)
	player.model.rotation.y = 0
	game.message.text = ""
	await frames(40)
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/ljubav-prototype.png")
		print("Screenshot saved to /tmp/ljubav-prototype.png")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
