#define MIME_INVISIBLE_TOUCH_LENGTH 16 SECONDS

/datum/action/cooldown/spell/touch/invisible_touch
	name = "Invisible Touch"
	desc = "Touch something to make it disappear temporarily."
	background_icon_state = "bg_mime"
	overlay_icon_state = "bg_mime_border"
	button_icon = 'icons/obj/wizard.dmi'
	button_icon_state = "nothing"
	panel = "Mime"

	invocation = ""
	invocation_type = INVOCATION_EMOTE
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIME_VOW
	antimagic_flags = NONE

	school = SCHOOL_MIME
	cooldown_time = MIME_INVISIBLE_TOUCH_LENGTH * 2
	spell_max_level = 1

	hand_path = /obj/item/melee/touch_attack/invisible_touch
	draw_message = span_notice("You channel mime power into your hand.")
	drop_message = span_notice("You let the power from your hand dissipate.")

	var/list/things = list()
	var/list/blacklist = list (
        /obj/machinery/nuclearbomb/selfdestruct,
        /obj/structure/closet
        )

/datum/action/cooldown/spell/touch/invisible_touch/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/touch/invisible_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(isturf(victim))
		return FALSE
	if(victim in blacklist)
		to_chat(caster, span_warning("[victim] is too dangerous to mess with!"))
		return FALSE
	if(iscarbon(victim))
		to_chat(caster, span_warning("It doesn't work on other people!")) // Not yet at least
		return FALSE
	if(isobj(victim))
		vanish_target(victim)
	return TRUE

/datum/action/cooldown/spell/touch/invisible_touch/proc/vanish_target(atom/T)
	T.alpha = 0
	T.visible_message("[T] vanishes!")
	
	addtimer(CALLBACK(src, PROC_REF(revert_target), T), MIME_INVISIBLE_TOUCH_LENGTH)

/datum/action/cooldown/spell/touch/invisible_touch/proc/revert_target(atom/T)
	if(T)
		T.alpha = initial(T.alpha)
		T.visible_message("[T] reappears!")

/obj/item/melee/touch_attack/invisible_touch
	name = "\improper vanishing hand"
	desc = "\"But I can see it!\""
	icon_state = "nothing"
	item_state = "nothing"

#undef MIME_INVISIBLE_TOUCH_LENGTH
