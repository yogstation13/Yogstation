/obj/structure/toilet_bong
	name = "toilet bong"
	desc = "It's a toilet that's been fitted into a bong. It is used for exactly what you think it's for."
	icon = 'yogstation/icons/obj/watercloset.dmi'
	icon_state = "toiletbong"
	density = FALSE
	anchored = TRUE
	var/mutable_appearance/weed_overlay

/obj/structure/toilet_bong/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = AddComponent(/datum/component/storage/concrete)
	STR.attack_hand_interact = FALSE
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/grown/cannabis, /obj/item/reagent_containers/food/snacks/grown/tobacco))
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = WEIGHT_CLASS_SMALL * 24
	STR.max_items = 24
	RegisterSignal(STR, COMSIG_STORAGE_INSERTED, TYPE_PROC_REF(/atom/, update_icon))
	RegisterSignal(STR, COMSIG_STORAGE_REMOVED, TYPE_PROC_REF(/atom/, update_icon))
	weed_overlay = mutable_appearance('yogstation/icons/obj/watercloset.dmi', "weed")
	START_PROCESSING(SSobj, src)

/obj/structure/toilet_bong/update_overlays()
	. = ..()
	if (LAZYLEN(contents))
		. += weed_overlay

/obj/structure/toilet_bong/attack_hand(mob/user)
	. = ..()
	if (!LAZYLEN(contents))
		to_chat(user, span_warning("[src] is empty!"))
		return
	if (do_after(user, 2 SECONDS, src))
		var/obj/item/reagent_containers/boof = contents[1]
		user.visible_message(span_boldnotice("[user] takes a huge rip from [src]!"), span_boldnotice("You take a huge rip from [src]!"))
		var/smoke_spread = 1
		if (prob(15))
			user.visible_message(span_danger("[user] coughs while using [src], filling the area with smoke!"), span_userdanger("You cough while using [src], filling the area with smoke!"))
			smoke_spread = 5
		var/turf/location = get_turf(user)
		var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
		smoke.attach(location)
		smoke.set_up(smoke_spread, location = location, carry = boof.reagents, silent = TRUE)
		smoke.start()
		qdel(boof)
		update_appearance(UPDATE_ICON)

// It's a bong powered by a **flamethrower**, it's definitely an open flame!!
/obj/structure/toilet_bong/process()
	var/turf/location = get_turf(src)
	location.hotspot_expose(700,2)
