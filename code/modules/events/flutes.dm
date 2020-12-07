//
//add ability to cure sanity instability with psychatrist?
//add goals?
//xoxeyos
//massive help from arcturus-prime

//----------------------------
//ROUND EVENT CONTROL "FLUTES"
//----------------------------
/datum/round_event_control/flutes
	name = "Flutes"
	typepath = /datum/round_event/flutes
	max_occurrences = 1
	weight = 1
	min_players = 30

//--------------------
//ROUND EVENT "FLUTES"
//--------------------
//OBJECT DEF
/datum/round_event/flutes
	var/list/mob/living/carbon/chosen_players = list()

//EVENT START PROC
//This gets executed at the start of the event
/datum/round_event/flutes/start()
	var/list/mob/living/carbon/avail_players = list()
	for(var/mob/living/carbon/M in GLOB.player_list)
		if(M.stat)
			continue
		avail_players.Add(M)
	shuffle_inplace(avail_players)
	var/target_amount = (round((avail_players.len / 10), 1) == 0 ? 1 : round((avail_players.len / 10), 1))
	for(var/mob/living/carbon/C in avail_players)
		C.playsound_local(C, 'sound/ambience/flutes.ogg', 20, FALSE, pressure_affected = FALSE)
		pick_flute_scene(C)
		chosen_players.Add(C)
		if(chosen_players.len >= target_amount)
			break

/datum/round_event/flutes/proc/pick_flute_scene(mob/living/carbon/M)
	switch(rand(1, 6))
		if(1)
			flute_vis_flicker(M)
		if(2)
			flute_headache(M)
		if(3)
			flute_tremble(M)
		if(4)
			flute_chanting(M)
		if(5)
			flute_starlight(M)
		if(6)
			flute_corridor_encounter(M)

/datum/round_event/flutes/proc/flute_vis_flicker(mob/living/carbon/M)
	to_chat(M, "<span class='warning'><b>Your vision flickers.</b></span>")
	M.blur_eyes(15)

/datum/round_event/flutes/proc/flute_headache(mob/living/carbon/M)
	to_chat(M, "<span class='warning'><b>You get an intense headache!</b></span>")
	M.blur_eyes(15)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 20, 30)
	M.adjustStaminaLoss(15)

/datum/round_event/flutes/proc/flute_tremble(mob/living/carbon/M)
	to_chat(M, "<span class='warning'><b>Something trembles along the edge of your vision, your eyes water, with the familiar beat of blood racing through your head.</b></span>")
	M.blur_eyes(30)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30, 35)
	M.adjustStaminaLoss(30)

/datum/round_event/flutes/proc/flute_chanting(mob/living/carbon/M)
	to_chat(M, "<span class ='cultlarge'><b>You hear faint chanting.. You feel a heavy weight upon your shoulders, as something shifts it's gaze towards you..</b></span>")
	M.blur_eyes(30)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 60)
	M.adjustStaminaLoss(50)
	ADD_TRAIT(M, TRAIT_UNSTABLE, M)
	//sanity = 75

/datum/round_event/flutes/proc/flute_starlight(mob/living/carbon/M)
	to_chat(M, "<span class='warning'><b>As the nearest stars light your skin and your station, you can make out the faint whispers being spoken in turn with the monotone flutes playing beyond you. You feel so tired, as the struts of metal piping, the walls, the floor twist in unnatural ways, as the lights dim.</b></span>")
	sleep(30 SECONDS)
	M.blur_eyes(40)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 65, 70, 80)
	ADD_TRAIT(M, TRAIT_UNSTABLE, M)
	//sanity = 50
	sleep(25 SECONDS)
	to_chat(M, "<span class='warning'><b>Exhaustion takes you.</b></span>")
	M.SetSleeping(70)
	to_chat(M, "<span class='notice'><b>You see vague, inhuman forms, in the tightest corners of your alien dreams, dancing frantically to thundering drums, in tune with yellow monotone flutes.</b></span>")
	sleep(20 SECONDS)
	M.adjustBruteLoss(15)
	to_chat(M, "<span class='notice'><b>You wake from your deep dreams, blood oozing from your nose, while your head beats to a familiar tune.</b></span>")

/datum/round_event/flutes/proc/flute_corridor_encounter(mob/living/carbon/M)
	to_chat(M, "<span class='notice'><b>You glance upwards, down the corridor.</b></span>")
	sleep(5 SECONDS)
	to_chat(M, "<span class='bold large_brass'><b>A BRIGHT BLINDING LIGHT FILLS YOUR VISION!</b></span>")
	M.eye_blind = 5
	sleep(10 SECONDS)
	to_chat(M, "<span class='reallybig hypnophrase'><b>Your mind oozes at what it cannot comprehend, you feel your soul snatching onto your brain, with chills rolling up your spine. You barely hang on.</b></span>")
	if(HAS_TRAIT(M, TRAIT_UNSTABLE))
		to_chat(M, "<span class='green'><b>Your mind shatters.</b></span>")
		M.SetSleeping(30)
		sleep(30 SECONDS)
		to_chat(M, "<span class='suicide'><b>Your flesh undulates, and boils off your bones. You were blind, yet now you've seen a glimpse behind the cosmic curtain.</b></span>")
		//sanity = 25
		REMOVE_TRAIT(M, TRAIT_UNSTABLE, M)
		M.blur_eyes(5)
		M.adjustStaminaLoss(90)
		M.adjustBruteLoss(60, 70, 75, 80, 85)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 65, 70, 75, 80, 90)
		M.set_species(/datum/species/skeleton)
		sleep(30 SECONDS)
		to_chat(M, "<span class='warning'><b>Your mind.. Has been humbled. You have escaped by the skin of your teeth, but have lost your body, and much, much more. You feel.. Mirth?</b></span>")
	else
		to_chat(M, "<span class='suicide'><b>Your mind shatters.</b></span>")
		ADD_TRAIT(M, TRAIT_UNSTABLE, M)
		//sanity = 1
		M.SetSleeping(30)
		M.blur_eyes(40)
		M.adjustStaminaLoss(99)
		to_chat(M, "<span class='narsie'><b>Y'HAH HT'HU THRZHZU. UA'KLL GHRT AWN ZUU!</b></span>")
		M.adjustBruteLoss(60, 70, 75, 80, 85)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 65, 70, 75, 80, 90)
	random_blackouts_enable(M)

/datum/round_event/flutes/proc/random_blackouts_enable(mob/living/carbon/M)
	ADD_TRAIT(M, RANDOM_BLACKOUTS, M)
	spawn
		while(HAS_TRAIT(M, RANDOM_BLACKOUTS))
			sleep(15 SECONDS)
			spawn
				random_blackout(M)

/datum/round_event/flutes/proc/random_blackout(mob/living/carbon/M)
	var/list/nearby_lights = list()
	for(var/obj/machinery/light/L in M.loc.loc.contents)
		if(L.bulb_power == 0 && L.light_power == 0)
			continue
		nearby_lights.Add(L)
	var/obj/machinery/light/random_light = nearby_lights[rand(1, nearby_lights.len)]
	random_light.light_power = 0
	random_light.bulb_power = 0
	random_light.update()
	sleep(rand(8, 30) SECONDS)
	random_light.light_power = 1
	random_light.bulb_power = 1
	random_light.update()
