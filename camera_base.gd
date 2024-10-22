extends Camera3D
# other camera scripts can inherit from this
# they must call the base_camera_process at the top of their _process method

var mouse_pressed_prev = false
var weapon = 1
const FLAMETHROWER_PER_SECOND = 12
var flamethrower_cooldown = 0
const BASE_FOV = 100
var delta_mouse = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta) -> void:
	base_camera_process(delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func base_camera_process(delta):
	# screen shake
	fov = BASE_FOV + randf_range(0.0, Data.shaking_amt)
	
	# inputs
	if Input.is_action_pressed("click"):
		Data.current_weapon = Data.Weapon.CLICK
	if Input.is_action_pressed("flamethrower"):
		Data.current_weapon = Data.Weapon.FLAMETHROWER
	if Input.is_action_pressed("push"):
		Data.current_weapon = Data.Weapon.PUSH
	
	# destroy destructables
	var cam = get_viewport().get_camera_3d()
	var space_state = get_world_3d().direct_space_state
	var mpos_2d = get_viewport().get_mouse_position()
	var raycast_origin = cam.project_ray_origin(mpos_2d)
	var raycast_end = cam.project_position(mpos_2d, 1000)
	var query = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_end)
	var intersect = space_state.intersect_ray(query)
	flamethrower_cooldown += delta
	if intersect.size() > 0:
		if Data.current_weapon == Data.Weapon.CLICK:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				if not mouse_pressed_prev:
					var original = intersect.collider
					if original.get_parent().has_meta("destructable"):
						var N = 200
						var M = 4
						for j in range(M+1):
							for i in range(N):
								var raycast_start_push = original.global_position
								var raycast_end_push = original.global_position+Vector3(
									40*cos(2.0*PI*(float(i)/N)), float(j)/M*3-1.5, 40*sin(2.0*PI*(float(i)/N))
								)
								var query_push = PhysicsRayQueryParameters3D.create(
									raycast_start_push, raycast_end_push)
								query_push.exclude = [original.get_rid()]
								var intersect_push = space_state.intersect_ray(query_push)
								if intersect_push.size() > 0:
									if intersect_push.collider.get_parent().has_meta("destructable"):
										var other = intersect_push.collider
										var dist = original.position.distance_to(other.global_position)
										var deltapos = (other.global_position-raycast_start_push)
										other.apply_impulse(deltapos*minf(0.08/(dist), 1))
								# todo: this should also push (explode?) nearby cubes
						original.get_parent().explode()
						
		if Data.current_weapon == Data.Weapon.FLAMETHROWER:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				if intersect.collider.get_parent().has_meta("destructable"):
					if (1.0/FLAMETHROWER_PER_SECOND) < flamethrower_cooldown:
						flamethrower_cooldown = 0
					
						intersect.collider.get_parent().burn()
		
		if Data.current_weapon == Data.Weapon.PUSH:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				if not mouse_pressed_prev:
					if intersect.collider.get_parent().has_meta("destructable"):
						intersect.collider.get_parent().push(position)
						
	
	mouse_pressed_prev = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
