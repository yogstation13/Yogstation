//////////////////////////////////////////////////////////////////////////
//--------------------Abilities all three classes get-------------------//
//////////////////////////////////////////////////////////////////////////
/obj/item/melee/touch_attack/darkspawn
	name = "Psionic hand"
	desc = "Concentrated psionic power, primed to toy with mortal minds."
	icon_state = "flagellation"
	item_state = "hivemind"

/obj/item/melee/touch_attack/devour_will
	name = "Psionic hand"
	desc = "Concentrated psionic power, primed to toy with mortal minds."
	icon = 'yogstation/icons/obj/darkspawn_items.dmi'
	icon_state = "dark_bead"
	item_state = "hivemind"
//////////////////////////////////////////////////////////////////////////
//-----------------------Main progression ability-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/devour_will
	name = "Devour Will"
	desc = "Creates a dark bead that can be used on a human to fully recharge Psi, gain one lucidity, and knock them unconscious. The victim will be stunned for the duration of the channel, being interrupted \
	will knock both you and the victim down. Costs 5 Psi."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	sound = null
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "devour_will"
	check_flags = AB_CHECK_HANDS_BLOCKED |  AB_CHECK_IMMOBILE | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE
	psi_cost = 5
	hand_path = /obj/item/melee/touch_attack/devour_will
	var/eating = FALSE //If we're devouring someone's will

/datum/action/cooldown/spell/touch/devour_will/can_cast_spell(feedback)
	if(eating)
		return
	return ..()

/datum/action/cooldown/spell/touch/devour_will/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/touch/devour_will/cast(mob/living/carbon/cast_on)
	. = ..()
	playsound(owner, 'yogstation/sound/magic/devour_will_form.ogg', 50, 1)

/datum/action/cooldown/spell/touch/devour_will/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/target, mob/living/carbon/caster)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(caster)
	if(!darkspawn || eating || target == caster)
		return
	if(!target.mind)
		to_chat(caster, span_warning("You cannot drain the mindless."))
		return
	if(is_darkspawn_or_thrall(target))
		to_chat(caster, span_warning("You cannot drain allies."))
		return
	if(!istype(target))
		to_chat(caster, span_warning("[target]'s mind is too pitiful to be of any use."))
		return
	if(target.stat == DEAD)
		to_chat(caster, span_warning("[target] is too weak to drain."))
		return
	if(target.has_status_effect(STATUS_EFFECT_DEVOURED_WILL))
		to_chat(caster, span_warning("[target]'s mind has not yet recovered enough willpower to be worth devouring."))
		return

	caster.Immobilize(1 SECONDS) // So they don't accidentally move while beading
	target.silent += 5

	caster.balloon_alert(caster, "Cera ko...")
	to_chat(caster, span_velvet("You begin siphoning [target]'s will..."))
	target.emote("scream")
	target.visible_message(span_danger("<i>[target] suddenly howls and clutches their face as violet light screams from their eyes!</i>"), span_userdanger("<i>AAAAAAAAAAAAAAA-</i>"))
	playsound(target, 'yogstation/sound/magic/devour_will_long.ogg', 65, FALSE)

	eating = TRUE
	if(!do_after(caster, 5 SECONDS, target))
		to_chat(target, span_boldwarning("All right... You're all right."))
		caster.Knockdown(5 SECONDS)
		eating = FALSE
		return FALSE
	eating = FALSE

	if(target.has_status_effect(STATUS_EFFECT_DEVOURED_WILL))
		to_chat(caster, span_warning("[target]'s mind has not yet recovered enough willpower to be worth devouring."))
		return
		
	//put the victim to sleep before the visible_message proc so the victim doesn't see it
	to_chat(target, span_progenitor("You suddenly feel... empty. Thoughts try to form, but flit away. You slip into a deep, deep slumber..."))
	playsound(target, 'yogstation/sound/magic/devour_will_end.ogg', 75, FALSE)
	target.playsound_local(target, 'yogstation/sound/magic/devour_will_victim.ogg', 50, FALSE)
	target.Unconscious(5 SECONDS)

	//get how much lucidity and willpower will be given
	var/willpower_amount = 2
	var/lucidity_amount = 1
	if(HAS_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED)) //change the numbers before text
		lucidity_amount = 0
		willpower_amount *= 0.5
		willpower_amount = round(willpower_amount) //make sure it's a whole number still

	//format the text output to the darkspawn
	var/list/self_text = list() 
	
	caster.balloon_alert(caster, "...akkraup'dej")
	self_text += span_velvet("You devour [target]'s will.")
	if(HAS_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED))
		self_text += span_warning("[target]'s mind is already damaged by previous devouring and has granted less willpower and no lucidity.")
	else
		self_text += span_velvet("This individual's lucidity brings you one step closer to the sacrament...")
		self_text += span_warning("After meddling with [target]'s mind, they will grant less willpower and no lucidity any future times their will is devoured.")
	self_text += span_warning("[target] is now severely weakened and will take some time to recover.")
	caster.visible_message(span_warning("[caster] gently lowers [target] to the ground..."), self_text.Join("<br>"))

	//pass out the willpower and lucidity to the darkspawns
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.grant_willpower(willpower_amount)
		team.grant_lucidity(lucidity_amount)

	//apply the long-term debuffs to the victim
	target.apply_status_effect(STATUS_EFFECT_BROKEN_WILL)
	target.apply_status_effect(STATUS_EFFECT_DEVOURED_WILL)
	ADD_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED, type)
	return TRUE

