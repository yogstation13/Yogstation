/obj/item/reagent_containers/herb
	possible_transfer_amounts = list()
	var/preset_herb_type
	var/herb_type

/obj/item/reagent_containers/herb/proc/set_herb_type(herb)
	herb_type = herb
	if(preset_herb_type)
		herb_type = preset_herb_type
	list_reagents =  list(GLOB.herb_manager.get_chem(herb_type) = 10)
	add_initial_reagents()
		
/obj/item/reagent_containers/herb/attack_self(mob/user)
	if(!canconsume(user, user))
		return ..()
	
	