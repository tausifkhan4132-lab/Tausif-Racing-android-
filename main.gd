extends Node3D

var car: Node3D
var speed := 0.0
var steer := 0.0
var distance := 0.0
var nitro := 100.0
var game_over := false
var hud: Label
var touch_left := false
var touch_right := false
var throttle := false
var braking := false
var boost := false

func _ready():
    _build_world()
    _build_car()
    _build_hud()
    _build_controls()

func _build_world():
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_SKY
    e.sky = Sky.new()
    e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.environment = e
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -25, 0)
    sun.light_energy = 1.25
    add_child(sun)

    _box("Grass", Vector3(0,-0.25,0), Vector3(90,0.5,220), Color(0.08,0.28,0.12))
    _box("Track", Vector3(0,0,0), Vector3(15,0.15,220), Color(0.12,0.13,0.16))
    for x in [-7.7,7.7]:
        _box("Kerb", Vector3(x,0.12,0), Vector3(0.6,0.22,220), Color(0.85,0.12,0.12))
    for z in range(-100,111,10):
        _box("LaneMark", Vector3(0,0.11,z), Vector3(0.18,0.025,4), Color(0.9,0.9,0.82))
    for side in [-1,1]:
        for z in range(-90,101,18):
            _box("Barrier", Vector3(side*9,0.6,z), Vector3(0.5,1.2,10), Color(0.72,0.75,0.8))
            _box("Grandstand", Vector3(side*17,1.6,z), Vector3(8,3.2,9), Color(0.18,0.23,0.32))
    # Start/finish stripe
    for i in range(15):
        _box("StartStripe", Vector3(-7.0+i,0.14,-62), Vector3(1,0.035,1.2), Color(0.95,0.95,0.95) if i%2==0 else Color(0.08,0.08,0.08))

    var camera := Camera3D.new()
    camera.position = Vector3(0,5.0,9.5)
    camera.rotation_degrees = Vector3(-17,0,0)
    camera.current = true
    car = Node3D.new()
    car.name = "PlayerCar"
    add_child(car)
    car.add_child(camera)

func _build_car():
    var body_mat := _mat(Color(0.015,0.025,0.045), 0.25, 0.7)
    var glass_mat := _mat(Color(0.025,0.15,0.22), 0.18, 0.35)
    var tire_mat := _mat(Color(0.012,0.012,0.015), 0.9)
    _mesh_box(car, "Body", Vector3(0,0.75,0), Vector3(2.0,0.55,3.8), body_mat)
    _mesh_box(car, "Cabin", Vector3(0,1.22,-0.25), Vector3(1.5,0.65,1.8), glass_mat)
    _mesh_box(car, "FrontBumper", Vector3(0,0.55,-1.95), Vector3(1.9,0.25,0.22), body_mat)
    _mesh_box(car, "RearWing", Vector3(0,1.18,1.55), Vector3(2.2,0.12,0.35), body_mat)
    for x in [-1.0,1.0]:
        for z in [-1.25,1.25]:
            _mesh_box(car, "Wheel", Vector3(x,0.48,z), Vector3(0.38,0.85,0.75), tire_mat)
    var light_mat := _mat(Color(1,0.04,0.025), 0.2, 0.2, true)
    for x in [-0.65,0.65]:
        _mesh_box(car, "TailLight", Vector3(x,0.78,1.94), Vector3(0.42,0.12,0.04), light_mat)
    car.position = Vector3(0,0,0)

func _build_hud():
    var layer := CanvasLayer.new()
    add_child(layer)
    hud = Label.new()
    hud.position = Vector2(18,18)
    hud.add_theme_font_size_override("font_size", 26)
    hud.add_theme_color_override("font_color", Color(0.2,0.95,1))
    layer.add_child(hud)



func _build_controls():
    var layer := CanvasLayer.new()
    layer.name = "ControlsLayer"
    add_child(layer)

    _button(layer, "◀", Vector2(22,-110), Vector2(90,75), "left")
    _button(layer, "▶", Vector2(122,-110), Vector2(90,75), "right")
    _button(layer, "BRAKE", Vector2(-205,-110), Vector2(90,75), "brake")
    _button(layer, "GO", Vector2(-105,-110), Vector2(90,75), "go")
    _button(layer, "NITRO", Vector2(-105,-205), Vector2(190,65), "nitro")

func _button(layer: CanvasLayer, caption: String, offset: Vector2, size: Vector2, action: String):
    var b := Button.new()
    b.text = caption
    b.size = size
    b.anchor_left = 0.5
    b.anchor_right = 0.5
    b.anchor_top = 1.0
    b.anchor_bottom = 1.0
    b.offset_left = offset.x
    b.offset_right = offset.x + size.x
    b.offset_top = offset.y
    b.offset_bottom = offset.y + size.y
    b.add_theme_font_size_override("font_size", 22)
    layer.add_child(b)
    b.button_down.connect(func(): _set_action(action, true))
    b.button_up.connect(func(): _set_action(action, false))

func _set_action(action: String, pressed: bool):
    match action:
        "left": touch_left = pressed
        "right": touch_right = pressed
        "go": throttle = pressed
        "brake": braking = pressed
        "nitro": boost = pressed

func _process(delta):
    if Input.is_action_pressed("ui_left") or touch_left:
        steer = move_toward(steer, -1.0, delta*3.0)
    elif Input.is_action_pressed("ui_right") or touch_right:
        steer = move_toward(steer, 1.0, delta*3.0)
    else:
        steer = move_toward(steer, 0.0, delta*2.0)

    var accelerating = Input.is_action_pressed("ui_up") or throttle
    var braking_now = Input.is_action_pressed("ui_down") or braking
    if accelerating: speed = move_toward(speed, 48.0, delta*18.0)
    elif braking_now: speed = move_toward(speed, 0.0, delta*38.0)
    else: speed = move_toward(speed, 22.0, delta*4.0)

    if boost and nitro > 0:
        speed = min(speed + delta*25.0, 65.0)
        nitro = max(nitro-delta*28.0, 0.0)
    else:
        nitro = min(nitro+delta*7.0, 100.0)

    car.position.x += steer * speed * delta * 0.11
    car.position.x = clamp(car.position.x, -5.5, 5.5)
    car.position.z -= speed * delta * 0.22
    distance += speed*delta/3.6
    if car.position.z < -50: car.position.z = 0
    hud.text = "TAUSIF RACING   |   SPEED %03d km/h\nDISTANCE %.0f m   |   NITRO %d%%" % [int(speed*3.6), distance, int(nitro)]

func _box(n: String, p: Vector3, s: Vector3, color: Color):
    var node := MeshInstance3D.new()
    node.name = n
    var mesh := BoxMesh.new()
    mesh.size = s
    node.mesh = mesh
    node.position = p
    node.material_override = _mat(color)
    add_child(node)

func _mesh_box(parent: Node3D, n: String, p: Vector3, s: Vector3, material: Material):
    var node := MeshInstance3D.new()
    node.name = n
    var mesh := BoxMesh.new()
    mesh.size = s
    node.mesh = mesh
    node.position = p
    node.material_override = material
    parent.add_child(node)

func _mat(color: Color, metallic := 0.0, roughness := 0.5, emission := false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metallic
    m.roughness = roughness
    if emission:
        m.emission_enabled = true
        m.emission = color
    return m
