extends Node2D

signal can_pickup(item)
signal cant_pickup()

var shell_texture
# Called when the node enters the scene tree for the first time.
func _ready():
	shell_texture = asset_loader.shell_list["shell" + str((randi() % 3) +1)]
	$Area2D/Sprite.texture = shell_texture

func _on_Area2D_body_entered(body):
	
	emit_signal("can_pickup", self)
	$Area2D/Sprite.modulate.r = 255


func _on_Area2D_body_exited(body):
	emit_signal("cant_pickup")
	$Area2D/Sprite.modulate.r = 0
