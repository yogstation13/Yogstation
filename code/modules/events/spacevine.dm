/datum/round_event_control/spacevine
	name = "Space Vines"
	typepath = /datum/round_event/spacevine
	weight = 15
	max_occurrences = 1
	min_players = 25
	description = "Kudzu begins to overtake the station. Might spawn man-traps."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7
	admin_setup = list(
		/datum/event_admin_setup/set_location/spacevine,
		/datum/event_admin_setup/multiple_choice/spacevine,
		/datum/event_admin_setup/input_number/spacevine_potency,
		/datum/event_admin_setup/input_number/spacevine_production,
	)
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_ALIEN)
	checks_antag_cap = TRUE
	event_group = /datum/event_group/guests

/datum/round_event/spacevine
	fakeable = FALSE
	///Override location the vines will spawn in.
	var/turf/override_turf
	///used to confirm if admin selected mutations should be used or not.
	var/mutations_overridden = FALSE
	///Admin selected mutations that the kudzu will spawn with, can be set to none to act as mutationless kudzu.
	var/list/override_mutations = list()
	///Potency of the spawned kudzu.
	var/potency
	///Production value of the spawned kuduz.
	var/production

/datum/round_event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas


	if(override_turf)
		turfs += override_turf
	else
		var/obj/structure/spacevine/vine = new()

		for(var/area/hallway/area in GLOB.areas)
			for(var/turf/open/floor in area.get_turfs_from_all_zlevels())
				if(floor.Enter(vine))
					turfs += floor

		qdel(vine)

	if(length(turfs)) //Pick a turf to spawn at if we can
		var/turf/floor = pick(turfs)
		var/list/selected_mutations = list()

		if(mutations_overridden == FALSE)
			selected_mutations = list(pick(subtypesof(/datum/spacevine_mutation)))
		else
			selected_mutations = override_mutations
		if(isnull(potency))
			potency = rand(50,100)
		if(isnull(production))
			production = rand(1, 4)

		new /datum/spacevine_controller(floor, selected_mutations, potency, production, src) //spawn a controller at turf with randomized stats and a single random mutation

/datum/event_admin_setup/set_location/spacevine
	input_text = "Spawn vines at current location?"

/datum/event_admin_setup/set_location/spacevine/apply_to_event(datum/round_event/spacevine/event)
	event.override_turf = chosen_turf

/datum/event_admin_setup/multiple_choice/spacevine
	input_text = "Select starting mutations."
	min_choices = 0

/datum/event_admin_setup/multiple_choice/spacevine/prompt_admins()
	var/customize_mutations = tgui_alert(usr, "Select mutations?", event_control.name, list("Custom", "Random", "Cancel"))
	switch(customize_mutations)
		if("Custom")
			return ..()
		if("Random")
			choices = list("[pick(subtypesof(/datum/spacevine_mutation))]")
		else
			return ADMIN_CANCEL_EVENT

/datum/event_admin_setup/multiple_choice/spacevine/get_options()
	return subtypesof(/datum/spacevine_mutation/)

/datum/event_admin_setup/multiple_choice/spacevine/apply_to_event(datum/round_event/spacevine/event)
	var/list/type_choices = list()
	for(var/choice in choices)
		type_choices += text2path(choice)
	event.mutations_overridden = TRUE
	event.override_mutations = type_choices

/datum/event_admin_setup/input_number/spacevine_potency
	input_text = "Set vine's potency (effects mutation frequency + max severity)"
	max_value = 100

/datum/event_admin_setup/input_number/spacevine_potency/prompt_admins()
	default_value = rand(50, 100)
	return ..()

/datum/event_admin_setup/input_number/spacevine_potency/apply_to_event(datum/round_event/spacevine/event)
	event.potency = chosen_value

/datum/event_admin_setup/input_number/spacevine_production
	input_text = "Set vine's production (effects spreading cap + speed) (lower is faster)"
	min_value = 1
	max_value = 10

/datum/event_admin_setup/input_number/spacevine_production/prompt_admins()
	default_value = rand(1, 4)
	return ..()

/datum/event_admin_setup/input_number/spacevine_production/apply_to_event(datum/round_event/spacevine/event)
	event.production = chosen_value


/datum/spacevine_mutation
	var/name = ""
	var/severity = 1
	var/hue
	var/quality

/datum/spacevine_mutation/proc/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	holder.mutations |= src
	holder.add_atom_colour(hue, FIXED_COLOUR_PRIORITY)

