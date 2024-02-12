/datum/action/cooldown/spell/pointed/appendicitis
	name = "Bestow Appendicitis"
	desc = "Give someone appendicitis."
	button_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "appendix"

	active_msg = "You prepare to give someone appendicitis."
	deactive_msg = "You stop preparing to give someone appendicitis."
	cast_range = 10
	aim_assist = TRUE

	sound = 'sound/magic/enter_blood.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 6 SECONDS

	invocation = "OW'MI'SEID"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/pointed/appendicitis/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/appendicitis/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.stat == DEAD)
		return FALSE

	if(cast_on.can_block_magic(antimagic_flags) || !cast_on.getorgan(/obj/item/organ/appendix) || LAZYFIND(cast_on.diseases, /datum/disease/appendicitis))
		owner.balloon_alert(owner, "no effect!")
		return FALSE

	var/datum/disease/D = new /datum/disease/appendicitis()
	cast_on.ForceContractDisease(D, FALSE, TRUE)
	return TRUE
