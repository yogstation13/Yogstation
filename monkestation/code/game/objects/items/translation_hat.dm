/obj/item/clothing/mask/translator
	name = "MonkeTech AutoTranslator"
	desc = "A small device that will translate speech."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	icon_state = "translator"
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	worn_icon_state = "translator"
	slot_flags = ITEM_SLOT_MASK | ITEM_SLOT_NECK
	modifies_speech = TRUE
	var/current_language = /datum/language/common

/obj/item/clothing/mask/translator/proc/generate_language_names(mob/user)
	var/static/list/language_name_list
	if(!language_name_list)
		language_name_list = list()
		for(var/language in user.mind.language_holder.understood_languages)
			if(language in user.mind.language_holder.blocked_languages)
				continue
			var/atom/A = language
			language_name_list[initial(A.name)] = A
	return language_name_list

/obj/item/clothing/mask/translator/attack_self(mob/user)
	. = ..()
	if(ishuman(user))
		var/list/display_names = generate_language_names(user)
		if(!display_names.len > 1)
			return
		var/choice = input(user,"Please select a language","Select a language:") as null|anything in sort_list(display_names)
		if(!choice)
			return
		current_language = display_names[choice]

/obj/item/clothing/mask/translator/equipped(mob/M, slot)
	. = ..()
	if ((slot == ITEM_SLOT_MASK || slot == ITEM_SLOT_NECK) && modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/translator/handle_speech(datum/source, list/speech_args)
	. = ..()
	if(!(clothing_flags * (VOICEBOX_DISABLED)))
		if(obj_flags & EMAGGED)
			speech_args[SPEECH_LANGUAGE] = pick(GLOB.all_languages)
		else
			speech_args[SPEECH_LANGUAGE] = current_language

/obj/item/clothing/mask/translator/examine(mob/user)
	. = ..()
	. += span_notice("Click while in hand to select output language.")

/obj/item/clothing/mask/translator/emag_act()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	icon_state = "translator_emag"
	playsound(src, "sparks", 100, 1)
