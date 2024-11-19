extends Node

func _sorte_item_all(newList :Array[ItemContayner],_sorting_id_to_id :Dictionary,item_list: ItemList) -> void:
	_sorting_id_to_id.clear()
	var number : int = 0
	for i : int in range(newList.size()) :
		var i_item : ItemContayner = newList[i]
		if i_item.item_stakable :
			item_list.add_item( str(i_item.item_name)+" - "+str(i_item.item_count),i_item.item_image)
		else :
			item_list.add_item( str(i_item.item_name),i_item.item_image)
		_sorting_id_to_id[i] = number
		number +=1

func _sorte_item_wpn(newList :Array[ItemContayner],_sorting_id_to_id :Dictionary,item_list: ItemList) -> void:
	_sorting_id_to_id.clear()
	var number : int = 0
	for i : int in range(newList.size()) :
		var i_item : ItemContayner = newList[i]
		if i_item.item_type == Global.ITEM_TYPE.weapon1 or i_item.item_type == Global.ITEM_TYPE.weapon2 or i_item.item_type == Global.ITEM_TYPE.weapon3 :
			item_list.add_item( str(i_item.item_name),i_item.item_image)
			_sorting_id_to_id[i] = number
			number +=1
		else :
			_sorting_id_to_id[i] = -1

func _sorte_item_ammo(newList :Array[ItemContayner],_sorting_id_to_id :Dictionary,item_list: ItemList) -> void:
	_sorting_id_to_id.clear()
	var number : int = 0
	for i : int in range(newList.size()) :
		var i_item : ItemContayner = newList[i]
		if i_item.item_type == Global.ITEM_TYPE.ammo :
			item_list.add_item( str(i_item.item_name)+" - "+str(i_item.item_count),i_item.item_image)
			_sorting_id_to_id[i] = number
			number +=1
		else :
			_sorting_id_to_id[i] = -1

func _sorte_item_monster_part(newList :Array[ItemContayner],_sorting_id_to_id :Dictionary,item_list: ItemList) -> void:
	_sorting_id_to_id.clear()
	var number : int = 0
	for i : int in range(newList.size()) :
		var i_item : ItemContayner = newList[i]
		if i_item.item_type == Global.ITEM_TYPE.monster_part :
			item_list.add_item( str(i_item.item_name)+" - "+str(i_item.item_count),i_item.item_image)
			_sorting_id_to_id[i] = number
			number +=1
		else :
			_sorting_id_to_id[i] = -1

func _sorte_item_cons(newList :Array[ItemContayner],_sorting_id_to_id :Dictionary,item_list: ItemList) -> void:
	_sorting_id_to_id.clear()
	var number : int = 0
	for i : int in range(newList.size()) :
		var i_item : ItemContayner = newList[i]
		if i_item.item_type == Global.ITEM_TYPE.consumer :
			item_list.add_item( str(i_item.item_name)+" - "+str(i_item.item_count),i_item.item_image)
			_sorting_id_to_id[i] = number
			number +=1
		else :
			_sorting_id_to_id[i] = -1

func get_real_id_from_sorted_id(_array_link : Array[ItemContayner], _sorting_id_to_id : Dictionary,item_list: ItemList) -> ItemContayner :
	return _array_link[_sorting_id_to_id.find_key(item_list.get_selected_items()[0])]
	
func get_real_id_drom_id(id:int,_array_link : Array[ItemContayner], _sorting_id_to_id : Dictionary,item_list: ItemList) -> ItemContayner:
	return _array_link[_sorting_id_to_id.find_key(id)]
