///
//randomly pick people from a short list
//add ability to cure sanity instability with psychatrist
//add sprites?
//add goals?
//xoxeyos

#define FLUTE_VIS_FLICKER 1
#define FLUTE_HEADACHE 2
#define FLUTE_TREMBLE 3
#define FLUTE_CHANT 4
#define FLUTE_STARLIGHT 5
#define FLUTE_CORRIDOR_ENCOUNTER 6

/datum/round_event_control/flutes
	name = "Flutes"
	typepath = /datum/round_event/flutes
	max_occurrences = 1
	weight = 0
	min_players = 40

/datum/round_event/flutes

/datum/round_event/flutes/proc/sound_intro()
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client.prefs.toggles & SOUND_MIDI) && is_station_level(M.loc.z))
			M.playsound_local(M, 'sound/ambience/flutes.ogg', 20, FALSE, pressure_affected = FALSE)

/datum/round_event/flutes/proc/pick_flute_scene(mob/living/carbon/human/M)

	var/pick_flute_scene = rand(6)

	switch(pick_flute_scene)
		if(FLUTE_VIS_FLICKER)
			to_chat(M, "<span class='warning'><b>Your vision flickers.</b></span>")
			M.blur_eyes(15)
		//code for FLUTE_VIS_FLICKER
		if(FLUTE_HEADACHE)
			to_chat(M, "<span class='warning'><b>You get an intense headache!</b></span>")
			M.blur_eyes(15)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 20, 30)
			M.adjustStaminaLoss(15)
		//code for FLUTE_HEADACHE
		if(FLUTE_TREMBLE)
			to_chat(M, "<span class='warning'><b>Something trembles along the edge of your vision, your eyes water, with the familiar beat of blood racing through your head.</b></span>")
			M.blur_eyes(30)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30, 35)
			M.adjustStaminaLoss(30)
		//code for FLUTE_TREMBLE
		if(FLUTE_CHANT)
			to_chat(M, "<span class ='cultlarge'><b>You hear faint chanting.. You feel a heavy weight upon your shoulders, as something shifts it's gaze towards you..</b></span>")
			M.blur_eyes(30)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 60)
			M.adjustStaminaLoss(50)
			ADD_TRAIT(M, TRAIT_UNSTABLE, M)
			//sanity = 75
		//code for FLUTE_CHANTING
		if(FLUTE_STARLIGHT)
			to_chat(M, "<span class='warning'><b>As the nearest stars light your skin and your station, you can make out the faint whispers being spoken in turn with the monotone flutes playing beyond you. You feel so tired, as the struts of metal piping, the walls, the floor twist in unnatural ways, as the lights dim.</b></span>")
			addtimer(CALLBACK(src, "flute_starlight", 30))
			M.blur_eyes(40)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 65, 70, 80)
			ADD_TRAIT(M, TRAIT_UNSTABLE, M)
			//sanity = 50
			addtimer(CALLBACK(src, "flute_starlight", 25))
			to_chat(M, "<span class='warning'><b>Exhaustion takes you.</b></span>")
			M.SetSleeping(70)
			to_chat(M, "<span class='notice'><b>You see vague, inhuman forms, in the tightest corners of your alien dreams, dancing frantically to thundering drums, in tune with yellow monotone flutes.</b></span>")
			addtimer(CALLBACK(src, "flute_starlight", 25))
			M.adjustBruteLoss(15)
			to_chat(M, "<span class='notice'><b>You wake from your deep dreams, blood oozing from your nose, while your head beats to a familiar tune.</b></span>")
		//code for FLUTE_STARLIGHT
		if(FLUTE_CORRIDOR_ENCOUNTER)
			to_chat(M, "<span class='notice'><b>You glance upwards, down the corridor.</b></span>")
			addtimer(CALLBACK(src, "flute_corridor", 5))
			to_chat(M, "span class='bold large_brass'><b>A BRIGHT BLINDING LIGHT FILLS YOUR VISION!</b></span>")
			M.eye_blind = 5
			addtimer(CALLBACK(src, "flute_corridor", 10))
			to_chat(M, "<span class='reallybig hypnophrase'><b>Your mind oozes at what it cannot comprehend, you feel your soul snatching onto your brain, with chills rolling up your spine. You barely hang on.</b></span>")
			if(HAS_TRAIT(M, TRAIT_UNSTABLE))
				to_chat(M, "<span class='green'><b>Your mind shatters.</b></span>")
				M.SetSleeping(30)
				addtimer(CALLBACK(src, "flute_corridor", 30))
				to_chat(M, "<span class='suicide'><b>Your flesh undulates, and boils off your bones. You were blind, yet now you've seen a glimpse behind the cosmic curtain.</b></span>")
				//sanity = 25
				REMOVE_TRAIT(M, TRAIT_UNSTABLE, M)
				M.blur_eyes(5)
				M.adjustStaminaLoss(90)
				M.adjustBruteLoss(90)
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 90)
				M.set_species(/datum/species/skeleton)
				addtimer(CALLBACK(src, "flute_corridor", 30))
				to_chat(M, "<span class='warning'><b>Your mind.. Has been humbled. You have escaped by the skin of your teeth, but have lost your body, and much, much more. You feel.. Mirth?</b></span>")
			else
				to_chat(M, "span class='suicide'><b>Your mind shatters.</b></span>")
				ADD_TRAIT(M, TRAIT_UNSTABLE, M)
				//sanity = 1
				M.SetSleeping(30)
				M.blur_eyes(40)
				M.adjustStaminaLoss(99)
				to_chat(M, "<span class='Narsie'><b>Y'HAH HT'HU THRZHZU. UA'KLL GHRT AWN ZUU!</b></span>")
				M.adjustBruteLoss(99)
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 99.9)
		//code for FLUTE_CORRIDOR_ENCOUNTER
