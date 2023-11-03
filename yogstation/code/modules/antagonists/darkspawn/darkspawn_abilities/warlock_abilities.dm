//////////////////////////////////////////////////////////////////////////
//---------------------Warlock light eater ability----------------------// little bit of anti-fire too
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/extinguish
	name = "Extinguish"
	desc = "Extinguish all light around you."
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Kindle"
	active_icon_state = "Kindle"
	base_icon_state = "Kindle"
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	cooldown_time = 30 SECONDS
	sound = 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg'
	aoe_radius = 7
	var/obj/item/darkspawn_extinguish/bopper

/datum/action/cooldown/spell/aoe/extinguish/Grant(mob/grant_to)
	. = ..()
	bopper = new(src)
	
/datum/action/cooldown/spell/aoe/extinguish/Remove(mob/living/remove_from)
	qdel(bopper)
	. = ..()

/datum/action/cooldown/spell/aoe/extinguish/cast(atom/cast_on)
	. = ..()
	to_chat(owner, span_velvet("You extinguish all lights."))

/datum/action/cooldown/spell/aoe/extinguish/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(isturf(victim)) //no turf hitting
		return
	if(!can_see(caster, victim, aoe_radius)) //no putting out on the other side of walls
		return
	if(ishuman(victim))//put out any
		var/mob/living/carbon/human/target = victim
		target.extinguish_mob()
		if(is_darkspawn_or_veil(target)) //don't put out or damage any lights carried by allies
			return
	if(isobj(victim))//put out any items too
		var/obj/target = victim
		target.extinguish()
	SEND_SIGNAL(bopper, COMSIG_ITEM_AFTERATTACK, victim, owner, TRUE) //just use a light eater attack on everyone

/obj/item/darkspawn_extinguish
	name = "extinguish"
	desc = "you shouldn't be seeing this, it's just used for the spell and nothing else"

/obj/item/darkspawn_extinguish/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/light_eater)

//////////////////////////////////////////////////////////////////////////
//---------------------Mess up an APC pretty badly----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/null_charge
	name = "Null Charge"
	desc = "Empties an APC, preventing it from recharging until fixed."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "null_charge"

	cooldown_time = 30 SECONDS
	antimagic_flags = NONE
	panel = null
	check_flags =  AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 15
	hand_path = /obj/item/melee/touch_attack/null_charge

/datum/action/cooldown/spell/touch/null_charge/is_valid_target(atom/cast_on)
	return istype(cast_on, /obj/machinery/power/apc)

/datum/action/cooldown/spell/touch/null_charge/cast_on_hand_hit(obj/item/melee/touch_attack/hand, obj/machinery/power/apc/target, mob/living/carbon/human/caster)
	if(!target || !istype(target))//sanity check
		return FALSE

	//Turn it off for the time being
	target.set_light(0)
	target.visible_message(span_warning("The [target] flickers and begins to grow dark."))

	to_chat(caster, span_velvet("You dim the APC's screen and carefully begin siphoning its power into the void."))
	if(!do_after(caster, 5 SECONDS, target))
		//Whoops!  The APC's light turns back on
		to_chat(caster, span_velvet("Your concentration breaks and the APC suddenly repowers!"))
		target.set_light(2)
		target.visible_message(span_warning("The [target] begins glowing brightly!"))
	else
		//We did it
		to_chat(caster, span_velvet("You return the APC's power to the void, disabling it."))
		target.cell?.charge = 0	//Sent to the shadow realm
		target.chargemode = 0 //Won't recharge either until an engineer hits the button
		target.charging = 0
		target.update_appearance(UPDATE_ICON)

/obj/item/melee/touch_attack/null_charge
	name = "null charge"
	desc = "Succ that power boi."
	icon_state = "flagellation"
	item_state = "hivemind"

//////////////////////////////////////////////////////////////////////////
//-----------------------Drain enemy, heal ally-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/extract
	name = "Extract"
	desc = "Drain a target's life force or bestow it to an ally."
	button_icon = 'yogstation/icons/mob/sling.dmi'
	button_icon_state = "slingbeam"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	cooldown_time = 5 SECONDS
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = 5
	var/mob/living/channeled
	var/datum/beam/visual
	var/datum/antagonist/darkspawn/cost
	var/upkeep_cost = 1 //happens 5 times a second

/datum/action/cooldown/spell/pointed/extract/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/pointed/extract/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/cooldown/spell/pointed/extract/Grant(mob/grant_to)
	. = ..()
	if(isdarkspawn(owner))
		cost = isdarkspawn(owner)

/datum/action/cooldown/spell/pointed/extract/can_cast_spell(feedback)
	if(channeled)
		return FALSE
	. = ..()

/datum/action/cooldown/spell/pointed/extract/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_cast_on = cast_on
	if(living_cast_on.stat == DEAD)
		to_chat(owner, span_warning("[cast_on] is dead!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/extract/process()
	. = ..()
	if(channeled)
		if(channeled.stat == DEAD)
			channeled = null
			qdel(visual)
			return
		if(get_dist(owner, channeled) > cast_range)
			channeled = null
			qdel(visual)
			return
		if(cost && (!cost.use_psi(upkeep_cost)))
			channeled = null
			qdel(visual)
			return
		if(is_darkspawn_or_veil(channeled))
			channeled.heal_ordered_damage(10, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
		else
			channeled.apply_damage(10, BURN)
			if(isliving(owner))
				var/mob/living/healed = owner
				healed.heal_ordered_damage(10, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))

/datum/action/cooldown/spell/pointed/extract/cast(mob/living/cast_on)
	. = ..()
	visual = owner.Beam(cast_on, "slingbeam", 'yogstation/icons/mob/sling.dmi' , INFINITY, 10)
	channeled = cast_on
