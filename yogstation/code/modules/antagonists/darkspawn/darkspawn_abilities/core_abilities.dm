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
//After a brief charge-up, equips a temporary dark bead that can be used on a human to knock them out and drain their will, making them vulnerable to conversion.
/datum/action/cooldown/spell/touch/devour_will
	name = "Devour Will"
	desc = "Creates a dark bead that can be used on a human to fully recharge Psi, gain one lucidity, and knock them unconscious. The victim will be stunned for the duration of the channel, being interrupted \
	will knock both you and the victim down. Costs 5 Psi."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "devour_will"
	check_flags = AB_CHECK_HANDS_BLOCKED |  AB_CHECK_IMMOBILE | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 5
	hand_path = /obj/item/melee/touch_attack/devour_will
	var/eating = FALSE //If we're devouring someone's will
	var/list/victims = list()//A list of people we've used the bead on recently; we can't drain them again so soon
	var/last_victim

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
	if(!darkspawn || eating || target == caster) //no eating urself ;)))))))
		return
	if(!target.mind)
		to_chat(caster, span_warning("You cannot drain the mindless."))
		return
	if(is_darkspawn_or_veil(target))
		to_chat(caster, span_warning("You cannot drain allies."))
		return
	if(!istype(target))
		to_chat(caster, span_warning("[target]'s mind is too pitiful to be of any use."))
		return
	if(!target.health || target.stat)
		to_chat(caster, span_warning("[target] is too weak to drain."))
		return
	if(victims[target])
		to_chat(caster, span_warning("[target] must be given time to recover from their last draining."))
		return
	if(target.ckey && last_victim == target.ckey)
		to_chat(caster, span_warning("[target]'s mind is still too scrambled. Drain someone else first."))
		return
	eating = TRUE
	target.Stun(5 SECONDS)
	caster.Immobilize(1 SECONDS) // So they don't accidentally move while beading
	ADD_TRAIT(target, TRAIT_PARALYSIS, "bead-trait")
	if(caster.loc != target)
		caster.visible_message(span_warning("[caster] grabs [target] and leans in close..."), "<span class='velvet bold'>cera qo...</span><br>\
		[span_danger("You begin siphoning [target]'s mental energy...")]")
		to_chat(target, span_userdanger("<i>AAAAAAAAAAAAAA-</i>"))
		target.silent += 4
		playsound(target, 'yogstation/sound/magic/devour_will.ogg', 65, FALSE) //T A S T Y   S O U L S
		if(!do_after(caster, 3 SECONDS, target))
			REMOVE_TRAIT(target, TRAIT_PARALYSIS, "bead-trait")
			caster.Knockdown(3 SECONDS)
			to_chat(target, span_boldwarning("All right... You're all right."))
			target.Knockdown(3 SECONDS)
			qdel(src, force = TRUE)
			return
	else
		target.visible_message("<span class='userdanger italics'>[target] suddenly howls and clutches as their face as violet light screams from their eyes!</span>", \
		"<span class='userdanger italics'>AAAAAAAAAAAAAAA-</span>")
		to_chat(caster, span_velvet("<b>cera qo...</b><br>You begin siphoning [target]'s will..."))
		playsound(target, 'yogstation/sound/magic/devour_will_long.ogg', 65, FALSE)
		if(!do_after(caster, 5 SECONDS, target))
			REMOVE_TRAIT(target, TRAIT_PARALYSIS, "bead-trait")
			caster.Knockdown(5 SECONDS)
			to_chat(target, span_boldwarning("All right. You're all right."))
			target.Knockdown(5 SECONDS)
			qdel(src, force = TRUE)
			return
	REMOVE_TRAIT(target, TRAIT_PARALYSIS, "bead-trait")
	caster.visible_message(span_warning("[caster] gently lowers [target] to the ground..."),
		span_velvet("<b>...aranupdejc</b><br> You devour [target]'s will. Your Psi has been fully restored.\
		Additionally, you have gained one lucidity. Use it to purchase and upgrade abilities.<br>\
		[span_warning("[target] is now severely weakened and will take some time to recover.")] \
		[span_warning("Additionally, you can not drain them again without first draining someone else.")]"))
	playsound(target, 'yogstation/sound/magic/devour_will_victim.ogg', 50, FALSE)

	darkspawn.psi = darkspawn.psi_cap
	darkspawn.update_psi_hud()

	to_chat(caster, "<span class ='velvet'> This individual's lucidity brings you one step closer to the sacrament...</span>")
	for(var/datum/mind/dark_mind in get_antag_minds(/datum/antagonist/darkspawn))
		var/datum/antagonist/darkspawn/teammate = dark_mind.has_antag_datum(/datum/antagonist/darkspawn)
		if(teammate && istype(teammate))//sanity check
			teammate.lucidity++ 
			teammate.lucidity_drained++

	victims[target] = TRUE
	last_victim = target.ckey
	to_chat(target, span_userdanger("You suddenly feel... empty. Thoughts try to form, but flit away. You slip into a deep, deep slumber..."))
	target.playsound_local(target, 'yogstation/sound/magic/devour_will_end.ogg', 75, FALSE)
	target.Unconscious(5 SECONDS)
	target.apply_effect(EFFECT_STUTTER, 20)
	target.apply_status_effect(STATUS_EFFECT_BROKEN_WILL)
	addtimer(CALLBACK(src, PROC_REF(make_eligible), target), 60 SECONDS)
	qdel(src, force = TRUE)
	return TRUE

/datum/action/cooldown/spell/touch/devour_will/proc/make_eligible(mob/living/target)
	if(!target || !victims[target])
		return
	victims[target] = FALSE
	to_chat(owner, span_notice("[target] has recovered from their draining and is vulnerable to Devour Will again."))
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
	antimagic_flags = NONE
	panel = null
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_IMMOBILE
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 60
	var/in_use = FALSE
	hand_path = /obj/item/melee/touch_attack/darkspawn

/datum/action/cooldown/spell/touch/silver_tongue/can_cast_spell(feedback)
	if(SSshuttle.emergency.mode != SHUTTLE_CALL || in_use)
		return
	return ..()

/datum/action/cooldown/spell/touch/silver_tongue/is_valid_target(atom/cast_on)
	return istype(cast_on, /obj/machinery/computer/communications)
	
/datum/action/cooldown/spell/touch/silver_tongue/cast_on_hand_hit(obj/item/melee/touch_attack/hand, obj/machinery/computer/communications/target, mob/living/carbon/caster)
	if(in_use)
		return
	in_use = TRUE
	if(target.stat)
		to_chat(owner, span_warning("[target] is depowered."))
		return FALSE
	owner.visible_message(span_warning("[owner] briefly touches [src]'s screen, and the keys begin to move by themselves!"), \
	"<span class='velvet bold'>[pick("Oknnu. Pda ywlpwej swo hkccaz ej.", "Pda aiancajyu eo kran. Oknnu bkn swopejc ukqn peia.", "We swo knzanaz xu Hws Psk. Whh ckkz jks.")]</span><br>\
	[span_velvet("You begin transmitting a recall message to Central Command...")]")
	play_recall_sounds(target)
	if(!do_after(owner, 8 SECONDS, target))
		in_use = FALSE
		return
	if(!target)
		in_use = FALSE
		return
	if(target.stat)
		to_chat(owner, span_warning("[target] has lost power."))
		in_use = FALSE
		return
	in_use = FALSE
	SSshuttle.emergency.cancel()
	to_chat(owner, span_velvet("The ruse was a success. The shuttle is on its way back."))
	return TRUE

/datum/action/cooldown/spell/touch/silver_tongue/proc/play_recall_sounds(obj/machinery/C) //neato sound effects
	set waitfor = FALSE
	for(var/i in 1 to 4)
		sleep(1 SECONDS)
		if(!C || C.stat)
			return
		playsound(C, "terminal_type", 50, TRUE)
		if(prob(25))
			playsound(C, 'sound/machines/terminal_alert.ogg', 50, FALSE)
			do_sparks(5, TRUE, get_turf(C))
	playsound(C, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
	sleep(0.5 SECONDS)
	if(!C || C.stat)
		return
	playsound(C, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

//////////////////////////////////////////////////////////////////////////
//--------------------Transform into a simplemob------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/shapeshift/crawling_shadows
	name = "Crawling Shadows"
	desc = "Assumes a shadowy form for a minute that can crawl through vents and squeeze through the cracks in doors. You can also knock people out by attacking them."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "creep"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 60
	die_with_shapeshifted_form = FALSE
	convert_damage = FALSE
	sound = 'yogstation/sound/magic/devour_will_end.ogg'
	possible_shapes = list(/mob/living/simple_animal/hostile/crawling_shadows)

/datum/action/cooldown/spell/shapeshift/crawling_shadows/can_cast_spell(feedback)
	if(owner.has_status_effect(STATUS_EFFECT_TAGALONG))
		return FALSE
	. = ..()
	
//////////////////////////////////////////////////////////////////////////
//------------------------Summon a distraction--------------------------//
//////////////////////////////////////////////////////////////////////////
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
	playsound(owner, 'yogstation/sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/effect/simulacrum/simulacrum = new(get_turf(owner))
	simulacrum.mimic(owner)


//////////////////////////////////////////////////////////////////////////
//-----------------Used for placing things into the world---------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/darkspawn_build
	name = "Darkspawn building thing"
	desc = "You shouldn't be able to see this."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "sacrament"
	antimagic_flags = NONE
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	cooldown_time = 15 SECONDS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	psi_cost = 20
	cast_range = 2
	var/casting = FALSE
	var/cast_time = 2 SECONDS
	var/object_type

/datum/action/cooldown/spell/pointed/darkspawn_build/can_cast_spell(feedback)
	if(casting)
		return FALSE
	. = ..()

/datum/action/cooldown/spell/pointed/darkspawn_build/before_cast(atom/cast_on)
	. = ..()
	if(!object_type)
		. = . | SPELL_CANCEL_CAST
		CRASH("someone forgot to set the placed object of a darkspawn building ability")
	if(cast_on.density)
		return . | SPELL_CANCEL_CAST
	if(casting)
		return . | SPELL_CANCEL_CAST
	if(. & SPELL_CANCEL_CAST)
		return .
	casting = TRUE
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_begin.ogg', 50, TRUE)
	if(!do_after(owner, cast_time, cast_on))
		casting = FALSE
		return . | SPELL_CANCEL_CAST
	casting = FALSE
	
/datum/action/cooldown/spell/pointed/darkspawn_build/cast(atom/cast_on)
	. = ..()
	if(!object_type) //sanity check
		return
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	var/obj/thing = new object_type(get_turf(cast_on))
	owner.visible_message(span_warning("[owner] knits shadows together into a [thing]!"), span_velvet("You create a [thing]"))
