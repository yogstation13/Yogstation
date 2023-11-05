//////////////////////////////////////////////////////////////////////////
//----------------------Fighter light eater ability---------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/toggle/shadow_tendril
	name = "Shadow Tendril"
	desc = "Twists an active arm into a mass of tendrils with many important uses. Examine the tendrils to see a list of uses."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	var/twin = FALSE

/datum/action/cooldown/spell/toggle/shadow_tendril/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes())
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/shadow_tendril/process()
	active = owner.is_holding_item_of_type(/obj/item/umbral_tendrils)
	if(twin)
		name = "Twinned Shadow Tendrils"
		desc = "Twists one or both of your arms into tendrils with many uses."
	. = ..()

/datum/action/cooldown/spell/toggle/shadow_tendril/Enable()
	var/list/hands_free = owner.get_empty_held_indexes()
	if(!twin || hands_free.len < 2)
		owner.visible_message(span_warning("[owner]'s arm contorts into tentacles!"), "<span class='velvet bold'>ikna</span><br>\
		[span_notice("You transform your arm into umbral tendrils. Examine them to see possible uses.")]")
		playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
		var/obj/item/umbral_tendrils/T = new(owner, isdarkspawn(owner))
		owner.put_in_hands(T)
	else
		owner.visible_message(span_warning("[owner]'s arms contort into tentacles!"), "<span class='velvet'><b>ikna ikna</b><br>\
		You transform both arms into umbral tendrils. Examine them to see possible uses.</span>")
		playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE), 1)
		for(var/i in 1 to 2)
			var/obj/item/umbral_tendrils/T = new(owner, isdarkspawn(owner) )
			owner.put_in_hands(T)

/datum/action/cooldown/spell/toggle/shadow_tendril/Disable()
	owner.visible_message(span_warning("[owner]'s tentacles transform back!"), "<span class='velvet bold'>haoo</span><br>\
	[span_notice("You dispel the tendrils.")]")
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/umbral_tendrils/T in owner)
		qdel(T)


//////////////////////////////////////////////////////////////////////////
//---------------------Fighter anti-fire ability------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/deluge
	name = "deluge"
	desc = "yeah i make people wet."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "time_dilation"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 10
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/aoe/deluge/cast(atom/cast_on)
	. = ..()
	if(isliving(owner))
		var/mob/living/target = owner
		target.extinguish_mob()
		target.adjust_wet_stacks(20)
		ADD_TRAIT(target, TRAIT_NOFIRE, type)
		addtimer(CALLBACK(src, PROC_REF(unbuff), target), 10 SECONDS, TIMER_UNIQUE, TIMER_OVERRIDE)

/datum/action/cooldown/spell/aoe/deluge/proc/unbuff(mob/living/target)
	REMOVE_TRAIT(target, TRAIT_NOFIRE, type)

/datum/action/cooldown/spell/aoe/deluge/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isliving(victim))
		return
	var/mob/living/target = victim
	target.extinguish_mob()
	if(is_darkspawn_or_veil(target) && ispreternis(target)) //don't make preterni allies wet
		return
	target.adjust_wet_stacks(20)

//////////////////////////////////////////////////////////////////////////
//-----------------------Targeted Dash with CC--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/shadow_crash
	name = "Shadow crash"
	desc = "Charge in a direction."
	panel = "Shadowling Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "glare"
	panel = null
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	cooldown_time = 15 SECONDS
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
	. = ..()
	
/datum/action/cooldown/spell/pointed/shadow_crash/cast(atom/cast_on)
	. = ..()
	owner.throw_at(cast_on, 4, 1, owner, FALSE)
	if(isliving(owner))
		var/mob/living/thing = owner
		thing.SetImmobilized(0.4 SECONDS, TRUE, TRUE) //to prevent walking out of your charge
	charging = TRUE
	addtimer(VARSET_CALLBACK(src, charging, FALSE), 1 SECONDS, TIMER_UNIQUE)
	
