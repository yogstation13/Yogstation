//screen shit
/obj/screen/fullscreen/trip
	icon_state = "trip"
	layer = TRIP_LAYER
	alpha = 0 //we animate it ourselves

//floor trip
/obj/screen/fullscreen/ftrip
	icon_state = "ftrip"
	icon = 'yogstation/icons/mob/screen_full_big.dmi'
	screen_loc = "CENTER-9,CENTER-7"
	appearance_flags = TILE_BOUND
	layer = ABOVE_OPEN_TURF_LAYER
	plane = BLACKNESS_PLANE
	alpha = 0 //we animate it ourselves

//wall trip
/obj/screen/fullscreen/gtrip
	icon_state = "gtrip"
	icon = 'yogstation/icons/mob/screen_full_big.dmi'	
	screen_loc = "CENTER-9,CENTER-7"
	appearance_flags = TILE_BOUND
	layer = BELOW_MOB_LAYER
	plane = BLACKNESS_PLANE 
	alpha = 0 //we animate it ourselves

// reagents

/datum/reagent/jungle
	name = "Impossible Jungle Chem"
	description = "A reagent that is impossible to make in the jungle."
	can_synth = FALSE
	taste_description = "jungle"

/datum/reagent/jungle/retrosacharide
	name = "Retrosacharide"
	description = "Sacharide with a twisting structure that resembles the golden spiral."
	taste_description = "starch"

/datum/reagent/jungle/retrosacharide/on_mob_metabolize(mob/living/L)
	. = ..()
	

/datum/reagent/jungle/retrosacharide/on_mob_life(mob/living/L)
	. = ..()
	

/datum/reagent/jungle/retrosacharide/on_mob_end_metabolize(mob/living/L)
	. = ..()

/datum/reagent/jungle/polybycin
	name = "Polybycin"
	description = "An unknown molecule with simmiliar structure to psychodelics found on terra, effects unknown."
	taste_description = "madness"
	metabolization_rate = REAGENTS_METABOLISM / 2

	var/offset = 0;
	var/obj/screen/fullscreen/trip/cached_screen
	var/obj/screen/fullscreen/ftrip/cached_screen_floor
	var/obj/screen/fullscreen/gtrip/cached_screen_game

/datum/reagent/jungle/polybycin/on_mob_metabolize(mob/living/L)
	. = ..()
	add_filters(L)
	
/datum/reagent/jungle/polybycin/on_mob_life(mob/living/L)
	. = ..()
	update_filters(L)

/datum/reagent/jungle/polybycin/on_mob_end_metabolize(mob/living/L)
	remove_filters(L)
	. = ..()

// I seperated these functions from the ones right above this comment for clarity, and because i wanted to seperate visual stuff from effects stuff, makes it easier to understand.
/datum/reagent/jungle/polybycin/proc/add_filters(mob/living/L)
	if(!L.hud_used || !L.client)
		return

	var/obj/screen/plane_master/game_world/game_plane =  L.hud_used.plane_masters["[GAME_PLANE]"]
	var/obj/screen/plane_master/floor/floor_plane  = L.hud_used.plane_masters["[FLOOR_PLANE]"]

	cached_screen = L.overlay_fullscreen("polycybin_trip",/obj/screen/fullscreen/trip)
	cached_screen_floor = L.overlay_fullscreen("polycybin_ftrip",/obj/screen/fullscreen/ftrip)
	cached_screen_game = L.overlay_fullscreen("polycybin_gtrip",/obj/screen/fullscreen/gtrip)

	cached_screen_floor.add_filter("polycybin_ftrip",1,list("type"="alpha","render_source"=floor_plane.get_render_target()))
	cached_screen_game.add_filter("polycybin_gtrip",1,list("type"="alpha","render_source"=game_plane.get_render_target()))

/datum/reagent/jungle/polybycin/proc/remove_filters(mob/living/L)
	if(!L.client)
		return
	
	cached_screen = null
	cached_screen_floor = null
	cached_screen_game = null
	
	L.clear_fullscreen("polycybin_trip")
	L.clear_fullscreen("polycybin_ftrip")
	L.clear_fullscreen("polycybin_gtrip")
	

/datum/reagent/jungle/polybycin/proc/update_filters(mob/living/L)
	if(!L.client)
		return
	
	animate(cached_screen, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)
	animate(cached_screen_floor, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)
	animate(cached_screen_game, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)

