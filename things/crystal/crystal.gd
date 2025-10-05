extends Node3D

@onready var visual_initial_scale = $Visual.scale


func _on_detector_body_entered(body: Node3D) -> void:
	if self.is_in_group("provisional_collected"):
		return
	if self.is_in_group("really_collected"):
		return
	collect()

func collect():
	self.add_to_group("provisional_collected")
	$AudioStreamPlayer3D.play()
	$CPUParticles3D.emitting = true
	var tween = create_tween()
	tween.tween_property($Visual, "scale", Vector3.ZERO, 0.5).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	#self.hide()

func uncollect():
	self.remove_from_group("provisional_collected")
	$Visual.scale = visual_initial_scale
	#self.show()
