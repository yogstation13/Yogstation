/mob/living/basic/slugcat
	death_sound = 'monkestation/sound/effects/slugcat/death.ogg'

	// language_holder = /datum/language_holder/slugcat
	initial_language_holder = /datum/language_holder/slugcat

/datum/language/wawa
	name = "Slosh"
	desc = "The language of the slugcats. They have mastered the art of conveying complex thoughts just using one versatile syllable."
	key = "w"
	syllables = list("wawa")
	default_priority = 70

	icon_state = "wawa"
	icon = 'monkestation/icons/misc/language.dmi'

/datum/language_holder/slugcat
	understood_languages = list(/datum/language/common = list(LANGUAGE_MIND),
								/datum/language/wawa = list(LANGUAGE_MIND))
	spoken_languages = list(/datum/language/wawa = list(LANGUAGE_MIND))

// wawa
/datum/emote/living/wawa
	key = "wawa"
	key_third_person = "wawas"
	message = "goes wawa!"
	message_param = "wawa's at %t!"
	message_mime = "wawa's silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	cooldown = 10
	audio_cooldown = 10

/datum/emote/living/wawa/get_sound(mob/living/user)
	return pick(
		'monkestation/sound/effects/slugcat/wawa1.ogg',
		'monkestation/sound/effects/slugcat/wawa2.ogg',
		'monkestation/sound/effects/slugcat/wawa3.ogg',
		'monkestation/sound/effects/slugcat/wawa4.ogg',
	)

/datum/emote/living/wawa/can_run_emote(mob/user, status_check, intentional)
	return ..() && isslugcat(user)

// wa
/datum/emote/living/wa
	key = "wa"
	key_third_person = "wa"
	message = "goes wa!"
	message_param = "wa's at %t!"
	message_mime = "wa's silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	audio_cooldown = 1.8 SECONDS

/datum/emote/living/wa/get_sound(mob/living/user)
	return pick(
		'monkestation/sound/effects/slugcat/wa1.ogg',
		'monkestation/sound/effects/slugcat/wa2.ogg',
		'monkestation/sound/effects/slugcat/wa3.ogg',
		'monkestation/sound/effects/slugcat/wa4.ogg',
		'monkestation/sound/effects/slugcat/wa5.ogg',
		'monkestation/sound/effects/slugcat/wa6.ogg',
		'monkestation/sound/effects/slugcat/wa7.ogg',
		'monkestation/sound/effects/slugcat/wa8.ogg',
	)

/datum/emote/living/wa/can_run_emote(mob/user, status_check, intentional)
	return ..() && isslugcat(user)
