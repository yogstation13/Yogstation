//screen shit
/atom/movable/screen/fullscreen/trip
	icon_state = "trip"
	layer = TRIP_LAYER
	alpha = 0 //we animate it ourselves

//floor trip
/atom/movable/screen/fullscreen/ftrip
	icon_state = "ftrip"
	icon = 'yogstation/icons/mob/screen_full_big.dmi'
	screen_loc = "CENTER-9,CENTER-7"
	appearance_flags = TILE_BOUND
	layer = ABOVE_OPEN_TURF_LAYER
	alpha = 0 //we animate it ourselves

//wall trip
/atom/movable/screen/fullscreen/gtrip
	icon_state = "gtrip"
	icon = 'yogstation/icons/mob/screen_full_big.dmi'	
	screen_loc = "CENTER-9,CENTER-7"
	appearance_flags = TILE_BOUND
	layer = BELOW_MOB_LAYER
	alpha = 0 //we animate it ourselves

// reagents

/datum/reagent/jungle
	name = "Impossible Jungle Chem"
	description = "A reagent that is impossible to make in the jungle."
	can_synth = FALSE
	taste_description = "jungle"

/datum/reagent/jungle/retrosacharide
	name = "Retrosacharide"
	description = "Sacharide with a twisting structure that resembles the golden spiral. It seeks to achieve stability, but it never seems to stop."
	taste_description = "starch"
	var/delta_healing = 5

/datum/reagent/jungle/retrosacharide/on_mob_life(mob/living/L)
	. = ..()
	var/brute = L.getBruteLoss()
	var/fire = L.getFireLoss()
	var/toxin = L.getToxLoss()

	var/average = (brute + fire + toxin)/3 

	if(brute != fire || brute != toxin)
		var/b_offset = clamp(average - brute,-delta_healing,delta_healing)
		var/f_offset = clamp(average - fire,-delta_healing,delta_healing)
		var/t_offset = clamp(average - toxin,-delta_healing,delta_healing)
		L.adjustBruteLoss(b_offset,FALSE)
		L.adjustFireLoss(f_offset,FALSE)
		L.adjustToxLoss(t_offset)
		return
	
	switch(rand(0,2))
		if(0)
			L.adjustBruteLoss(-0.5)
		if(1)
			L.adjustFireLoss(-0.5)	
		if(2)
			L.adjustToxLoss(-0.5)

/datum/reagent/jungle/jungle_scent
	name = "Jungle scent"
	description = "It reeks of the jungle pits, but I wonder if it has any effects do to that?"
	taste_description = "jungle"
	metabolization_rate = REAGENTS_METABOLISM / 2
	var/has_mining = FALSE

/datum/reagent/jungle/jungle_scent/on_mob_metabolize(mob/living/L)
	. = ..()
	if("mining" in L.faction)
		has_mining = TRUE
		return
	L.faction += "mining"

/datum/reagent/jungle/jungle_scent/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(has_mining)
		return 
	L.faction -= "mining"

/datum/reagent/jungle/polybycin
	name = "Polybycin"
	description = "An unknown molecule with simmiliar structure to psychodelics found on terra, effects unknown."
	taste_description = "colours"
	metabolization_rate = REAGENTS_METABOLISM / 2

	var/offset = 0
	var/atom/movable/screen/fullscreen/trip/cached_screen
	var/atom/movable/screen/fullscreen/ftrip/cached_screen_floor
	var/atom/movable/screen/fullscreen/gtrip/cached_screen_game

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
/datum/reagent/jungle/polybycin/proc/add_filters(mob/living/psychonaut)
	if(!psychonaut.hud_used || !psychonaut.client)
		return

	// var/atom/movable/screen/plane_master/game_world/game_plane =  psychonaut.hud_used.plane_masters["[GAME_PLANE]"]
	//var/atom/movable/screen/plane_master/floor/floor_plane  = psychonaut.hud_used.plane_masters["[FLOOR_PLANE]"]
	var/atom/movable/plane_master_controller/game_plane_master_controller = psychonaut.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	cached_screen = psychonaut.overlay_fullscreen("polycybin_trip",/atom/movable/screen/fullscreen/trip)
	cached_screen_floor = psychonaut.overlay_fullscreen("polycybin_ftrip",/atom/movable/screen/fullscreen/ftrip)
	cached_screen_game = psychonaut.overlay_fullscreen("polycybin_gtrip",/atom/movable/screen/fullscreen/gtrip)

	game_plane_master_controller.add_filter("polycybin_ftrip", 1, alpha_mask_filter(render_source = FLOOR_PLANE))
	game_plane_master_controller.add_filter("polycybin_gtrip", 1 , alpha_mask_filter())

