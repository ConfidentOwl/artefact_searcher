extends Node

class_name EffectsUpdate

@onready var player: Player = $".."

var hp_regen : float = 0
var hp_time : float = 0
var duration_regen : float = 0 
var duration_time : float = 0
var blooding_damage_in : float = 0 
var blooding_damage_in_time : float = 0
var rad_in : float = 0
var rad_in_time : float = 0

var blooding_damage : float = 0
var radion_damage : float = 0


func _init() -> void:
	pass

func _physics_process(delta: float) -> void:
	if radion_damage > 0 :
		player._curent_HP -= radion_damage*delta*0.0001
		if rad_in_time > 0:
			radion_damage -= rad_in *delta
			rad_in_time -= delta
		if radion_damage <=0:
			radion_damage =0
	if blooding_damage > 0 :
		player._curent_HP -= blooding_damage*delta 
		blooding_damage -= (delta/10) 
		if blooding_damage_in > 0:
			blooding_damage -= blooding_damage_in
			blooding_damage_in_time -= delta
		if blooding_damage <= 0:
			blooding_damage =0 
	if hp_time >0:
		player._curent_HP += hp_regen * delta
		hp_time -= delta 
		if hp_time <=0 :
			hp_regen = 0
			hp_time = 0
	if duration_time >0 :
		player._curent_DURATION += duration_regen * delta
		duration_time -= delta 
		if duration_time <=0 :
			duration_regen = 0
			duration_time = 0

func add_efects(item : ItemContayner) ->void:
	if hp_regen<item.effect_hp_regen:
		hp_regen = item.effect_hp_regen
		hp_time = item.effect_hp_time
	if duration_regen< item.effect_stamina_regen:
		duration_regen = item.effect_stamina_regen
		duration_time = item.effect_stamina_time
	if item.effect_blood_add != 0:
		blooding_damage += item.effect_blood_add
		if blooding_damage <= 0:
			blooding_damage =0
	if item.effect_antirad_add > 0:
		rad_in = item.effect_antirad_add
		rad_in_time = item.effect_antirad_time 

func add_blooding(count :float) -> void :
	blooding_damage += count 
	if blooding_damage <= 0:
		blooding_damage = 0
		
func add_radion(count :float) -> void:
	radion_damage += count 
	if radion_damage <= 0:
		radion_damage = 0