/datum/spacevine_mutation/proc/process_mutation(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_birth(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_grow(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_death(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	return expected_damage

/datum/spacevine_mutation/proc/on_cross(obj/structure/spacevine/holder, mob/crosser)
	return

/datum/spacevine_mutation/proc/on_chem(obj/structure/spacevine/holder, datum/reagent/R)
	return

/datum/spacevine_mutation/proc/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	return

/datum/spacevine_mutation/proc/on_spread(obj/structure/spacevine/holder, turf/target)
	return

/datum/spacevine_mutation/proc/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	return

/datum/spacevine_mutation/proc/on_explosion(severity, target, obj/structure/spacevine/holder)
	return


/datum/spacevine_mutation/light
	name = "light"
	hue = "#ffff00"
	quality = POSITIVE
	severity = 4

/datum/spacevine_mutation/light/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.set_light(severity, 0.3)

/datum/spacevine_mutation/toxicity
	name = "toxic"
	hue = "#ff00ff"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/toxicity/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(prob(severity) && istype(crosser) && !isvineimmune(crosser) && crosser.can_inject(crosser, FALSE, BODY_ZONE_CHEST))
		to_chat(crosser, span_alert("You accidentally touch the vine and feel a strange sensation."))
		crosser.apply_damage(5, TOX, null, crosser.getarmor(null, BIO))

/datum/spacevine_mutation/toxicity/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	if(!isvineimmune(eater))
		eater.apply_damage(5, TOX, null, eater.getarmor(null, BIO))

/datum/spacevine_mutation/explosive  //OH SHIT IT CAN CHAINREACT RUN!!!
	name = "explosive"
	hue = "#ff0000"
	quality = NEGATIVE
	severity = 2

/datum/spacevine_mutation/explosive/on_explosion(explosion_severity, target, obj/structure/spacevine/holder)
	if(explosion_severity < 3)
		qdel(holder)
	else
		. = 1
		QDEL_IN(holder, 5)

/datum/spacevine_mutation/explosive/on_death(obj/structure/spacevine/holder, mob/hitter, obj/item/I)
	explosion(holder.loc, 0, 0, severity, 0, 0)

/datum/spacevine_mutation/fire_proof
	name = "fire proof"
	hue = "#ff8888"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/fire_proof/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	. = ..()
	holder.extinguish()
	holder.resistance_flags |= FIRE_PROOF

/datum/spacevine_mutation/fire_proof/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/weapon, expected_damage)
	if(weapon?.damtype == BURN)
		return expected_damage * 0.5
	return expected_damage

/datum/spacevine_mutation/vine_eating
	name = "vine eating"
	hue = "#ff7700"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/vine_eating/on_spread(obj/structure/spacevine/holder, turf/target)
	var/obj/structure/spacevine/prey = locate() in target
	if(prey && !prey.mutations.Find(src))  //Eat all vines that are not of the same origin
		qdel(prey)

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "aggressive spreading"
	hue = "#333333"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/aggressive_spread/on_spread(obj/structure/spacevine/holder, turf/target)
	for(var/atom/destructible_atom in target)
		if(isliving(destructible_atom)) // living things need to be handled differently
			var/mob/living/victim = destructible_atom
			if(isvineimmune(victim))
				continue
			if(!victim.can_inject(null, FALSE))
				continue
			victim.apply_damage(5, BRUTE, null, victim.getarmor(null, BIO))
			continue

		if(!destructible_atom.uses_integrity)
			continue // skip anything that isn't destructible
		if(destructible_atom.layer < ABOVE_NORMAL_TURF_LAYER)
			continue // don't bother with stuff under the floors
		destructible_atom.ex_act(severity, target)

/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	if(isvineimmune(buckled))
		return
	if(!buckled.can_inject(null, FALSE))
		return
	buckled.apply_damage(10, BRUTE, null, buckled.getarmor(null, BIO))

/datum/spacevine_mutation/transparency
	name = "transparent"
	hue = ""
	quality = POSITIVE

/datum/spacevine_mutation/transparency/on_grow(obj/structure/spacevine/holder)
	holder.set_opacity(0)
	holder.alpha = 125

/datum/spacevine_mutation/oxy_eater
	name = "oxygen consuming"
	hue = "#ffff88"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/oxy_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.set_moles(GAS_O2, max(GM.get_moles(GAS_O2) - severity * holder.energy, 0))

/datum/spacevine_mutation/nitro_eater
	name = "nitrogen consuming"
	hue = "#8888ff"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/nitro_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.set_moles(GAS_N2, max(GM.get_moles(GAS_N2) - severity * holder.energy, 0))

/datum/spacevine_mutation/carbondioxide_eater
	name = "CO2 consuming"
	hue = "#00ffff"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/carbondioxide_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.set_moles(GAS_CO2, max(GM.get_moles(GAS_CO2) - severity * holder.energy, 0))

/datum/spacevine_mutation/plasma_eater
	name = "toxins consuming"
	hue = "#ffbbff"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/plasma_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.set_moles(GAS_PLASMA, max(GM.get_moles(GAS_PLASMA) - severity * holder.energy, 0))

/datum/spacevine_mutation/thorns
	name = "thorny"
	hue = "#666666"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(severity) && istype(crosser) && !isvineimmune(crosser) && crosser.can_inject(crosser, FALSE, BODY_ZONE_CHEST))
		crosser.apply_damage(5, BRUTE, null, crosser.getarmor(null, BIO), sharpness = SHARP_POINTY)
		to_chat(crosser, span_alert("You cut yourself on the thorny vines."))

/datum/spacevine_mutation/thorns/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	. =	expected_damage
	// carbons have arms
	var/obj/item/bodypart/arm_used = iscarbon(hitter) ? hitter.has_hand_for_held_index(hitter.active_hand_index) : null
	if(prob(severity) && istype(hitter) && !isvineimmune(hitter) && hitter.can_inject(hitter, FALSE, arm_used?.body_zone))
		// thick gloves protect you
		var/obj/item/clothing/glove_protection = hitter.get_item_by_slot(ITEM_SLOT_GLOVES)
		if(isclothing(glove_protection) && (glove_protection.clothing_flags & THICKMATERIAL))
			return
		// check bio protection
		hitter.apply_damage(5, BRUTE, arm_used?.body_zone, hitter.getarmor(arm_used?.body_zone, BIO), sharpness = SHARP_POINTY)
		to_chat(hitter, span_alert("You cut yourself on the thorny vines."))

/datum/spacevine_mutation/woodening
	name = "hardened"
	hue = "#997700"
	quality = NEGATIVE

/datum/spacevine_mutation/woodening/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.density = TRUE
	holder.max_integrity = 100
	holder.update_integrity(holder.max_integrity)

/datum/spacevine_mutation/woodening/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(I.is_sharp())
		return expected_damage * 0.5
	return expected_damage

/datum/spacevine_mutation/flowering
	name = "flowering"
	hue = "#0A480D"
	quality = NEGATIVE
	severity = 10

/datum/spacevine_mutation/flowering/on_grow(obj/structure/spacevine/holder)
	if(holder.energy == 2 && prob(severity) && !locate(/obj/structure/alien/resin/flower_bud_enemy) in range(5,holder))
		new/obj/structure/alien/resin/flower_bud_enemy(get_turf(holder))

/datum/spacevine_mutation/flowering/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(25))
		holder.entangle(crosser)


// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	density = FALSE
	layer = SPACEVINE_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE //Clicking anywhere on the turf is good enough
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 50
	var/energy = 0
	var/datum/spacevine_controller/master = null
	var/list/mutations = list()

/obj/structure/spacevine/Initialize(mapload)
	. = ..()
	add_atom_colour("#ffffff", FIXED_COLOUR_PRIORITY)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	RegisterSignal(src, COMSIG_ATOM_CLEAVE_ATTACK, PROC_REF(on_cleave_attack))

/obj/structure/spacevine/proc/on_cleave_attack()
	return ATOM_ALLOW_CLEAVE_ATTACK // vines don't have density but should still be cleavable

/obj/structure/spacevine/examine(mob/user)
	. = ..()
	var/text = "This one is a"
	if(mutations.len)
		for(var/A in mutations)
			var/datum/spacevine_mutation/SM = A
			text += " [SM.name]"
	else
		text += " normal"
	text += " vine."
	. += text

/obj/structure/spacevine/Destroy()
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_death(src)
	if(master)
		master.VineDestroyed(src)
	mutations = list()
	set_opacity(0)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force=1)
	return ..()

