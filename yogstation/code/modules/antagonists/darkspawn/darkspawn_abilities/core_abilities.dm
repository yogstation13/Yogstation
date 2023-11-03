//////////////////////////////////////////////////////////////////////////
//--------------------Abilities all three classes get-------------------//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//-----------------------Main progression ability-----------------------//
//////////////////////////////////////////////////////////////////////////
//After a brief charge-up, equips a temporary dark bead that can be used on a human to knock them out and drain their will, making them vulnerable to conversion.
/datum/action/cooldown/spell/devour_will
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
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 5
	var/list/victims = list()//A list of people we've used the bead on recently; we can't drain them again so soon
	var/last_victim

/datum/action/cooldown/spell/devour_will/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes())
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/devour_will/cast(atom/cast_on)
	. = ..()
	owner.visible_message(span_warning("A glowing black orb appears in [owner]'s hand!"), "<span class='velvet'><b>pwga...iejz</b><br>\
	You form a dark bead in your hand.</span>")
	playsound(owner, 'yogstation/sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/item/dark_bead/B = new
	owner.put_in_hands(B)
	B.linked_ability = src
	return TRUE

/datum/action/cooldown/spell/devour_will/proc/make_eligible(mob/living/L)
	if(!L || !victims[L])
		return
	victims[L] = FALSE
	to_chat(owner, span_notice("[L] has recovered from their draining and is vulnerable to Devour Will again."))
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
	else
		owner.visible_message(span_warning("[owner] splits in two!"), \
		span_velvet("<b>zayaera</b><br>You create an illusion of yourself."))
	playsound(owner, 'yogstation/sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/effect/simulacrum/simulacrum = new(get_turf(owner))
	simulacrum.mimic(owner)
