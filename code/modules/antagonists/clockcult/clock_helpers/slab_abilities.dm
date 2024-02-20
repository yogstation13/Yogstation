//The base for slab-bound/based ranged abilities //',:)
/datum/action/innate/slab
	click_action = TRUE
	var/obj/item/clockwork/slab/slab
	var/successful = FALSE
	var/in_progress = FALSE
	var/finished = FALSE

/datum/action/innate/slab/Destroy()
	slab = null
	return ..()

/datum/action/innate/slab/IsAvailable(feedback = FALSE)
	return TRUE

/datum/action/innate/slab/InterceptClickOn(mob/living/caller, params, atom/clicked_on)
	if(in_progress)
		return FALSE
	if(caller.incapacitated() || !slab || !(slab in caller.held_items) || clicked_on == slab)
		unset_ranged_ability(caller)
		return FALSE

	. = ..()
	if(!.)
		return FALSE
	var/mob/living/i_hate_this = caller || owner || usr
	i_hate_this?.client?.mouse_override_icon = initial(caller?.client?.mouse_override_icon)
	i_hate_this?.update_mouse_pointer()
	i_hate_this?.click_intercept = null
	finished = TRUE
	QDEL_IN(src, 0.1 SECONDS)
	return TRUE

//For the Hateful Manacles scripture; applies replicant handcuffs to the clicked_on.
/datum/action/innate/slab/hateful_manacles

