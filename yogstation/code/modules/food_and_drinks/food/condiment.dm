/obj/item/reagent_containers/food/condiment
	var/static/list/yog_possible_states // Holding this in a static since it's cumbersome to calculate this every single time a saltshaker is instantiated
	//(also, refactoring into a static means that condiments aren't hammering GLOB with a bunch of repetitive or empty typelists for every sort of condiment that exists.)

/obj/item/reagent_containers/food/condiment/proc/initialize_possible_states()
	if(!possible_states.len) // This is a signal used by some children types to mark that they can't really change themselves.
		return
	if(!yog_possible_states)
		yog_possible_states = list()
		//...And now we initialize possible_states PROPERLY
		var/list/craftable_types = subtypesof(/obj/item/reagent_containers/food/condiment) - subtypesof(/obj/item/reagent_containers/food/condiment/pack) // Can't make ketchup packets
		for(var/conditype in craftable_types)
			var/obj/item/reagent_containers/food/condiment/dummy = new conditype()
			if(LAZYLEN(dummy.list_reagents) == 1)
				var/spice = dummy.list_reagents[1]
				yog_possible_states[spice] = list(dummy.icon_state,dummy.name,dummy.desc)
			qdel(dummy) // I have to do this, right?
	possible_states = yog_possible_states

/obj/item/reagent_containers/food/condiment/proc/food_transfer(obj/item/reagent_containers/food/snacks/target, mob/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return
	if(target.reagents.total_volume >= target.reagents.maximum_volume)
		to_chat(user, span_warning("You can't add anymore to [target]!"))
		return
	var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
	to_chat(user, span_notice("You pour [trans] units of the condiment onto [target]."))

/obj/item/reagent_containers/food/condiment/pack/initialize_possible_states() // Condiment packs just behave like TG because we don't have any of our own.
	possible_states = typelist("possible_states", possible_states)

/obj/item/reagent_containers/food/condiment/pack/food_transfer(obj/item/reagent_containers/food/snacks/target, mob/user)
	user.playsound_local(get_turf(src),'sound/effects/rip1.ogg', 18)
	if(!reagents.total_volume)
		to_chat(user, span_warning("You tear open [src], but there's nothing in it."))
		qdel(src)
		return
	if(target.reagents.total_volume >= target.reagents.maximum_volume)
		to_chat(user, span_warning("You tear open [src], but [target] is stacked so high that it just drips off!") )
		qdel(src)
		return
	else
		to_chat(user, span_notice("You tear open [src] above [target] and the condiments drip onto it."))
		src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		qdel(src)

/obj/item/reagent_containers/food/condiment/cinnamon
	name = "cinnamon shaker"
	desc = "A spice obtained from the bark of a cinnamomum tree"
	icon_state = "cinnamonshaker"
	list_reagents = list(/datum/reagent/consumable/cinnamon = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/cinnamon/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is attempting the cinnamon challenge! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS