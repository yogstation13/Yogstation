/obj/machinery/composters
	name = "NT-Brand Auto Composter"
	desc = "Just insert your bio degradable materials and it will produce compost."
	icon = 'monkestation/icons/obj/machines/composter.dmi'
	icon_state = "composter"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/composters

	/// Current level of biomatter in the composter.
	var/biomatter = 0
	/// The amount of biomatter needed to make 1 biocube.
	var/biocube_cost = 40

/obj/machinery/composters/Initialize(mapload)
	. = ..()
	if(mapload)
		biomatter = 80

/obj/machinery/composters/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(istype(attacking_item, /obj/item/seeds))
		compost(attacking_item)

	if(istype(attacking_item, /obj/item/food))
		compost(attacking_item)

	if(istype(attacking_item, /obj/item/storage/bag)) // covers any kind of bag that has a compostible item
		var/obj/item/storage/bag/bag = attacking_item
		var/list/to_compost
		for(var/item in bag.contents)
			if(!istype(item, /obj/item/food) && !istype(item, /obj/item/seeds))
				continue
			if(bag.atom_storage.attempt_remove(item, src))
				LAZYADD(to_compost, item)
			CHECK_TICK
		if(to_compost)
			compost(to_compost)
		to_chat(user, span_info("You empty \the [bag] into \the [src]."))

/obj/machinery/gibber/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/machinery/composters/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(user.pulling && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(!(obj_flags & EMAGGED))
			to_chat(user, span_warning("Safeties prevent the composting of living beings!"))
			return
		if(!iscarbon(L))
			to_chat(user, span_warning("This item is not suitable for [src]!"))
			return
		var/mob/living/carbon/C = L
		if(C.buckled || C.has_buckled_mobs())
			to_chat(user, span_warning("[C] is attached to something!"))
			return

		for(var/obj/item/I in C.held_items + C.get_equipped_items())
			if(!HAS_TRAIT(I, TRAIT_NODROP))
				to_chat(user, span_warning("Subject may not have abiotic items on!"))
				return

		user.visible_message(span_danger("[user] starts to put [C] into [src]!"))

		add_fingerprint(user)

		if(do_after(user, 8 SECONDS, target = src))
			if(C && user.pulling == C && !C.buckled && !C.has_buckled_mobs() && !occupant)
				user.visible_message(span_danger("[user] stuffs [C] into [src]!"))
				compost(C, allow_carbons = TRUE)

	if(biomatter < biocube_cost)
		to_chat(user, span_notice("Not enough biomatter to produce Bio-Cube"))
		return
	new /obj/item/stack/biocube(drop_location(), 1)
	biomatter -= biocube_cost
	update_desc()
	update_appearance()

/obj/machinery/composters/update_desc()
	. = ..()
	desc = "Just insert your bio degradable materials and it will produce compost."
	desc += "\nBiomatter: [biomatter]"

/obj/machinery/composters/update_overlays()
	. = ..()
	if(biomatter < 40)
		. += mutable_appearance('monkestation/icons/obj/machines/composter.dmi', "light_off", layer = OBJ_LAYER + 0.01)
	else
		. += mutable_appearance('monkestation/icons/obj/machines/composter.dmi', "light_on", layer = OBJ_LAYER + 0.01)

/obj/machinery/composters/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, "composter_open", "composter", tool)

/obj/machinery/composters/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool))
		return ..()

/obj/machinery/composters/proc/compost(list/composting, allow_carbons = FALSE)
	if(!islist(composting))
		composting = list(composting)
	var/biomatter_added = 0
	var/yucky = FALSE
	for(var/atom/movable/composter as anything in composting)
		if(istype(composter, /obj/item/seeds))
			biomatter_added++
			qdel(composter)
		else if(istype(composter, /obj/item/food))
			biomatter_added += 5
			qdel(composter)
		else if(istype(composter, /mob/living/carbon) && allow_carbons)
			var/mob/living/carbon/carbon_target = composter
			if(carbon_target.stat != DEAD)
				continue
			yucky = TRUE
			biomatter_added += biocube_cost
			INVOKE_ASYNC(carbon_target, TYPE_PROC_REF(/mob/living/carbon, gib))
		CHECK_TICK
	if(!biomatter_added)
		return
	biomatter += biomatter_added
	if(yucky)
		playsound(loc, 'sound/machines/juicer.ogg', vol = 50, vary = TRUE)
		audible_message(span_hear("You hear a loud squelchy grinding sound."))
	update_desc()
	update_appearance()
	flick("composter_animate", src)

/obj/machinery/composters/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "safeties overriden")
	return TRUE

/obj/item/seeds/MouseDrop(atom/over, atom/src_location, over_location, src_control, over_control, params)
	. = ..()
	// ensure user is next to what we're mouse dropping into
	if(!Adjacent(usr, over) || !istype(src_location))
		return
	// ensure the stuff we're mouse dropping is ALSO adjacent
	var/obj/machinery/composters/dropped = over
	if(istype(dropped) && Adjacent(src_location, over_location))
		dropped.compost(src_location.contents)

/obj/item/food/MouseDrop(atom/over, atom/src_location, over_location, src_control, over_control, params)
	. = ..()
	// ensure user is next to what we're mouse dropping into
	if(!Adjacent(usr, over) || !istype(src_location))
		return
	// ensure the stuff we're mouse dropping is ALSO adjacent
	var/obj/machinery/composters/dropped = over
	if(istype(dropped) && Adjacent(src_location, over_location))
		dropped.compost(src_location.contents)

/obj/item/stack/biocube
	name = "biocube"
	desc = "A cube made of pure biomatter, it does wonders on plant trays."
	icon = 'monkestation/icons/obj/misc.dmi'
	icon_state = "bio_cube"
	singular_name = "biocube"
	max_amount = 20
	item_flags = parent_type::item_flags | NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	full_w_class = WEIGHT_CLASS_SMALL
	merge_type = /obj/item/stack/biocube
	/// The base amount of time a single biocube boosts for.
	var/base_time = 1 MINUTES

/obj/item/stack/biocube/examine(mob/user)
	. = ..()
	. += span_info("It will boost plant growth for <b>[DisplayTimeText(boost_time())]</b>.")

/obj/item/stack/biocube/pre_attack(atom/target, mob/living/user, params)
	if(SEND_SIGNAL(target, COMSIG_ATTEMPT_BIOBOOST, boost_time()))
		qdel(src)
		return TRUE
	return ..()

/// Returns the amount of time (in deciseconds) the applied bio-boost will last for.
/obj/item/stack/biocube/proc/boost_time()
	return round(amount * base_time)

/obj/item/stack/biocube/five
	amount = 5

/obj/item/stack/biocube/twenty
	amount = 20
