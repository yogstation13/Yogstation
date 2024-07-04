/datum/emote/living/carbon/human/scream
	message_vox = "shrieks!"

/datum/emote/living/carbon/human/quill
	key = "quill"
	key_third_person = "quills"
	message = "rustles their quills."
	message_param = "rustles their quills at %t."
	emote_type = EMOTE_AUDIBLE
	// Credit to sound-ideas (freesfx.co.uk) for the sound.

/datum/emote/living/carbon/human/quill/get_sound(mob/living/user)
	return 'sound/effects/voxrustle.ogg'

/datum/emote/living/carbon/human/quill/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	if(!.)
		return FALSE
	if(!isvox(user))
		return FALSE
