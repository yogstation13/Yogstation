/datum/action/cooldown/spell/touch/envy
	name = "Vanity Steal"
	desc = "Engulfs your arm in a jealous might, allowing you to steal the look of the first human-like struck with it. Note, the form change is not reversible."
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "transform"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	school = SCHOOL_EVOCATION
	invocation = "I'M BETTER THAN YOU!!"
	invocation_type = INVOCATION_WHISPER
	
	cooldown_time = 15 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN

	hand_path = /obj/item/melee/touch_attack/envy
	///The ID acess we store
	var/list/stored_access

/datum/action/cooldown/spell/touch/envy/Grant(mob/living/caster)
	. = ..()
	RegisterSignal(caster, COMSIG_MOB_ALLOWED, PROC_REF(envy_access))

/datum/action/cooldown/spell/touch/envy/Remove(mob/living/caster)
	UnregisterSignal(caster, COMSIG_MOB_ALLOWED)
	return ..()

/datum/action/cooldown/spell/touch/envy/proc/envy_access(datum/source, obj/access_checker)
	return access_checker.check_access_list(stored_access)

/datum/action/cooldown/spell/touch/envy/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/touch/envy/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	if(!istype(target))
		return FALSE
	if(target.can_block_magic())
		to_chat(caster, span_warning("[target] resists your unholy jealousy!"))
		to_chat(target, span_warning("A creeping feeling of jealousy dances around your mind before being suddenly dispelled."))
		return FALSE
	playsound(caster, 'sound/magic/demon_attack1.ogg', 75, TRUE)

	if(caster.real_name == target.dna.real_name)
		caster.balloon_alert(caster, "you are already [target]!")
		return FALSE

	var/obj/item/card/id/ID = target.get_idcard()
	stored_access = LAZYCOPY(ID?.access)
	caster.fully_replace_character_name(caster.real_name, target.dna.real_name)
	target.dna.transfer_identity(caster, transfer_SE=1)
	caster.updateappearance(mutcolor_update=1)
	caster.domutcheck()
	caster.visible_message(
	span_warning("[caster]'s appearance shifts into [target]'s!"), \
	span_boldannounce("[target.p_they(TRUE)] think[target.p_s()] [target.p_theyre()] \
				<i>sooo</i> much better than you. Not anymore, [target.p_they()] won't.")
	)
	
	return TRUE

/obj/item/melee/touch_attack/envy
	name = "Envious Hand"
	desc = "A writhing, burning aura of jealousy, ready to be unleashed."
	icon_state = "flagellation"
	item_state = "hivemind"
