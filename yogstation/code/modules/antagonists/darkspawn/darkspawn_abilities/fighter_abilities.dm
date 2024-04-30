//////////////////////////////////////////////////////////////////////////
//----------------------Fighter light eater ability---------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/toggle/shadow_tendril
	name = "Umbral Tendril"
	desc = "Twists an active arm into a mass of tendrils with many uses."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	///what additional effects the ability has
	var/ability_flags = NONE

/datum/action/cooldown/spell/toggle/shadow_tendril/link_to(Target)
	. = ..()
	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_DARKSPAWN_UPGRADE_ABILITY, PROC_REF(handle_upgrade))
		RegisterSignal(target, COMSIG_DARKSPAWN_DOWNGRADE_ABILITY, PROC_REF(handle_downgrade))
	
/datum/action/cooldown/spell/toggle/shadow_tendril/proc/handle_upgrade(atom/source, flag)
	ability_flags |= flag
	if(flag & TENDRIL_UPGRADE_TWIN)
		name = "Twinned [initial(name)]s"
		desc = "Twists one or both of your arms into tendrils with many uses."

/datum/action/cooldown/spell/toggle/shadow_tendril/proc/handle_downgrade(atom/source, flag)
	ability_flags -= flag
	if(flag & TENDRIL_UPGRADE_TWIN)
		name = initial(name)
		desc = initial(desc)

/datum/action/cooldown/spell/toggle/shadow_tendril/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes() && !active)
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/toggle/shadow_tendril/process()
	active = owner.is_holding_item_of_type(/obj/item/umbral_tendrils)
	return ..()

/datum/action/cooldown/spell/toggle/shadow_tendril/Enable()
	var/list/hands_free = owner.get_empty_held_indexes()
	var/num_tendrils = min((ability_flags & TENDRIL_UPGRADE_TWIN) ? 2 : 1, LAZYLEN(hands_free))

	if(!num_tendrils)
		return

	owner.visible_message(span_warning("[owner]'s arm[num_tendrils > 1 ? "s" : ""] contort into tentacles!"), \
		span_velvet("You transform your arm[num_tendrils > 1 ? "s" : ""] into umbral tendrils. Examine them to see possible uses."))
	owner.balloon_alert(owner, "Ikna")
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE)

	if(num_tendrils > 1) //add an additional sound and balloon alert for the extra tendril
		addtimer(CALLBACK(src, PROC_REF(echo)), 1)

	for(var/i in 1 to num_tendrils)
		var/obj/item/umbral_tendrils/T = new(owner, isdarkspawn(owner))
		if(ability_flags & TENDRIL_UPGRADE_CLEAVE)
			T.AddComponent(/datum/component/cleave_attack, arc_size=180)
		owner.put_in_hands(T)

/datum/action/cooldown/spell/toggle/shadow_tendril/proc/echo()
	owner.balloon_alert(owner, "Ikna")
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE)

/datum/action/cooldown/spell/toggle/shadow_tendril/Disable()
	owner.balloon_alert(owner, "Haoo")
	owner.visible_message(span_warning("[owner]'s tentacles transform back!"), span_notice("You dispel the tendrils."))
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/umbral_tendrils/T in owner)
		QDEL_NULL(T)

//////////////////////////////////////////////////////////////////////////
//---------------------Fighter anti-fire ability------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/deluge
	name = "Deluge"
	desc = "Calls upon the endless depths to douse all with the beyond."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "deluge"
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 25
	cooldown_time = 45 SECONDS

/datum/action/cooldown/spell/aoe/deluge/cast(atom/cast_on)
	. = ..()
	if(isliving(owner))
		owner.balloon_alert(owner, "Wyrmul")
		var/mob/living/target = owner
		target.extinguish_mob()
		target.adjust_wet_stacks(20)
		target.adjust_wet_stacks(20)

/datum/action/cooldown/spell/aoe/deluge/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!can_see(caster, victim))
		return
	if(isliving(victim))
		var/mob/living/target = victim
		target.extinguish_mob()
		if(is_darkspawn_or_thrall(target) && ispreternis(target)) //don't make preterni allies wet
			return
		target.adjust_wet_stacks(20)
		target.adjust_wet_stacks(20)
	else if(isobj(victim))
		var/obj/target = victim
		target.extinguish()

