
extends Node3D

var car: Node3D
var hud: Label

var speed: float = 0.0
var steer: float = 0.0
var distance: float = 0.0
var nitro: float = 100.0

var touch_left: bool = false
var touch_right: bool = false
var throttle: bool = false
var braking: bool = false
var boost: bool = false


func _ready() -> void:
    build_world()
    build_car()
    build_hud()
    build_controls()


func build_world() -> void:
    var world = WorldEnvironment.new()
    var environment = Environment.new()

    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY

    world.environment = environment
    add_child(world)

    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-45, -25, 0)
    sun.light_energy = 1.2
    add_child(sun)

    make_box("Grass", Vector3(0, -0.3, 0), Vector3(90, 0.5, 220), Color(0.08, 0.3, 0.12))
    make_box("Road", Vector3(0, 0, 0), Vector3(15, 0.15, 220), Color(0.12, 0.13, 0.16))

    for x in [-7.7, 7.7]:
        make_box("RoadEdge", Vector3(x, 0.15, 0), Vector3(0.5, 0.2, 220), Color.RED)

    for z in range(-100, 110, 10):
        make_box("Line", Vector3(0, 0.1, z), Vector3(0.15, 0.03, 4), Color.WHITE)


func build_car() -> void:
    car = Node3D.new()
    car.name = "PlayerCar"
    add_child(car)

    var camera = Camera3D.new()
    camera.position = Vector3(0, 5, 9.5)
    camera.rotation_degrees = Vector3(-17, 0, 0)
    camera.current = true
    car.add_child(camera)

    var body = make_material(Color(0.02, 0.04, 0.12))
    var glass = make_material(Color(0.02, 0.3, 0.5))
    var tire = make_material(Color.BLACK)

    make_car_box("Body", Vector3(0, 0.75, 0), Vector3(2, 0.55, 3.8), body)
    make_car_box("Cabin", Vector3(0, 1.2, -0.25), Vector3(1.5, 0.65, 1.8), glass)

    for x in [-1.0, 1.0]:
        for z in [-1.25, 1.25]:
            make_car_box("Wheel", Vector3(x, 0.48, z), Vector3(0.38, 0.85, 0.75), tire)


func build_hud() -> void:
    var layer = CanvasLayer.new()
    add_child(layer)

    hud = Label.new()
    hud.position = Vector2(18, 18)
    hud.add_theme_font_size_override("font_size", 24)
    hud.add_theme_color_override("font_color", Color.CYAN)
    layer.add_child(hud)


func make_box(n: String, p: Vector3, s: Vector3, c: Color) -> void:
    var node = MeshInstance3D.new()
    node.name = n

    var mesh = BoxMesh.new()
    mesh.size = s

    node.mesh = mesh
    node.position = p
    node.material_override = make_material(c)

    add_child(node)


func make_car_box(n: String, p: Vector3, s: Vector3, mat: Material) -> void:
    var node = MeshInstance3D.new()
    node.name = n

    var mesh = BoxMesh.new()
    mesh.size = s

    node.mesh = mesh
    node.position = p
    node.material_override = mat

    car.add_child(node)


func make_material(c: Color) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    material.albedo_color = c
    material.roughness = 0.5
    return material

