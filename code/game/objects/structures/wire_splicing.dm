/obj/structure/wire_splicing
	name = "wire splicing"
	desc = "Looks like someone was very drunk when doing this, or just didn't care. This can be removed by wirecutters."
	icon = 'icons/obj/traps.dmi'
	icon_state = "wire_splicing1"
	density = FALSE
	anchored = TRUE
	flags_1 = CONDUCT_1
	layer = CATWALK_LAYER
	var/messiness = 0 // How bad the splicing was, determines the chance of shock

/obj/structure/wire_splicing/Initialize(mapload)
	. = ..()
	messiness = rand (1,10)
	icon_state = "wire_splicing[messiness]"
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


	//At messiness of 2 or below, triggering when walking on a catwalk is impossible
	//Above that it becomes possible, so we will change the layer to make it poke through catwalks
	if (messiness > 2)
		layer = LOW_OBJ_LAYER  // I wont do such stuff on splicing "reinforcement". Take it as nasty feature


	//Wire splice can only exist on a cable. Lets try to place it in a good location
	if (locate(/obj/structure/cable) in get_turf(src)) //if we're already in a good location, no problem!
		return

	//Make a list of turfs with cables in them
	var/list/candidates = list()

	//We will give each turf a score to determine its suitability
	var/best_score = -INFINITY
	for(var/obj/structure/cable/C in range(3, get_turf(src)))
		var/turf/open/T = get_turf(C)

		//Wire inside a wall? can't splice there
		if (!istype(T))
			continue

		//We already checked this one
		if (T in candidates)
			continue

		var/turf_score = 0

		//Nobody walks on underplating so we don't want to place traps there

		if (T.initial_gas_mix == AIRLESS_ATMOS)
			continue //No traps in space

		/*
		//Catwalks are made for walking on, we definitely want traps there
		if (locate(/obj/structure/catwalk) in T)
			turf_score += 2
		*/

		//If its below the threshold ignore it
		if (turf_score < best_score)
			continue

		//If it sets a new threshold, discard everything before
		else if (turf_score > best_score)
			best_score = turf_score
			candidates.Cut()

		candidates.Add(T)

	//No nearby cables? Cancel
	if (!length(candidates))
		return INITIALIZE_HINT_QDEL

	loc = pick(candidates)

/obj/structure/wire_splicing/examine(mob/user)
	. = ..()
	if(is_syndicate(user))
		. += span_warning("or you could add more wires..!")
	. += "It has [messiness] wire[messiness > 1?"s":""] dangling around."

/obj/structure/wire_splicing/proc/on_entered(datum/source, atom/movable/AM, ...)
	if(isliving(AM))
		var/mob/living/L = AM
		//var/turf/T = get_turf(src)
		var/chance_to_shock = messiness * 10
		/*
		if(locate(/obj/structure/catwalk) in T)
			chance_to_shock -= 20
		*/
		shock(L, chance_to_shock)

/obj/structure/wire_splicing/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return FALSE
	if(!prob(prb))
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = locate(/obj/structure/cable) in T
	if(!C)
		return FALSE
	if(electrocute_mob(user, C.powernet, src, siemens_coeff, zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)))
		do_sparks(5, TRUE, src)
		return TRUE
	else
		return FALSE

		

/obj/structure/wire_splicing/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER)
		if(I.use_tool(src, user, 2 SECONDS, volume = 50))
			if (shock(user, 50))
				return
			user.visible_message("[user] cuts the splicing.", span_notice("You cut the splicing."))
			investigate_log(" was cut by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
			var/turf/T = get_turf(src)
			var/obj/structure/cable/C = locate() in T
			var/new_color = C?.cable_color || pick(GLOB.cable_colors)
			new /obj/item/stack/cable_coil(T, messiness, new_color)
			qdel(src)

	if(istype(I, /obj/item/stack/cable_coil) && user.a_intent == INTENT_HARM)
		var/obj/item/stack/cable_coil/coil = I
		if(coil.get_amount() >= 1)
			reinforce(user, coil)

/obj/structure/wire_splicing/proc/reinforce(mob/user, obj/item/stack/cable_coil/coil)
	if(messiness >= 10)
		to_chat(user,span_warning("You can't seem to jam more cable into the splicing!"))
		return
	if(do_after(user, 2 SECONDS, src))
		if (shock(user, 50))
			return
		messiness = min(messiness + 1, 10)
		icon_state = "wire_splicing[messiness]"
		investigate_log("wire splicing was reinforced to [messiness] by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
		user.visible_message("[user] tucks more wires into the splicing.", span_notice("You add more cables to the splicing."))
		coil.use(1)
		if(messiness < 10 && coil && coil.get_amount() >= 1)
			reinforce(user, coil)
