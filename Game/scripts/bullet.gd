extends RigidBody2D

@export var lifetime:float = 3.0   # Tiempo máximo antes de desaparecer (por seguridad)

func _ready() -> void:
	# Auto-destruirse después de cierto tiempo aunque no choque
	contact_monitor = true
	max_contacts_reported = 2
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()


func _process(_delta:float)->void:
	if get_contact_count() >= 1 and is_inside_tree():
		queue_free()
