/datum/brain_trauma/special/obsessed
	name = "Psychotic Schizophrenia"
	desc = "Patient has a subtype of delusional disorder, becoming irrationally attached to someone."
	scan_desc = "psychotic schizophrenic delusions"
	gain_text = "If you see this message, make a github issue report. The trauma initialized wrong."
	lose_text = span_warning("The voices in your head fall silent.")
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_SURGERY
	var/mob/living/obsession
	var/datum/mind/obsessedmind
	var/datum/objective/spendtime/attachedobsessedobj
	var/datum/antagonist/obsessed/antagonist
	var/viewing = FALSE //it's a lot better to store if the owner is watching the obsession than checking it twice between two procs

	var/total_time_creeping = 0 //just for roundend fun
	var/time_spent_away = 0
	var/obsession_hug_count = 0

/datum/brain_trauma/special/obsessed/on_gain()

	//setup, linking, etc//
	if(!obsession)//admins didn't set one
		obsession = find_obsession()
		if(!obsession)//we didn't find one
			lose_text = ""
			qdel(src)
			return
	obsessedmind = obsession.mind
	gain_text = span_warning("You hear a sickening, raspy voice in your head. It wants one small task of you...")
	owner.mind.add_antag_datum(/datum/antagonist/obsessed)
	antagonist = owner.mind.has_antag_datum(/datum/antagonist/obsessed)
	antagonist.trauma = src
	RegisterSignal(obsession, COMSIG_MOB_EYECONTACT, .proc/stare)
	..()
	//antag stuff//
	antagonist.forge_objectives(obsession.mind)
	antagonist.greet()

/datum/brain_trauma/special/obsessed/on_life()
	if(obsessedmind.current != obsession) //ensure we keep our target body up to date
		obsession = obsessedmind.current
	if(!obsession || obsession.stat == DEAD)
		viewing = FALSE//important, makes sure you no longer stutter when happy if you murdered them while viewing
		return
	if(get_dist(get_turf(owner), get_turf(obsession)) > 7)
		viewing = FALSE //they are further than our viewrange they are not viewing us
		out_of_view()
		return//so we're not searching everything in view every tick
	if(obsession in view(7, owner))
		viewing = TRUE
	else
		viewing = FALSE
	if(viewing)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/creeping, obsession.name)
		total_time_creeping += 20
		time_spent_away = 0
		if(attachedobsessedobj)//if an objective needs to tick down, we can do that since traumas coexist with the antagonist datum
			attachedobsessedobj.timer -= 20 //mob subsystem ticks every 2 seconds(?), remove 20 deciseconds from the timer. sure, that makes sense.
	else
		out_of_view()

/datum/brain_trauma/special/obsessed/proc/out_of_view()
	time_spent_away += 20
	if(time_spent_away > 1800) //3 minutes
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/notcreepingsevere, obsession.name)
	else
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/notcreeping, obsession.name)

/datum/brain_trauma/special/obsessed/on_lose()
	..()
	owner.mind.remove_antag_datum(/datum/antagonist/obsessed)
	UnregisterSignal(obsession, COMSIG_MOB_EYECONTACT)

/datum/brain_trauma/special/obsessed/handle_speech(datum/source, list/speech_args)
	if(!viewing)
		return
	if(prob(25)) // 25% chances to be nervous and stutter.
		if(prob(50)) // 12.5% chance (previous check taken into account) of doing something suspicious.
			addtimer(CALLBACK(src, .proc/on_failed_social_interaction), rand(1, 3) SECONDS)
		else if(!owner.stuttering)
			to_chat(owner, span_warning("Being near [obsession] makes you nervous and you begin to stutter..."))
		owner.stuttering = max(3, owner.stuttering)

/datum/brain_trauma/special/obsessed/on_hug(mob/living/hugger, mob/living/hugged)
	if(hugged == obsession)
		obsession_hug_count++

/datum/brain_trauma/special/obsessed/proc/on_failed_social_interaction()
	if(QDELETED(owner) || owner.stat >= UNCONSCIOUS)
		return
	switch(rand(1, 100))
		if(1 to 40)
			INVOKE_ASYNC(owner, /mob.proc/emote, pick("blink", "blink_r"))
			owner.blur_eyes(10)
			to_chat(owner, span_userdanger("You sweat profusely and have a hard time focusing..."))
		if(41 to 80)
			INVOKE_ASYNC(owner, /mob.proc/emote, "pale")
			shake_camera(owner, 15, 1)
			owner.adjustStaminaLoss(70)
			to_chat(owner, span_userdanger("You feel your heart lurching in your chest..."))
		if(81 to 100)
			INVOKE_ASYNC(owner, /mob.proc/emote, "cough")
			owner.dizziness += 10
			owner.adjust_disgust(5)
			to_chat(owner, span_userdanger("You gag and swallow a bit of bile..."))

/datum/brain_trauma/special/obsessed/proc/stare(datum/source, mob/living/examining_mob, triggering_examiner)

	if(examining_mob != owner || !triggering_examiner || prob(50))
		return
	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, obsession, span_warning("You catch [examining_mob] staring at you...")), 3)
	return COMSIG_BLOCK_EYECONTACT

/datum/brain_trauma/special/obsessed/proc/find_obsession()
	var/chosen_victim
	var/list/possible_targets = list()
	var/list/viable_minds = list()
	for(var/mob/Player in GLOB.player_list)//prevents crewmembers falling in love with nuke ops they never met, and other annoying hijinks
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) && !isbrain(Player) && Player.client && Player != owner && SSjob.GetJob(Player.mind.assigned_role))
			viable_minds += Player.mind
	for(var/datum/mind/possible_target in viable_minds)
		if(possible_target != owner && ishuman(possible_target.current))
			possible_targets += possible_target.current
	if(possible_targets.len > 0)
		chosen_victim = pick(possible_targets)
	return chosen_victim
