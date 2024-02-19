/datum/action/cooldown/spell/pointed/coinflip

	name = "Fear And Hunger"
	desc = "This spell causes the target to flip an imaginary coin, and if they call it wrong they lose a random limb"
	button_icon_state = "autotomy"

	/// Message showing to the spell owner upon activating pointed spell.
	active_msg = "You prepare a spectral coin."
	/// Message showing to the spell owner upon deactivating pointed spell.
	deactive_msg = "You put the coin back in your pocket..."
	/// The casting range of our spell
	cast_range = 5
	/// Variable dictating if the spell will use turf based aim assist
	aim_assist = TRUE

	sound = 'sound/items/coinflip.ogg'
	school = SCHOOL_CONJURATION
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

	return

/datum/action/cooldown/spell/pointed/coinflip/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You hear a coin flipping in the distance, but nothing more."))
		playsound(usr.loc, 'sound/items/coinflip.ogg', 25, 1)
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	cast_on.add_atom_colour("#802796", ADMIN_COLOUR_PRIORITY)
	cast_on.SetImmobilized(10 HOURS)
	cast_on.adjust_blindness(10 HOURS)
	select_coin(cast_on)
	cast_on.remove_atom_colour(ADMIN_COLOUR_PRIORITY)

	return TRUE


/datum/action/cooldown/spell/pointed/coinflip/proc/select_coin(mob/living/user)
	var/answerChoice = tgui_input_list(user, "Heads or tails", "Call it", list("heads","tails"))
	var/list/sideslist = list("heads","tails")
	var/coinflip

	coinflip = pick(sideslist)

	if(answerChoice == coinflip)
		return
	if(!iscarbon(user))
		return
	var/mob/living/carbon/CM = user
	for(var/obj/item/bodypart/bodypart in CM.bodyparts)
		if(!(bodypart.body_part & (HEAD|CHEST)))
			if(bodypart.dismemberable)
				bodypart.dismember()
	
	user.adjust_blindness(0 SECONDS)
	user.SetImmobilized(0 SECONDS)
