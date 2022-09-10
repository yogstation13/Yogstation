//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/human/hulk
	name = "Mutation"
	desc = "A poorly understood genome that causes the holder's muscles to expand, inhibit speech and gives the person a bad skin condition."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("Your muscles hurt!")
	health_req = 25
	instability = 50
	class = MUT_OTHER
	locked = TRUE

/datum/mutation/human/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_HULK)
	owner.update_body_parts()
	owner.dna.species.handle_mutant_bodyparts(owner)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	RegisterSignal(owner, COMSIG_MOB_SAY, .proc/handle_speech)

/datum/mutation/human/hulk/on_attack_hand(atom/target, proximity)
	if(proximity) //no telekinetic hulk attack
		return target.attack_hulk(owner)

/datum/mutation/human/hulk/on_life()
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, span_danger("You suddenly feel very weak."))

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_HULK)
	REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_HULK)
	owner.update_body_parts()
	owner.dna.species.handle_mutant_bodyparts(owner)
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/human/hulk/proc/handle_speech(original_message, wrapped_message)
	var/message = wrapped_message[1]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	wrapped_message[1] = message
	return COMPONENT_UPPERCASE_SPEECH

/datum/mutation/human/genetics_hulk
	name = "Hulk"
	desc = "A seemingly dormant genome, but reacts violently to aggitation."
	difficulty = 16
	instability = 50
	class = MUT_OTHER
	locked = TRUE
	quality = POSITIVE
	get_chance = 10
	lowest_value = 256 * 14
	text_gain_indication = span_notice("You feel an anger welling inside you.")
	health_req = 25

/datum/mutation/human/genetics_hulk/on_losing(mob/living/carbon/human/owner)
	. = ..()
	dna.remove_mutation(ACTIVE_HULK)
	return

/datum/mutation/human/active_hulk
	name = "Hulk State"
	desc = "The single most angry genome ever seen. Mutating this will incite a one-time immediate Hulkformation in the mutatee."
	quality = POSITIVE
	instability = 30
	class = MUT_OTHER
	locked = TRUE
	text_gain_indication = span_notice("Your muscles hurt!")
	health_req = 1
	var/health_based = 0

/datum/mutation/human/active_hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_CC() //RAGE RAGE RAGE, RISE RISE RISE
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_HULK)
	RegisterSignal(owner, COMSIG_MOB_SAY, .proc/handle_speech)
	if(istype(owner.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = owner.w_uniform
		if(owner.canUnEquip(U))
			owner.visible_message("[U] falls apart!", span_warning("You tear your clothes up in anger!"))
			qdel(U)
	if(istype(owner.wear_suit, /obj/item/clothing/suit))
		var/obj/item/clothing/suit/S = owner.wear_suit
		if(owner.canUnEquip(S))
			owner.dropItemToGround(S)
	owner.undershirt = "Nude"
	owner.dna.species.no_equip.Add(SLOT_WEAR_SUIT, SLOT_W_UNIFORM)
	owner.say("PUNY HUMANS!!")
	owner.physiology.stamina_mod = 0.3
	owner.update_body()
	if(iswizard(owner))
		owner.mind.AddSpell(/obj/effect/proc_holder/spell/aoe_turf/repulse/hulk) //Restricted to Wizards. Mistakes were made.

/datum/mutation/human/active_hulk/on_attack_hand(atom/target, proximity)
	if(proximity) //no telekinetic hulk attack
		if(prob(3))
			owner.Jitter(10)
		owner.adjustStaminaLoss(-0.5)
		return target.attack_hulk(owner)

/datum/mutation/human/active_hulk/on_life()
	owner.adjustStaminaLoss(0.9)
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, span_danger("You suddenly feel very weak. Your rage dies out."))

/datum/mutation/human/active_hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_HULK)
	REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_HULK)
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_HULK)
	UnregisterSignal(owner, COMSIG_MOB_SAY)
	owner.dna.species.no_equip.Remove(SLOT_WEAR_SUIT, SLOT_W_UNIFORM)
	owner.physiology.stamina_mod = initial(owner.physiology.stamina_mod)
	owner.update_body_parts()
	owner.dna.species.handle_mutant_bodyparts(owner)
	owner.mind.spell_list.Remove(/obj/effect/proc_holder/spell/aoe_turf/repulse/hulk)

/datum/mutation/human/active_hulk/proc/handle_speech(original_message, wrapped_message)
	var/message = wrapped_message[1]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	wrapped_message[1] = message
	return COMPONENT_UPPERCASE_SPEECH