//////////////////////////////////////////////////////////////////////////
//-----------------------Targeted Dash with CC--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/shadow_crash
	name = "Shadow crash"
	desc = "Charge in a direction."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "shadow_crash"
	panel = "Darkspawn"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = NONE
	cooldown_time = 5 SECONDS
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	psi_cost = 20
	var/charging = FALSE

/datum/action/cooldown/spell/pointed/shadow_crash/Grant(mob/grant_to)
	. = ..()
	ADD_TRAIT(owner, TRAIT_IMPACTIMMUNE, type)
	RegisterSignal(owner, COMSIG_MOVABLE_IMPACT, PROC_REF(impact))
	
/datum/action/cooldown/spell/pointed/shadow_crash/Remove(mob/living/remove_from)
	UnregisterSignal(owner, COMSIG_MOVABLE_IMPACT)
	REMOVE_TRAIT(owner, TRAIT_IMPACTIMMUNE, type)
	return ..()
	
/datum/action/cooldown/spell/pointed/shadow_crash/cast(atom/cast_on)
	. = ..()
	if(!isliving(owner))
		return
	var/mob/living/thing = owner
	owner.balloon_alert(owner, "Vorl'ax")
	charging = TRUE
	thing.SetImmobilized(1 SECONDS, TRUE, TRUE) //to prevent walking out of your charge
	thing.throw_at(cast_on, 4, 1, thing, FALSE, callback = CALLBACK(src, PROC_REF(end_dash), thing))

/datum/action/cooldown/spell/pointed/shadow_crash/proc/end_dash(mob/living/H)
	charging = FALSE
	H.SetImmobilized(0, TRUE, TRUE) //remove the block on movement

/datum/action/cooldown/spell/pointed/shadow_crash/proc/impact(atom/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!charging)
		return
	
	if(isturf(hit_atom))
		return

	if(isobj(hit_atom))
		var/obj/thing = hit_atom
		thing.take_damage(29) //does 29 twice so it can break weak things, but doesn't do anything to structures with reinforcement
		thing.take_damage(29)

	if(!isliving(hit_atom))
		return

	var/mob/living/target = hit_atom
	var/blocked = FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, 0, "[source]", attack_type = LEAP_ATTACK))
			blocked = TRUE
	
	var/destination = get_ranged_target_turf(get_turf(target), throwingdatum.init_dir, 5)
	if(blocked)
		target.throw_at(destination, 3, 2)
	else
		target.throw_at(destination, 3, 2, callback = CALLBACK(target, TYPE_PROC_REF(/mob/living, Paralyze), 2 SECONDS))

//////////////////////////////////////////////////////////////////////////
//------------------------Action speed boost----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/time_dilation
	name = "Time Dilation"
	desc = "Greatly increases reaction times and action speed, and provides immunity to slowdown. This lasts for 1 minute. Costs 75 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "time_dilation"
	check_flags = AB_CHECK_CONSCIOUS
	panel = "Darkspawn"
	antimagic_flags = NONE
	spell_requirements = SPELL_REQUIRES_HUMAN
	sound = 'yogstation/sound/creatures/darkspawn_howl.ogg'
	psi_cost = 75

/datum/action/cooldown/spell/time_dilation/can_cast_spell(feedback)
	if(owner.has_status_effect(STATUS_EFFECT_TIME_DILATION))
		if(feedback)
			to_chat(owner, span_notice("You still have time dilation in effect."))
		return FALSE
	return ..()

/datum/action/cooldown/spell/time_dilation/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = owner
	L.apply_status_effect(STATUS_EFFECT_TIME_DILATION)
	L.balloon_alert(L, "Quix'thra ZYXAR!")
	L.visible_message(span_warning("[L] howls as their body sigils begin to scream light in every direction!"), span_velvet("Your sigils howl out light as your body moves at incredible speed!"))

//////////////////////////////////////////////////////////////////////////
//----------------------------Delayed AOE CC----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/demented_outburst
	name = "Demented Outburst"
	desc = "Deafens and confuses listeners after a five-second charge period, knocking away everyone nearby. Costs 50 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "demented_outburst"
	antimagic_flags = NONE
	panel = "Darkspawn"
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 50 //big boom = big cost
	cooldown_time = 20 SECONDS
	aoe_radius = 7
	///Boolean, if the spell is being charged up
	var/casting = FALSE
	///Duration spent charging the spell
	var/cast_time = 5 SECONDS