/obj/structure/spacevine/proc/on_chem_effect(datum/reagent/R)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_chem(src, R)
	if(!override && istype(R, /datum/reagent/toxin/plantbgone))
		if(prob(50))
			qdel(src)

/obj/structure/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_eat(src, eater)
	if(!override)
		qdel(src)

/obj/structure/spacevine/attacked_by(obj/item/I, mob/living/user)
	var/damage_dealt = I.force
	if(I.is_sharp())
		damage_dealt *= 4
	if(I.damtype == BURN)
		damage_dealt *= 4

	for(var/datum/spacevine_mutation/SM in mutations)
		damage_dealt = SM.on_hit(src, user, I, damage_dealt) //on_hit now takes override damage as arg and returns new value for other mutations to permutate further
	take_damage(damage_dealt, I.damtype, MELEE, 1)

/obj/structure/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/spacevine/proc/on_entered(datum/source, atom/movable/AM, ...)
	if(!isliving(AM))
		return
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_cross(src, AM)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/spacevine/attack_hand(mob/user)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	if(buckled_mobs?.len)
		user_unbuckle_mob(buckled_mobs[1], user)
	return ..()

/obj/structure/spacevine/attack_paw(mob/living/user)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user,user)

/obj/structure/spacevine/attack_alien(mob/living/user)
	eat(user)