/datum/reagent/jungle/polybycin/proc/remove_filters(mob/living/L)
	if(!L.client)
		return
	
	cached_screen = null
	cached_screen_floor = null
	cached_screen_game = null
	
	L.clear_fullscreen("polycybin_trip")
	L.clear_fullscreen("polycybin_ftrip")
	L.clear_fullscreen("polycybin_gtrip")
	

/datum/reagent/jungle/polybycin/update_filters(mob/living/L)
	if(!L.client)
		return
	. = ..()
	if(cached_screen)	
		animate(cached_screen, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)
	if(cached_screen_floor)
		animate(cached_screen_floor, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)
	if(cached_screen_game)
		animate(cached_screen_game, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)


/datum/ore_patch
	var/ore_type 
	var/ore_quantity_lower
	var/ore_quantity_upper
	var/ore_color
	var/overlay_state

/datum/ore_patch/proc/spawn_at(turf/T)
	var/i = 0
	var/amt = rand(ore_quantity_lower,ore_quantity_upper)
	for(i = 0; i < amt; i++)
		new ore_type(T)

/datum/ore_patch/iron
	ore_type = /obj/item/stack/ore/iron
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#878687" 
	overlay_state = "rock_Iron"

/datum/ore_patch/plasma
	ore_type = /obj/item/stack/ore/plasma
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#c716b8"
	overlay_state = "rock_Plasma"

/datum/ore_patch/uranium
	ore_type = /obj/item/stack/ore/uranium
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#1fb83b"
	overlay_state = "rock_Uranium"

/datum/ore_patch/titanium
	ore_type = /obj/item/stack/ore/titanium
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#b3c0c7"
	overlay_state = "rock_Titanium"

/datum/ore_patch/gold
	ore_type = /obj/item/stack/ore/gold
	ore_quantity_upper = 1
	ore_quantity_lower = 1
	ore_color = "#f0972b"
	overlay_state = "rock_Gold"

/datum/ore_patch/silver
	ore_type = /obj/item/stack/ore/silver
	ore_quantity_upper = 1
	ore_quantity_lower = 1
	ore_color = "#bdbebf"
	overlay_state = "rock_Silver"

/datum/ore_patch/diamond
	ore_type = /obj/item/stack/ore/diamond
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#22c2d4"
	overlay_state = "rock_Diamond"

/datum/ore_patch/bluespace
	ore_type = /obj/item/stack/ore/bluespace_crystal
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#506bc7"
	overlay_state = "rock_BScrystal"

/datum/ore_patch/dilithium
	ore_type = /obj/item/stack/ore/dilithium_crystal
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#bd50c7"
	overlay_state = "rock_Dilithium"

/datum/ore_patch/sand
	ore_type = /obj/item/stack/ore/glass/basalt
	ore_quantity_upper = 10
	ore_quantity_lower = 2
	ore_color = "#2d2a2d"
	overlay_state = "rock_Dilithium"

/datum/reagent/space_cleaner/sterilizine/primal
	name = "Primal Sterilizine"
	description = "While crude and odorous, it still seems to kill enough bacteria to be usable."

/datum/reagent/toxin/meduracha //try putting this in a blowgun!
	name = "Meduracha Toxin"
	description = "Harvested from Meduracha tentacles, the toxin has quickly decayed into a less deadly form, but still is quite fatal."
	color = "#00ffb3"
	taste_description = "acid"
	toxpwr = 3.5 //slightly more damaging than ground up plasma, and also causes other minor effects

/datum/reagent/toxin/meduracha/on_mob_life(mob/living/carbon/M)
	M.damageoverlaytemp = 60
	M.update_damage_hud()
	M.adjust_eye_blur(3)
	return ..()

/datum/reagent/quinine 
	name = "Quinine"
	description = "Dark brown liquid used to treat exotic diseases."
	color =  "#5e3807" 
	taste_description = "bitter and sour"

/datum/reagent/magnus_purpura_enzyme
	name = "Magnus purpura enzyme"
	description = "Yellowish liquid with potent anti-acidic properties"
	color = "#e0ea4e"
	taste_description = "sweet"
	metabolization_rate = 0.1
	var/alert_id = "magnus_purpura"

/datum/reagent/magnus_purpura_enzyme/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L,TRAIT_SULPH_PIT_IMMUNE,JUNGLELAND_TRAIT)
	L.throw_alert(alert_id,/atom/movable/screen/alert/magnus_purpura)

/datum/reagent/magnus_purpura_enzyme/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjustToxLoss(-3.5 * REM) // YOU CAN ONLY GET IT ON JUNGLELAND, why not make it pretty good?

