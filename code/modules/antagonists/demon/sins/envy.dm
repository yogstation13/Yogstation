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
	spell_requirements = NONE

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

/obj/item/melee/touch_attack/envy
	name = "Envious Hand"
	desc = "A writhing, burning aura of jealousy, ready to be unleashed."
	icon_state = "flagellation"
	item_state = "hivemind"

/datum/action/cooldown/spell/touch/envy/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/mob/living/living_victim = victim
	if(living_victim.anti_magic_check())
		to_chat(caster, span_warning("[living_victim] resists your unholy jealousy!"))
		to_chat(living_victim, span_warning("A creeping feeling of jealousy dances around your mind before being suddenly dispelled."))
		return TRUE
	playsound(caster, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(!ishuman(victim))
		return FALSE

	var/mob/living/carbon/human/human_victim = victim
	if(caster.real_name == human_victim.dna.real_name)
		return FALSE

	var/datum/action/cooldown/spell/touch/envy/envy_spell
	var/obj/item/card/id/ID = human_victim.get_idcard()
	envy_spell?.stored_access = ID?.access
	caster.fully_replace_character_name(caster.real_name, human_victim.dna.real_name)
	human_victim.dna.transfer_identity(caster, transfer_SE=1)
	caster.updateappearance(mutcolor_update=1)
	caster.domutcheck()
	caster.visible_message(
	span_warning("[caster]'s appearance shifts into [human_victim]'s!"), \
	span_boldannounce("[human_victim.p_they(TRUE)] think[human_victim.p_s()] human_victimH.p_theyre()] \
				<i>sooo</i> much better than you. Not anymore, [human_victim.p_they()] won't.")
	)
	return TRUE
