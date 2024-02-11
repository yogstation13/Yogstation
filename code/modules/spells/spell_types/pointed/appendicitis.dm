/datum/action/cooldown/spell/pointed/appendicitis
	name = "Bestow Appendicitis"
	desc = "Give someone appendicitis."
	button_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "appendix"

	/// Message showing to the spell owner upon activating pointed spell.
	active_msg = "You prepare to give someone appendicitis."
	/// Message showing to the spell owner upon deactivating pointed spell.
	deactive_msg = "You stop preparing to give someone appendicitis."
	/// The casting range of our spell
	cast_range = 10
	/// Variable dictating if the spell will use turf based aim assist
	aim_assist = TRUE

	sound = 'sound/magic/enter_blood.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 60 SECONDS

	invocation = "OW'MI'SEID"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/pointed/appendicitis/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE
	return

/datum/action/cooldown/spell/pointed/appendicitis/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(H.stat == DEAD)
		return FALSE

	if(cast_on.can_block_magic(antimagic_flags) || !cast_on.getorgan(/obj/item/organ/appendix))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	var/foundAlready = FALSE	//don't infect someone that already has appendicitis
	for(var/datum/disease/appendicitis/A in H.diseases)
		foundAlready = TRUE
		break
	if(foundAlready)
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	var/datum/disease/D = new /datum/disease/appendicitis()
	cast_on.ForceContractDisease(D, FALSE, TRUE)
	return TRUE