//////////////////////////////////////////////////////////////////////////
//--------------------------Glorified handcuffs-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/restrain_body
	name = "Restrain body"
	desc = "Forms rudimentary restraints on a target's hands."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	sound = null
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "restrain_body"
	check_flags = AB_CHECK_HANDS_BLOCKED |  AB_CHECK_IMMOBILE | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE
	hand_path = /obj/item/melee/touch_attack/darkspawn
	psi_cost = 5
	//Boolean on whether we're tying someone's hands
	var/tying = FALSE

/datum/action/cooldown/spell/touch/restrain_body/can_cast_spell(feedback)
	if(tying)
		return
	return ..()

/datum/action/cooldown/spell/touch/restrain_body/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/touch/restrain_body/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/target, mob/living/carbon/caster)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(caster)
	if(!darkspawn || tying || target == caster) //no tying yourself
		return
	if(is_darkspawn_or_thrall(target))
		to_chat(caster, span_warning("You cannot restrain allies."))
		return
	if(!istype(target))
		to_chat(caster, span_warning("[target]'s mind is too pitiful to be of any use."))
		return
	if(target.handcuffed)
		to_chat(caster, span_warning("[target] is already restrained."))
		return

	caster.balloon_alert(caster, "Koce ra...")
	to_chat(caster, span_velvet("You begin restraining [target]..."))
	playsound(target, 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg', 50, TRUE)
	tying = TRUE
	if(!do_after(caster, 1.5 SECONDS, target, progress = FALSE))
		tying = FALSE
		return FALSE
	tying = FALSE

	target.silent += 5

	if(target.handcuffed)
		to_chat(caster, span_warning("[target] is already restrained."))
		return

	playsound(target, 'yogstation/sound/magic/devour_will_form.ogg', 50, TRUE)
	target.set_handcuffed(new /obj/item/restraints/handcuffs/darkspawn(target))
	target.update_handcuffed()

	return TRUE

//the restrains in question
/obj/item/restraints/handcuffs/darkspawn
	name = "shadow stitched restraints"
	desc = "Bindings created by stitching together shadows."
	icon_state = "handcuffAlien"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	breakouttime = 30 SECONDS
	flags_1 = NONE
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/darkspawn/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

//////////////////////////////////////////////////////////////////////////
//-----------------------Recall shuttle ability-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/silver_tongue
	name = "Silver Tongue"
	desc = "When used near a communications console, allows you to forcefully transmit a message to Central Command, initiating a shuttle recall. Only usable if the shuttle is inbound. Costs 60 Psi."
	button_icon_state = "silver_tongue"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	invocation_type = INVOCATION_NONE
	antimagic_flags = NONE
	panel = "Darkspawn"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_IMMOBILE
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 60
	hand_path = /obj/item/melee/touch_attack/darkspawn
	///Boolean on whether this is in use.
	var/in_use = FALSE
	///The time it takes to use this spell, used in do after and to play sounds as it goes.
	var/duration = 8 SECONDS

/datum/action/cooldown/spell/touch/silver_tongue/can_cast_spell(feedback)
	if(SSshuttle.emergency.mode != SHUTTLE_CALL || in_use)
		return
	return ..()

/datum/action/cooldown/spell/touch/silver_tongue/is_valid_target(atom/cast_on)
	return istype(cast_on, /obj/machinery/computer/communications)
	
/datum/action/cooldown/spell/touch/silver_tongue/cast_on_hand_hit(obj/item/melee/touch_attack/hand, obj/machinery/computer/communications/target, mob/living/carbon/caster)
	if(in_use)
		return
	if(target.stat)
		to_chat(owner, span_warning("[target] is depowered."))
		return FALSE
		
	caster.balloon_alert(caster, "[pick("Pda ykw'lpwe skwo h'kccaz ej.", "Pda aiank'cajyu eo kran.", "Oknnu, bkn swop'ejc ukqn pkza.", "Wke swo kxn'znaz xu hws psk.")]")
	owner.visible_message(span_warning("[owner] briefly touches [target]'s screen, and the keys begin to move by themselves!"), span_velvet("You begin transmitting a recall message to Central Command..."))
	in_use = TRUE	
	play_recall_sounds(target, (duration/10)-1)
	if(!do_after(owner, duration, target))
		in_use = FALSE
		return
	in_use = FALSE
	if(!target)
		return
	if(target.stat)
		to_chat(owner, span_warning("[target] has lost power."))
		return
	SSshuttle.emergency.cancel()
	to_chat(owner, span_velvet("The ruse was a success. The shuttle is on its way back."))
	return TRUE

/datum/action/cooldown/spell/touch/silver_tongue/proc/play_recall_sounds(obj/machinery/C, iterations) //neato sound effects
	set waitfor = FALSE
	if(!C || C.stat || !in_use)
		return
	playsound(C, "terminal_type", 50, TRUE)
	if(prob(25))
		playsound(C, 'sound/machines/terminal_alert.ogg', 50, FALSE)
		do_sparks(5, TRUE, get_turf(C))
	
	if(iterations <= 0)
		addtimer(CALLBACK(src, PROC_REF(end_recall_sounds), C), 0.4 SECONDS)
	else
		addtimer(CALLBACK(src, PROC_REF(play_recall_sounds), C, iterations - 1), 1 SECONDS)

/datum/action/cooldown/spell/touch/silver_tongue/proc/end_recall_sounds(obj/machinery/C) //end the neato sound effects
	set waitfor = FALSE
	if(!C || C.stat || !in_use)
		return
	playsound(C, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
	sleep(0.4 SECONDS)
	if(!C || C.stat || !in_use)
		return
	playsound(C, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

//////////////////////////////////////////////////////////////////////////
//-----------------Used for placing things into the world---------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/darkspawn_build
	name = "Darkspawn building thing"
	desc = "You shouldn't be able to see this."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "sacrament(old)"
	antimagic_flags = NONE
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	psi_cost = 35
	cooldown_time = 15 SECONDS
	cast_range = 2
	///Whether or not the user is in the process of "building"
	var/casting = FALSE
	///How long it takes to "build"
	var/cast_time = 2 SECONDS
	///The object type that is placed at the end
	var/object_type
	///Whether or not the object can be placed on a tile containing dense things
	var/can_density = FALSE
	///The final text output when the spell finishes (flavour)
	var/language_final = "xom"

/datum/action/cooldown/spell/pointed/darkspawn_build/can_cast_spell(feedback)
	if(casting)
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/darkspawn_build/before_cast(atom/cast_on)
	. = ..()
	if(!object_type)
		. |= SPELL_CANCEL_CAST
		CRASH("someone forgot to set the placed object of a darkspawn building ability")
	if(!can_density && cast_on.density)
		return . | SPELL_CANCEL_CAST
	if(casting)
		return . | SPELL_CANCEL_CAST
	if(. & SPELL_CANCEL_CAST)
		return .
	if(cast_time)
		casting = TRUE
		owner.balloon_alert(owner, "Xkla'thra...")
		playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_begin.ogg', 50, TRUE)
		if(!do_after(owner, cast_time, cast_on))
			casting = FALSE
			return . | SPELL_CANCEL_CAST
		casting = FALSE
	
/datum/action/cooldown/spell/pointed/darkspawn_build/cast(atom/cast_on)
	. = ..()
	if(!object_type) //sanity check
		return
	playsound(get_turf(cast_on), 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	var/obj/thing = new object_type(get_turf(cast_on))
	owner.balloon_alert(owner, "...[language_final]")
	owner.visible_message(span_warning("[owner] knits shadows together into [thing]!"), span_velvet("You create [thing]"))

//////////////////////////////////////////////////////////////////////////
//----------Reform the darkspawn body after death from mmi or borg------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/reform_body
	name = "Reform body"
	desc = "You may have lost your body, but it matters not."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "sacrament(old)"
	antimagic_flags = NONE
	spell_requirements = SPELL_CASTABLE_AS_BRAIN
	
/datum/action/cooldown/spell/reform_body/cast(atom/cast_on)
	. = ..()
	if(isdarkspawn(owner))
		var/datum/antagonist/darkspawn/darkmind = isdarkspawn(owner)
		if(darkmind)//sanity check
			darkmind.reform_body()

