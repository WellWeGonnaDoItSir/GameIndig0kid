class_name Viewpoint
extends Node3D

signal interacted(message: String)
@export var prompt := "E  ·  Read the seaside note"

func _ready() -> void:
	Geometry.box(self, Vector3(0.18, 1.1, 0.18), Vector3(0, 0.55, 0), Color("8c7470"), true)
	var plaque := Geometry.box(self, Vector3(1.3, 0.65, 0.14), Vector3(0, 1.15, 0), Color("755e75"), true)
	plaque.rotation.x = -0.12
	var label := Label3D.new()
	label.text = "Ljubav nosim\nna ramenu"
	label.font_size = 36
	label.pixel_size = 0.005
	label.position = Vector3(0, 1.16, 0.09)
	add_child(label)

func interact() -> void:
	interacted.emit("Love rests on my shoulder.\nEven the longest road feels softer when we walk it together.")
