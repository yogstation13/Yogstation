//Converts people within three tiles of the caster into veils. Also confuses noneligible targets and stuns silicons.
/datum/action/cooldown/spell/touch/veil_mind
	name = "Thrall mind"
	desc = "Converts nearby eligible targets into veils. To be eligible, they must be alive and recently drained by Devour Will."
	button_icon_state = "veil_mind"
	check_flags =  AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	hand_path = /obj/item/melee/touch_attack/veil_mind

/datum/action/cooldown/spell/touch/veil_mind/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/touch/veil_mind/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	owner.visible_message(span_warning("[owner]'s sigils flare as they inhale..."), "<span class='velvet bold'>dawn kqn okjc...</span><br>\
	[span_notice("You take a deep breath...")]")
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg', 25)
	if(!do_after(owner, 2 SECONDS, owner))
		return FALSE
	owner.visible_message(span_boldwarning("[owner] lets out a chilling cry!"), "<span class='velvet bold'>...wjz oanra</span><br>\
	[span_notice("You veil the minds of everyone nearby.")]")
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_scream.ogg', 100)
	if(isveil(target))
		target.revive(1)
	else
		if(target.has_status_effect(STATUS_EFFECT_BROKEN_WILL))
			if(target.add_veil())
				to_chat(owner, span_velvet("<b>[target.real_name]</b> has become a veil!"))
		else
			to_chat(target, span_boldwarning("...and it scrambles your thoughts!"))
			target.dir = pick(GLOB.cardinals)
			target.adjust_confusion(10 SECONDS)
	return TRUE

/obj/item/melee/touch_attack/veil_mind
	name = "Veiling hand"
	desc = "Concentrated psionic power, primed to toy with mortal minds."
	icon_state = "flagellation"
	item_state = "hivemind"
