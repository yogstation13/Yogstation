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
	if(isturf(cast_on))
		return FALSE
	if(cast_on.type in blacklist)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/invisible_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(ismob(victim))
		if(ishuman(victim))
			vanish_items(victim)
			caster.visible_message(span_danger("[caster] casts a spell on [victim], turning their clothes invisible!"))
			return TRUE
		to_chat(caster, span_warning("There is nothing on [victim] to make disappear"))
		return FALSE
	
	if(isobj(victim))
		vanish_target(victim)
		return TRUE

/datum/action/cooldown/spell/touch/invisible_touch/proc/vanish_items(mob/living/carbon/human/H)
	if(H.head)
		vanish_target(H.head)
	if(H.wear_mask)
		vanish_target(H.wear_mask)
	if(H.wear_suit)
		vanish_target(H.wear_suit)
	if(H.wear_neck)
		vanish_target(H.wear_neck)
	if(H.back)
		vanish_target(H.back)
	if(H.w_uniform)
		vanish_target(H.w_uniform)
	if(H.shoes)
		vanish_target(H.shoes)
	H.regenerate_icons()

	addtimer(CALLBACK(src, PROC_REF(revert_items), H), MIME_INVISIBLE_TOUCH_LENGTH+1) // +1 incase of minor lag or something


/datum/action/cooldown/spell/touch/invisible_touch/proc/vanish_target(atom/T)
	T.alpha = 0
	T.visible_message("[T] vanishes!")
	
	addtimer(CALLBACK(src, PROC_REF(revert_target), T), MIME_INVISIBLE_TOUCH_LENGTH)

/datum/action/cooldown/spell/touch/invisible_touch/proc/revert_target(atom/T)
	if(T)
		T.alpha = initial(T.alpha)
		T.visible_message("[T] reappears!")

datum/action/cooldown/spell/touch/invisible_touch/proc/revert_items(mob/living/carbon/human/H)
	H.regenerate_icons()

/obj/item/melee/touch_attack/invisible_touch
	name = "\improper vanishing hand"
	desc = "\"But I can see it!\""
	icon_state = "nothing"
	item_state = "nothing"

#undef MIME_INVISIBLE_TOUCH_LENGTH
