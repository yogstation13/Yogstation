/datum/round_event_control/minispasm
	name = "Minispasms"
	typepath = /datum/round_event/minispasm
	weight = 8
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/minispasm
	startWhen = 60
	endWhen = 90
	var/static/list/psi_operancy_messages = list(
		"There's something in your skull!",
		"Something is eating your thoughts!",
		"You can feel your brain being rewritten!",
		"Something is crawling over your frontal lobe!",
		"<b>THE SIGNAL THE SIGNAL THE SIGNAL THE SIGNAL THE</b>",
		"Something is drilling through your skull!",
		"Your head feels like it's going to implode!",
		"Thousands of ants are tunneling in your head!"
		)

/datum/round_event/minispasm/announce()
	priority_announce( \
		"PRIORITY ALERT: SIGMA-[rand(50,80)] NON-STANDARD PSIONIC SIGNAL-WAVE TRANSMISSION DETECTED - 97% MATCH, NON-VARIANT \
		SIGNAL SOURCE TRIANGULATED TO DISTANT SITE: All personnel are advised to avoid \
		exposure to active audio transmission equipment including radio headsets and intercoms \
		for the duration of the signal broadcast.", 
		"Central Command Higher Dimensional Affairs")

/datum/round_event/minispasm/start()
	var/list/victims = list()
	for(var/obj/item/radio/radio in world)
		if(radio.on)
			for(var/mob/living/victim in range(radio.canhear_range, radio.loc))
				if(!isnull(victims[victim]) || victim.stat != CONSCIOUS || HAS_TRAIT(victim, TRAIT_DEAF))
					continue
				victims[victim] = radio
	for(var/thing in victims)
		var/mob/living/victim = thing
		var/obj/item/radio/source = victims[victim]
		do_spasm(victim, source)

/datum/round_event/minispasm/proc/do_spasm(mob/living/victim, obj/item/radio/source)
	if(victim.psi)
		playsound(source, 'sound/creatures/narsie_rises.ogg', 75) //LOUD AS FUCK BOY
		to_chat(victim, span_danger("A hauntingly familiar sound hisses from \icon[source] \the [source], and your vision flickers!"))
		victim.psi.backblast(rand(5,15))
		victim.Paralyze(5)
		victim.Jitter(100)
	else
		victim.visible_message(span_danger("[victim] starts having a seizure!"), span_userdanger("An indescribable, brain-tearing sound hisses from \icon[source] \the [source], and you collapse in a seizure!"))
		victim.Unconscious(200)
		victim.Jitter(10)
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "minispasm", /datum/mood_event/epilepsy)
		var/new_latencies = rand(2,4)
		var/list/faculties = list(PSI_COERCION, PSI_REDACTION, PSI_ENERGISTICS, PSI_PSYCHOKINESIS)
		for(var/i = 1 to new_latencies)
			to_chat(victim, span_danger("<font size = 3>[pick(psi_operancy_messages)]</font>"))
			victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(10,20))
			victim.set_psi_rank(pick_n_take(faculties), 1)
			sleep(30)
		victim.psi.update()
	sleep(45)
	victim.psi.check_latency_trigger(100, "a psionic scream", redactive = TRUE)

/datum/round_event/minispasm/end()
	priority_announce( \
		"PRIORITY ALERT: SIGNAL BROADCAST HAS CEASED. Personnel are cleared to resume use of non-hardened radio transmission equipment. Have a nice day.", 
		"Central Command Higher Dimensional Affairs")
