extends CharacterBody3D #Herda as propriedades e metodos comuns a nodes desse tipo

@onready var camera : Camera3D = $CameraRig/Camera3D as Camera3D #Garante que o node esteja carregado antes do script continuar
@export var speed : float = 10.0
@export var accelerationspd : float = 2.5
@export var decelerationspd : float = 0.25 #Cria as variaveis 3 variavies ai e as exporta pro inspector
var direction : Vector3 = Vector3(0.0, 0.0, 0.0) #Cria um vetor3 de direçao, começa tudo no 0


func _physics_process(_delta : float) -> void: #Funçao built in executada 60 vezes por segundo. Retorna nada

	var input_dir : Vector2 = Vector2(
		Input.get_axis(&"move_left", &"move_right"),
		Input.get_axis(&"move_forward", &"move_back")
	) #Cria um vetor2 de direçao 2d. cada valor do vetor é o resultado da subtraçao do movimento positivo e negativo no get_axis
	var forward : Vector3 = camera.global_basis.z.normalized() #Cria um vetor3 que representa o angulo da frente da camera
	var right : Vector3 = camera.global_basis.x.normalized() #Cria um vetor3 que representa o angulo da direita da camera
	direction = (forward * input_dir.y + right * input_dir.x).normalized() #O vetor da direçao criado anteriormente é modificado de forma a direção descrita pelos valores desse vetor estarem sempre de acordo com a frente e a direita da camera. os vetores de cada direçao sao multiplicados pelo ngc la e dops sao somados. nao faço ideia da logica por tras desse calculo tho

	if input_dir.length() > 0.0: #verifica primeiro se ha qualquer movimento acontecendo, pois input_dir vai retornar 0 caso nenhum bota esteja sendo pressionado 
		velocity.x += direction.x * accelerationspd #faz a velocidade x ser a direçao x do nosso vetor direction multiplicado pela aceleraçao
		velocity.z += direction.z * accelerationspd #analogo
		var horizontal = Vector2(velocity.x, velocity.z) #Velocity é un vector3 mas só estamos lidando com o movimento em 2 dimensoes, entao isso é util

		if horizontal.length() > speed: #checa se a mgnitude do vetor horziontal (que é a velocidade do movimento x z) é maior que o limite de velocidade. se sim, trunca pro limite
			horizontal = horizontal.normalized() * speed
			velocity.x = horizontal.x
			velocity.z = horizontal.y

	else:
		velocity.x = move_toward(velocity.x, 0, decelerationspd)
		velocity.z = move_toward(velocity.z, 0, decelerationspd)

	move_and_slide()
