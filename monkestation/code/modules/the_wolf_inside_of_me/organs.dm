/obj/item/organ/internal/ears/werewolf
	name = "wolf ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	icon_state = "kitty"
	desc = "Allows the user to more easily hear whispers. The user becomes extra vulnerable to loud noises, however"
	// Same sensitivity as felinid ears
	damage_multiplier = 2

/*
/obj/item/organ/internal/ears/werewolf/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	organ_traits = list(TRAIT_GOOD_HEARING)
*/

/obj/item/organ/internal/eyes/werewolf
	name = "wolf eyes"
	desc = "Large and powerful eyes."
	sight_flags = SEE_MOBS
	color_cutoffs = list(25, 5, 42)

/obj/item/organ/internal/heart/werewolf
	name = "massive heart"
	desc = "An absolutely monstrous heart."
	icon_state = "heart-on"
	base_icon_state = "heart"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
/obj/item/organ/internal/heart/wolf/Initialize(mapload)
	. = ..()
	transform = transform.Scale(1.5)

/obj/item/organ/internal/liver/werewolf

	name = "Beastly liver"
	desc = "A large monstrous liver."
	icon_state = "liver"
	///Var for brute healing via blood
	var/blood_brute_healing = 2.5
	///Var for burn healing via blood
	var/blood_burn_healing = 2.5


/obj/item/organ/internal/liver/werewolf/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, times_fired)
	. = ..()
	//parent returned COMSIG_MOB_STOP_REAGENT_CHECK or we are failing
	if((. & COMSIG_MOB_STOP_REAGENT_CHECK) || (organ_flags & ORGAN_FAILING))
		return
	if(istype(chem, /datum/reagent/silver))
		organ_owner.stamina?.adjust(7.5 * REM * seconds_per_tick)
		organ_owner.adjustFireLoss(5.0 * REM * seconds_per_tick, updating_health = TRUE)


/obj/item/organ/internal/tongue/werewolf
	name = "wolf tongue"
	desc = "A large tongue that looks like a mix of a human's and a wolf's."
	icon_state = "werewolf_tongue"
	icon = 'monkestation/code/modules/the_wolf_inside_of_me/icons/mutant_bodyparts.dmi'
	say_mod = "growls"
	modifies_speech = TRUE
	taste_sensitivity = 5
	//liked_foodtypes = GROSS | MEAT | RAW | GORE
	//disliked_foodtypes = SUGAR

/obj/item/organ/internal/tongue/werewolf/modify_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")

		// all occurrences of characters "eiou" (case-insensitive) are replaced with "r"
		message = replacetext(message, regex(@"[eiou]", "ig"), "r")
		// all characters other than "zhrgbmna .!?-" (case-insensitive) are stripped
		message = replacetext(message, regex(@"[^zhrgbmna.!?-\s]", "ig"), "")
		// multiple spaces are replaced with a single (whitespace is trimmed)
		message = replacetext(message, regex(@"(\s+)", "g"), " ")

		var/list/old_words = splittext(message, " ")
		var/list/new_words = list()
		for(var/word in old_words)
			// lower-case "r" at the end of words replaced with "rh"
			word = replacetext(word, regex(@"\lr\b"), "rh")
			// an "a" or "A" by itself will be replaced with "hra"
			word = replacetext(word, regex(@"\b[Aa]\b"), "hra")
			new_words += word

		message = new_words.Join(" ")
		message = capitalize(message)
		speech_args[SPEECH_MESSAGE] = message
