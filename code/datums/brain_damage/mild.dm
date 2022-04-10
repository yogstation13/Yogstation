//Mild traumas are the most common; they are generally minor annoyances.
//They can be cured with mannitol and patience, although brain surgery still works.
//Most of the old brain damage effects have been transferred to the dumbness trauma.

/datum/brain_trauma/mild

/datum/brain_trauma/mild/hallucinations
	name = "Hallucinations"
	desc = "Patient suffers constant hallucinations."
	scan_desc = "schizophrenia"
	gain_text = ""
	lose_text = ""

/datum/brain_trauma/mild/hallucinations/on_life()
	owner.hallucination = min(owner.hallucination + 10, 50)
	..()

/datum/brain_trauma/mild/hallucinations/on_lose()
	owner.hallucination = 0
	..()

/datum/brain_trauma/mild/reality_dissociation
	name = "Reality Dissociation Syndrome"
	desc = "Patient suffers from acute reality dissociation syndrome and experiences vivid hallucinations"
	scan_desc = "reality dissociation syndrome"
	gain_text = span_userdanger("...")
	lose_text = span_notice("You feel in tune with the world again.")
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/mild/reality_dissociation/on_life()
	if(owner.reagents.has_reagent(/datum/reagent/toxin/mindbreaker, needs_metabolizing = TRUE))
		owner.hallucination = 0
	else if(prob(2))
		owner.hallucination += rand(10, 25)
	..()

/datum/brain_trauma/mild/reality_dissociation/on_lose()
	owner.hallucination = 0
	..()

/datum/brain_trauma/mild/stuttering
	name = "Stuttering"
	desc = "Patient can't speak properly."
	scan_desc = "reduced mouth coordination"
	gain_text = ""
	lose_text = ""

/datum/brain_trauma/mild/stuttering/on_life()
	owner.stuttering = min(owner.stuttering + 5, 25)
	..()

/datum/brain_trauma/mild/stuttering/on_lose()
	owner.stuttering = 0
	..()

/datum/brain_trauma/mild/dumbness
	name = "Dumbness"
	desc = "Patient has reduced brain activity, making them less intelligent."
	scan_desc = "reduced brain activity"
	gain_text = ""
	lose_text = ""

/datum/brain_trauma/mild/dumbness/on_gain()
	ADD_TRAIT(owner, TRAIT_DUMB, TRAUMA_TRAIT)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "dumb", /datum/mood_event/oblivious)
	..()

/datum/brain_trauma/mild/dumbness/on_life()
	owner.derpspeech = min(owner.derpspeech + 5, 25)
	if(prob(3))
		owner.emote("drool")
	else if(owner.stat == CONSCIOUS && prob(3))
		owner.say(pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage"), forced = "brain damage")
	..()

/datum/brain_trauma/mild/dumbness/on_lose()
	REMOVE_TRAIT(owner, TRAIT_DUMB, TRAUMA_TRAIT)
	owner.derpspeech = 0
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "dumb")
	..()

/datum/brain_trauma/mild/speech_impediment
	name = "Speech Impediment"
	desc = "Patient is unable to form coherent sentences."
	scan_desc = "communication disorder"
	gain_text = ""
	lose_text = ""

/datum/brain_trauma/mild/speech_impediment/on_gain()
	ADD_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/mild/speech_impediment/on_lose()
	REMOVE_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/mild/concussion
	name = "Concussion"
	desc = "Patient's brain is concussed."
	scan_desc = "concussion"
	gain_text = ""
	lose_text = ""

/datum/brain_trauma/mild/concussion/on_life()
	if(prob(5))
		switch(rand(1,11))
			if(1)
				owner.vomit()
			if(2,3)
				owner.dizziness += 10
			if(4,5)
				owner.confused += 10
				owner.blur_eyes(10)
			if(6 to 9)
				owner.slurring += 30
			if(10)
				to_chat(owner, span_notice("You forget for a moment what you were doing."))
				owner.Stun(20)
			if(11)
				to_chat(owner, span_warning("You faint."))
				owner.Unconscious(80)

	..()

/datum/brain_trauma/mild/healthy
	name = "Anosognosia"
	desc = "Patient always feels healthy, regardless of their condition."
	scan_desc = "self-awareness deficit"
	gain_text = ""
	lose_text = ""

/datum/brain_trauma/mild/healthy/on_gain()
	owner.set_screwyhud(SCREWYHUD_HEALTHY)
	..()

/datum/brain_trauma/mild/healthy/on_life()
	owner.set_screwyhud(SCREWYHUD_HEALTHY) //just in case of hallucinations
	owner.adjustStaminaLoss(-5) //no pain, no fatigue
	..()

/datum/brain_trauma/mild/healthy/on_lose()
	owner.set_screwyhud(SCREWYHUD_NONE)
	..()

/datum/brain_trauma/mild/muscle_weakness
	name = "Muscle Weakness"
	desc = "Patient experiences occasional bouts of muscle weakness."
	scan_desc = "weak motor nerve signal"
	gain_text = ""
	lose_text = ""

