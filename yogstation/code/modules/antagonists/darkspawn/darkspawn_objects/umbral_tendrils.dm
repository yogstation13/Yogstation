//Created by Pass.
/obj/item/umbral_tendrils
	name = "umbral tendrils"
	desc = "A mass of pulsing, chitonous tendrils with exposed violet flesh."
	icon = 'yogstation/icons/obj/darkspawn_items.dmi'
	icon_state = "umbral_tendrils"
	item_state = "umbral_tendrils"
	lefthand_file = 'yogstation/icons/mob/inhands/antag/darkspawn_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/antag/darkspawn_righthand.dmi'
	hitsound = 'yogstation/sound/magic/pass_attack.ogg'
	attack_verb = list("impaled", "tentacled", "torn")
	item_flags = ABSTRACT | DROPDEL
	sharpness = SHARP_EDGED
	force = 25
	wound_bonus = -60 //no wounding
	bare_wound_bonus = 20
	var/obj/item/umbral_tendrils/twin
	COOLDOWN_DECLARE(grab_cooldown)
	COOLDOWN_DECLARE(dodge_cooldown)
	var/cooldown_length = 1 SECONDS //just to prevent accidentally wasting all your psi

/obj/item/umbral_tendrils/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	AddComponent(/datum/component/light_eater)
	for(var/obj/item/umbral_tendrils/U in loc)
		if(U != src)
			twin = U
			U.twin = src
			force *= 0.75
			U.force *= 0.75

/obj/item/umbral_tendrils/Destroy()
	if(!QDELETED(twin))
		qdel(twin)
	return ..()

/obj/item/umbral_tendrils/worn_overlays(mutable_appearance/standing, isinhands, icon_file) //this doesn't work and i have no clue why
	. = ..()
	if(isinhands)
		. += emissive_appearance(icon_file, "[item_state]_emissive", src)

/obj/item/umbral_tendrils/examine(mob/user)
	. = ..()
	if(isobserver(user) || isdarkspawn(user))
		. += span_velvet("<b>Functions:</b>")
		. += span_velvet("<b>Airlock Forcing:</b> Click on an airlock to force it open for 15 Psi (or 30 if it's bolted.)")
		. += span_velvet("<b>Tendril Swing:</b> Right click to consume 30 psi to a projectile that travels up to five tiles, knocking down[twin ? " and pulling forwards" : ""] the first creature struck.")
		. += span_velvet("The tendrils will devour any lights hit.")
		. += span_velvet("Also functions to pry open depowered airlocks using right click.")

/obj/item/umbral_tendrils/attack(mob/living/target, mob/living/user, twinned_attack = TRUE)
	. = ..()
	if(!. && twin && twinned_attack && user.Adjacent(target))
		addtimer(CALLBACK(twin, PROC_REF(attack), target, user, FALSE), 0.2 SECONDS)

/obj/item/umbral_tendrils/afterattack(atom/target, mob/living/user, proximity, params)
	. = ..()
	if(twin && proximity && !QDELETED(target) && (isstructure(target) || ismachinery(target)) && user.get_active_held_item() == src)
		target.attackby(twin, user)

/obj/item/umbral_tendrils/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if(!isdarkspawn(user))
		return ..()
	tendril_swing(user, target) //Note that airlock interactions can be found in airlock.dm.
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/umbral_tendrils/proc/tendril_swing(mob/living/user, mob/living/target) //swing the tendrils to knock someone down
	if(!COOLDOWN_FINISHED(src, grab_cooldown))
		return
	if(!(user.mind && SEND_SIGNAL(user.mind, COMSIG_MIND_CHECK_ANTAG_RESOURCE, ANTAG_RESOURCE_DARKSPAWN, 30)))
		return
	if(isliving(target) && target.lying)
		to_chat(user, span_warning("[target] is already knocked down!"))
		return
	SEND_SIGNAL(user.mind, COMSIG_MIND_SPEND_ANTAG_RESOURCE, list(ANTAG_RESOURCE_DARKSPAWN = 30))
	COOLDOWN_START(src, grab_cooldown, cooldown_length)
	user.visible_message(span_warning("[user] draws back [src] and swings them towards [target]!"), \
	span_velvet("<b>opehhjaoo</b><br>You swing your tendrils towards [target]!"))
	playsound(user, 'sound/magic/tail_swing.ogg', 50, TRUE)
	var/obj/projectile/umbral_tendrils/T = new(get_turf(user))
	T.preparePixelProjectile(target, user)
	T.twinned = twin
	T.firer = user
	T.fire()

/obj/projectile/umbral_tendrils
	name = "umbral tendrils"
	icon_state = "cursehand0"
	hitsound = 'yogstation/sound/magic/pass_attack.ogg'
	layer = LARGE_MOB_LAYER
	damage = 0
	nodamage = TRUE
	speed = 1
	range = 5
	var/twinned = FALSE
	var/beam

/obj/projectile/umbral_tendrils/fire(setAngle)
	beam = firer.Beam(src, icon_state = "curse0", time = INFINITY, maxdistance = INFINITY)
	..()

/obj/projectile/umbral_tendrils/Destroy()
	qdel(beam)
	. = ..()

/obj/projectile/umbral_tendrils/on_hit(atom/movable/target, blocked = FALSE)
	if(blocked >= 100)
		return
	. = TRUE
	if(isliving(target))
		var/mob/living/L = target
		if(is_team_darkspawn(L))
			return BULLET_ACT_FORCE_PIERCE //ignore allies
		if(iscarbon(target))
			playsound(target, 'yogstation/sound/magic/pass_attack.ogg', 50, TRUE)
			L.Knockdown(6 SECONDS)
			if(!twinned)
				target.visible_message(span_warning("[firer]'s [name] slam into [target], knocking them off their feet!"), \
				span_userdanger("You're knocked off your feet!"))
			else
				L.Immobilize(0.15 SECONDS) // so they cant cancel the throw by moving
				target.throw_at(get_step_towards(firer, target), 7, 2) //pull them towards us!
				target.visible_message(span_warning("[firer]'s [name] slam into [target] and drag them across the ground!"), \
				span_userdanger("You're suddenly dragged across the floor!"))
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), target, 'yogstation/sound/magic/pass_attack.ogg', 50, TRUE), 1)
		else if(issilicon(target))
			var/mob/living/silicon/robot/R = target
			target.visible_message(span_warning("[firer]'s [name] smashes into [target]'s chassis!"), \
			span_userdanger("Heavy percussive impact detected. Recalibrating motor input."))
			R.playsound_local(target, 'sound/misc/interference.ogg', 25, FALSE)
			playsound(R, 'sound/effects/bang.ogg', 50, TRUE)
			R.Paralyze(40)
			R.adjustBruteLoss(10)
		else
			return BULLET_ACT_FORCE_PIERCE //ignore things that don't matter

