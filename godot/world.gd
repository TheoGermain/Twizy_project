extends Spatial

var lPancartes
var dico_classes

# Called when the node enters the scene tree for the first time.
func _ready():
	#print ("tour=",$tour)
	#print ("pancarte=",$tour/pancarte)
	#print ("children=",get_child_count())
	# on construit la liste de tous les StaticBody "pancarte"
	lPancartes=[]
	_traversal(self)
	# on affiche cette liste, qui dans cet exemple doit contenir 4 éléments
	#print(lPancartes)
	dico_classes = {"pancarte_12" : 0, "pancarte_13" : 1, "pancarte_14" : 2, "pancarte_15" : 3, "pancarte_16" : 4, "pancarte_22" : 5, "pancarte_23" : 6, "pancarte_24" : 7, "pancarte_25" : 8, "pancarte_26" : 9, "pancarte_32" : 10, "pancarte_33" : 11, "pancarte_34" : 12, "pancarte_42" : 13, "pancarte_43" : 14, "pancarte_44" : 15, "pancarte_45" : 16, "pancarte_46" : 17, "pancarte_53" : 18, "pancarte_54" : 19, "pancarte_55" : 20, "pancarte_56" : 21, "pancarte_65" : 22, "pancarte_66" : 23}
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# fonction de parcours de la hiérarchie des objets
# chaque fois qu'on voit un objet dont le nom commence par "pan"
# on l'ajoute à la liste lPancartes
# de cette manière on crée dynamiquement la liste des objets pancarte
func _traversal(n):
	#print(n.name)
	if (n.name.left(3)=="pan"):
		lPancartes.append(n)
	if (n.get_child_count()>0):
		for c in n.get_children():
			_traversal(c)
		
