/datum/action/cooldown/spell/touch/envy
	name = "Vanity Steal"
	desc = "Engulfs your arm in a jealous might, allowing you to steal the look of the first human-like struck with it. Note, the form change is not reversible."
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "transform"
	background_icon_state = "bg_demon"

	school = SCHOOL_EVOCATION
	invocation = "I'M BETTER THAN YOU!!"
	invocation_type = INVOCATION_WHISPER
	
	cooldown_time = 15 SECONDS
	spell_requirements = NONE

	hand_path = /obj/item/melee/touch_attack/envy
	///The ID acess we store
	var/list/stored_access

/datum/action/cooldown/spell/touch/envy/Grant(mob/living/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_ALLOWED, PROC_REF(envy_access))

/datum/action/cooldown/spell/touch/envy/Remove(mob/living/user)
	UnregisterSignal(user, COMSIG_MOB_ALLOWED)
	return ..()

/datum/action/cooldown/spell/touch/envy/proc/envy_access(datum/source, obj/access_checker)
	return access_checker.check_access_list(stored_access)

/obj/item/melee/touch_attack/envy
	name = "Envious Hand"
	desc = "A writhing, burning aura of jealousy, ready to be unleashed."
	icon_state = "flagellation"
	item_state = "hivemind"

/obj/item/melee/touch_attack/envy/afterattack(atom/target, mob/living/carbon/human/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	var/mob/living/living_target = target
	if(living_target.anti_magic_check())
		to_chat(user, span_warning("[living_target] resists your unholy jealousy!"))
		to_chat(living_target, span_warning("A creeping feeling of jealousy dances around your mind before being suddenly dispelled."))
		return ..()
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/human_target = target
	if(user.real_name == human_target.dna.real_name)
		return

	var/datum/action/cooldown/spell/touch/envy/envy_spell = spell_which_made_us?.resolve()
	var/obj/item/card/id/ID = human_target.get_idcard()
	envy_spell?.stored_access = ID?.access
	user.fully_replace_character_name(user.real_name, human_target.dna.real_name)
	human_target.dna.transfer_identity(user, transfer_SE=1)
	user.updateappearance(mutcolor_update=1)
	user.domutcheck()
	user.visible_message(
	span_warning("[user]'s appearance shifts into [human_target]'s!"), \
	span_boldannounce("[human_target.p_they(TRUE)] think[human_target.p_s()] human_targetH.p_theyre()] \
				<i>sooo</i> much better than you. Not anymore, [human_target.p_they()] won't.")
	)
	return ..()
