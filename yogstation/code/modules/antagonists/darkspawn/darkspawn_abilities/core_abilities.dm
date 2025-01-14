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
	desc = "Creates a dark bead that can be used on a human to begin draining the lucidity and willpower from a living target, knocking them unconscious for a time.\
			<br>Being interrupted will knock you down for a time."
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
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 5)
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
	if(is_team_darkspawn(target))
		to_chat(caster, span_warning("You cannot drain allies."))
		return
	if(!istype(target))
		to_chat(caster, span_warning("[target]'s mind is too pitiful to be of any use."))
		return
	if(target.stat == DEAD)
		to_chat(caster, span_warning("[target] is too weak to drain."))
		return
	if(get_shadow_tumor(target))
		to_chat(owner, span_danger("[target] already has a dark bead lodged within their psyche."))
		return FALSE

	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(!team)
		CRASH("darkspawn without a team is trying to thrall someone")

	caster.Immobilize(1 SECONDS) // So they don't accidentally move while beading
	target.Immobilize(10 SECONDS) //we remove this if it's canceled early
	target.silent += 5

	caster.balloon_alert(caster, "Cera ko...")
	to_chat(caster, span_velvet("You begin siphoning [target]'s will..."))
	target.emote("scream")
	target.visible_message(span_danger("<i>[target] suddenly howls and clutches their face as violet light screams from their eyes!</i>"), span_userdanger("<i>AAAAAAAAAAAAAAA-</i>"))
	playsound(target, 'yogstation/sound/magic/devour_will_long.ogg', 65, FALSE)

	eating = TRUE
	if(!do_after(caster, 5 SECONDS, target))
		to_chat(caster, span_danger("Being interrupted causes a backlash of psionic power."))
		caster.Immobilize(5 SECONDS)
		caster.Knockdown(10 SECONDS)
		to_chat(target, span_boldwarning("All right... You're all right."))
		target.SetImmobilized(0)
		eating = FALSE
		return FALSE
	eating = FALSE

	if(get_shadow_tumor(target))
		to_chat(owner, span_danger("[target] already has a dark bead lodged within their psyche."))
		return FALSE
		
	//put the victim to sleep before the visible_message proc so the victim doesn't see it
	to_chat(target, span_progenitor("You suddenly feel... empty. Thoughts try to form, but flit away. You slip into a deep, deep slumber..."))
	playsound(target, 'yogstation/sound/magic/devour_will_end.ogg', 75, FALSE)
	target.playsound_local(target, 'yogstation/sound/magic/devour_will_victim.ogg', 50, FALSE)

	//format the text output to the darkspawn
	var/list/self_text = list() 
	
	caster.balloon_alert(caster, "...akkraup'dej")

	var/obj/item/organ/shadowtumor/bead = target.getorganslot(ORGAN_SLOT_BRAIN_TUMOR)
	if(!bead || !istype(bead))
		bead = new
		bead.Insert(target, FALSE, FALSE)
		bead.antag_team = team

	//pass out the willpower and lucidity to the darkspawns
	if(!HAS_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED))
		ADD_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED, type)
		self_text += span_velvet("You place a dark bead deep within [target]'s psyche.")
		self_text += span_velvet("This individual's lucidity brings you one step closer to the sacrament...")
		self_text += span_velvet("You also feed off their will to fuel your growth, generating 2 willpower.")
		self_text += span_velvet("No further attempts to drain this individual will provide willpower or lucidity.")
		team.grant_willpower(2)
		team.grant_lucidity(1)
	else
		self_text += span_velvet("You replace the dark bead deep within [target]'s psyche.")

	caster.visible_message(span_warning("[caster] gently lowers [target] to the ground..."), self_text.Join("<br>"))

	//apply the long-term debuff to the victim
	target.apply_status_effect(STATUS_EFFECT_BROKEN_WILL)
	return TRUE

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
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 60)
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
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 35)
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

