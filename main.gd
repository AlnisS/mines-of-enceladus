extends Node3D

@onready var rov: RigidBody3D = %ROV
@onready var rov_reset_transform: Transform3D = %ROV.global_transform

var rov_energy = 100.0
var rov_in_dock = false

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
	#var pilot_force := pilot_force_input.normalized() * 2.0
	var pilot_force := pilot_force_input * 2.0
	var pilot_torque := pilot_torque_input * 0.2
	if Input.is_action_pressed("rov_translate_sprint"):
		pilot_force *= 2.0
	if resetting:
		pilot_force = Vector3.ZERO
		pilot_torque = Vector3.ZERO
	var rov_basis := rov.global_basis
	var pilot_force_global = rov_basis * pilot_force if rov_energy > 0 else Vector3.ZERO
	var pilot_torque_global = rov_basis * pilot_torque if rov_energy > 0 else Vector3.ZERO
	
	var righting_torque = rov_basis.y.cross(Vector3.UP) * 0.3
	righting_torque = Vector3.ZERO # TODO: option to enable righting torque?
	rov.apply_central_force(pilot_force_global)
	rov.apply_torque(pilot_torque_global + righting_torque)
	
	var thruster_scales = abs(pilot_force) / 4.0 * 1.5
	var thruster_scales_2 = abs(pilot_torque) / 0.2  / 2.0
	$Thruster1.pitch_scale = lerp($Thruster1.pitch_scale, thruster_scales.x, 0.2)
	$Thruster2.pitch_scale = lerp($Thruster2.pitch_scale, thruster_scales.y, 0.2)
	$Thruster3.pitch_scale = lerp($Thruster3.pitch_scale, thruster_scales.z, 0.2)
	$Thruster4.pitch_scale = lerp($Thruster4.pitch_scale, thruster_scales_2.x, 0.2)
	$Thruster5.pitch_scale = lerp($Thruster5.pitch_scale, thruster_scales_2.y, 0.2)
	$Thruster6.pitch_scale = lerp($Thruster6.pitch_scale, thruster_scales_2.z, 0.2)
	
	
	var energy_consumption = 0.0
	energy_consumption += pilot_force.length()
	energy_consumption += pilot_torque.length() * 0.2
	energy_consumption += 0.4
	energy_consumption *= 0.4 * 1.0
	energy_consumption *= 0.6
	rov_energy -= delta * energy_consumption
	rov_energy = max(rov_energy, 0.0)
	if rov_in_dock:
		rov_energy += delta * 10.0
		rov_energy = min(rov_energy, 100.0)
		if rov_energy == 100.0:
			if $Charging.volume_db == -5.0:
				$Charging.volume_db -= 0.01
				create_tween().tween_property($Charging, "volume_db", -25.0, 0.3)
	if rov_energy == 0.0 or Input.is_action_just_pressed("ui_up"):
		rov_reset()
	%EnergyBar.value = rov_energy
	
	var crystal_count = get_tree().get_nodes_in_group("provisional_collected").size()
	%CrystalsValue.text = str(crystal_count)
	
	var rot = rov.global_rotation_degrees
	%YawValue.text = "%.0f°" % (-rot.y + 0.001)
	%PitchValue.text = "%.0f°" % (rot.x + 0.001)
	%RollValue.text = "%.0f°" % (-rot.z + 0.001)
	
	%DepthValue.text = "%.0fm" % -(rov.global_position.z - 8734.0)

var resetting = false

func rov_reset():
	if resetting:
		return
	resetting = true
	var tween = get_tree().create_tween()
	%LossScreen.show()
	tween.tween_property(%LossScreen, "modulate", Color.BLACK, 1.0)
	tween.tween_property(%Ambiance, "volume_db", -25.0, 1.0)
	await tween.finished
	
	rov_energy = 100.0
	rov.global_transform = rov_reset_transform
	for crystal in get_tree().get_nodes_in_group("provisional_collected"):
		if not crystal.is_in_group("really_collected"):
			crystal.uncollect()
	
	%Ambiance.play(0)
	
	tween = get_tree().create_tween()
	%LossScreen.show()
	tween.tween_property(%LossScreen, "modulate", Color.TRANSPARENT, 1.0)
	tween.tween_property(%Ambiance, "volume_db", -5.0, 1.0)
	await tween.finished
	%LossScreen.hide()
	resetting = false
	#await 


func _on_station_dock_entered(body: Node3D) -> void:
	if body == rov:
		print("rov entered dock")
		rov_in_dock = true
		$Charging.volume_db = -5.0
		if rov_energy < 99.0:
			$Charging.play()
		var provs = get_tree().get_nodes_in_group("provisional_collected")
		for crystal in provs:
			if not crystal.is_in_group("really_collected"):
				crystal.add_to_group("really_collected")
			# TODO: count score
			


func _on_station_dock_exited(body: Node3D) -> void:
	if body == rov:
		print("rov exited dock")
		rov_in_dock = false