/datum/action/cooldown/spell/pointed/shadow_crash/proc/impact(atom/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!charging)
		return
	
	if(isturf(hit_atom))
		return

	if(isobj(hit_atom))
		var/obj/thing = hit_atom
		thing.take_damage(29)
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
		target.throw_at(destination, 4, 2)
	else
		target.throw_at(destination, 4, 2, callback = CALLBACK(target, TYPE_PROC_REF(/mob/living, Knockdown), 2 SECONDS))

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
	panel = null
	antimagic_flags = NONE
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	sound = 'yogstation/sound/creatures/darkspawn_howl.ogg'
	psi_cost = 75

/datum/action/cooldown/spell/time_dilation/can_cast_spell(feedback)
	if(owner.has_status_effect(STATUS_EFFECT_TIME_DILATION))
		if(feedback)
			to_chat(owner, span_notice("You still have time dilation in effect."))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/time_dilation/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = owner
	L.apply_status_effect(STATUS_EFFECT_TIME_DILATION)
	L.visible_message(span_warning("[L] howls as their body moves at wild speeds!"), span_velvet("<b>ckppw ck bwop</b><br>Your sigils howl out light as your body moves at incredible speed!"))

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
	panel = null
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
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
		return
	if(isitem(AM) && isliving(AM.loc))//don't throw anything being held by someone
		return
	if(isliving(AM))
		var/mob/living/dude = AM
		if(is_darkspawn_or_veil(dude))
			return
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
		
//////////////////////////////////////////////////////////////////////////
//----------------Complete Protection from light at a cost--------------//
//////////////////////////////////////////////////////////////////////////
//Allows you to move through light unimpeded while active. Drains 5 Psi per second.
/datum/action/cooldown/spell/toggle/creep
	name = "Creep"
	desc = "Grants immunity to lightburn while active. Can be toggled on and off. Drains 5 Psi per second."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "creep"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	var/datum/antagonist/darkspawn/cost
	var/upkeep_cost = 1 //happens 5 times a second

/datum/action/cooldown/spell/toggle/creep/Grant(mob/grant_to)
	. = ..()
	if(isdarkspawn(owner))
		cost = isdarkspawn(owner)
		
/datum/action/cooldown/spell/toggle/creep/process()
	if(active && cost && (!cost.use_psi(upkeep_cost)))
		Activate(owner)
	. = ..()

/datum/action/cooldown/spell/toggle/creep/Enable()
	owner.visible_message(span_warning("Velvety shadows coalesce around [owner]!"), span_velvet("<b>odeahz</b><br>You begin using Psi to shield yourself from lightburn."))
	playsound(owner, 'yogstation/sound/magic/devour_will_victim.ogg', 50, TRUE)
	ADD_TRAIT(owner, TRAIT_DARKSPAWN_CREEP, type)

/datum/action/cooldown/spell/toggle/creep/Disable()
	to_chat(owner, span_velvet("You release your grip on the shadows."))
	playsound(owner, 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	REMOVE_TRAIT(owner, TRAIT_DARKSPAWN_CREEP, type)

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
	button_icon_state = "creep"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	var/datum/antagonist/darkspawn/cost
	var/upkeep_cost = 1 //happens 5 times a second
	var/was_running

/datum/action/cooldown/spell/toggle/indomitable/Grant(mob/grant_to)
	. = ..()
	if(isdarkspawn(owner))
		cost = isdarkspawn(owner)
		
/datum/action/cooldown/spell/toggle/indomitable/process()
	if(active && cost && (!cost.use_psi(upkeep_cost)))
		Activate(owner)
	if(owner.m_intent != MOVE_INTENT_WALK)
		owner.toggle_move_intent()
	. = ..()

/datum/action/cooldown/spell/toggle/indomitable/Enable()
	owner.visible_message(span_warning("Shadows stitch [owner]'s legs to the ground!"), span_velvet("<b>odeahz</b><br>You begin using Psi to defend yourself from disruption."))
	playsound(owner, 'yogstation/sound/magic/devour_will_form.ogg', 50, TRUE)
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, type)
	was_running = (owner.m_intent == MOVE_INTENT_RUN)
	if(was_running)
		owner.toggle_move_intent()

/datum/action/cooldown/spell/toggle/indomitable/Disable()
	to_chat(owner, span_velvet("You release your grip on the shadows."))
	playsound(owner, 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, type)
	if(was_running && owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent()
