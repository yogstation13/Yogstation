/obj/item/psychic_power/telekinesis
	name = "telekinetic grip"
	maintain_cost = 3
	icon_state = "telekinesis"
	var/atom/movable/focus

/obj/item/psychic_power/telekinesis/Destroy()
	focus = null
	. = ..()

/obj/item/psychic_power/telekinesis/process()
	if(!focus || !isturf(focus.loc) || get_dist(get_turf(focus), get_turf(owner)) > owner.psi.get_rank(PSI_PSYCHOKINESIS))
		owner.dropItemToGround(src)
		return
	. = ..()

/obj/item/psychic_power/telekinesis/proc/set_focus(atom/movable/_focus)

	if(!isturf(_focus.loc))
		return FALSE

	var/check_paramount
	if(isliving(_focus))
		var/mob/living/victim = _focus
		check_paramount = (victim.mob_size >= MOB_SIZE_HUMAN)
	else if(isitem(_focus))
		var/obj/item/thing = _focus
		check_paramount = (thing.w_class >= WEIGHT_CLASS_BULKY)
	else
		return FALSE

	if(_focus.anchored || (check_paramount && owner.psi.get_rank(PSI_PSYCHOKINESIS) < PSI_RANK_PARAMOUNT))
		focus = _focus
		. = attack_self(owner)
		if(!.)
			to_chat(owner, span_warning("\The [_focus] is too hefty for you to get a mind-grip on."))
		qdel(src)
		return FALSE

	focus = _focus
	overlays.Cut()
	var/image/I = image(icon = focus.icon, icon_state = focus.icon_state)
	I.color = focus.color
	I.overlays = focus.overlays
	overlays += I
	return TRUE

/obj/item/psychic_power/telekinesis/attack_self(mob/user)
	user.visible_message(span_notice("[user] makes a strange gesture."))
	sparkle()
	return focus.do_simple_ranged_interaction(user)

/obj/item/psychic_power/telekinesis/afterattack(atom/target, mob/living/user, proximity)

	if(!target || !user || (isobj(target) && !isturf(target.loc)) || !user.psi || !user.psi.can_use() || !user.psi.spend_power(5))
		return

	//user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN) FIX ME
	user.psi.set_cooldown(5)

	var/distance = get_dist(get_turf(user), get_turf(focus ? focus : target))
	if(distance > user.psi.get_rank(PSI_PSYCHOKINESIS))
		to_chat(user, span_warning("Your telekinetic power won't reach that far."))
		return FALSE

	if(target == focus)
		attack_self(user)
	else
		user.visible_message(span_danger("[user] gestures sharply!"))
		sparkle()
		if(!isturf(target) && istype(focus,/obj/item) && target.Adjacent(focus))
			var/obj/item/I = focus
			var/resolved = target.attackby(I, user, user.zone_selected)
			if(!resolved && target && I)
				I.afterattack(target,user,1) // for splashing with beakers
		else
			if(!focus.anchored)
				var/user_rank = owner.psi.get_rank(PSI_PSYCHOKINESIS)
				focus.throw_at(target, user_rank*2, user_rank*10, owner)
			sleep(1)
			sparkle()
		owner.dropItemToGround(src)

/obj/item/psychic_power/telekinesis/proc/sparkle()
	set waitfor = 0
	if(focus)
		var/obj/effect/overlay/O = new /obj/effect/overlay(get_turf(focus))
		O.name = "sparkles"
		O.anchored = 1
		O.density = 0
		O.layer = FLY_LAYER
		//O.set_dir(pick(cardinal))
		O.icon = 'icons/effects/effects.dmi'
		O.icon_state = "nothing"
		flick("empdisable",O)
		sleep(5)
		qdel(O)