/datum/brain_trauma/mild/muscle_weakness/on_life()
	var/fall_chance = 1
	if(owner.m_intent == MOVE_INTENT_RUN)
		fall_chance += 2
	if(prob(fall_chance) && (owner.mobility_flags & MOBILITY_STAND))
		to_chat(owner, span_warning("Your leg gives out!"))
		owner.Paralyze(35)

	else if(owner.get_active_held_item())
		var/drop_chance = 1
		var/obj/item/I = owner.get_active_held_item()
		drop_chance += I.w_class
		if(prob(drop_chance) && owner.dropItemToGround(I))
			to_chat(owner, span_warning("You drop [I]!"))

	else if(prob(3))
		to_chat(owner, span_warning("You feel a sudden weakness in your muscles!"))
		owner.adjustStaminaLoss(50)
	..()

/datum/brain_trauma/mild/muscle_spasms
	name = "Muscle Spasms"
	desc = "Patient has occasional muscle spasms, causing them to move unintentionally."
	scan_desc = "nervous fits"
	gain_text = ""
	lose_text = ""

/datum/brain_trauma/mild/muscle_spasms/on_gain()
	owner.apply_status_effect(STATUS_EFFECT_SPASMS)
	..()

/datum/brain_trauma/mild/muscle_spasms/on_lose()
	owner.remove_status_effect(STATUS_EFFECT_SPASMS)
	..()

/datum/brain_trauma/mild/nervous_cough
	name = "Nervous Cough"
	desc = "Patient feels a constant need to cough."
	scan_desc = "nervous cough"
	gain_text = span_warning("Your throat itches incessantly...")
	lose_text = span_notice("Your throat stops itching.")

/datum/brain_trauma/mild/nervous_cough/on_life()
	if(prob(12) && !HAS_TRAIT(owner, TRAIT_SOOTHED_THROAT))
		if(prob(5))
			to_chat(owner, "<span notice='warning'>[pick("You have a coughing fit!", "You can't stop coughing!")]</span>")
			owner.Immobilize(20)
			owner.emote("cough")
			addtimer(CALLBACK(owner, /mob/.proc/emote, "cough"), 6)
			addtimer(CALLBACK(owner, /mob/.proc/emote, "cough"), 12)
		owner.emote("cough")
	..()

/datum/brain_trauma/mild/expressive_aphasia
	name = "Expressive Aphasia"
	desc = "Patient is affected by partial loss of speech leading to a reduced vocabulary."
	scan_desc = "inability to form complex sentences"
	gain_text = ""
	lose_text = ""

	var/static/list/common_words = world.file2list("strings/1000_most_common.txt")

// Returns false if word has more than 4 distinct letters
/datum/brain_trauma/mild/expressive_aphasia/proc/is_simple(word)
	var/list/distinct = list()
	for(var/i=1, i<=length(word), i++)
		var/c = lowertext(word[i])
		if(!(c in distinct) && !(c in list(".", ",", ";", "!", ":", "?")))
			distinct += c
		if(distinct.len > 4)
			return 0
	return 1

/datum/brain_trauma/mild/expressive_aphasia/proc/stutter(word)
	var/new_word = copytext(word, 1, rand(2, 5))
	if(prob(40))
		new_word += pick("- uh", "- erm")
	return new_word + "..  "

// Shuffle letters from index randNum to last letter
/datum/brain_trauma/mild/expressive_aphasia/proc/partial_shuffle(word)
	var/randNum = rand(2, 5)
	var/new_word = copytext(word, 1, randNum)
	var/list/shuffled = shuffle(text2charlist(copytext(word, randNum, length(word))))
	return new_word + jointext(shuffled, "") + word[length(word)]

/datum/brain_trauma/mild/expressive_aphasia/handle_speech(datum/source, list/speech_args)
	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		if(H.drunkenness > 10)
			return
	
	var/message = speech_args[SPEECH_MESSAGE]

	if(message)
		var/list/message_split = splittext(message, " ")
		var/list/new_message = list()

		for(var/word in message_split)
			var/suffix = ""
			var/suffix_foundon = 0
			for(var/potential_suffix in list(".", ",", ";", "!", ":", "?"))
				suffix_foundon = findtext(word, potential_suffix, -length(potential_suffix))
				if(suffix_foundon)
					suffix = copytext(word,suffix_foundon,length(word)+1)
					break

			if(suffix_foundon)
				word = copytext(word, 1, suffix_foundon)

			word = html_decode(word)

			if((length(word) < 8) || (lowertext(word) in common_words) || is_simple(word))
				new_message += word + suffix
			else
				var/new_word = ""
				if(prob(70))
					new_word += stutter(word)
					if(prob(40))
						new_word += pick(stutter(lowertext(word)), partial_shuffle(lowertext(word)) + suffix)
				else
					new_word += partial_shuffle(word) + suffix
				new_message += new_word
				break

		message = jointext(new_message, " ")

	speech_args[SPEECH_MESSAGE] = trim(message)
