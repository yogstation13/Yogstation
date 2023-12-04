/obj/item/clothing/gloves/powerfist
	name = "power-fist"
	desc = "A metal gauntlet with a piston-powered ram ontop for that extra 'ompfh' in your punch."
	icon = 'icons/obj/traitor.dmi'
	icon_state = "powerfist"
	item_state = "powerfist"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	attack_verb = list("whacked", "fisted", "power-punched")
	force = 20
	throwforce = 10
	throw_range = 7
	strip_delay = 80
	cold_protection = HANDS
	heat_protection = HANDS
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, ELECTRIC = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/click_delay = 1.5
	var/fisto_setting = 1
	var/max_setting = 3
	var/gasperfist = 3
	var/obj/item/tank/internals/tank = null //Tank used for the gauntlet's piston-ram.

/obj/item/clothing/gloves/powerfist/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(power_punch))

/obj/item/clothing/gloves/powerfist/dropped(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES)==src)
		UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	return ..()

/obj/item/clothing/gloves/powerfist/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += span_notice("You'll need to get closer to see any more.")
		return
	if(tank)
		. += span_notice("[icon2html(tank, user)] It has \a [tank] mounted onto it.")


/obj/item/clothing/gloves/powerfist/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals))
		if(!tank)
			var/obj/item/tank/internals/IT = W
			if(IT.volume <= 3)
				to_chat(user, span_warning("\The [IT] is too small for \the [src]."))
				return
			updateTank(W, 0, user)
	else if(W.tool_behaviour == TOOL_WRENCH)
		fisto_setting++
		if(fisto_setting > max_setting)
			fisto_setting = 1
		W.play_tool_sound(src)
		user.balloon_alert(user, span_notice("power set to [fisto_setting]"))
		to_chat(user, span_notice("You tweak \the [src]'s piston valve to [fisto_setting]."))
	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(tank)
			updateTank(tank, 1, user)
	else if(W.tool_behaviour == TOOL_ANALYZER)
		if(tank)
			atmosanalyzer_scan(user, tank)

/obj/item/clothing/gloves/powerfist/proc/updateTank(obj/item/tank/internals/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			to_chat(user, span_notice("\The [src] currently has no tank attached to it."))
			return
		to_chat(user, span_notice("You detach \the [thetank] from \the [src]."))
		tank.forceMove(get_turf(user))
		user.put_in_hands(tank)
		tank = null
	if(!removing)
		if(tank)
			to_chat(user, span_warning("\The [src] already has a tank."))
			return
		if(!user.transferItemToLoc(thetank, src))
			return
		to_chat(user, span_notice("You hook \the [thetank] up to \the [src]."))
		tank = thetank

/obj/item/clothing/gloves/powerfist/attack(mob/living/target, mob/living/user)
	power_punch(user, target)

/obj/item/clothing/gloves/powerfist/proc/power_punch(mob/living/user, atom/movable/target)
	if(!user || user.a_intent!=INTENT_HARM || (!isliving(target) && !isobj(target)) || isitem(target))
		return
	if(!tank)
		to_chat(user, span_warning("\The [src] can't operate without a source of gas!"))
		return
	var/moles_used = min(tank.air_contents.total_moles(), gasperfist * fisto_setting)
	var/datum/gas_mixture/gasused = tank.air_contents.remove(gasperfist * fisto_setting)
	var/turf/T = get_turf(src)
	if(!T)
		return
	T.assume_air(gasused)
	if(!gasused)
		to_chat(user, span_warning("\The [src]'s tank is empty!"))
		do_attack(user, target, force / 5)
		playsound(loc, 'sound/weapons/punch1.ogg', 50, 1)
		target.visible_message(span_danger("[user]'s powerfist lets out a dull thunk as [user.p_they()] punch[user.p_es()] [target.name]!"), \
			span_userdanger("[user]'s punches you!"))
		return COMPONENT_NO_ATTACK_HAND
	if(moles_used < gasperfist * fisto_setting)
		to_chat(user, span_warning("\The [src]'s piston-ram lets out a weak hiss, it needs more gas!"))
		playsound(loc, 'sound/weapons/punch4.ogg', 50, 1)
		do_attack(user, target, force / 2)
		target.visible_message(span_danger("[user]'s powerfist lets out a weak hiss as [user.p_they()] punch[user.p_es()] [target.name]!"), \
			span_userdanger("[user]'s punch strikes with force!"))
		return COMPONENT_NO_ATTACK_HAND
	do_attack(user, target, force * moles_used / gasperfist)
	target.visible_message(span_danger("[user]'s powerfist lets out a loud hiss as [user.p_they()] punch[user.p_es()] [target.name]!"), \
		span_userdanger("You cry out in pain as [user]'s punch flings you backwards!"))
	new /obj/effect/temp_visual/kinetic_blast(target.loc)
	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, 1)

	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))

	if(!target.anchored)
		target.throw_at(throw_target, 5 * fisto_setting, 0.5 + (fisto_setting / 2))

	log_combat(user, target, "power fisted", src)

	return COMPONENT_NO_ATTACK_HAND

/obj/item/clothing/gloves/powerfist/proc/do_attack(mob/living/user, atom/target, punch_force)
	if(isliving(target))
		var/mob/living/target_mob = target
		target_mob.apply_damage(punch_force, BRUTE, wound_bonus = CANT_WOUND)
	else if(isobj(target))
		var/obj/target_obj = target
		target_obj.take_damage(punch_force, BRUTE, MELEE, FALSE)
	user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	user.changeNext_move(CLICK_CD_MELEE * click_delay)

/obj/item/clothing/gloves/powerfist/filled
	var/obj/item/tank/internals/plasma/full/fire

/obj/item/clothing/gloves/powerfist/filled/Initialize(mapload)
	. = ..()
	fire = new(src)
	tank = fire
