extends Node3D

const CRYSTAL = preload("uid://bj5ie04fkrbov")

func _ready() -> void:
	var bounds = $CrystalBounds
	var p0 = bounds.global_position - (bounds.size / 2)
	var ps = bounds.size
	
	var ray = $CrystalRayCast
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	seed(42)
	for i in range(100):
		
		for j in range(10000):
			var candidate = p0 + ps * Vector3(randf(), randf(), randf())
			ray.position = candidate
			ray.rotation_degrees = Vector3(randf(), randf(), randf()) * 360.0
			ray.force_raycast_update()
			#print(candidate, ray.get_collider())
			if ray.get_collider():
				var p = ray.get_collision_point()
				var n = ray.get_collision_normal()
				n += (Vector3(randf(), randf(), randf()) * 0.5 - Vector3.ONE) * 0.1
				print(p)
				var c = CRYSTAL.instantiate()
				$Crystals.add_child(c)
				c.global_position = p
				c.look_at(p + n)
				break