/datum/spacevine_controller
	var/list/obj/structure/spacevine/vines
	var/list/growth_queue
	var/spread_multiplier = 2
	var/spread_cap = 30
	var/list/vine_mutations_list
	var/mutativeness = 1

/datum/spacevine_controller/New(turf/location, list/muts, potency, production, datum/round_event/event = null)
	vines = list()
	growth_queue = list()
	var/obj/structure/spacevine/SV = spawn_spacevine_piece(location, null, muts)
	if (event)
		event.announce_to_ghosts(SV)
	START_PROCESSING(SSobj, src)
	vine_mutations_list = list()
	init_subtypes(/datum/spacevine_mutation/, vine_mutations_list)
	if(potency != null)
		mutativeness = potency / 10
	if(production != null)
		spread_cap *= production / 5
		spread_multiplier *= 2 / (5 + production)

/datum/spacevine_controller/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_SEPERATOR
	VV_DROPDOWN_OPTION(VV_HK_SPACEVINE_PURGE, "Delete Vines")

/datum/spacevine_controller/vv_do_topic(href_list)
	. = ..()
	if(href_list[VV_HK_SPACEVINE_PURGE])
		if(tgui_alert(usr, "Are you sure you want to delete this spacevine cluster?", "Delete Vines", list("Yes", "No")) == "Yes")
			DeleteVines()

/datum/spacevine_controller/proc/DeleteVines()	//this is kill
	QDEL_LIST(vines)	//this will also qdel us

/datum/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/obj/structure/spacevine/new_vine = new(location)
	growth_queue += new_vine
	vines += new_vine
	new_vine.master = src
	if(muts && muts.len)
		for(var/datum/spacevine_mutation/M in muts)
			M.add_mutation_to_vinepiece(new_vine)
		return
	if(parent)
		new_vine.mutations |= parent.mutations
		var/parentcolor = parent.atom_colours[FIXED_COLOUR_PRIORITY]
		new_vine.add_atom_colour(parentcolor, FIXED_COLOUR_PRIORITY)
		if(prob(mutativeness))
			var/datum/spacevine_mutation/random_mutate = pick(vine_mutations_list - new_vine.mutations)
			random_mutate.add_mutation_to_vinepiece(new_vine)

	for(var/datum/spacevine_mutation/vine_mutation in new_vine.mutations)
		vine_mutation.on_birth(new_vine)

	var/datum/gas_mixture/turf_air = location.return_air()
	new_vine.temperature_expose(turf_air, turf_air.return_temperature(), turf_air.return_volume())
	if(QDELETED(new_vine)) // it already died from the environment
		return

	location.Entered(new_vine)
	return new_vine

/datum/spacevine_controller/proc/VineDestroyed(obj/structure/spacevine/S)
	S.master = null
	vines -= S
	growth_queue -= S
	if(!vines.len)
		var/obj/item/seeds/kudzu/KZ = new(S.loc)
		KZ.mutations |= S.mutations
		KZ.set_potency(mutativeness * 10)
		KZ.set_production((spread_cap / initial(spread_cap)) * 5)
		qdel(src)

/datum/spacevine_controller/process(delta_time)
	if(!LAZYLEN(vines))
		qdel(src) //space vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return

	var/length = round(clamp(delta_time * 0.5 * vines.len / spread_multiplier, 1, spread_cap))
	var/i = 0
	var/list/obj/structure/spacevine/queue_end = list()

	for(var/obj/structure/spacevine/SV in growth_queue)
		if(QDELETED(SV))
			continue
		i++
		queue_end += SV
		growth_queue -= SV
		for(var/datum/spacevine_mutation/SM in SV.mutations)
			SM.process_mutation(SV)
		if(SV.energy < 2) //If tile isn't fully grown
			if(DT_PROB(10, delta_time))
				SV.grow()
		else //If tile is fully grown
			SV.entangle_mob()

		SV.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/obj/structure/spacevine/proc/grow()
	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		set_opacity(1)
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_grow(src)

