//The base for slab-bound/based ranged abilities //',:)
/datum/action/cooldown/slab
	var/obj/item/clockwork/slab/slab
	var/successful = FALSE
	var/finished = FALSE
	var/in_progress = FALSE

/datum/action/cooldown/slab/Destroy()
	slab = null
	return ..()

/datum/action/cooldown/slab/unset_click_ability(atom/caster)
	. = ..()
	finished = TRUE
	QDEL_IN(src, 0.6 SECONDS)

/datum/action/cooldown/slab/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!..() || in_progress)
		return FALSE
	if(owner.incapacitated() || !slab || !(slab in owner.held_items) || target == slab)
		unset_click_ability(owner)
		return FALSE

	return TRUE

//For the Hateful Manacles scripture; applies replicant handcuffs to the target.
/datum/action/cooldown/slab/hateful_manacles

/datum/action/cooldown/slab/hateful_manacles/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!..())
		return FALSE

	var/turf/T = owner.loc
	if(!isturf(T))
		return FALSE

	if(iscarbon(target) && target.Adjacent(owner))
		var/mob/living/carbon/L = target
		if(is_servant_of_ratvar(L))
			to_chat(owner, span_neovgre("\"[L.p_theyre(TRUE)] a servant.\""))
			return FALSE
		else if(L.stat)
			to_chat(owner, span_neovgre("\"There is use in shackling the dead, but for examples.\""))
			return FALSE
		else if (istype(L.handcuffed, /obj/item/restraints/handcuffs/clockwork))
			to_chat(owner, span_neovgre("\"[L.p_theyre(TRUE)] already helpless, no?\""))
			return FALSE
		//yogs start -- shackling people with just one arm is right-out
		else if(L.get_num_arms(FALSE) < 2 && !L.get_arm_ignore())
			to_chat(owner, span_neovgre("\"[L.p_theyre(TRUE)] lacking in arms necessary for shackling.\""))
			return TRUE
		//yogs end
		
		playsound(owner.loc, 'sound/weapons/handcuffs.ogg', 30, TRUE)
		owner.visible_message(span_danger("[owner] begins forming manacles around [L]'s wrists!"), \
		"[span_neovgre_small("You begin shaping replicant alloy into manacles around [L]'s wrists...")]")
		to_chat(L, span_userdanger("[owner] begins forming manacles around your wrists!"))
		if(do_mob(owner, L, 30))
			if(!(istype(L.handcuffed,/obj/item/restraints/handcuffs/clockwork)))
				L.handcuffed = new/obj/item/restraints/handcuffs/clockwork(L)
				L.update_handcuffed()
				to_chat(owner, "[span_neovgre_small("You shackle [L].")]")
				log_combat(owner, L, "handcuffed")
		else
			to_chat(owner, span_warning("You fail to shackle [L]."))

		successful = TRUE

		unset_click_ability(owner)

	return TRUE

/obj/item/restraints/handcuffs/clockwork
	name = "replicant manacles"
	desc = "Heavy manacles made out of freezing-cold metal. It looks like brass, but feels much more solid."
	icon_state = "brass_manacles"
	item_state = "brass_manacles"
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/clockwork/dropped(mob/user)
	user.visible_message(span_danger("[user]'s [name] come apart at the seams!"), \
	span_userdanger("Your [name] break apart as they're removed!"))
	. = ..()

//For the Sentinel's Compromise scripture; heals a target servant.
/datum/action/cooldown/slab/compromise
	ranged_mousepointer = 'icons/effects/compromise_target.dmi'

/datum/action/cooldown/slab/compromise/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!..())
		return FALSE

	var/turf/T = owner.loc
	if(!isturf(T))
		return FALSE

	if(isliving(target) && (target in view(7, get_turf(owner))))
		var/mob/living/L = target
		if(!is_servant_of_ratvar(L))
			to_chat(owner, span_inathneq("\"[L] does not yet serve Ratvar.\""))
			return TRUE
		if(L.stat == DEAD)
			to_chat(owner, span_inathneq("\"[L.p_theyre(TRUE)] dead. [text2ratvar("Oh, child. To have your life cut short...")]\""))
			return TRUE

		var/brutedamage = L.getBruteLoss()
		var/burndamage = L.getFireLoss()
		var/oxydamage = L.getOxyLoss()
		var/totaldamage = brutedamage + burndamage + oxydamage
		if(!totaldamage && (!L.reagents || !L.reagents.has_reagent(/datum/reagent/water/holywater)))
			to_chat(owner, span_inathneq("\"[L] is unhurt and untainted.\""))
			return TRUE

		successful = TRUE

		to_chat(owner, span_brass("You bathe [L == owner ? "yourself":"[L]"] in Inath-neq's power!"))
		var/targetturf = get_turf(L)
		var/has_holy_water = (L.reagents && L.reagents.has_reagent(/datum/reagent/water/holywater))
		var/healseverity = max(round(totaldamage*0.05, 1), 1) //shows the general severity of the damage you just healed, 1 glow per 20
		for(var/i in 1 to healseverity)
			new /obj/effect/temp_visual/heal(targetturf, "#1E8CE1")
		if(totaldamage)
			L.adjustBruteLoss(-brutedamage, TRUE, FALSE, BODYPART_ANY)
			L.adjustFireLoss(-burndamage, TRUE, FALSE, BODYPART_ANY)
			L.adjustOxyLoss(-oxydamage)
			L.adjustToxLoss(totaldamage * 0.5, TRUE, TRUE)
			clockwork_say(owner, text2ratvar("[has_holy_water ? "Heal tainted" : "Mend wounded"] flesh!"))
			log_combat(owner, L, "healed with Sentinel's Compromise")
			L.visible_message(span_warning("A blue light washes over [L], [has_holy_water ? "causing [L.p_them()] to briefly glow as it mends" : " mending"] [L.p_their()] bruises and burns!"), \
			"[span_heavy_brass("You feel Inath-neq's power healing your wounds[has_holy_water ? " and purging the darkness within you" : ""], but a deep nausea overcomes you!")]")
		else
			clockwork_say(owner, text2ratvar("Purge foul darkness!"))
			log_combat(owner, L, "purged of holy water with Sentinel's Compromise")
			L.visible_message(span_warning("A blue light washes over [L], causing [L.p_them()] to briefly glow!"), \
			"[span_heavy_brass("You feel Inath-neq's power purging the darkness within you!")]")
		playsound(targetturf, 'sound/magic/staff_healing.ogg', 50, 1)

		if(has_holy_water)
			L.reagents.remove_reagent(/datum/reagent/water/holywater, 1000)

		unset_click_ability(owner)

	return TRUE

//For the Kindle scripture; stuns and mutes a target non-servant.
/datum/action/cooldown/slab/kindle
	ranged_mousepointer = 'icons/effects/volt_target.dmi'

/datum/action/cooldown/slab/kindle/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!..())
		return FALSE

	var/turf/T = owner.loc
	if(!isturf(T))
		return FALSE

	if(target in view(7, get_turf(owner)))

		successful = TRUE

		var/turf/U = get_turf(target)
		to_chat(owner, span_brass("You release the light of Ratvar!"))
		clockwork_say(owner, text2ratvar("Purge all untruths and honor Engine!"))
		log_combat(owner, U, "fired at with Kindle")
		playsound(owner, 'sound/magic/blink.ogg', 50, TRUE, frequency = 0.5)
		var/obj/item/projectile/kindle/A = new(T)
		A.preparePixelProjectile(target, caller, params)
		A.fire()

		unset_click_ability(owner)

	return TRUE

/obj/item/projectile/kindle
	name = "kindled flame"
	icon_state = "pulse0"
	nodamage = TRUE
	damage = 0 //We're just here for the stunning!
	damage_type = BURN
	flag = BOMB
	range = 3
	log_override = TRUE

/obj/item/projectile/kindle/Destroy()
	visible_message(span_warning("[src] flickers out!"))
	. = ..()

/obj/item/projectile/kindle/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/L = target
		if(is_servant_of_ratvar(L) || L.stat || L.has_status_effect(STATUS_EFFECT_KINDLE))
			return BULLET_ACT_HIT
		var/atom/O = L.anti_magic_check()
		playsound(L, 'sound/magic/fireball.ogg', 50, TRUE, frequency = 1.25)
		if(O)
			if(isitem(O))
				L.visible_message(span_warning("[L]'s eyes flare with dim light!"), \
				span_userdanger("Your [O] glows white-hot against you as it absorbs [src]'s power!"))
			else if(ismob(O))
				L.visible_message(span_warning("[L]'s eyes flare with dim light!"))
			playsound(L, 'sound/weapons/sear.ogg', 50, TRUE)
		else
			L.visible_message(span_warning("[L]'s eyes blaze with brilliant light!"), \
			span_userdanger("Your vision suddenly screams with white-hot light!"))
			L.Paralyze(15)
			L.apply_status_effect(STATUS_EFFECT_KINDLE)
			L.flash_act(1, 1)
			if(iscultist(L))
				L.adjustFireLoss(15)
	return ..()


//For the cyborg Linked Vanguard scripture, grants you and a nearby ally Vanguard
/datum/action/cooldown/slab/vanguard
	ranged_mousepointer = 'icons/effects/vanguard_target.dmi'

/datum/action/cooldown/slab/vanguard/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!..())
		return FALSE

	var/turf/T = owner.loc
	if(!isturf(T))
		return FALSE

	if(isliving(target) && (target in view(7, get_turf(owner))))
		var/mob/living/L = target
		if(!is_servant_of_ratvar(L))
			to_chat(owner, span_inathneq("\"[L] does not yet serve Ratvar.\""))
			return FALSE
		if(L.stat == DEAD)
			to_chat(owner, span_inathneq("\"[L.p_theyre(TRUE)] dead. [text2ratvar("Oh, child. To have your life cut short...")]\""))
			return FALSE
		if(islist(L.stun_absorption) && L.stun_absorption["vanguard"] && L.stun_absorption["vanguard"]["end_time"] > world.time)
			to_chat(owner, span_inathneq("\"[L.p_theyre(TRUE)] already shielded by a Vanguard.\""))
			return FALSE

		successful = TRUE

		if(L == owner)
			for(var/mob/living/LT in spiral_range(7, T))
				if(LT.stat == DEAD || !is_servant_of_ratvar(LT) || LT == owner || !(LT in view(7, get_turf(owner))) || \
				(islist(LT.stun_absorption) && LT.stun_absorption["vanguard"] && LT.stun_absorption["vanguard"]["end_time"] > world.time))
					continue
				L = LT
				break

		L.apply_status_effect(STATUS_EFFECT_VANGUARD)
		caller.apply_status_effect(STATUS_EFFECT_VANGUARD)

		clockwork_say(owner, text2ratvar("Shield us from darkness!"))

		unset_click_ability(owner)

	return TRUE

//For the cyborg Judicial Marker scripture, places a judicial marker
/datum/action/cooldown/slab/judicial
	ranged_mousepointer = 'icons/effects/visor_reticule.dmi'

/datum/action/cooldown/slab/judicial/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!..())
		return FALSE

	var/turf/T = owner.loc
	if(!isturf(T))
		return FALSE

	if(target in view(7, get_turf(owner)))
		successful = TRUE

		clockwork_say(owner, text2ratvar("Kneel, heathens!"))
		owner.visible_message(span_warning("[owner]'s eyes fire a stream of energy at [target], creating a strange mark!"), \
		"[span_heavy_brass("You direct the judicial force to [target].")]")
		var/turf/targetturf = get_turf(target)
		new/obj/effect/clockwork/judicial_marker(targetturf, owner)
		log_combat(owner, targetturf, "created a judicial marker")
		unset_click_ability(owner)

	return TRUE
