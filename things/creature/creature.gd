extends Node3D

@onready var start_transform = self.global_transform
@onready var start_omni_range = $OmniLight3D.omni_range

var chasing = false
var speed = 0.0

func _rov() -> RigidBody3D:
	return get_tree().get_first_node_in_group("rov")

func _on_detector_body_entered(body: Node3D) -> void:
	print("start chasing")
	start_chasing()

func start_chasing():
	if chasing:
		return
	chasing = true
	$AudioStreamPlayer3D.play()

func _physics_process(delta: float) -> void:
	var rov = _rov()
	if not rov:
		return
	
	look_at(rov.global_position)
	
	if chasing:
		speed += delta
		$OmniLight3D.omni_range = speed * 4.0
		$OmniLight3D.show()
	else:
		$OmniLight3D.hide()
	
	var displacement = rov.global_position - self.global_position
	var distance = displacement.length()
	if distance < 2.0:
		get_tree().get_first_node_in_group("main").rov_reset()
		global_position += -global_basis.z * speed * delta * (distance * distance * 0.25)
	else:
		global_position += -global_basis.z * speed * delta


func reset():
	chasing = false
	speed = 0.0
	global_transform = start_transform
	$OmniLight3D.omni_range = 0.0
