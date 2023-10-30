//Emits a shockwave that blasts everyone and everything nearby far away. People close to the user are deafened and stunned.
/datum/action/cooldown/spell/aoe/demented_outburst
	name = "Demented Outburst"
	desc = "Deafens and confuses listeners after a five-second charge period, knocking away everyone nearby. Costs 50 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "demented_outburst"
	antimagic_flags = NONE
	panel = null
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 50 //big boom = big cost
	aoe_radius = 5
	var/casting = FALSE
	var/cast_time = 5 SECONDS

/datum/action/cooldown/spell/aoe/demented_outburst/can_cast_spell(feedback)
	if(casting)
		return FALSE
	. = ..()

/datum/action/cooldown/spell/aoe/demented_outburst/before_cast(atom/cast_on)
	. = ..()
	if(casting)
		return . | SPELL_CANCEL_CAST
	if(. & SPELL_CANCEL_CAST)
		return .
	casting = TRUE
	owner.visible_message(span_boldwarning("[owner] begins to growl as their chitin hardens..."), "<span class='velvet bold'>cap...</span><br>[span_danger("You begin harnessing your power...")]")
	playsound(owner, 'yogstation/sound/magic/demented_outburst_charge.ogg', 50, 0)
	if(!do_after(owner, cast_time, cast_on))
		casting = FALSE
		return . | SPELL_CANCEL_CAST
	casting = FALSE

/datum/action/cooldown/spell/aoe/demented_outburst/cast(atom/cast_on)
	. = ..()
	owner.visible_message(span_userdanger("[owner] lets out a deafening scream!"), "<span class='velvet bold italics'>WSWU!</span><br>[span_danger("You let out a deafening outburst!")]")
	playsound(owner, 'yogstation/sound/magic/demented_outburst_scream.ogg', 75, 0)

/datum/action/cooldown/spell/aoe/demented_outburst/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!can_see(victim, caster, aoe_radius))
		return
	if(!ismovable(victim))
		return
	var/atom/movable/AM = victim
	if(AM.anchored)
		continue
	var/distance = get_dist(owner, AM)
	var/turf/target = get_edge_target_turf(owner, get_dir(owner, get_step_away(AM, owner)))
	AM.throw_at(target, ((clamp((5 - (clamp(distance - 2, 0, distance))), 3, 5))), 1, owner)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(distance <= 1) //you done fucked up now
			C.visible_message(span_warning("The blast sends [C] flying!"), span_userdanger("The force sends you flying!"))
			C.Paralyze(5 SECONDS)
			C.Knockdown(5 SECONDS)
			C.adjustBruteLoss(10)
			C.soundbang_act(1, 5, 15, 5)
		else if(distance <= 3)
			C.visible_message(span_warning("The blast knocks [C] off their feet!"), span_userdanger("The force bowls you over!"))
			C.Paralyze(2.5  SECONDS)
			C.Knockdown(3 SECONDS)
			C.soundbang_act(1, 3, 5, 0)
	if(iscyborg(AM))
		var/mob/living/silicon/robot/R = AM
		R.visible_message(span_warning("The blast sends [R] flying!"), span_userdanger("The force sends you flying!"))
		R.Paralyze(10 SECONDS) //fuck borgs
		R.soundbang_act(1, 5, 15, 5)
