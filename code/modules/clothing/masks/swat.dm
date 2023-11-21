/obj/item/clothing/mask/gas/sechailer/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000."
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/dispatch)
	icon_state = "swat"
	item_state = "swat"
	aggressiveness = 3
	flags_inv = HIDEFACIALHAIR|HIDEFACE|HIDEEYES|HIDEEARS|HIDEHAIR
	visor_flags_inv = 0
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/mask/gas/sechailer/swat/encrypted
	name = "\improper MK.II SWAT mask"
	desc = "A top-grade mask that encrypts your voice, allowing only other users of the same mask to understand you. \
			There are some buttons with basic commands to control the locals."

/obj/item/clothing/mask/gas/sechailer/swat/encrypted/equipped(mob/living/user)
	. = ..()
	user.add_blocked_language(subtypesof(/datum/language) - /datum/language/encrypted, LANGUAGE_HAT)
	user.grant_language(/datum/language/encrypted, TRUE, TRUE, LANGUAGE_HAT)

/obj/item/clothing/mask/gas/sechailer/swat/encrypted/dropped(mob/living/user)
	user.remove_blocked_language(subtypesof(/datum/language), LANGUAGE_HAT)
	user.remove_language(/datum/language/encrypted, TRUE, TRUE, LANGUAGE_HAT)
	return ..()

/obj/item/clothing/mask/gas/sechailer/swat/encrypted/handle_speech(mob/living/carbon/source, mob/speech_args)
	if(source.wear_mask == src)
		var/chosen_sound = file("sound/voice/cpvoice/ds ([rand(1,27)]).ogg")
		playsound(source, chosen_sound, 50, FALSE)
