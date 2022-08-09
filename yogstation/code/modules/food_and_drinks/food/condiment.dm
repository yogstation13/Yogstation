/obj/item/reagent_containers/food/condiment/proc/food_transfer(obj/item/reagent_containers/food/snacks/target, mob/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return
	if(target.reagents.total_volume >= target.reagents.maximum_volume)
		to_chat(user, span_warning("You can't add anymore to [target]!"))
		return
	var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
	to_chat(user, span_notice("You pour [trans] units of the condiment onto [target]."))

/obj/item/reagent_containers/food/condiment/pack/food_transfer(obj/item/reagent_containers/food/snacks/target, mob/user)
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