/obj/structure/spacevine/proc/entangle_mob()
	if(!has_buckled_mobs() && prob(25))
		for(var/mob/living/V in src.loc)
			entangle(V)
			if(has_buckled_mobs())
				break //only capture one mob at a time


/obj/structure/spacevine/proc/entangle(mob/living/V)
	if(!V || isvineimmune(V))
		return
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_buckle(src, V)
	if((V.stat != DEAD) && (V.buckled != src)) //not dead or captured
		to_chat(V, span_danger("The vines [pick("wind", "tangle", "tighten")] around you!"))
		buckle_mob(V, 1)

/obj/structure/spacevine/proc/spread()
	// check adjacent turfs if this vine can spread to it
	var/list/valid_turfs = list()
	var/turf/turf_candidate
	for(var/direction in GLOB.cardinals_multiz)
		turf_candidate = get_step_multiz(src, direction)
		if(!turf_candidate) // nowhere to go in that direction
			continue
		turf_candidate ||= can_z_move(DOWN, turf_candidate, z_move_flags = ZMOVE_FALL_FLAGS|ZMOVE_ALLOW_ANCHORED)
		if(!can_spread_to(turf_candidate))
			continue
		valid_turfs |= turf_candidate

	// no valid turfs
	if(!valid_turfs.len)
		return

	// spread onto one of the valid turfs
	INVOKE_ASYNC(src, PROC_REF(spread_to_turf), pick(valid_turfs))

/// Checks whether this vine can spread to the given turf
/obj/structure/spacevine/proc/can_spread_to(turf/turf_candidate)
	if(isclosedturf(turf_candidate) || isspaceturf(turf_candidate)) // absolutely not
		return FALSE

	if(islava(turf_candidate) && !(resistance_flags & LAVA_PROOF))
		return FALSE // don't bother with lava unless we're resistant

	var/area/turf_area = get_area(turf_candidate)
	if(!turf_area.blob_allowed) // no growing outside the station
		return FALSE
	
	var/turf/starting_turf = get_turf(src)
	if(isgroundlessturf(starting_turf) && isgroundlessturf(turf_candidate)) // can bridge a 1 tile gap at most
		return FALSE

	var/obj/machinery/door/blocked_door = locate(/obj/machinery/door) in turf_candidate
	if(blocked_door && !(blocked_door.welded || blocked_door.locked)) // a door to be opened
		return TRUE

	if(!(turf_candidate.Enter(src, TRUE) && starting_turf.Exit(src, turf_candidate))) // blocked by something
		return FALSE

	return TRUE

/// Creates a new spacevine on a given turf
/obj/structure/spacevine/proc/spread_to_turf(turf/stepturf)
	var/obj/machinery/door/the_door = locate(/obj/machinery/door) in stepturf
	var/obj/structure/spacevine/existing_vine = locate(/obj/structure/spacevine) in stepturf

	if(the_door && !existing_vine) // open the door!
		if(the_door.density && istype(the_door, /obj/machinery/door/airlock))
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, 1)
			sleep(6 SECONDS)
		if(QDELETED(src))
			return
		if(!can_spread_to(stepturf))
			return
		the_door.open()

	for(var/datum/spacevine_mutation/mutation as anything in mutations)
		mutation.on_spread(src, stepturf)
	if(!existing_vine || QDELETED(existing_vine))
		var/obj/structure/spacevine/new_vine = master.spawn_spacevine_piece(stepturf, src)
		if(the_door && (new_vine && !QDELETED(new_vine)))
			var/turf/second_step = get_step_multiz(stepturf, get_dir(get_turf(src), stepturf))
			if(second_step && can_spread_to(second_step)) // vines need a bit of help to get through doors properly
				sleep(2 SECONDS)
				if(QDELETED(new_vine) || QDELETED(src))
					return
				if(!can_spread_to(second_step))
					return
				new_vine.spread_to_turf(second_step)

/obj/structure/spacevine/ex_act(severity, target)
	if(istype(target, type)) //if its agressive spread vine dont do anything
		return
	var/i
	for(var/datum/spacevine_mutation/SM in mutations)
		i += SM.on_explosion(severity, target, src)
	if(!i && prob(100/severity))
		qdel(src)

/obj/structure/spacevine/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST && !(resistance_flags & FIRE_PROOF))
		qdel(src)

/obj/structure/spacevine/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isvineimmune(mover))
		return TRUE

/proc/isvineimmune(atom/A)
	if(isliving(A))
		var/mob/living/M = A
		if(("vines" in M.faction) || ("plants" in M.faction))
			return TRUE
	return FALSE
