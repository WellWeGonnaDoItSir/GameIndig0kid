extends Node3D

var player: CharacterBody3D
var menu: PanelContainer
var settings: VBoxContainer
var menu_buttons: VBoxContainer
var start_button: Button
var prompt: Label
var message: Label
var hud: Label
var viewpoint: Viewpoint
var music: MusicDirector
var started := false
var message_time := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input()
	var neighborhood := Node3D.new()
	neighborhood.set_script(preload("res://scripts/neighborhood.gd"))
	neighborhood.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(neighborhood)
	player = preload("res://scenes/player.tscn").instantiate()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(player)
	player.position = Vector3(0, 0.3, 10)
	viewpoint = Viewpoint.new()
	viewpoint.position = Vector3(0, 0, -18.5)
	neighborhood.add_child(viewpoint)
	viewpoint.interacted.connect(_show_message)
	music = MusicDirector.new()
	music.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(music)
	_build_ui()
	get_tree().paused = true

func _setup_input() -> void:
	var bindings := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "jump": KEY_SPACE, "sprint": KEY_SHIFT, "interact": KEY_E, "pause": KEY_ESCAPE}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = bindings[action]
		InputMap.action_add_event(action, event)

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)
	hud = Label.new()
	hud.text = "LJUBAV NOSIM NA RAMENU\nWASD  Walk   ·   Shift  Run   ·   Space  Jump\nMouse  Look   ·   Wheel  Distance   ·   Esc  Pause"
	hud.position = Vector2(28, 24)
	hud.add_theme_font_size_override("font_size", 17)
	hud.add_theme_color_override("font_outline_color", Color("333b50"))
	hud.add_theme_constant_override("outline_size", 5)
	root.add_child(hud)
	prompt = Label.new()
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt.position += Vector2(-150, -80)
	prompt.add_theme_font_size_override("font_size", 22)
	prompt.add_theme_color_override("font_outline_color", Color("333b50"))
	prompt.add_theme_constant_override("outline_size", 6)
	root.add_child(prompt)
	message = Label.new()
	message.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	message.position += Vector2(-330, -155)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 21)
	message.add_theme_color_override("font_outline_color", Color("333b50"))
	message.add_theme_constant_override("outline_size", 6)
	root.add_child(message)
	menu = PanelContainer.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu.offset_left = -270
	menu.offset_right = 270
	menu.offset_top = -210
	menu.offset_bottom = 210
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.17, 0.25, 0.94)
	style.set_corner_radius_all(18)
	style.content_margin_left = 36
	style.content_margin_right = 36
	style.content_margin_top = 30
	style.content_margin_bottom = 30
	menu.add_theme_stylebox_override("panel", style)
	root.add_child(menu)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	menu.add_child(column)
	var title := Label.new()
	title.text = "Ljubav nosim na ramenu"
	title.add_theme_font_size_override("font_size", 28)
	column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "A little light. A quiet sea. A road together."
	column.add_child(subtitle)
	menu_buttons = VBoxContainer.new()
	column.add_child(menu_buttons)
	start_button = _button(menu_buttons, "Start Game", _resume)
	_button(menu_buttons, "Settings", func(): settings.show(); menu_buttons.hide())
	_button(menu_buttons, "Exit Game", func(): get_tree().quit())
	settings = VBoxContainer.new()
	column.add_child(settings)
	var sensitivity_label := Label.new()
	sensitivity_label.text = "Mouse sensitivity"
	settings.add_child(sensitivity_label)
	var sensitivity := HSlider.new()
	sensitivity.min_value = 0.001
	sensitivity.max_value = 0.006
	sensitivity.step = 0.0001
	sensitivity.value = player.mouse_sensitivity
	sensitivity.value_changed.connect(func(value: float): player.mouse_sensitivity = value)
	settings.add_child(sensitivity)
	var volume_label := Label.new()
	volume_label.text = "Soundtrack volume (no track supplied yet)"
	settings.add_child(volume_label)
	var volume := HSlider.new()
	volume.min_value = -40
	volume.max_value = 0
	volume.value = AudioServer.get_bus_volume_db(0)
	volume.value_changed.connect(func(value: float): AudioServer.set_bus_volume_db(0, value))
	settings.add_child(volume)
	_button(settings, "Back", func(): settings.hide(); menu_buttons.show())
	settings.hide()
	hud.hide()

func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 45
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _resume() -> void:
	started = true
	player.active = true
	menu.hide()
	hud.show()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and started:
		if get_tree().paused:
			_resume()
		else:
			get_tree().paused = true
			menu.show()
			settings.hide()
			menu_buttons.show()
			start_button.text = "Resume"
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("interact") and started and not get_tree().paused:
		if player.global_position.distance_to(viewpoint.global_position) < 2.6:
			viewpoint.interact()

func _process(delta: float) -> void:
	prompt.text = viewpoint.prompt if started and not get_tree().paused and player.global_position.distance_to(viewpoint.global_position) < 2.6 else ""
	if not get_tree().paused:
		message_time = maxf(0, message_time - delta)
		if message_time == 0:
			message.text = ""

func _show_message(text: String) -> void:
	message.text = text
	message_time = 8.0
