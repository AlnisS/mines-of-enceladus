extends Node3D

signal dock_entered(body: Node3D)
signal dock_exited(body: Node3D)

func _on_dock_area_body_entered(body: Node3D) -> void:
	print("enter dock: ", body)
	dock_entered.emit(body)
	

func _on_dock_area_body_exited(body: Node3D) -> void:
	print("exit dock: ", body)
	dock_exited.emit(body)
	
