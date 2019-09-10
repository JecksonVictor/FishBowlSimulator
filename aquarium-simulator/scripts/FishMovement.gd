extends Sprite

var direction            = 1
export var normalSpeed   = 50
export var foodRadarSize = 100
var currentSpeed         = 50
var lookingAtFood        = false
var currentState         = "normal"
var currentFood          = null
var margin  		     = 28
var extras  		     = {}

signal food_eaten(fish)

export(Texture) var normalTexture = null
export(Texture) var deadTexture   = null

export var maxEnergy = 5 #o máximo de comida que o peixe pode comer
export var energy    = 0 #quantidade de energia atual que o peixe tem
export var energyDuration = 3.0 #duração em segundos que o peixe demora pra gastar um ponto de energia

var currentDuration = null #informa quanto tempo foi gasto na energia atual

func _ready():
	currentDuration = energyDuration


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentDuration -= delta
	
	if currentDuration <= 0:
		energy -= 1
		currentDuration = energyDuration
		
	if energy < 0:
		currentState = "morto"
		
	if currentState == "morto":
		texture = deadTexture
	else:
		texture = normalTexture
	
	if currentSpeed > normalSpeed:
		currentSpeed = currentSpeed - (100 * delta)
		
	if position.x < margin or position.x > get_viewport().size.x - margin:
		direction = direction * -1
		
	flip_h = false
	flip_v = false
	
	if currentState == "normal":
		normal_state(delta)
	elif currentState == "observando":
		watching_state(delta)
	elif currentState == "cheio":
		full_state(delta)
	elif currentState == "faminto":
		starving_state(delta)
	elif currentState == "morto":
		dead_state(delta)
	
	

func normal_state(delta):
	position.x = position.x + (get_current_speed() * delta * direction)
	flip_h     = direction < 0
	rotation_degrees = 0

func watching_state(delta):
	if currentFood.get_ref():
		var foodDirection = (currentFood.get_ref().position - position).normalized()
		position += get_current_speed() * delta * foodDirection
	else:
		currentFood = null
		currentState = "normal"
	
func full_state(delta):
	pass
	
func starving_state(delta):
	pass
	
func dead_state(delta):
	flip_v = true
	flip_h = false
	rotation_degrees = 0
	if position.y < get_viewport().size.y - margin:
		position.y += 10 * delta
	
func is_full():
	return energy == maxEnergy

func is_hungry():
	return energy == 0 or energy == 1
	
func get_food_radar_size():
	if is_hungry():
		return 4 * foodRadarSize
	elif is_full():
		return 0.25 * foodRadarSize
	else:
		return foodRadarSize

func get_current_speed():
	if is_hungry():
		return 4 * currentSpeed
	elif is_full():
		return 0.25 * currentSpeed
	else:
		return currentSpeed

func _on_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		#direction  = direction * -1
		currentSpeed = 400

func look_at_food(food):
	if currentState == "morto":
		return
	currentState = "observando"
	currentFood  = weakref(food)
	look_at(food.position)
	flip_h = false
	lookingAtFood = true
	
func look_straight():
	currentState = "normal"
	currentFood  = null
	rotation = 0
	flip_v = false
	lookingAtFood = false

func _on_Area2D_area_entered(area):
	if currentState == "morto":
		return
		
	if area.is_in_group("food"):
		area.eaten = true
		energy += 1
		emit_signal("food_eaten", self)
		
		if energy > maxEnergy:
			currentState = "morto"
		else:
			currentState = "normal"