/datum/action/innate/slab/hateful_manacles/do_ability(mob/living/caller, params, atom/clicked_on)
	var/turf/T = caller.loc
	if(!isturf(T))
		return FALSE

	if(iscarbon(clicked_on) && clicked_on.Adjacent(caller))
		var/mob/living/carbon/L = clicked_on
		if(is_servant_of_ratvar(L))
			to_chat(caller, span_neovgre("\"[L.p_theyre(TRUE)] a servant.\""))
			return FALSE
		else if(L.stat)
			to_chat(caller, span_neovgre("\"There is use in shackling the dead, but for examples.\""))
			return FALSE
		else if (istype(L.handcuffed, /obj/item/restraints/handcuffs/clockwork))
			to_chat(caller, span_neovgre("\"[L.p_theyre(TRUE)] already helpless, no?\""))
			return FALSE
		//yogs start -- shackling people with just one arm is right-out
		else if(L.get_num_arms(FALSE) < 2 && !L.get_arm_ignore())
			to_chat(caller, span_neovgre("\"[L.p_theyre(TRUE)] lacking in arms necessary for shackling.\""))
			return TRUE
		//yogs end
		
		playsound(caller.loc, 'sound/weapons/handcuffs.ogg', 30, TRUE)
		caller.visible_message(span_danger("[caller] begins forming manacles around [L]'s wrists!"), \
		"[span_neovgre_small("You begin shaping replicant alloy into manacles around [L]'s wrists...")]")
		to_chat(L, span_userdanger("[caller] begins forming manacles around your wrists!"))
		if(do_after(caller, 3 SECONDS, L))
			if(!(istype(L.handcuffed,/obj/item/restraints/handcuffs/clockwork)))
				L.set_handcuffed(new /obj/item/restraints/handcuffs/clockwork(L))
				L.update_handcuffed()
				to_chat(caller, "[span_neovgre_small("You shackle [L].")]")
				log_combat(caller, L, "handcuffed")
		else
			to_chat(caller, span_warning("You fail to shackle [L]."))

		successful = TRUE

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

//For the Sentinel's Compromise scripture; heals a clicked_on servant.
/datum/action/innate/slab/compromise
	ranged_mousepointer = 'icons/effects/mouse_pointers/compromise_target.dmi'

/datum/action/innate/slab/compromise/do_ability(mob/living/caller, params, atom/clicked_on)
	var/turf/T = caller.loc
	if(!isturf(T))
		return FALSE

	if(isliving(clicked_on) && (clicked_on in view(7, get_turf(caller))))
		var/mob/living/L = clicked_on
		if(!is_servant_of_ratvar(L))
			to_chat(caller, span_inathneq("\"[L] does not yet serve Ratvar.\""))
			return TRUE
		if(L.stat == DEAD)
			to_chat(caller, span_inathneq("\"[L.p_theyre(TRUE)] dead. [text2ratvar("Oh, child. To have your life cut short...")]\""))
			return TRUE

		var/brutedamage = L.getBruteLoss()
		var/burndamage = L.getFireLoss()
		var/oxydamage = L.getOxyLoss()
		var/totaldamage = brutedamage + burndamage + oxydamage
		if(!totaldamage && (!L.reagents || !L.reagents.has_reagent(/datum/reagent/water/holywater)))
			to_chat(caller, span_inathneq("\"[L] is unhurt and untainted.\""))
			return TRUE

		successful = TRUE

		to_chat(caller, span_brass("You bathe [L == caller ? "yourself":"[L]"] in Inath-neq's power!"))
		var/clicked_onturf = get_turf(L)
		var/has_holy_water = (L.reagents && L.reagents.has_reagent(/datum/reagent/water/holywater))
		var/healseverity = max(round(totaldamage*0.05, 1), 1) //shows the general severity of the damage you just healed, 1 glow per 20
		for(var/i in 1 to healseverity)
			new /obj/effect/temp_visual/heal(clicked_onturf, "#1E8CE1")
		if(totaldamage)
			L.adjustBruteLoss(-brutedamage, TRUE, FALSE, BODYPART_ANY)
			L.adjustFireLoss(-burndamage, TRUE, FALSE, BODYPART_ANY)
			L.adjustOxyLoss(-oxydamage)
			L.adjustToxLoss(totaldamage * 0.5, TRUE, TRUE)
			clockwork_say(caller, text2ratvar("[has_holy_water ? "Heal tainted" : "Mend wounded"] flesh!"))
			log_combat(caller, L, "healed with Sentinel's Compromise")
			L.visible_message(span_warning("A blue light washes over [L], [has_holy_water ? "causing [L.p_them()] to briefly glow as it mends" : " mending"] [L.p_their()] bruises and burns!"), \
			"[span_heavy_brass("You feel Inath-neq's power healing your wounds[has_holy_water ? " and purging the darkness within you" : ""], but a deep nausea overcomes you!")]")
		else
			clockwork_say(caller, text2ratvar("Purge foul darkness!"))
			log_combat(caller, L, "purged of holy water with Sentinel's Compromise")
			L.visible_message(span_warning("A blue light washes over [L], causing [L.p_them()] to briefly glow!"), \
			"[span_heavy_brass("You feel Inath-neq's power purging the darkness within you!")]")
		playsound(clicked_onturf, 'sound/magic/staff_healing.ogg', 50, 1)

		if(has_holy_water)
			L.reagents.remove_reagent(/datum/reagent/water/holywater, 1000)

	return TRUE

//For the Kindle scripture; stuns and mutes a clicked_on non-servant.
/datum/action/innate/slab/kindle
	ranged_mousepointer = 'icons/effects/mouse_pointers/volt_target.dmi'

/datum/action/innate/slab/kindle/do_ability(mob/living/caller, params, atom/clicked_on)
	var/turf/T = caller.loc
	if(!isturf(T))
		return FALSE

	if(clicked_on in view(7, get_turf(caller)))

		successful = TRUE

		var/turf/U = get_turf(clicked_on)
		to_chat(caller, span_brass("You release the light of Ratvar!"))
		clockwork_say(caller, text2ratvar("Purge all untruths and honor Engine!"))
		log_combat(caller, U, "fired at with Kindle")
		playsound(caller, 'sound/magic/blink.ogg', 50, TRUE, frequency = 0.5)
		var/obj/projectile/kindle/A = new(T)
		A.preparePixelProjectile(clicked_on, caller, params)
		A.fire()

	return TRUE

/obj/projectile/kindle
	name = "kindled flame"
	icon_state = "pulse0"
	nodamage = TRUE
	damage = 0 //We're just here for the stunning!
	damage_type = BURN
	armor_flag = BOMB
	range = 3
	log_override = TRUE

/obj/projectile/kindle/Destroy()
	visible_message(span_warning("[src] flickers out!"))
	. = ..()

/obj/projectile/kindle/on_hit(atom/clicked_on, blocked = FALSE)
	if(isliving(clicked_on))
		var/mob/living/L = clicked_on
		if(is_servant_of_ratvar(L) || L.stat || L.has_status_effect(STATUS_EFFECT_KINDLE))
			return BULLET_ACT_HIT
		var/atom/O = L.can_block_magic()
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
			L.Paralyze(1.5 SECONDS)
			L.apply_status_effect(STATUS_EFFECT_KINDLE)
			L.flash_act(1, 1)
			if(iscultist(L))
				L.adjustFireLoss(15)

	return ..()


//For the cyborg Linked Vanguard scripture, grants you and a nearby ally Vanguard
/datum/action/innate/slab/vanguard
	ranged_mousepointer = 'icons/effects/mouse_pointers/vanguard_target.dmi'

/datum/action/innate/slab/vanguard/do_ability(mob/living/caller, params, atom/clicked_on)
	var/turf/T = caller.loc
	if(!isturf(T))
		return FALSE

	if(isliving(clicked_on) && (clicked_on in view(7, get_turf(caller))))
		var/mob/living/L = clicked_on
		if(!is_servant_of_ratvar(L))
			to_chat(caller, span_inathneq("\"[L] does not yet serve Ratvar.\""))
			return FALSE
		if(L.stat == DEAD)
			to_chat(caller, span_inathneq("\"[L.p_theyre(TRUE)] dead. [text2ratvar("Oh, child. To have your life cut short...")]\""))
			return FALSE
		if(islist(L.stun_absorption) && L.stun_absorption["vanguard"] && L.stun_absorption["vanguard"]["end_time"] > world.time)
			to_chat(caller, span_inathneq("\"[L.p_theyre(TRUE)] already shielded by a Vanguard.\""))
			return FALSE

		successful = TRUE

		if(L == caller)
			for(var/mob/living/LT in spiral_range(7, T))
				if(LT.stat == DEAD || !is_servant_of_ratvar(LT) || LT == caller || !(LT in view(7, get_turf(caller))) || \
				(islist(LT.stun_absorption) && LT.stun_absorption["vanguard"] && LT.stun_absorption["vanguard"]["end_time"] > world.time))
					continue
				L = LT
				break

		L.apply_status_effect(STATUS_EFFECT_VANGUARD)
		caller.apply_status_effect(STATUS_EFFECT_VANGUARD)

		clockwork_say(caller, text2ratvar("Shield us from darkness!"))

	return TRUE

//For the cyborg Judicial Marker scripture, places a judicial marker
/datum/action/innate/slab/judicial
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'

/datum/action/innate/slab/judicial/do_ability(mob/living/caller, params, atom/clicked_on)
	var/turf/T = caller.loc
	if(!isturf(T))
		return FALSE

	if(clicked_on in view(7, get_turf(caller)))
		successful = TRUE

		clockwork_say(caller, text2ratvar("Kneel, heathens!"))
		caller.visible_message(span_warning("[caller]'s eyes fire a stream of energy at [clicked_on], creating a strange mark!"), \
		"[span_heavy_brass("You direct the judicial force to [clicked_on].")]")
		var/turf/clicked_onturf = get_turf(clicked_on)
		new/obj/effect/clockwork/judicial_marker(clicked_onturf, caller)
		log_combat(caller, clicked_onturf, "created a judicial marker")

	return TRUE
