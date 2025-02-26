/obj/item/organ/internal/tongue/robot/clockwork
	name = "dynamic micro-phonograph"
	desc = "An old-timey looking device connected to an odd, shifting cylinder."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "tongueclock"

/obj/item/organ/internal/tongue/robot/clockwork/better
	name = "amplified dynamic micro-phonograph"

/obj/item/organ/internal/tongue/robot/clockwork/better/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT
	//speech_args[SPEECH_SPANS] |= SPAN_REALLYBIG  //i disabled this, its abnoxious and makes their chat take 3 times as much space in chat

/obj/item/organ/internal/tongue/arachnid
	name = "arachnid tongue"
	desc = "The tongue of an Arachnid. Mostly used for lying."
	say_mod = "chitters"
	modifies_speech = TRUE
	disliked_foodtypes = NONE // Okay listen, i don't actually know what irl spiders don't like to eat and i'm pretty tired of looking for answers.
	liked_foodtypes = GORE | MEAT | BUGS | GROSS

/obj/item/organ/internal/tongue/arachnid/get_scream_sound()
	return 'monkestation/sound/voice/screams/arachnid/arachnid_scream.ogg'

/obj/item/organ/internal/tongue/arachnid/get_laugh_sound()
	return 'monkestation/sound/voice/laugh/arachnid/arachnid_laugh.ogg'

/obj/item/organ/internal/tongue/arachnid/modify_speech(datum/source, list/speech_args) //This is flypeople speech
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
		message = replacetext(message, "s", "z")
		message = replacetext(message, "S", "Z")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/internal/tongue/arachnid/get_possible_languages()
	return ..() + /datum/language/buzzwords

/obj/item/organ/internal/tongue/jelly
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/tongue/jelly/get_possible_languages()
	return ..() + /datum/language/slime

/obj/item/organ/internal/tongue/synth
	name = "synthetic voicebox"
	desc = "A fully-functional synthetic tongue, encased in soft silicone. Features include high-resolution vocals and taste receptors."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "cybertongue"
	say_mod = "beeps"
	attack_verb_continuous = list("beeps", "boops")
	attack_verb_simple = list("beep", "boop")
	modifies_speech = TRUE
	liked_foodtypes = NONE
	disliked_foodtypes = NONE
	toxic_foodtypes = NONE
	taste_sensitivity = 25 // not as good as an organic tongue
	organ_traits = list(TRAIT_SILICON_EMOTES_ALLOWED)
	maxHealth = 100 //RoboTongue!
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_TONGUE
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/tongue/synth/get_scream_sound()
	return 'monkestation/sound/voice/screams/silicon/scream_silicon.ogg'

/obj/item/organ/internal/tongue/synth/get_laugh_sound()
	if(owner.gender == FEMALE)
		return pick(
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF0.ogg', 
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF1.ogg', 
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF2.ogg',
		)		
	if(owner.gender == MALE)
		return pick(
			'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M0.ogg', 
			'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M1.ogg', 
			'monkestation/sound/voice/laugh/silicon/laugh_siliconM2.ogg',
		)
	else
		return pick(
			'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M0.ogg', 
			'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M1.ogg', 
			'monkestation/sound/voice/laugh/silicon/laugh_siliconM2.ogg', 
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF0.ogg', 
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF1.ogg', 
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF2.ogg',
		)

/obj/item/organ/internal/tongue/synth/can_speak_language(language)
	return TRUE

/obj/item/organ/internal/tongue/synth/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/datum/design/synth_tongue
	name = "Synthetic Tongue"
	desc = "A fully-functional synthetic tongue, encased in soft silicone. Features include high-resolution vocals and taste receptors."
	id = "synth_tongue"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/tongue/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_SYNTHETIC_ORGANS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE
