extends KinematicBody

export var speed = 10
export var acceleration = 5
export var gravity = 0.98
export var jump_power = 30
export var mouse_sensitivity = 0.3

onready var head = $Head
onready var camera = $Head/Camera
onready var counter = 0
onready var margin_x = 10
onready var margin_y = 10

var velocity = Vector3()
var camera_x_rotation = 0

var world
var lPancartes
var to_from
var dist
var cpt = 0

func _ready():
	# on récupère le pointeur sur la racine de l'arborescence
	# car on en a besoin pour récupérer lPancartes qui se trouve dans cet objet
	world=get_tree().get_root().get_node("World")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))

		#var x_delta = event.relative.y * mouse_sensitivity
		#if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90: 
		#	camera.rotate_x(deg2rad(-x_delta))
		#	camera_x_rotation += x_delta

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	cpt += 1
	var head_basis = head.get_global_transform().basis
	
	var direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= head_basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += head_basis.z
	
	if Input.is_action_pressed("move_left"):
		direction -= head_basis.x
	elif Input.is_action_pressed("move_right"):
		direction += head_basis.x
	
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity.y -= gravity

	# on récupère ici lPancartes
	# on regarde dans cette liste quelles sont les pancartes visibles
	# (au sens de leur notifier). On ne sait pas encore si ces pancartes
	# sont vraiment visibles, on sait juste qu'elles se trouvent
	# dans le champ de la caméra, peut être occultées par d'autres objets devant
	# à la fin de la boucle, lP contient la liste des pancartes visibles
	lPancartes=world.lPancartes
	var lP=[]
	for p in lPancartes:
		if (p.get_node("ntf").is_on_screen()):
			#print (p.name)
			lP.append(p)
	
	#if Input.is_action_just_pressed("jump") and is_on_floor():
	#	velocity.y += jump_power
	
	velocity = move_and_slide(velocity, Vector3.UP)

	# C'est là qu'on commence à faire du ray casting. On sait à ce stade
	# les pancartes qui sont dans le champ de la caméra. On va tracer
	# un rayon entre la caméra, dans sa position absolue (from), et toutes
	# les positions associées (to) de la liste lP. On va donc itérer
	# sur les éléments p de cette liste lP, et appeler intersect_ray
	# pour chaque couple from,to. intersect_ray renvoie le 1er
	# objet qui collisionne avec le rayon partant de la caméra.
	# si ce premier objet est justement la pancarte qui a servi
	# à faire le ray-casting cela veut dire que la pancarte est
	# vraiment visible et "devant" tous les autres objets que la caméra voit
	var rcn=$Head/Camera/RayCast
	var from=$Head/Camera.global_transform.origin
	var to
	var result
	var space_state = get_world().direct_space_state
	var s=""
	var lP_on_screen = []
	for p in lP:
		to=p.global_transform.origin
		#print ("from ", from, " to ", to)
		result = space_state.intersect_ray(from, to)

		if result.size() != 0 and result.collider.name==p.name :
			#s+=result.collider.name+","
			lP_on_screen.append(p)
	#print (s)
	#print(lP_on_screen)
	
	if Input.is_action_pressed("take_screenshot") or cpt == 100:
		cpt = 0
		if lP_on_screen.size() != 0 :
			var f = File.new()
			f.open("/Users/theo/Documents/Projets_Godot/screen/screen"+str(counter)+".txt", f.WRITE)
			for pan in lP_on_screen :
				print(pan.name)
				from=$Head/Camera.global_transform.origin
				to=pan.global_transform.origin
				to_from = Vector2((from-to)[0],(from-to)[2]);
				to_from = to_from.normalized()
				dist = sqrt(pow((to-from)[0],2)+pow((to-from)[1],2)+pow((to-from)[2],2))
				var classe = world.dico_classes[pan.name.left(11)]
				computeBoundingBox(pan.get_node("MeshInstance"),classe,f)
			saveImage()
			f.close()
			counter+=1
	
	#var to=get_tree().get_root().get_node("World").get_node("tour").get_node("pancarteRouge").global_transform.origin
	#print ("from ", from, " to ", to)

	
func saveImage():
	get_viewport().get_texture().get_data()
	#yield(get_tree(), "idle_frame")
	#yield(get_tree(), "idle_frame")
	var screenshot=get_viewport().get_texture().get_data()
	screenshot.flip_y()
	filename="/Users/theo/Documents/Projets_Godot/screen/screen"+str(counter)+".png"
	print (filename)
	screenshot.save_png(filename)

func computeBoundingBox(mi,cl,file):
	print("classe :", cl)
	var miMesh=mi.get_mesh()
	var mdt=MeshDataTool.new() 
	var gt=mi.get_global_transform()[0]
	gt = gt.normalized()
	var normal = Vector2(gt[0],gt[2])
	var dot_product = normal.dot(to_from)
	print(dot_product)
	print("dist ",dist)
	
	if dot_product > 0.50 :
		mdt.create_from_surface(miMesh, 0)
		#print ("count=",mdt.get_vertex_count())
		var xmin=100000.0
		var xmax=-100000.0
		var ymin=100000.0
		var ymax=-100000.0
		
		for i in range(mdt.get_vertex_count()):
			#print (i,mdt.get_vertex(i))
			var positionOnScreen = camera.unproject_position(mi.get_global_transform().origin+mdt.get_vertex(i))
			#print (i,positionOnScreen)
			if (positionOnScreen.x<xmin):
				xmin=positionOnScreen.x
			if (positionOnScreen.x>xmax):
				xmax=positionOnScreen.x	
			if (positionOnScreen.y<ymin):
				ymin=positionOnScreen.y
			if (positionOnScreen.y>ymax):
				ymax=positionOnScreen.y
		#print (xmin,",",ymin,",",xmax,",",ymax)
		mdt.clear()
		
		xmin-=margin_x
		xmax+=margin_x
		ymin-=margin_y
		ymax+=margin_y
		
		if xmin<0:
			xmin=0
		if xmax>1024:
			xmax=1024
		if ymin<0:
			ymin=0
		if ymax>600:
			ymax=600
			
		var width = xmax-xmin
		var height = ymax-ymin
		print(width," ",height)
			
		#print (xmin,",",ymin,",",xmax,",",ymax)
		var yolo_x=(xmin+(width/2))/1024.0
		var yolo_y=(ymin+(height/2))/600.0
		var yolo_width=width/1024.0
		var yolo_height=height/600.0
		
		#print(cl," ",yolo_x," ",yolo_y," ",yolo_width," ",yolo_height)
		if dist < 60:
			file.store_string(str(cl)+" "+str(yolo_x)+" "+str(yolo_y)+" "+str(yolo_width)+" "+str(yolo_height)+'\n')