/datum/reagent/magnus_purpura_enzyme/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L,TRAIT_SULPH_PIT_IMMUNE,JUNGLELAND_TRAIT)
	L.clear_alert(alert_id)
	return ..()

/datum/reagent/magnus_purpura_enzyme/condensed
	name = "Condensed magnus purpura enzyme"
	description = "Yellowish liquid with VERY potent anti-acidic properties"
	color = "#eeff00"
	taste_description = "sweet"
	metabolization_rate = 0.05
	alert_id = "magnus_purpura_condensed"

//i tried to base it off of actual malaria
/datum/disease/malaria 
	name = "Malaria Exotica"
	agent = "Plasmodium Exotica"
	cure_text = "Quinine, Synaptizine or Tonic water"
	max_stages = 8 // yes 8 fucking stages 
	severity = DISEASE_SEVERITY_HARMFUL
	disease_flags = CURABLE
	visibility_flags = HIDDEN_SCANNER 
	spread_flags = DISEASE_SPREAD_BLOOD
	needs_all_cures = FALSE	
	cures = list(/datum/reagent/quinine, /datum/reagent/medicine/synaptizine,/datum/reagent/consumable/tonic)
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	
	var/next_stage_time = 0
	var/time_per_stage = 2 MINUTES //around 16 minutes till this reaches lethality

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
					affected_mob.adjust_dizzy(5)

			if(prob(10))
				affected_mob.adjust_jitter(5)
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
					affected_mob.adjust_dizzy(5)

			if(prob(15))
				affected_mob.adjust_jitter(5)
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
				affected_mob.adjust_jitter(5)
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
					affected_mob.adjust_dizzy(5)

			if(prob(50))
				affected_mob.emote("cough")

			if(prob(20))
				affected_mob.adjust_jitter(5)
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

/datum/action/cooldown/tar_crown_spawn_altar
	name = "Summon tar altar"
	desc = "Summons a tar altar at your current location (MAX 3)"
	cooldown_time = 1 MINUTES
	background_icon = 'yogstation/icons/mob/actions/backgrounds.dmi'
	background_icon_state = "jungle"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "tar_crown_summon"
	var/obj/item/clothing/head/yogs/tar_king_crown/crown 

/datum/action/cooldown/tar_crown_spawn_altar/New(Target)
	. = ..()
	crown = target
	LAZYINITLIST(crown.actions)
	crown.actions += src

/datum/action/cooldown/tar_crown_spawn_altar/Trigger()
	. = TRUE
	if(!IsAvailable())
		return FALSE
	var/name = input(owner,"Choose name for the tar shrine","Shrine name")
	if(!name)
		return FALSE
	StartCooldown()
	if(crown.max_tar_shrines == crown.current_tar_shrines.len)
		var/key = pick(crown.current_tar_shrines)
		qdel(crown.current_tar_shrines[key])
		crown.current_tar_shrines -= key
	crown.current_tar_shrines[name] = new /obj/structure/tar_shrine(get_turf(owner))

/datum/action/cooldown/tar_crown_teleport
	name = "Teleport to a tar shrine"
	desc = "Teleports you to a chosen tar shrine"
	cooldown_time = 1 MINUTES
	background_icon = 'yogstation/icons/mob/actions/backgrounds.dmi'
	background_icon_state = "jungle"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "tar_crown_teleport"
	var/obj/item/clothing/head/yogs/tar_king_crown/crown 

/datum/action/cooldown/tar_crown_teleport/New(Target)
	. = ..()
	crown = target
	LAZYINITLIST(crown.actions)
	crown.actions += src

/datum/action/cooldown/tar_crown_teleport/Trigger()
	. = TRUE
	if(!IsAvailable())
		return FALSE
	var/name = input(owner,"Choose the altar to teleport to") as anything in crown.current_tar_shrines
	if(!name)
		return FALSE

	StartCooldown()
	var/location = get_turf(crown.current_tar_shrines[name])
	animate(owner,2.5 SECONDS,owner.color = "#280025")
	if(!do_after(owner,2.5 SECONDS,owner))
		animate(owner,0.5 SECONDS,owner.color = initial(owner.color))
		return
	new /obj/effect/tar_king/orb_in(get_turf(owner),owner,NORTH)
	do_teleport(owner,location)
	animate(owner,0.5 SECONDS,owner.color = initial(owner.color))

/// jungle recipes---
/datum/chemical_reaction/poultice/alt2
	name = "tribal poultice 2"
	id = "poultice_alt2"
	required_temp = 420
	required_reagents = list(/datum/reagent/cellulose = 40, /datum/reagent/ash = 15, /datum/reagent/space_cleaner/sterilizine/primal = 4)

