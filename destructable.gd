extends Node3D

var exploded = false
var explode_anim = 0.0

# every destructable needs these children with these names:
# RigidBody3D named RigidBody3D
# GPUParticles3D named ExplosionParticles
# GPUParticles3D named BurnParticles
# Node3D named Sounds

const DEFAULT_EXPLODE_SOUND = "res://assets/sounds/laser-explosion-glass.mp3"
const DEFAULT_BURN_SOUND = "res://assets/sounds/laser-explosion-rubble.mp3"  # todo change


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame (by subclass)
func destructable_process(delta: float) -> void:
	if exploded:
		explode_anim += delta
		var rb: RigidBody3D = $RigidBody3D
		if explode_anim > 2.5:
			queue_free()
		return


func do_sound(sound_path=DEFAULT_EXPLODE_SOUND, volume=1):
	var new_sound = AudioStreamPlayer3D.new()
	new_sound.set_stream(load(sound_path))
	new_sound.volume_db = volume
	new_sound.pitch_scale = randf()*0.4+0.8
	$Sounds.add_child(new_sound)
	new_sound.global_position = global_position
	new_sound.play()


func explode(sound_path=DEFAULT_EXPLODE_SOUND):
	do_sound(sound_path)
	Data.shake_screen(12)
	exploded = true
	var rb: RigidBody3D = $RigidBody3D
	rb.freeze = true
	rb.visible = false
	rb.collision_layer = 0
	var exp: GPUParticles3D = $ExplosionParticles
	exp.emitting = true
	exp.position = rb.position
	
func burn(sound_path=DEFAULT_BURN_SOUND):
	do_sound(sound_path, -10)
	Data.shake_screen(7)
	exploded = true
	var rb: RigidBody3D = $RigidBody3D
	rb.freeze = true
	rb.visible = false
	rb.collision_layer = 0
	var exp: GPUParticles3D = $BurnParticles
	exp.emitting = true
	exp.position = rb.position