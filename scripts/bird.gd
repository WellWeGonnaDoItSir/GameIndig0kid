extends Node3D

var elapsed := 0.0
var left_wing: MeshInstance3D
var right_wing: MeshInstance3D

func _ready() -> void:
	Geometry.sphere(self, Vector3.ZERO, Vector3(0.24, 0.22, 0.35), Color("ffe3a0"), 0.35)
	Geometry.sphere(self, Vector3(0, 0.11, -0.13), Vector3.ONE * 0.19, Color("fff1c9"), 0.25)
	Geometry.box(self, Vector3(0.06, 0.05, 0.1), Vector3(0, 0.1, -0.25), Color("f8a365"))
	for x in [-0.06, 0.06]:
		Geometry.sphere(self, Vector3(x, 0.14, -0.2), Vector3.ONE * 0.025, Color("394558"))
	left_wing = Geometry.sphere(self, Vector3(-0.14, 0.02, 0), Vector3(0.18, 0.045, 0.23), Color("ffd38f"), 0.3)
	right_wing = Geometry.sphere(self, Vector3(0.14, 0.02, 0), Vector3(0.18, 0.045, 0.23), Color("ffd38f"), 0.3)
	var light := OmniLight3D.new()
	light.light_color = Color("ffe0a3")
	light.light_energy = 0.6
	light.omni_range = 2.2
	add_child(light)

func _process(delta: float) -> void:
	elapsed += delta
	position.y = 1.66 + sin(elapsed * 2.4) * 0.018
	left_wing.rotation.z = sin(elapsed * 3.0) * 0.12
	right_wing.rotation.z = -left_wing.rotation.z
