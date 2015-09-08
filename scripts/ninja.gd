extends KinematicBody2D

var side = 0
var jump = false
var score = 0
var sound = 0
var start = false
var dead = false
var hit = false

func _ready():
	set_process_input(true)
	set_fixed_process(true)
	get_node("AnimatedSprite/AnimationPlayer").play("idle")

	
func _fixed_process(delta):
	if !dead:
		if !get_node("ray_bottom").is_colliding() && !get_node("ray_up").is_colliding():
			jump = false
			if side == 0:
				move(Vector2(0,10))
			else:
				move(Vector2(0,-10))
		else:
			jump = true

	else:
		if side == 0:
			move(Vector2(0,10))
		else:
			move(Vector2(0,-10))
	
	if get_node("RayCast2D").is_colliding():
		add_collision_exception_with(get_node("RayCast2D").get_collider())
		hit = true
		
	if hit:
		if side == 0:
			move(Vector2(-int(get_node("RayCast2D").get_collider().speed),10))
		else:
			move(Vector2(-int(get_node("RayCast2D").get_collider().speed),-10))
		hit = false

func _input(ev):
	if ev.is_pressed() && !ev.is_echo() && jump && start:
		jump = false
		sound = (randi() % 5)+1
		get_node("SamplePlayer2D").play("hit"+str(sound))
		score +=1
		get_parent().get_node("gui/scores").set_text("SCORE: "+str(score))
		if side == 0:
			move(Vector2(0,-10))
			side = 1
			get_node("AnimatedSprite/AnimationPlayer").play("rotate")
			get_node("AnimatedSprite").set_flip_h(true)
		else:
			move(Vector2(0,10))
			side = 0
			get_node("AnimatedSprite/AnimationPlayer").play("rotate",-1,-1,true)
			get_node("AnimatedSprite").set_flip_h(false)

func _on_VisibilityNotifier2D_exit_viewport( viewport ):
	get_parent().get_node("gui/replay").show()
	get_parent().get_node("gui/scores").hide()
	get_parent().get_node("gui/welcome").set_text("GAME OVER\n SCORE: "+str(score))
	get_parent().get_node("gui/welcome").show()


func _on_AnimationPlayer_finished():
	get_node("AnimatedSprite/AnimationPlayer").play("run")


func _on_start_pressed():
	get_parent().get_node("Timer").start()
	get_parent().get_node("gui/welcome").hide()
	get_node("AnimatedSprite/AnimationPlayer").play("run")
	for block in get_tree().get_nodes_in_group("init_blocks"):
		block.movement = true
	start = true
	get_parent().get_node("gui/start").queue_free()
