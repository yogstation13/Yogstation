//Creates an illusionary copy of the caster that runs in their direction for ten seconds and then vanishes.
/datum/action/cooldown/spell/simulacrum
	name = "Simulacrum"
	desc = "Creates an illusion that closely resembles you. The illusion will run forward for five seconds. Costs 20 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "simulacrum"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 20

/datum/action/cooldown/spell/simulacrum/cast(atom/cast_on)
	. = ..()
	if(isliving(owner))
		var/mob/living/L = owner
		L.visible_message(span_warning("[owner] breaks away from [L]'s shadow!"), \
		span_userdanger("You feel a sense of freezing cold pass through you!"))
		to_chat(owner, span_velvet("<b>zayaera</b><br>You create an illusion of yourself."))
	else
		owner.visible_message(span_warning("[owner] splits in two!"), \
		span_velvet("<b>zayaera</b><br>You create an illusion of yourself."))
	playsound(owner, 'yogstation/sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/effect/simulacrum/simulacrum = new(get_turf(owner))
	simulacrum.mimic(owner)
