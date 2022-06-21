/obj/structure/destructible/hog_structure/item_maker
	name = "item maker"
	desc = "you shouldn't see this"
	break_message = span_warning("bruh!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "lance"
	icon_originalname = "lance"
	max_integrity = 65
	var/working_on = FALSE
	var/datum/hog_product/product
	var/when_ready
	var/list/products = list(/datum/hog_product)

/obj/item/hog_item/prismatic_lance/Initialize()
	. = ..()
	for(var/datum/hog_product/D in products)
		D = new

/obj/structure/destructible/hog_structure/item_maker/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/datum/hog_product/D in products)
		qdel(D)
	return ..()

/obj/structure/destructible/hog_structure/item_maker/special_interaction(mob/user)
	var/mob/living/carbon/C = user
	if(!C)
		return
	if(working_on)
		to_chat(C, span_warning("The [src] is currently busy, please wait [(when_ready - world.time)/10] seconds!"))

	var/list/products_to_buy = list()
	var/list/names = list() ///A bit weird, but if you have any other idea... propose it

	for(var/datum/hog_product/D in products)
		products_to_buy[D.name] = D
		names += D.name

	var/datum/hog_product/picked_product = products_to_buy[input(god,"What do you want to order?","Item") in names]
	if(!picked_product)
		return
	if(hog_product.cost > cult.energy)
		to_chat(C,span_warning("Your cult doesn't have enough energy to afford [picked_product.name]!")) 
		return
	if(!order(picked_product))
		to_chat(C, span_warning("The [src] is currently busy, please wait [(when_ready - world.time)/10] seconds!"))



/obj/structure/destructible/hog_structure/item_maker/proc/order(var/datum/hog_product/order)
	if(working_on)
		return FALSE
	cult.change_energy_amount(order.cost)
	if(!product)
		product = order
	working_on = TRUE
	when_ready = world.time + order.time_to_make
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/structure/destructible/hog_structure/item_maker/process()
	if(when_ready <= world.time)
		var/obj/item/new_item = new product.result (get_turf(src)) 
		if(istype(new_item, /obj/item/hog_item))
			var/obj/item/hog_item/pog = new_item
			pog.handle_owner_change(cult)
		working_on = FALSE
		product = FALSE
		visible_message(span_userdanger("[src] suddenly splits out [new_item]!"))
		STOP_PROCESSING(SSobj, src)

/datum/hog_product
	var/name = "sus"
	var/description = "amogus"
	var/time_to_make = 1 SECONDS
	var/cost = 50
	var/obj/item/result = /obj/item/hog_item