/datum/reagent/toxin/concentrated 
	name = "Concentrated toxin"
	toxpwr = 2

#define STAGE_1_THRESHOLD 15
#define STAGE_2_THRESHOLD 30
#define STAGE_3_THRESHOLD 45
#define ALERT_ID "toxic_buildup_metabolites"
/datum/reagent/toxic_metabolities
	name = "Toxic metabolities"
	description = "Deadly toxic buildup of metabolities caused by direct exposition to jungleland's environment."
	taste_description = "death"
	color = "#002d09"
	harmful = TRUE
	can_synth = FALSE
	self_consuming = TRUE
	taste_mult = 100
	metabolization_rate = 0.5

	var/stage = 1
	var/old_volume = 0
	var/alert_type = /atom/movable/screen/alert/status_effect/toxic_buildup

// consumes 2 every 2 seconds
/datum/reagent/toxic_metabolities/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(HAS_TRAIT(M,TRAIT_SULPH_PIT_IMMUNE))
		cure()
		return
	switch(volume)
		if(0 to STAGE_1_THRESHOLD)
			if(old_volume > STAGE_1_THRESHOLD)
				decrement_stage(M)

			M.adjustToxLoss(0.25, forced = TRUE)
			// STAGE 1
		if(STAGE_1_THRESHOLD to STAGE_2_THRESHOLD)
			if(old_volume < STAGE_1_THRESHOLD)
				increment_stage(M)
			if(old_volume > STAGE_2_THRESHOLD)
				decrement_stage(M)

			M.adjustToxLoss(0.5, forced = TRUE)
			M.adjustOrganLoss(ORGAN_SLOT_LIVER,0.25)
			M.adjustStaminaLoss(2.5)
			if(prob(2.5))
				to_chat(M, "You feel slight burning coming from within you, as the toxins singe you from within!")
				M.adjustFireLoss(5)
			// STAGE 2
		if(STAGE_2_THRESHOLD to STAGE_3_THRESHOLD)
			if(old_volume < STAGE_2_THRESHOLD)
				increment_stage(M)
			if(old_volume > STAGE_3_THRESHOLD)
				decrement_stage(M)
			M.adjustToxLoss(1, forced = TRUE)
			M.adjustOrganLoss(ORGAN_SLOT_LIVER,0.5)
			M.adjustStaminaLoss(5)
			if(prob(5))
				to_chat(M, "You feel a burning sensation coming from within you, as the toxins burn you from within!")
				M.adjustFireLoss(10)
			// STAGE 3
		if(STAGE_3_THRESHOLD to INFINITY)
			if(old_volume < STAGE_3_THRESHOLD)
				increment_stage(M)
			M.adjustToxLoss(2.5, forced = TRUE)
			M.adjustOrganLoss(ORGAN_SLOT_LIVER,1)
			M.adjustStaminaLoss(10)
			if(prob(10))
				to_chat(M, "You feel deep burning sensation from within as the toxins burn you from within!")
				M.adjustFireLoss(15)
			// STAGE 4
	old_volume = volume

/datum/reagent/toxic_metabolities/on_mob_add(mob/living/L)
	. = ..()
	if(HAS_TRAIT(L,TRAIT_SULPH_PIT_IMMUNE))
		cure()
		return
	RegisterSignal(L,COMSIG_REGEN_CORE_HEALED,PROC_REF(cure))
	switch(volume)
		if(0 to STAGE_1_THRESHOLD)
			stage = 1
		if(STAGE_1_THRESHOLD to STAGE_2_THRESHOLD)
			stage = 2
		if(STAGE_2_THRESHOLD to STAGE_3_THRESHOLD)
			stage = 3
		if(STAGE_3_THRESHOLD to INFINITY)
			stage = 4
	old_volume = volume
	L.throw_alert(ALERT_ID,alert_type,stage)

/datum/reagent/toxic_metabolities/on_mob_delete(mob/living/L)
	L.clear_alert(ALERT_ID)
	return ..()
	
/datum/reagent/toxic_metabolities/proc/decrement_stage(mob/living/L)
	stage = max(1,stage - 1)
	L.throw_alert(ALERT_ID,alert_type,stage)

/datum/reagent/toxic_metabolities/proc/increment_stage(mob/living/L)
	stage = min(4,stage + 1)
	L.throw_alert(ALERT_ID,alert_type,stage)

/datum/reagent/toxic_metabolities/proc/cure()
	if(holder)
		holder.remove_reagent(type, volume)


#undef STAGE_1_THRESHOLD
#undef STAGE_2_THRESHOLD
#undef STAGE_3_THRESHOLD
#undef ALERT_ID
