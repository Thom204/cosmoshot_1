extends RigidBody2D

@export var lifetime:float = 3.0   # Tiempo máximo antes de desaparecer (por seguridad)
var atributes:BulletData
var source:Vector2

func _ready() -> void:
	# Auto-destruirse después de cierto tiempo aunque no choque
	contact_monitor = true
	max_contacts_reported = 2
	source = global_position
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("living") and body.has_method("damage"):
		body.damage(atributes.damage)
	queue_free()


func _process(_delta:float)->void:
	if not atributes:
		return
		
	if (source - global_position).length() >= atributes.alcance:
		queue_free()
