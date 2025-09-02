extends RigidBody2D

var direction:Vector2
var last_shot_time: float = -1.0
var current_weapon: int = 0
var weapon: BulletData
var players: Array[Node]
var current_enemy: int = 0
var current_target: RigidBody2D
@export var max_target_distance: float = 1000.0
@export var life: float = 100
@export var ang_max:float = 1
@export var thrust:float = 150
@export var torque:float = 150
@export var bullet_types: Array[BulletData]


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
	
	if (player.global_position - global_position).length() > weapon.alcance:
		apply_central_impulse(direction * thrust * get_process_delta_time())
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
	
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation + wiggle + PI/2
	
	get_tree().current_scene.add_child(bullet)
	bullet.add_collision_exception_with(self)
	
	var dir = Vector2.RIGHT.rotated(global_rotation + wiggle)
	bullet.apply_central_impulse(dir * weapon.speed)
	apply_central_impulse(-dir * weapon.blowback)


func _physics_process(_delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	if life <= 0:
		queue_free()


func _process(delta: float) -> void:
	if current_target == null:
		current_target = find_closest_player()
		return
		
	if not is_instance_valid(current_target) or \
		global_position.distance_to(current_target.global_position) > max_target_distance or\
		not current_target in get_tree().get_nodes_in_group("living"):
			
		current_target = null
		return
	
	var dir:Vector2 = (current_target.global_position - global_position).normalized()
	var angle_diff = wrapf((dir.angle() - global_rotation), -PI,PI)

	if angle_diff < -0.1:
		apply_torque_impulse(-torque * delta)
	elif angle_diff > 0.1:
		apply_torque_impulse(torque * delta)
	else:
		apply_torque_impulse(-angular_velocity * torque* 0.3 * delta)
		shoot(current_target)


func damage(dam : float) -> void:
	life -= dam
	
	if not players.is_empty():
		current_target = find_closest_player()


func find_closest_player() -> RigidBody2D:
	players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	
	var closest: RigidBody2D = null
	var closest_dist := INF
	
	if players.size() > 10:
		players = players.slice(0, 10)
		
	for p in players:
		if p == self:
			continue
		var dist = global_position.distance_to(p.global_position)
		if dist < closest_dist:
			closest = p
			closest_dist = dist
	
	return closest