/datum/status_effect/toxic_buildup
	id = "toxic_buildup"
	duration = -1 // we handle this ourselves
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /obj/screen/alert/status_effect/toxic_buildup
	var/stack = 0
	var/max_stack = 4
	var/stack_decay_time = 1 MINUTES
	var/current_stack_decay = 0

/datum/status_effect/toxic_buildup/on_creation(mob/living/new_owner, ...)
	. = ..()
	update_stack(1)

/datum/status_effect/toxic_buildup/tick()
	current_stack_decay += initial(tick_interval)
	if(current_stack_decay >= stack_decay_time)
		current_stack_decay = 0
		on_stack_decay()
		update_stack(-1)
		if(stack <= 0)
			qdel(src)
			return

	if(!ishuman(owner))
		return 
	var/mob/living/carbon/human/human_owner = owner	

	if(prob(10))
		to_chat(human_owner,span_alert("The toxins run a course through your veins, you feel sick."))	
		human_owner.adjust_disgust(5)

	switch(stack)
		if(1)
			human_owner.adjustToxLoss(0.1)
		if(2)
			human_owner.adjustToxLoss(0.25)
			if(prob(1))
				human_owner.vomit()
				current_stack_decay += 5 SECONDS
		if(3)
			human_owner.adjustToxLoss(0.5)
			if(prob(2))
				human_owner.vomit()
				current_stack_decay += 5 SECONDS
		if(4)
			human_owner.adjustToxLoss(1)
			if(prob(5))
				human_owner.vomit()
				current_stack_decay += 5 SECONDS


/datum/status_effect/toxic_buildup/proc/on_stack_decay()
	if(!ishuman(owner))
		return 
	var/mob/living/carbon/human/human_owner = owner	

	switch(stack)
		if(1)
			human_owner.adjustStaminaLoss(75)
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER,10)
		if(2)
			human_owner.Jitter(1)
			human_owner.adjustStaminaLoss(150)
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER,10)
		if(3)
			human_owner.Jitter(1)
			human_owner.Dizzy(1)
			human_owner.adjustStaminaLoss(300)
			human_owner.Paralyze(3 SECONDS)
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER,10)
		if(4)
			human_owner.adjust_blurriness(0.5)
			human_owner.Dizzy(1)
			human_owner.Jitter(1)
			human_owner.adjustStaminaLoss(450)
			human_owner.Sleeping(5 SECONDS)
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER,20)

/datum/status_effect/toxic_buildup/proc/cure()
	to_chat(owner,span_alert("The toxins are washed away from your body, you feel better."))
	qdel(src)

/datum/status_effect/toxic_buildup/proc/update_stack(amt)
	stack = min(stack + amt,max_stack)
	linked_alert = owner.throw_alert(id,alert_type,stack)

/datum/status_effect/toxic_buildup/refresh()
	update_stack(1)
	current_stack_decay = 0

/obj/screen/alert/status_effect/toxic_buildup
	name = "Toxic buildup"
	desc = "Toxins have built up in your system, they cause sustained toxin damage, and once they leave your system cause additional harm as your bodies adjustments to the toxicity backfire."
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "toxic_buildup"

/datum/ore_patch
	var/ore_type 
	var/ore_quantity_lower
	var/ore_quantity_upper
	var/ore_color

/datum/ore_patch/proc/spawn_at(turf/T)
	var/i = 0
	var/amt = rand(ore_quantity_lower,ore_quantity_upper)
	for(i = 0; i < amt; i++)
		new ore_type(T)
/datum/ore_patch/iron
	ore_type = /obj/item/stack/ore/iron
	ore_quantity_upper = 5
	ore_quantity_lower = 1
	ore_color = "#878687" 

/datum/ore_patch/plasma
	ore_type = /obj/item/stack/ore/plasma
	ore_quantity_upper = 3
	ore_quantity_lower = 1
	ore_color = "#c716b8"

/datum/ore_patch/uranium
	ore_type = /obj/item/stack/ore/uranium
	ore_quantity_upper = 3
	ore_quantity_lower = 1
	ore_color = "#1fb83b"

/datum/ore_patch/titanium
	ore_type = /obj/item/stack/ore/titanium
	ore_quantity_upper = 4
	ore_quantity_lower = 1
	ore_color = "#b3c0c7"

/datum/ore_patch/gold
	ore_type = /obj/item/stack/ore/gold
	ore_quantity_upper = 3
	ore_quantity_lower = 1
	ore_color = "#f0972b"

/datum/ore_patch/silver
	ore_type = /obj/item/stack/ore/silver
	ore_quantity_upper = 4
	ore_quantity_lower = 1
	ore_color = "#bdbebf"

