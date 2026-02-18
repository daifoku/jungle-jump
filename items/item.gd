extends Area2D

signal picked_up

var textures: Dictionary = {
	"cherry": "res://assets/sprites/cherry.png",
	"gem": "res://assets/sprites/gem.png"
}

func init( item_type: String, _position: Vector2) -> void:
	$Sprite2d.texture = load(textures[item_type]) as Texture
	position = _position
	
func _on_item_body_entered(body: PhysicsBody2D) -> void:
	picked_up.emit()
	queue_free()
