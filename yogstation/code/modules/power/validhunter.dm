/obj/machinery/power/validhunter_engine
	name = "validhunter engine"
	desc = "What is treason? Captain don't hurt me."
	icon = 'yogstation/icons/obj/validhunter_engine.dmi'
	icon_state = "throw_me_in_the_trash_and_feed_my_remains_to_the_devil"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE

	var/power_per_antag = 10000000 // 100MW
	var/operating = FALSE //Is it on?
	var/gibtime = 40 // Time from starting until done

/obj/machinery/power/validhunter_engine/Initialize()
	connect_to_network()
	return ..()

/obj/machinery/power/validhunter_engine/update_icon()
	if(operating)
		icon_state = "throw_me_in_the_trash_and_feed_my_remains_to_the_devil_operating"
	else
		icon_state = initial(icon_state)

/obj/machinery/power/validhunter_engine/wrench_act(mob/living/user, obj/item/I)
	if(!anchored && !isinspace())
		connect_to_network()
		to_chat(user, span_notice("You secure [src] to the floor."))
		anchored = TRUE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	else if(anchored)
		if(operating)
			to_chat(user, span_warning("You can't detach [src] from the floor, it's holding on too tightly!"))
			return TRUE

		disconnect_from_network()
		to_chat(user, span_notice("You unsecure [src] from the floor."))
		anchored = FALSE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)

	return TRUE

/obj/machinery/power/validhunter_engine/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return

	obj_flags |= EMAGGED
	to_chat(user, span_warning("You overload the syndicate chip."))

/obj/machinery/power/validhunter_engine/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	
	if(operating)
		to_chat(user, span_danger("It's locked and running."))
		return

	if(!anchored)
		to_chat(user, span_notice("[src] cannot be used unless bolted to the ground."))
		return
	
	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled ||L.has_buckled_mobs())
			to_chat(user, span_warning("[L] is attached to something!"))
			return

		user.visible_message(span_danger("[user] starts to put [L] into the engine!"))
		add_fingerprint(user)
		if(do_after(user, gibtime, src))
			if(L && user.pulling == L && !L.buckled && !L.has_buckled_mobs())
				user.visible_message(span_danger("[user] stuffs [L] into the engine!"))
				process_mob(L, user)

/obj/machinery/power/validhunter_engine/proc/process_mob(mob/living/L, mob/user)
	operating = TRUE
	update_icon()
	
	playsound(src.loc, 'sound/machines/terminal_on.ogg', 50, 1)
	L.forceMove(src)
	visible_message(span_italics("You hear a loud squelchy grinding sound."))
	playsound(src.loc, 'sound/machines/juicer.ogg', 50, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.02 SECONDS, loop = 200) //start shaking
	
	var/do_gib = FALSE
	var/emagged = obj_flags & EMAGGED
	if(L.mind && LAZYLEN(L.mind.antag_datums))
		if(!emagged)
			do_gib = TRUE
	else
		if(emagged)
			do_gib = TRUE
			
	if(!do_gib)
		addtimer(CALLBACK(src, .proc/fake_gib, L), gibtime)
		return
	
	var/sourcenutriment = L.nutrition / 15
	var/gibtype = /obj/effect/decal/cleanable/blood/gibs
	var/meat_produced = rand(1, 3)
	var/sourcename = L.real_name
	var/typeofmeat = /obj/item/reagent_containers/food/snacks/meat/slab/human
	var/typeofskin
	
	var/obj/item/reagent_containers/food/snacks/meat/slab/allmeat[meat_produced]
	var/obj/item/stack/sheet/animalhide/skin
	var/list/datum/disease/diseases = L.get_static_viruses()
	
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.dna && H.dna.species)
			typeofmeat = H.dna.species.meat
			typeofskin = H.dna.species.skinned_type

	else if(iscarbon(L))
		var/mob/living/carbon/C = L
		typeofmeat = C.type_of_meat
		gibtype = C.gib_type
		if(ismonkey(C))
			typeofskin = /obj/item/stack/sheet/animalhide/monkey
		else if(isalien(C))
			typeofskin = /obj/item/stack/sheet/animalhide/xeno

	for (var/i = 1 to meat_produced)
		var/obj/item/reagent_containers/food/snacks/meat/slab/newmeat = new typeofmeat
		newmeat.name = "[sourcename] [newmeat.name]"
		if(istype(newmeat))
			newmeat.subjectname = sourcename
			newmeat.reagents.add_reagent ("nutriment", sourcenutriment / meat_produced) // Thehehe. Fat guys go first
		allmeat[i] = newmeat

	if(typeofskin)
		skin = new typeofskin
	
	log_combat(user, occupant, "gibbed")
	L.(1)
	L.ghostize()
	qdel(L)
	addtimer(CALLBACK(src, .proc/gib_antag, skin, allmeat, meat_produced, gibtype, diseases), gibtime)

/obj/machinery/power/validhunter_engine/proc/gib_antag(obj/item/stack/sheet/animalhide/skin, list/obj/item/reagent_containers/food/snacks/meat/slab/allmeat, meat_produced, gibtype, list/datum/disease/diseases)
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
	add_avail(power_per_antag)
	var/turf/T = get_turf(src)
	var/list/turf/nearby_turfs = RANGE_TURFS(3,T) - T
	if(skin)
		skin.forceMove(loc)
		skin.throw_at(pick(nearby_turfs), meat_produced, 3)

	for (var/i = 1 to meat_produced)
		var/obj/item/meatslab = allmeat[i]
		meatslab.forceMove(loc)
		meatslab.throw_at(pick(nearby_turfs),i,3)
		for (var/turfs=1 to meat_produced)
			var/turf/gibturf = pick(nearby_turfs)
			if (!gibturf.density && (src in view(gibturf)))
				new gibtype(gibturf,i,diseases)

	pixel_x = initial(pixel_x) //return to its spot after shaking
	operating = FALSE
	update_icon()

/obj/machinery/power/validhunter_engine/proc/fake_gib(mob/living/L)
	playsound(src.loc, 'sound/machines/terminal_off.ogg', 50, 1)
	visible_message(span_warning("The machine spits the inhabitant back out."))
	dropContents()

	operating = FALSE
	update_icon()
	