/datum/ore_patch/diamond
	ore_type = /obj/item/stack/ore/diamond
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#22c2d4"

/datum/ore_patch/bluespace
	ore_type = /obj/item/stack/sheet/bluespace_crystal
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#506bc7"

/datum/reagent/quinine 
	name = "Quinine"
	description = "Dark brown liquid used to treat exotic diseases."
	color =  "#5e3807" 
	taste_description = "bitter and sour"

//i tried to base it off of actual malaria
/datum/disease/malaria 
	name = "Malaria Exotica"
	agent = "Plasmodium Exotica"
	max_stages = 8 // yes 10 fucking stages 
	severity = DISEASE_SEVERITY_HARMFUL
	disease_flags = CURABLE
	visibility_flags = HIDDEN_SCANNER 
	spread_flags = DISEASE_SPREAD_BLOOD
	needs_all_cures = FALSE	
	cures = list(/datum/reagent/quinine, /datum/reagent/medicine/synaptizine)
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	
	var/next_stage_time = 0
	var/time_per_stage = 2 MINUTES

/datum/disease/malaria/infect(mob/living/infectee, make_copy)
	next_stage_time = world.time + time_per_stage 
	return ..()

/datum/disease/malaria/stage_act()
	//we handle curing and stuff ourselves
	var/cure = has_cure()

	if(cure)
		if(prob(20))
			update_stage(stage - 1)
		if(stage == 0)
			cure()		
		return

	if( world.time >= next_stage_time)
		update_stage(clamp(stage + 1,0,max_stages))
		next_stage_time = world.time + time_per_stage + rand(-(time_per_stage * 0.25), time_per_stage * 0.25)

	switch(stage)
		if(1) //asymptomatic for some time
			return
		if(2)
			visibility_flags = NONE 
			affected_mob.adjust_bodytemperature(30, 0, BODYTEMP_HEAT_DAMAGE_LIMIT - 1) //slowly rising fever that is no lethal *yet*
			if(prob(10))
				to_chat(affected_mob, span_warning("[pick("You feel hot.", "You feel like you're burning.")]"))

			if(prob(40))
				to_chat(affected_mob, span_warning("[pick("You feel dizzy.", "Your head spins.")]"))
			return
		if(3)
			affected_mob.blood_volume -= 0.5
			affected_mob.adjust_bodytemperature(50, 0, BODYTEMP_HEAT_DAMAGE_LIMIT - 1) //fast rising not deadly fever
			if(prob(20))
				to_chat(affected_mob, span_warning("[pick("You feel hot.", "You feel like you're burning.")]"))

			if(prob(40))
				if(prob(50))
					to_chat(affected_mob, span_warning("[pick("You feel dizzy.", "Your head spins.")]"))
				else 
					to_chat(affected_mob, span_userdanger("A wave of dizziness washes over you!"))
					affected_mob.Dizzy(5)

			if(prob(10))
				affected_mob.Jitter(5)
				if(prob(30))
					to_chat(affected_mob, span_warning("[pick("Your head hurts.", "Your head pounds.")]"))
	
			if(prob(30))
				affected_mob.emote("cough")

			return
		if(4) //another period of asymptomaticity before shit really hits the fan
			affected_mob.blood_volume -= 0.25
			return

		if(5) // a few more minutes before disease really becomes deadly
			severity = DISEASE_SEVERITY_DANGEROUS
			affected_mob.blood_volume -= 0.75
			affected_mob.adjust_bodytemperature(30) //slowly rising fever that can become deadly
			if(prob(30))
				to_chat(affected_mob, span_warning("[pick("You feel hot.", "You feel like you're burning.")]"))

			if(prob(60))
				if(prob(40))
					to_chat(affected_mob, span_warning("[pick("You feel dizzy.", "Your head spins.")]"))
				else 
					to_chat(affected_mob, span_userdanger("A wave of dizziness washes over you!"))
					affected_mob.Dizzy(5)

			if(prob(15))
				affected_mob.Jitter(5)
				if(prob(30))
					if(prob(50))
						to_chat(affected_mob, span_warning("[pick("Your head hurts.", "Your head pounds.")]"))
					else 
						to_chat(affected_mob, span_warning("[pick("Your head hurts a lot.", "Your head pounds incessantly.")]"))
						affected_mob.adjustStaminaLoss(25)

			if(prob(40))
				affected_mob.emote("cough")

			return

		if(6) //another period of lower deadliness
			affected_mob.blood_volume -= 0.25
			if(prob(40))
				affected_mob.emote("cough")
			return
		if(7)
			affected_mob.blood_volume -= 1
			affected_mob.adjust_bodytemperature(35)
			if(prob(30))
				to_chat(affected_mob, span_warning("[pick("You feel hot.", "You feel like you're burning.")]"))


			if(prob(40))
				affected_mob.emote("cough")

			if(prob(15))
				affected_mob.Jitter(5)
				if(prob(60))
					if(prob(30))
						to_chat(affected_mob, span_warning("[pick("Your head hurts.", "Your head pounds.")]"))
					else 
						to_chat(affected_mob, span_warning("[pick("Your head hurts a lot.", "Your head pounds incessantly.")]"))
						affected_mob.adjustStaminaLoss(25)
			
			if(prob(10))
				affected_mob.adjustStaminaLoss(20)
				to_chat(affected_mob, span_warning("[pick("You feel weak.", "Your body feel numb.")]"))
			return
		if(8)
			affected_mob.blood_volume -= 2
			affected_mob.adjust_bodytemperature(75) //a deadly fever
			if(prob(40))
				to_chat(affected_mob, span_warning("[pick("You feel hot.", "You feel like you're burning.")]"))

			if(prob(70))
				if(prob(30))
					to_chat(affected_mob, span_warning("[pick("You feel dizzy.", "Your head spins.")]"))
				else 
					to_chat(affected_mob, span_userdanger("A wave of dizziness washes over you!"))
					affected_mob.Dizzy(5)

			if(prob(50))
				affected_mob.emote("cough")

			if(prob(20))
				affected_mob.Jitter(5)
				if(prob(50))
					to_chat(affected_mob, span_warning("[pick("Your head hurts a lot.", "Your head pounds incessantly.")]"))
					affected_mob.adjustStaminaLoss(25)
				else 
					to_chat(affected_mob, span_userdanger("[pick("Your head hurts!", "You feel a burning knife inside your brain!", "A wave of pain fills your head!")]"))						
					affected_mob.Stun(35)

			if(prob(25))
				affected_mob.adjustStaminaLoss(50)
				to_chat(affected_mob, span_warning("[pick("You feel very weak.", "Your body feel completely numb.")]"))
			return
		else
			return

	//instead of it being chance based, malaria is based on time
#define NOON_DIVISOR 1.6 
#define LIGHTING_GRANULARITY 3.4
#define UPDATES_IN_QUARTER_DAY 5

/datum/daynight_cycle 
	var/daynight_cycle = TRUE
	var/update_interval = 60 SECONDS
	var/updates = 0 
	var/cached_luminosity = 0
	var/list/affected_areas = list()

/datum/daynight_cycle/proc/finish_generation()
	INVOKE_ASYNC(src,.proc/daynight_cycle)

/datum/daynight_cycle/proc/daynight_cycle()
	set waitfor = FALSE
	updates += 1
	//whew that's quite a bit of math! it's quite simple once you get it tho, think of (current_inteval/update_interval) as x, sin(x * arcsin(1)) turns sin()'s period from 2*PI to 4,
	//working with integers is nicer, all the other stuff is mostly fluff to make it so it takes 10 update_interval to go from day to night and back.
	var/new_luminosity = CEILING( (LIGHTING_GRANULARITY  *sin( ( updates * arcsin(1) ) / UPDATES_IN_QUARTER_DAY) ) ,1 )/NOON_DIVISOR
	
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JUNGLELAND_DAYNIGHT_NEXT_PHASE,updates,new_luminosity)

	var/counter = 0	
	for(var/area/A as anything in affected_areas)
		for(var/turf/open/T in A)
			for(var/mob/living/L in T)
				if(!L.client)
					continue
				if(new_luminosity != cached_luminosity)
					if(new_luminosity > 0 && cached_luminosity < 0)
						to_chat(L,span_alertwarning("The dawn lights the whole jungle in new glorious light... a new day begins!"))
					if(new_luminosity < 0 && cached_luminosity > 0)
						to_chat(L,span_alertwarning("You can see the stars high in the sky... the night begins!"))

			T.set_light(1,new_luminosity) // we do not use dynamic light, because they are so insanely slow, it's just.. not worth it.
			if(counter == 255)
				CHECK_TICK
				counter = 0
			counter++
	cached_luminosity = new_luminosity

	addtimer(CALLBACK(src,.proc/daynight_cycle), update_interval, TIMER_UNIQUE | TIMER_OVERRIDE)

