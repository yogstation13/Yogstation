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
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	sound = null
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "devour_will"
	check_flags = AB_CHECK_HANDS_BLOCKED |  AB_CHECK_IMMOBILE | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
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
	if(target.has_status_effect(STATUS_EFFECT_DEVOURED_WILL))
		to_chat(caster, span_warning("[target]'s mind has not yet recovered enough willpower to be worth devouring."))
		return


	target.Stun(5 SECONDS)
	caster.Immobilize(1 SECONDS) // So they don't accidentally move while beading
	ADD_TRAIT(target, TRAIT_PARALYSIS, type)
	target.silent += 5

	target.visible_message(span_danger("<i>[target] suddenly howls and clutches as their face as violet light screams from their eyes!</i>"), span_userdanger("<i>AAAAAAAAAAAAAAA-</i>"))
	to_chat(caster, span_velvet("<b>cera qo...</b><br>You begin siphoning [target]'s will..."))
	playsound(target, 'yogstation/sound/magic/devour_will_long.ogg', 65, FALSE)

	eating = TRUE
	if(!do_after(caster, 5 SECONDS, target))
		to_chat(target, span_boldwarning("All right... You're all right."))
		REMOVE_TRAIT(target, TRAIT_PARALYSIS, type)
		caster.Knockdown(5 SECONDS)
		target.Knockdown(5 SECONDS)
		eating = FALSE
		return FALSE
	eating = FALSE

	REMOVE_TRAIT(target, TRAIT_PARALYSIS, type)

	//put the victim to sleep before the visible_message proc so the victim doesn't see it
	to_chat(target, span_progenitor("You suddenly feel... empty. Thoughts try to form, but flit away. You slip into a deep, deep slumber..."))
	playsound(target, 'yogstation/sound/magic/devour_will_end.ogg', 75, FALSE)
	target.playsound_local(target, 'yogstation/sound/magic/devour_will_victim.ogg', 50, FALSE)
	target.Unconscious(5 SECONDS)

	//get how much lucidity and willpower will be given
	var/willpower_amount = 4
	var/lucidity_amount = 1
	if(HAS_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED)) //change the numbers before text
		lucidity_amount = 0
		willpower_amount *= 0.5
		willpower_amount = round(willpower_amount) //make sure it's a whole number still

	//pass out the willpower and lucidity to the darkspawns
	for(var/datum/mind/dark_mind in get_antag_minds(/datum/antagonist/darkspawn))
		var/datum/antagonist/darkspawn/teammate = dark_mind.has_antag_datum(/datum/antagonist/darkspawn)
		if(teammate && istype(teammate))//sanity check
			teammate.willpower += willpower_amount
	SSticker.mode.lucidity += lucidity_amount

	//format the text output to the darkspawn
	var/list/self_text = list() 
	self_text += span_velvet("<b>...aranupdejc</b>")
	self_text += span_velvet("You devour [target]'s will.")
	self_text += span_velvet("You have gained [willpower_amount] willpower. Use willpower to purchase abilities and passives.")
	if(HAS_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED))
		self_text += span_warning("[target]'s mind is already damaged by previous devouring and has granted less willpower and no lucidity.")
	else
		self_text += span_velvet("This individual's lucidity brings you one step closer to the sacrament...")
		self_text += span_warning("After meddling with [target]'s mind, they will grant less willpower and no lucidity any future times their will is devoured.")
	self_text += span_warning("[target] is now severely weakened and will take some time to recover.")
	caster.visible_message(span_warning("[caster] gently lowers [target] to the ground..."), self_text.Join("<br>"))

	//apply the long-term debuffs to the victim
	target.apply_status_effect(STATUS_EFFECT_BROKEN_WILL)
	target.apply_status_effect(STATUS_EFFECT_DEVOURED_WILL)
	ADD_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED, type)
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
	panel = null
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_IMMOBILE
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 60
	var/in_use = FALSE
	hand_path = /obj/item/melee/touch_attack/darkspawn
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
	owner.visible_message(span_warning("[owner] briefly touches [src]'s screen, and the keys begin to move by themselves!"), span_velvet("<b>[pick("Oknnu. Pda ywlpwej swo hkccaz ej.", "Pda aiancajyu eo kran. Oknnu bkn swopejc ukqn peia.", "We swo knzanaz xu Hws Psk. Whh ckkz jks.")]</b><br>You begin transmitting a recall message to Central Command..."))
	play_recall_sounds(target)
	in_use = TRUE
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

/datum/action/cooldown/spell/touch/silver_tongue/proc/play_recall_sounds(obj/machinery/C) //neato sound effects
	set waitfor = FALSE
	playsound(C, "terminal_type", 50, TRUE)
	for(var/i in 1 to ((duration/10)-1)) //8 seconds (80) -> 7 loops -> 7 seconds of random typing and beeping
		sleep(1 SECONDS)
		if(!C || C.stat || !in_use)
			return
		playsound(C, "terminal_type", 50, TRUE)
		if(prob(25))
			playsound(C, 'sound/machines/terminal_alert.ogg', 50, FALSE)
			do_sparks(5, TRUE, get_turf(C))
	sleep(0.4 SECONDS)
	if(!C || C.stat || !in_use)
		return
	playsound(C, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
	sleep(0.4 SECONDS)
	if(!C || C.stat || !in_use)
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
/datum/action/cooldown/spell/simulacrum
	name = "Simulacrum"
	desc = "Creates an illusion that closely resembles you. The illusion will fight nearby enemies in your stead for 10 seconds. Costs 40 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "simulacrum"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 40
	var/duration = 10 SECONDS
	//no cooldown, make an army if you really want

/datum/action/cooldown/spell/simulacrum/cast(atom/cast_on)
	. = ..()
	if(!isliving(owner))
		return
	var/mob/living/L = owner
	L.visible_message(span_warning("[L] breaks away from [L]'s shadow!"))
	to_chat(L, span_velvet("<b>zayaera</b><br>You create an illusion of yourself."))
	playsound(L, 'yogstation/sound/magic/devour_will_form.ogg', 50, 1)

	var/mob/living/simple_animal/hostile/illusion/M = new(get_turf(L))
	M.faction = list(ROLE_DARKSPAWN)
	M.Copy_Parent(L, duration, 100, 10) //closely follows regular player stats so it's not painfully obvious (still sorta is)
	M.move_to_delay = L.movement_delay()

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
	var/can_density = FALSE

/datum/action/cooldown/spell/pointed/darkspawn_build/can_cast_spell(feedback)
	if(casting)
		return FALSE
	. = ..()

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
	owner.visible_message(span_warning("[owner] knits shadows together into [thing]!"), span_velvet("You create [thing]"))
