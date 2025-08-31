extends RigidBody2D

var direction:Vector2
var last_shot_time: float = -1.0
@export var ang_max:float = 1
@export var thrust:float = 150
@export var torque:float = 150
@export var bullet_types: Array[BulletData]
var current_weapon: int = 0
var weapon: BulletData

func _ready()->void:
	linear_damp = 0.1
	angular_damp = 0.5
	angular_damp_mode = RigidBody2D.DAMP_MODE_COMBINE
	direction = Vector2.UP.rotated(rotation)
	
func shoot(player: RigidBody2D) -> void:
	if bullet_types.is_empty():
		return
	
	weapon = bullet_types[current_weapon]
	if weapon.scene == null:
		return
	
	if (player.global_position - global_position).length() > weapon.speed:
		apply_central_impulse(direction * thrust * get_process_delta_time())
		return
	
	var bullet: RigidBody2D = weapon.scene.instantiate()
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_shot_time < weapon.cooldown:
		return 
	
	last_shot_time = now  # actualizar
	# Cambiar sprite de la bala si el recurso lo define
	if bullet.has_node("Sprite2D") and weapon.sprite:
		bullet.get_node("Sprite2D").texture = weapon.sprite

	var wiggle = randf_range(-weapon.dev, weapon.dev)
	
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation + wiggle
	
	get_tree().current_scene.add_child(bullet)
	bullet.add_collision_exception_with(self)
	
	var dir = Vector2.UP.rotated(global_rotation + wiggle)
	bullet.apply_central_impulse(dir * weapon.speed)
	apply_central_impulse(-dir * weapon.blowback)
	

func _physics_process(_delta: float) -> void:
	direction = Vector2.UP.rotated(rotation)

		
func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	
	var player:RigidBody2D = players[0] as RigidBody2D
	if player == null:
		return

	var dir:Vector2 = (player.global_position - global_position).normalized()
	var angle_diff = (dir.angle() - rotation) + PI/2

	if angle_diff < -0.15:
		apply_torque_impulse(-torque * delta)
	elif angle_diff > 0.15:
		apply_torque_impulse(torque * delta)
	
	else:
		shoot(player)