/datum/action/cooldown/spell/aoe/demented_outburst/can_cast_spell(feedback)
	if(casting)
		return FALSE
	return ..()

/datum/action/cooldown/spell/aoe/demented_outburst/before_cast(atom/cast_on)
	. = ..()
	if(casting)
		return . | SPELL_CANCEL_CAST
	if(. & SPELL_CANCEL_CAST)
		return .
	casting = TRUE
	owner.balloon_alert(owner, "Kap...")
	owner.visible_message(span_boldwarning("[owner] begins to growl as their chitin hardens..."), span_velvet("You begin focusing your power..."))
	playsound(owner, 'yogstation/sound/magic/demented_outburst_charge.ogg', 50, 0)
	if(!do_after(owner, cast_time, cast_on))
		casting = FALSE
		return . | SPELL_CANCEL_CAST
	casting = FALSE

/datum/action/cooldown/spell/aoe/demented_outburst/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "...WXSU!")
	owner.visible_message(span_userdanger("[owner] lets out a deafening scream!"), span_velvet("You let out a deafening outburst!"))
	playsound(owner, 'yogstation/sound/magic/demented_outburst_scream.ogg', 75, 0)

/datum/action/cooldown/spell/aoe/demented_outburst/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	if(!can_see(victim, caster, aoe_radius))
		return
	if(!ismovable(victim))
		return
	if(victim.anchored)
		return
	if(isitem(victim) && isliving(victim.loc))//don't throw anything being held by someone
		return
	if(isliving(victim))
		var/mob/living/dude = victim
		if(is_team_darkspawn(dude))
			return
	var/distance = get_dist(owner, victim)
	var/turf/target = get_edge_target_turf(owner, get_dir(owner, get_step_away(victim, owner)))
	victim.throw_at(target, ((clamp((5 - (clamp(distance - 2, 0, distance))), 3, 5))), 1, owner)
	if(iscarbon(victim))
		var/mob/living/carbon/C = victim
		if(distance <= 2) //you done fucked up now
			C.visible_message(span_warning("The blast sends [C] flying!"), span_userdanger("The force sends you flying!"))
			C.Stun(5 SECONDS)
			C.adjustBruteLoss(10)
			C.soundbang_act(1, 5, 15, 5)
		else if(distance <= 5)
			C.visible_message(span_warning("The blast knocks [C] off their feet!"), span_userdanger("The force bowls you over!"))
			C.Stun(3 SECONDS)
			C.soundbang_act(1, 3, 5, 0)
	if(iscyborg(victim))
		var/mob/living/silicon/robot/R = victim
		R.visible_message(span_warning("The blast sends [R] flying!"), span_userdanger("The force sends you flying!"))
		R.Paralyze(10 SECONDS) //fuck borgs
		R.soundbang_act(1, 5, 15, 5)
		
//////////////////////////////////////////////////////////////////////////
//----------------Complete Protection from light at a cost--------------//
//////////////////////////////////////////////////////////////////////////
//Allows you to move through light unimpeded while active. Drains 5 Psi per second.
/datum/action/cooldown/spell/toggle/creep
	name = "Encroach"
	desc = "Grants immunity to lightburn while active. Can be toggled on and off. Drains 5 Psi per second."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "encroach"
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	///Antag datum that the psi is coming from
	var/datum/antagonist/darkspawn/cost
	///Psi cost of maintaining the spell
	var/upkeep_cost = 1

/datum/action/cooldown/spell/toggle/creep/Grant(mob/grant_to)
	. = ..()
	if(isdarkspawn(owner))
		cost = isdarkspawn(owner)
		
/datum/action/cooldown/spell/toggle/creep/process()
	if(active && cost && (!cost.use_psi(upkeep_cost)))
		Activate(owner)
	return ..()

