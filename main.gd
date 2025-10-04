extends Node3D

@onready var rov: RigidBody3D = %ROV

func _physics_process(delta: float) -> void:
	var pilot_force_input := Vector3(
		Input.get_axis("rov_translate_left", "rov_translate_right"),
		Input.get_axis("rov_translate_down", "rov_translate_up"),
		Input.get_axis("rov_translate_forward", "rov_translate_backward")
	)
	var pilot_torque_input := Vector3(
		Input.get_axis("rov_pitch_down", "rov_pitch_up"),
		Input.get_axis("rov_yaw_right", "rov_yaw_left"),
		Input.get_axis("rov_roll_right", "rov_roll_left")
	)
	var pilot_force := pilot_force_input.normalized() * 2.0
	var pilot_torque := pilot_torque_input.normalized() * 0.2
	if Input.is_action_pressed("rov_translate_sprint"):
		pilot_force *= 2.0
	var rov_basis := rov.global_basis
	var pilot_force_global = rov_basis * pilot_force
	var pilot_torque_global = rov_basis * pilot_torque
	var righting_torque = rov_basis.y.cross(Vector3.UP) * 0.3
	rov.apply_central_force(pilot_force_global)
	rov.apply_torque(pilot_torque_global + righting_torque)
	
