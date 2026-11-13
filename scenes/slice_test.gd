extends Node3D

const MeshSlicer = preload("res://scripts/mesh_slicer.gd")

func _ready() -> void:
	call_deferred('slice_object')

func create_rigid_body(sliced_mesh, spawn_position):
	var body = RigidBody3D.new()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = sliced_mesh
	
	body.add_child(mesh_instance)
	
	var collision = CollisionShape3D.new()
	collision.shape = sliced_mesh.create_convex_shape()
	body.add_child(collision)	
	
	get_tree().current_scene.add_child(body)
	body.global_position = spawn_position
	
	return body
	
func slice_object() -> void:
	var mesh_instance: MeshInstance3D = $Pine1/Cylinder

	# Convert the slicing plane's transform
	# into the mesh's local coordinate system.
	var slice_transform = (
		mesh_instance.global_transform.affine_inverse()
		* $Slicer.global_transform
	)

	# Perform the slicing.
	var meshes = MeshSlicer.slice_mesh(
		slice_transform,
		mesh_instance.mesh
	)

	# Assign the first half of the resulting mesh.
	if meshes != null:
		mesh_instance.mesh = null
	else:
		print("Slicing failed!")
		return
		
	var mesh_zero_body = create_rigid_body(meshes[0], mesh_instance.global_position)
	var mesh_one_body = create_rigid_body(meshes[1], mesh_instance.global_position)
	
	for mesh_body in [mesh_zero_body, mesh_one_body]:
		mesh_body.set_collision_layer_value(3, true)
		mesh_body.set_collision_layer_value(1, false)
		
		mesh_body.set_collision_mask_value(1, true)
		mesh_body.set_collision_mask_value(1, true)
		mesh_body.set_collision_mask_value(2, true)
		mesh_body.set_collision_mask_value(3, true)
	
	mesh_zero_body.apply_force(Vector3(150,0,0))
	
	
	
