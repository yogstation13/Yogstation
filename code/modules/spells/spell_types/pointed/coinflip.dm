/datum/action/cooldown/spell/pointed/coinflip

	name = "Fear And Hunger"
	desc = "This spell causes the target to flip an imaginary coin, and if they call it wrong they lose a random limb"
	button_icon_state = "blind"

	/// Message showing to the spell owner upon activating pointed spell.
	active_msg = "You prepare a spectral coin."
	/// Message showing to the spell owner upon deactivating pointed spell.
	deactive_msg = "You put the coin back in your pocket..."
	/// The casting range of our spell
	cast_range = 7
	/// Variable dictating if the spell will use turf based aim assist
	aim_assist = TRUE

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 5 SECONDS

	invocation = "F'R ND H'NGR"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/pointed/coinflip/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	return !is_blind(human_target)


/datum/action/cooldown/spell/pointed/coinflip/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You hear a coin flipping in the distance, but nothing more."))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	to_chat(cast_on, span_warning("Heads, or tails!"))
	select_coin(owner)

	return TRUE


/datum/action/cooldown/spell/pointed/coinflip/proc/select_coin(mob/user, title = "Heads, or Tails?")
	var/answerChoice = tgui_input_list(user, "Heads or tails", "Call it", list("Heads","Tails"))
	var/list/sideslist = list("heads","tails")
	var/coinflip

	coinflip = pick(sideslist)

	if(answerChoice != "Heads" && coinflip == "heads" )
		message_admins("Heads Picked")
		if(iscarbon(user))
			var/mob/living/carbon/CM = user
			for(var/obj/item/bodypart/bodypart in CM.bodyparts)
				if(!(bodypart.body_part & (HEAD|CHEST)))
					if(bodypart.dismemberable)
						bodypart.dismember()

	if(answerChoice != "Tails" && coinflip == "tails" )
		message_admins("Tails Picked")
		if(iscarbon(user))
			var/mob/living/carbon/CM = user
			for(var/obj/item/bodypart/bodypart in CM.bodyparts)
				if(!(bodypart.body_part & (HEAD|CHEST)))
					if(bodypart.dismemberable)
						bodypart.dismember()

