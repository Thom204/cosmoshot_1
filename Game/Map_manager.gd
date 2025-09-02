extends Node2D

@export var map_size: Vector2 = Vector2(2000, 2000)

func _physics_process(_delta: float) -> void:
	var objects = get_tree().get_nodes_in_group("wrap")
	for obj in objects:
		var pos = obj.global_position

		if pos.x > map_size.x:
			pos.x = 0
		elif pos.x < -map_size.x:
			pos.x = map_size.x

		if pos.y > map_size.y:
			pos.y = 0
		elif pos.y < -map_size.y:
			pos.y = map_size.y

		obj.global_position = pos
