/obj/machinery/deepfryer
	icon = 'monkestation/code/modules/brewin_and_chewin/icons/eris_kitchen.dmi'
	icon_state = "fryer"
	var/obj/item/reagent_containers/cooking_container/deep_basket/basket

/obj/machinery/deepfryer/update_icon_state()
	. = ..()
	if(basket)
		icon_state = "fryer_off"
	else
		icon_state = "fryer"

/obj/machinery/deepfryer/process(seconds_per_tick)
	..()
	if(!basket)
		return
	if(basket.tracker)
		basket.fryer_data[J_HI] += 10 * seconds_per_tick
	else
		var/datum/reagent/consumable/cooking_oil/frying_oil = reagents.has_reagent(/datum/reagent/consumable/cooking_oil)
		if(!frying_oil)
			return
		for(var/obj/item/item as anything in basket.contents)
			reagents.chem_temp = frying_oil.fry_temperature
			if(!item)
				continue

			reagents.trans_to(item, oil_use * seconds_per_tick, multiplier = fry_speed * 3) //Fried foods gain more of the reagent thanks to space magic

		cook_time += fry_speed * seconds_per_tick
		if(cook_time >= 5 SECONDS && !frying_fried)
			frying_fried = TRUE //frying... frying... fried
			playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE)
			audible_message(span_notice("[src] dings!"))
		else if (cook_time >= 12 SECONDS && !frying_burnt)
			frying_burnt = TRUE
			visible_message(span_warning("[src] emits an acrid smell!"))

		use_power(active_power_usage)

/obj/machinery/deepfryer/proc/start_fry(obj/item/frying_item, mob/user)
	to_chat(user, span_notice("You put [frying_item] into [src]."))
	if(istype(frying_item, /obj/item/freeze_cube))
		log_bomber(user, "put a freeze cube in a", src)
		visible_message(span_userdanger("[src] starts glowing... Oh no..."))
		playsound(src, 'sound/effects/pray_chaplain.ogg', 100)
		add_filter("entropic_ray", 10, list("type" = "rays", "size" = 35, "color" = COLOR_VIVID_YELLOW))
		addtimer(CALLBACK(src, PROC_REF(blow_up)), 5 SECONDS)

	// Give them reagents to put frying oil in
	if(isnull(frying_item.reagents))
		frying_item.create_reagents(50, INJECTABLE)
	if(user.mind)
		ADD_TRAIT(frying_item, TRAIT_FOOD_CHEF_MADE, REF(user.mind))
	SEND_SIGNAL(frying_item, COMSIG_ITEM_ENTERED_FRYER)

	icon_state = "fryer_on"

/obj/machinery/deepfryer/proc/reset_frying(mob/user)
	if(!basket)
		return
	for(var/obj/item/item as anything in basket.contents)
		if(!QDELETED(item) && !(item.type in GLOB.oilfry_blacklisted_items))
			item.AddElement(/datum/element/fried_item, cook_time)
	if(user)
		basket.process_item(src, user, lower_quality_on_fail=CHEWIN_BASE_QUAL_REDUCTION, send_message=TRUE)
	frying_fried = FALSE
	frying_burnt = FALSE
	fry_loop.stop()
	cook_time = 0
	icon_state = "fryer_off"

/obj/machinery/deepfryer/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon, /obj/item/reagent_containers/cooking_container/deep_basket) && !basket)
		weapon.forceMove(src)
		basket = weapon
		if (!length(basket.contents))
			frying = FALSE
			icon_state = "fryer_off"
			return

		icon_state = "fryer_on"
		frying = TRUE
		for(var/obj/item/item as anything in basket.contents)
			start_fry(item, user)
		fry_loop.start()
