/datum/action/cooldown/spell/touch/invisible_touch
	name = "Invisible Touch"
	desc = "Touch somthing to make it disapear temporarily."
	background_icon_state = "bg_mime"
	overlay_icon_state = "bg_mime_border"
	button_icon = 'icons/mob/actions/actions_mime.dmi'// todo all sprites and such
	button_icon_state = "mime_speech"
	panel = "Mime"

	invocation_type = INVOCATION_EMOTE
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIME_VOW
	antimagic_flags = NONE

	school = SCHOOL_MIME
	cooldown_time = 1 MINUTES
	spell_max_level = 1

	hand_path = /obj/item/melee/touch_attack/invisible_touch

	var/list/things = list()
	var/list/blacklist = list (
        /obj/machinery/nuclearbomb/selfdestruct,
        /obj/structure/closet
        )

/datum/action/cooldown/spell/touch/invisible_touch/Destroy()
	for(var/obj/O in things)
		if(!O.alpha)
			reverttarget(O)
	..()

/datum/action/cooldown/spell/touch/invisible_touch/is_valid_target(atom/cast_on)
	// Do not supercall this
	. = TRUE
	//if(cast_on in blacklist)
	//	. = FALSE
	return

/datum/action/cooldown/spell/touch/invisible_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	. = ..()
	if(victim in blacklist)
		to_chat(caster, span_warning("[victim] is too dangerous to mess with!"))
		return
	if(iscarbon(victim))
		to_chat(caster, span_warning("It doesn't work on other people!")) // Not yet at least
		return
	if(isobj(victim))
		victim.alpha = 0
		victim.visible_message("[victim] vanishes!")
	
		addtimer(CALLBACK(src, PROC_REF(reverttarget), victim), 8 SECONDS)
	return TRUE

/datum/action/cooldown/spell/touch/invisible_touch/proc/reverttarget(atom/A)
	if(A)
		A.alpha = initial(A.alpha)
		A.visible_message("[A] reappears!")

/obj/item/melee/touch_attack/invisible_touch
	name = "\improper vanishing hand"
	desc = "\"But I can see it!\""
