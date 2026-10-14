class_name Geometry
extends RefCounted

static func material(color: Color, emission: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	if emission > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	return mat

static func box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = material(color)
	parent.add_child(visual)
	visual.position = pos
	if solid:
		var body := StaticBody3D.new()
		var collider := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collider.shape = shape
		parent.add_child(body)
		body.position = pos
		body.add_child(collider)
	return visual

static func sphere(parent: Node3D, pos: Vector3, scale_size: Vector3, color: Color, glow: float = 0.0) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = material(color, glow)
	parent.add_child(visual)
	visual.position = pos
	visual.scale = scale_size
	return visual
