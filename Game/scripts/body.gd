extends RigidBody2D

var direction:Vector2
var target_angle:float
var last_shot_time: float = -1.0
@export var ang_max:float = 1
@export var thrust:float = 150
@export var torque:float = 150
@export var bullet_types: Array[BulletData]
@export var turretMode: bool = true
@export var life: float = 100
var current_weapon: int = 0
var weapon: BulletData


func _ready()->void:
	linear_damp = 0.1
	angular_damp = 0.5
	angular_damp_mode = RigidBody2D.DAMP_MODE_COMBINE
	direction = Vector2.UP.rotated(rotation)
	target_angle = rotation
	#if !turretMode:
		#$turret.visible = false


func shoot() -> void:
	if bullet_types.is_empty():
		return
	
	weapon = bullet_types[current_weapon]
	if weapon.scene == null:
		return
	
	var bullet: RigidBody2D = weapon.scene.instantiate()
	bullet.atributes = weapon
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_shot_time < weapon.cooldown:
		return 
	
	last_shot_time = now  # actualizar
	# Cambiar sprite de la bala si el recurso lo define
	if bullet.has_node("Sprite2D") and weapon.sprite:
		bullet.get_node("Sprite2D").texture = weapon.sprite

	var wiggle = randf_range(-weapon.dev, weapon.dev)
	
	bullet.global_position = $turret.global_position
	bullet.global_rotation = $turret.global_rotation +PI/2+ wiggle
	
	get_tree().current_scene.add_child(bullet)
	bullet.add_collision_exception_with(self)
	
	var dir = Vector2.RIGHT.rotated($turret.global_rotation + wiggle)
	bullet.apply_central_impulse(dir * weapon.speed)
	apply_central_impulse(-dir * weapon.blowback)


func _physics_process(delta: float) -> void:
	# Movmiento con flechas, torreta libre
	if turretMode:
		if Input.is_action_pressed("ui_left") and angular_velocity < ang_max:
			apply_torque_impulse(-torque * delta)
		if Input.is_action_pressed("ui_right") and angular_velocity < ang_max:
			apply_torque_impulse(torque * delta)
		if Input.is_action_pressed("ui_up"):
			direction = Vector2.RIGHT.rotated(rotation)
			apply_central_impulse(direction * thrust  * delta)
	# Movimiento follow mouse, torreta bloqueada
	else:
		var dir = (get_global_mouse_position() - global_position).normalized()
		var angle_diff = wrapf((dir.angle() - global_rotation), -PI,PI)

		if angle_diff < -0.05:
			apply_torque_impulse(-torque * delta)
		elif angle_diff > 0.05:
			apply_torque_impulse(torque * delta)
		else:
			apply_torque_impulse(-angular_velocity * torque * delta)
			
		if Input.is_action_pressed("mouse_ritghtclick"):
			direction = Vector2.RIGHT.rotated(rotation)
			apply_central_impulse(direction * thrust * delta)
	
	if life <= 0:
		#Mostrar pantalla de perdida.
		visible = false
		self.remove_from_group("player")
		self.remove_from_group("living")


func _process(delta: float) -> void:
	if turretMode:
		var dir = (get_global_mouse_position() - $turret.global_position).normalized()
		target_angle = dir.angle()
		$turret.global_rotation = lerp_angle($turret.global_rotation, target_angle, 5 * delta)
	else:
		$turret.global_rotation = global_rotation
	if Input.is_action_pressed("mouse_leftclick"):
		shoot()
	if Input.is_action_just_pressed("weapon_1"):
		current_weapon = 0
	if Input.is_action_just_pressed("weapon_2") and bullet_types.size() > 1:
		current_weapon = 1


func damage(dam : float) -> void:
	life -= dam
