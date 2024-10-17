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
	min_players = 20
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_SPOOKY, TAG_MAGICAL)
	description = "plays some flute music."

//--------------------
//ROUND EVENT "FLUTES"
//--------------------
//OBJECT DEF
/datum/round_event/flutes
	fakeable = FALSE
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

	var/target_amount = max(round((length(avail_players) / 10), 1), 1) //1 per 10 people, but at least one

	for(var/mob/living/carbon/C in avail_players)
		C.playsound_local(C, 'sound/ambience/flutes.ogg', 20, FALSE, pressure_affected = FALSE)
		pick_flute_scene(C)
		chosen_players.Add(C)
		announce_to_ghosts(C)

		if(length(chosen_players) >= target_amount)
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
	to_chat(M, span_warning("<b>Your vision flickers.</b>"))
	M.adjust_eye_blur(15)

/datum/round_event/flutes/proc/flute_headache(mob/living/carbon/M)
	to_chat(M, span_warning("<b>You get an intense headache!</b>"))
	M.adjust_eye_blur(20)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 199)
	M.adjustStaminaLoss(20)

/datum/round_event/flutes/proc/flute_tremble(mob/living/carbon/M)
	to_chat(M, span_warning("<b>Something trembles along the edge of your vision, your eyes water, with the familiar beat of blood racing through your head.</b>"))
	M.adjust_eye_blur(30)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30, 199)
	M.adjustStaminaLoss(40)

/datum/round_event/flutes/proc/flute_chanting(mob/living/carbon/M)
	to_chat(M, span_cultlarge("<b>You hear faint chanting.. You feel a heavy weight upon your shoulders, as something shifts it's gaze towards you..</b>"))
	M.adjust_eye_blur(50)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 199)
	M.adjustStaminaLoss(50)
	ADD_TRAIT(M, TRAIT_UNSTABLE, M)

/datum/round_event/flutes/proc/flute_starlight(mob/living/carbon/M)
	to_chat(M, span_warning("<b>As the nearest stars light your skin and your station, you can make out the faint whispers being spoken in turn with the monotone flutes playing beyond you. You feel so tired, as the struts of metal piping, the walls, the floor twist in unnatural ways, as the lights dim.</b>"))
	sleep(10 SECONDS)
	M.adjust_eye_blur(40)
	sleep(10 SECONDS)
	to_chat(M, span_warning("<b>Exhaustion takes you.</b>"))
	M.SetSleeping(10 SECONDS)
	to_chat(M, span_notice("<b>You see vague, inhuman forms, in the tightest corners of your alien dreams, dancing frantically to thundering drums, in tune with yellow monotone flutes.</b>"))
	sleep(10 SECONDS)
	to_chat(M, span_notice("<b>You wake from your deep dreams, blood oozing from your nose, while your head beats to a familiar tune.</b>"))
	M.adjustBruteLoss(15)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70, 199)
	ADD_TRAIT(M, TRAIT_UNSTABLE, M)

/datum/round_event/flutes/proc/flute_corridor_encounter(mob/living/carbon/M)
	to_chat(M, span_notice("<b>You glance upwards, down the corridor.</b>"))

	sleep(5 SECONDS)

	to_chat(M, span_large_brass("<b>A BRIGHT BLINDING LIGHT FILLS YOUR VISION!</b>"))
	M.adjust_blindness(5)

	sleep(5 SECONDS)

	to_chat(M, span_hypnophrase("<b>Your mind oozes at what it cannot comprehend, you feel your soul snatching onto your brain, with chills rolling up your spine. You barely hang on.</b>"))
	to_chat(M, span_suicide("<b>Your mind shatters.</b>"))
	M.SetSleeping(30 SECONDS)
	sleep(20 SECONDS)
	if(HAS_TRAIT(M, TRAIT_UNSTABLE))
		to_chat(M, span_suicide("<b>Your flesh undulates, and boils off your bones. You were blind, yet now you've seen a glimpse behind the cosmic curtain.</b>"))
		sleep(2 SECONDS)
		REMOVE_TRAIT(M, TRAIT_UNSTABLE, M)
		M.set_species(/datum/species/skeleton)
		to_chat(M, span_warning("<b>Your mind.. Has been humbled. You have escaped by the skin of your teeth, but have lost your body, and much, much more. You feel.. Mirth?</b>"))
	else
		ADD_TRAIT(M, TRAIT_UNSTABLE, M)
		to_chat(M, span_narsie("<b>Y'HAH HT'HU THRZHZU. UA'KLL GHRT AWN ZUU!</b>"))
	M.adjustBruteLoss(60, TRUE, TRUE)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 65, 199)

	M.AddComponent(/datum/component/random_blackouts)


//apply this to an object to make nearby lights flicker randomly
/datum/component/random_blackouts
	var/atom/movable/host
	COOLDOWN_DECLARE(nextblackout)

/datum/component/random_blackouts/Initialize(...)
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	host = parent

/datum/component/random_blackouts/RegisterWithParent()
	START_PROCESSING(SSobj, src)

/datum/component/random_blackouts/UnregisterFromParent()
	STOP_PROCESSING(SSobj, src)

/datum/component/random_blackouts/process(delta_time)
	. = ..()
	if(COOLDOWN_FINISHED(src, nextblackout))
		random_blackout()
		COOLDOWN_START(src, nextblackout, (rand(10, 30) SECONDS))

/datum/component/random_blackouts/proc/random_blackout()
	if(!host || QDELETED(host))
		message_admins("Random blackouts from flute event isn't properly cleaned up, tell molti")
		return
	var/list/nearby_lights = list()
	for(var/obj/machinery/light/L in get_area(host))
		if(L.on)
			nearby_lights.Add(L)
	var/obj/machinery/light/random_light = nearby_lights[rand(1, length(nearby_lights))]
	random_light.flicker()
