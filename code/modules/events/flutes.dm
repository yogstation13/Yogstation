///
//randomly pick people from a short list
//add ability to cure sanity instability with psychatrist?
//add goals?
//xoxeyos

//---------
//UTILITIES
//---------
/proc/list_intersection(var/list/A, var/list/B)
	var/intersection[0]
	for(var/item in A)
		if(item in B)
			intersection.Add(item)
	return intersection

//----------------------------
//ROUND EVENT CONTROL "FLUTES"
//----------------------------
/datum/round_event_control/flutes
	name = "Flutes"
	typepath = /datum/round_event/flutes
	max_occurrences = 1
	weight = 0
	min_players = 30

//--------------------
//ROUND EVENT "FLUTES"
//--------------------
//OBJECT DEF
/datum/round_event/flutes
	var/chosen_players[0]

//ROUND START PROC
//This gets executed at the start of the round
/datum/round_event/flutes/start()
	var/list/remaining_players = list_intersection(GLOB.player_list, GLOB.alive_mob_list)
	var/number_of_players_to_select = round((remaining_players.len / 10), 1)
	for(var/i; i<=(number_of_players_to_select == 0 ? 1 : number_of_players_to_select); i++)
		var/player = remaining_players[rand(1, remaining_players.len)]
		sound_intro(player)
		pick_flute_scene(player)
		remaining_players.Remove(player)
		chosen_players.Add(player)

//EVENT PROCS
/datum/round_event/flutes/proc/sound_intro(mob/living/carbon/M)
	if((M.client.prefs.toggles & SOUND_MIDI) && is_station_level(M.loc.z))
		M.playsound_local(M, 'sound/ambience/flutes.ogg', 20, FALSE, pressure_affected = FALSE)

/datum/round_event/flutes/proc/pick_flute_scene(mob/living/carbon/M)
	var/flutes_chosen_scene
	switch(rand(1, 6))
		if(1)
			flutes_chosen_scene = "flute_vis_flicker"
			flute_vis_flicker(M)
		if(2)
			flutes_chosen_scene = "flute_headache"
			flute_headache(M)
		if(3)
			flutes_chosen_scene = "flute_tremble"
			flute_tremble(M)
		if(4)
			flutes_chosen_scene = "flute_chanting"
			flute_chanting(M)
		if(5)
			flutes_chosen_scene = "flute_starlight"
			flute_starlight(M)
		if(6)
			flutes_chosen_scene = "flute_corridor_encounter"
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
	sleep(30000)
	M.blur_eyes(40)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 65, 70, 80)
	ADD_TRAIT(M, TRAIT_UNSTABLE, M)
	//sanity = 50
	sleep(25000)
	to_chat(M, "<span class='warning'><b>Exhaustion takes you.</b></span>")
	M.SetSleeping(70)
	to_chat(M, "<span class='notice'><b>You see vague, inhuman forms, in the tightest corners of your alien dreams, dancing frantically to thundering drums, in tune with yellow monotone flutes.</b></span>")
	sleep(25000)
	M.adjustBruteLoss(15)
	to_chat(M, "<span class='notice'><b>You wake from your deep dreams, blood oozing from your nose, while your head beats to a familiar tune.</b></span>")

/datum/round_event/flutes/proc/flute_corridor_encounter(mob/living/carbon/M)
	to_chat(M, "<span class='notice'><b>You glance upwards, down the corridor.</b></span>")
	sleep(5000)
	to_chat(M, "span class='bold large_brass'><b>A BRIGHT BLINDING LIGHT FILLS YOUR VISION!</b></span>")
	M.eye_blind = 5
	sleep(10000)
	to_chat(M, "<span class='reallybig hypnophrase'><b>Your mind oozes at what it cannot comprehend, you feel your soul snatching onto your brain, with chills rolling up your spine. You barely hang on.</b></span>")
	if(HAS_TRAIT(M, TRAIT_UNSTABLE))
		to_chat(M, "<span class='green'><b>Your mind shatters.</b></span>")
		M.SetSleeping(30)
		sleep(30000)
		to_chat(M, "<span class='suicide'><b>Your flesh undulates, and boils off your bones. You were blind, yet now you've seen a glimpse behind the cosmic curtain.</b></span>")
		//sanity = 25
		REMOVE_TRAIT(M, TRAIT_UNSTABLE, M)
		M.blur_eyes(5)
		M.adjustStaminaLoss(90)
		M.adjustBruteLoss(90)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 90)
		M.set_species(/datum/species/skeleton)
		sleep(30000)
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
