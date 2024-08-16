/obj/item/organ/tongue/vox
	name = "vox tongue"
	desc = "You almost swear you can hear it shrieking."
	icon_state = "tongue-vox"
	taste_sensitivity = 50 // There's not much need for taste when you're a scavenger.

/obj/item/organ/tongue/vox/Initialize(mapload)
	. = ..()
	attack_verb += "skree'd"

/obj/item/organ/tongue/vox/handle_speech(datum/source, list/speech_args)
	..()
	if(prob(20))
		playsound(owner, 'sound/voice/vox/shriek1.ogg', 25, 1, 1)