/datum/action/cooldown/spell/toggle/creep/Enable()
	owner.balloon_alert(owner, "Odeahz")
	owner.visible_message(span_warning("Velvety shadows coalesce around [owner]!"), span_velvet("You begin using Psi to shield yourself from lightburn."))
	playsound(owner, 'yogstation/sound/magic/devour_will_victim.ogg', 50, TRUE)
	var/datum/antagonist/darkspawn/dude = isdarkspawn(owner)
	if(dude)
		ADD_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)

/datum/action/cooldown/spell/toggle/creep/Disable()
	owner.balloon_alert(owner, "Phwo")
	to_chat(owner, span_velvet("You release your grip on the shadows."))
	playsound(owner, 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	var/datum/antagonist/darkspawn/dude = isdarkspawn(owner)
	if(dude)
		REMOVE_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)

//////////////////////////////////////////////////////////////////////////
//------------Toggled CC immunity force walking with psi drain----------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/toggle/indomitable
	name = "Indomitable"
	desc = "Grants immunity to all CC effects, but locks the user into walking."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "indomitable"
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	cooldown_time = 1 SECONDS
	///Antag datum that the psi is coming from
	var/datum/antagonist/darkspawn/cost
	///Psi cost of maintaining the spell
	var/upkeep_cost = 1
	///Boolean, if the user was running before activating this spell
	var/was_running
	///List of traits applied during the effect
	var/list/traits = list(TRAIT_STUNIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_NODEATH, TRAIT_IGNOREDAMAGESLOWDOWN)

/datum/action/cooldown/spell/toggle/indomitable/Grant(mob/grant_to)
	. = ..()
	if(isdarkspawn(owner))
		cost = isdarkspawn(owner)
		
/datum/action/cooldown/spell/toggle/indomitable/process()
	if(active && cost && (!cost.use_psi(upkeep_cost)))
		Activate(owner)
	if(active && owner.m_intent != MOVE_INTENT_WALK)
		owner.toggle_move_intent()
	return ..()

/datum/action/cooldown/spell/toggle/indomitable/Enable()
	owner.balloon_alert(owner, "Zhaedo")
	owner.visible_message(span_warning("Shadows stitch [owner]'s legs to the ground!"), span_velvet("You begin using Psi to defend yourself from disruption."))
	playsound(owner, 'yogstation/sound/magic/devour_will_form.ogg', 50, TRUE)
	owner.add_traits(traits, type)
	owner.move_resist = INFINITY
	was_running = (owner.m_intent == MOVE_INTENT_RUN)
	if(was_running)
		owner.toggle_move_intent()

/datum/action/cooldown/spell/toggle/indomitable/Disable()
	owner.balloon_alert(owner, "Phwo")
	to_chat(owner, span_velvet("You release your grip on the shadows."))
	playsound(owner, 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	owner.remove_traits(traits, type)
	owner.move_resist = initial(owner.move_resist)
	if(was_running && owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent()

//////////////////////////////////////////////////////////////////////////
//-------------------AOE forced movement towards user-------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/taunt
	name = "Incite"
	desc = "Force everyone nearby to walk towards you, but disables your ability to attack for a time."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "incite"
	sound = 'yogstation/sound/ambience/antag/veil_mind_scream.ogg'
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 15
	cooldown_time = 20 SECONDS
	invocation_type = INVOCATION_SHOUT
	invocation = "Kmmo'axhe!"

/datum/action/cooldown/spell/aoe/taunt/cast(atom/cast_on)
	. = ..()
	if(isliving(owner))
		var/mob/living/target = owner
		target.SetDaze(5000 SECONDS, TRUE, TRUE)
		ADD_TRAIT(target, TRAIT_PUSHIMMUNE, type)
		target.move_resist = INFINITY
		addtimer(CALLBACK(src, PROC_REF(unlock), target), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/action/cooldown/spell/aoe/taunt/proc/unlock(mob/living/target)
	REMOVE_TRAIT(target, TRAIT_PUSHIMMUNE, type)
	target.move_resist = initial(target.move_resist)
	target.SetDaze(0, TRUE, TRUE)

/datum/action/cooldown/spell/aoe/taunt/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isliving(victim) || !can_see(caster, victim))
		return
	var/mob/living/target = victim
	if(is_darkspawn_or_thrall(target))
		return
	target.apply_status_effect(STATUS_EFFECT_TAUNT, owner)
