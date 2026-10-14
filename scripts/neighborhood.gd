extends Node3D

func _ready() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("657fb4")
	sky_mat.sky_horizon_color = Color("ffd2a0")
	sky_mat.ground_bottom_color = Color("9173a0")
	sky_mat.ground_horizon_color = Color("ffc697")
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c6b9e2")
	env.ambient_light_energy = 0.4
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.fog_enabled = true
	env.fog_light_color = Color("e8bba9")
	env.fog_density = 0.0018
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-24, -40, 0)
	sun.light_color = Color("ffd3a0")
	sun.light_energy = 0.85
	sun.shadow_enabled = true
	add_child(sun)
	Geometry.box(self, Vector3(40, 1, 46), Vector3(0, -0.5, 2), Color("dbbba0"), true)
	Geometry.box(self, Vector3(8, 0.06, 36), Vector3(0, 0.03, 5), Color("c3a9a0"))
	for side in [-1, 1]:
		Geometry.box(self, Vector3(2, 0.04, 36), Vector3(side * 5, 0.02, 5), Color("f4d6b7"))
	Geometry.box(self, Vector3(38, 0.12, 7), Vector3(0, 0.06, -17), Color("ead2b4"), true)
	# Ocean shader uses world coordinates so waves stay continuous across the surface.
	var ocean := Geometry.box(self, Vector3(1600, 0.1, 1400), Vector3(0, -1.2, -722), Color("59a6ba"))
	var shader := Shader.new()
	shader.code = "shader_type spatial; render_mode specular_schlick_ggx; varying vec3 world_pos; void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){float wave=sin(world_pos.x*0.65+TIME*0.6)*sin(world_pos.z*0.9+TIME*0.4); float stripe=pow(max(0.0,sin(world_pos.x*0.09+world_pos.z*0.25+TIME*0.4)),14.0); ALBEDO=mix(vec3(0.13,0.46,0.58),vec3(0.38,0.70,0.73),wave*0.5+0.5)+vec3(0.24,0.15,0.07)*stripe; ROUGHNESS=0.32; METALLIC=0.2;}"
	var water_mat := ShaderMaterial.new()
	water_mat.shader = shader
	ocean.material_override = water_mat
	Geometry.sphere(self, Vector3(-95, 24, -300), Vector3.ONE * 24, Color("ffd59b"), 1.0)
	for i in 8:
		var side := -1 if i % 2 == 0 else 1
		var z := 18.0 - floorf(i / 2.0) * 8.0
		_building(Vector3(side * 11, 0, z), i)
	for side in [-1, 1]:
		for z in [22, 10, -3, -12]:
			_tree(Vector3(side * 6.5, 0, z))
			_flowers(Vector3(side * 6.5, 0, z + 1.7))
		# Seawall and rails enclose the playable area without blocking sea views.
		Geometry.box(self, Vector3(0.4, 1.1, 46), Vector3(side * 19.6, 0.55, 2), Color("e5c6b1"), true)
	Geometry.box(self, Vector3(40, 1.2, 0.5), Vector3(0, 0.6, 24.7), Color("e5c6b1"), true)
	for x in range(-19, 20, 2):
		Geometry.box(self, Vector3(0.14, 1.1, 0.14), Vector3(x, 0.55, -20.5), Color("756f88"), true)
	Geometry.box(self, Vector3(40, 0.12, 0.15), Vector3(0, 1.0, -20.5), Color("756f88"))
	Geometry.box(self, Vector3(40, 0.85, 0.25), Vector3(0, 0.42, -20.7), Color("e5c6b1"), true)
	for x in [-9, 9]:
		Geometry.box(self, Vector3(2.7, 0.18, 0.8), Vector3(x, 0.55, -18), Color("ae7869"), true)
		Geometry.box(self, Vector3(2.7, 0.65, 0.14), Vector3(x, 0.95, -18.35), Color("ae7869"), true)
		for offset in [-1, 1]:
			Geometry.box(self, Vector3(0.15, 0.5, 0.6), Vector3(x + offset, 0.25, -18), Color("656a7d"), true)
	for x in [-4.8, 4.8]:
		Geometry.box(self, Vector3(0.12, 3.4, 0.12), Vector3(x, 1.7, -13), Color("696b80"))
		Geometry.sphere(self, Vector3(x, 3.4, -13), Vector3.ONE * 0.42, Color("ffe7af"), 1.3)

func _building(pos: Vector3, index: int) -> void:
	var colors := [Color("eaa398"), Color("85bfc1"), Color("efc77d"), Color("b7a8d5")]
	var height := 5.0 + (index % 3) * 0.7
	Geometry.box(self, Vector3(7, height, 6.5), pos + Vector3(0, height / 2, 0), colors[index % 4], true)
	Geometry.box(self, Vector3(7.5, 0.35, 7), pos + Vector3(0, height, 0), Color("a76c7c"))
	Geometry.box(self, Vector3(7.2, 0.24, 6.7), pos + Vector3(0, 0.2, 0), Color("f5dbbf"))
	var facing := 1.0 if pos.x < 0 else -1.0
	var front := pos.x + facing * 3.52
	for z in [-1.8, 1.8]:
		for y in [1.7, 3.7]:
			Geometry.box(self, Vector3(0.09, 1.4, 1.15), Vector3(front, y, pos.z + z), Color("fff1d0"))
			Geometry.box(self, Vector3(0.12, 1.15, 0.9), Vector3(front + facing * 0.06, y, pos.z + z), Color("567f9b"))
			Geometry.box(self, Vector3(0.15, 0.08, 1.0), Vector3(front + facing * 0.08, y, pos.z + z), Color("f5d8b8"))
	Geometry.box(self, Vector3(0.14, 2, 1.0), Vector3(front, 1, pos.z), Color("775e78"))
	Geometry.box(self, Vector3(1.0, 0.15, 1.8), Vector3(front + facing * 0.4, 2.4, pos.z), colors[(index + 1) % 4])

func _tree(pos: Vector3) -> void:
	Geometry.box(self, Vector3(0.32, 2.3, 0.32), pos + Vector3(0, 1.15, 0), Color("9a7466"), true)
	Geometry.sphere(self, pos + Vector3(0, 3, 0), Vector3(2.5, 2.7, 2.4), Color("88b898"))
	Geometry.sphere(self, pos + Vector3(0.65, 3.25, 0.2), Vector3(1.5, 1.8, 1.7), Color("a6cca0"))

func _flowers(pos: Vector3) -> void:
	Geometry.box(self, Vector3(1.7, 0.35, 0.8), pos + Vector3(0, 0.18, 0), Color("bc857c"), true)
	for i in 5:
		var p := pos + Vector3(-0.65 + i * 0.32, 0.55, 0)
		Geometry.box(self, Vector3(0.035, 0.45, 0.035), p, Color("719b82"))
		Geometry.sphere(self, p + Vector3(0, 0.23, 0), Vector3.ONE * 0.19, Color("ffd1ad") if i % 2 else Color("daa0c5"))
