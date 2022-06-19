/obj/item/hog_item/book
	name = "Cult Book"
	desc = "A strange tome, filled with dark magic."
	icon_state = "book"
	original_icon = "book"
	force = 13
	damtype = BURN
	var/charges = 0
	var/casting = FALSE
	var/stam_damage = 49
	var/can_rcd = TRUE ///Can it convert objects?

/obj/item/hog_item/book/attack_self(mob/user)
	return ///Here will be code for making spells

/obj/item/hog_item/book/attack(mob/M, mob/living/carbon/human/user)
	if(!iscarbon(M))
		return ..()

	var/mob/living/carbon/C = M
	if(user == C)
		return ..()
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(!cultie)
		return ..()
	if(cultie.cult == src.cult)
		var/datum/antagonist/hog/cultie2 = IS_HOG_CULTIST(C)
		if(cultie.cult == cultie2.cult && user.a_intent != INTENT_HELP)
			to_chat(user, span_cult("Attacking your brothers is very rude!"))
			return
	else
		return ..()

	if(user.a_intent == INTENT_DISARM)
		if(iscultist(C) || C.anti_magic_check() || HAS_TRAIT(C, TRAIT_MINDSHIELD) || is_servant_of_ratvar(C) || IS_HOG_CULTIST(C))  ///Mindshielded nerds just get attacked, antimagic dudes and enemy cult members also
			return ..()
		if(!charges)
			return ..()
		var/stamina_damage = C.getStaminaLoss()
		if(stamina_damage >= 85)
			var/stunforce = 4 SECONDS //A bit less if alredy stunned
			if(!C.IsParalyzed())
				to_chat(C, span_cult("You feel pure horror inflitrating your mind!"))
				stunforce = 11 SECONDS
			C.Paralyze(stunforce)
		else
			C.apply_damage(stam_damage, STAMINA, BODY_ZONE_CHEST, 0)
			addtimer(CALLBACK(src, C,  .proc/calm_down), 2 SECONDS)	
		charges--
		return

	if(user.a_intent == INTENT_GRAB)
		if(!C.handcuffed)
			playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
			C.visible_message(span_danger("[user] begins restraining [C] with divine magic!"), \
									span_userdanger("[user] begins shaping a magical field around your wrists!"))
			if(do_mob(user, C, 30))
				if(!C.handcuffed)
					C.handcuffed = new /obj/item/restraints/handcuffs/energy/hogcult/used(C)
					C.update_handcuffed()
					C.silent += 5
					to_chat(user, span_notice("You restrain [C]."))
					log_combat(user, C, "restrained")
				else
					to_chat(user, span_warning("[C] is already restrained."))
			else
				to_chat(user, span_warning("You fail to restrain [C]."))
		else
			to_chat(user, span_warning("[C] is already restrained."))
		return

	if(user.a_intent == INTENT_HELP)
		to_chat(user, span_notice("You try to transfer your energy to [C]..."))
		give_energy(C, user)
		return 
	. = ..()

/obj/item/hog_item/book/proc/calm_down(var/mob/living/carbon/target)
	if(!target)
		return
	target.apply_damage(stam_damage, STAMINA, BODY_ZONE_CHEST, 0)

/obj/item/hog_item/book/proc/give_energy(var/mob/living/carbon/C, var/mob/living/carbon/human/user)
	var/datum/antagonist/hog/user_datum = IS_HOG_CULTIST(user)
	var/datum/antagonist/hog/c_datum = IS_HOG_CULTIST(C)
	if(!user_datum)
		return
	if(!c_datum || user_datum.cult != c_datum.cult)
		to_chat(user, span_warning("[C] is not serving your cult, you can't give energy to him."))
		return
	if(c_datum.energy >= c_datum.max_energy)
		to_chat(user, span_notice("[C] alredy has enough energy."))
		return	
	if(!do_mob(user, C, 1.5 SECONDS))
		to_chat(user, span_warning("You stop transfering energy to [C]."))
		return
	var/energy_to_give = min(HOG_ENERGY_TRANSFER_AMOUNT, user_datum.energy)
	if(energy_to_give <= 0)
		to_chat(user, span_warning("You don't have any energy to give!"))
		return	
	user_datum.get_energy(-energy_to_give)	
	c_datum.get_energy(energy_to_give)	
	to_chat(user, span_warning("You sucessfully transfer [energy_to_give] energy to [C]. You now have [user_datum.energy] energy left."))
	to_chat(C, span_notice("[user] transfers [energy_to_give] energy to you. You now have [c_datum.energy] energy."))
	give_energy(C, user)

/obj/item/restraints/handcuffs/energy/hogcult
	name = "celestial bound"
	desc = "Divine energy field that binds the wrists with celestial magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/hogcult/used/dropped(mob/user)
	user.visible_message(span_danger("[user]'s shackles shatter in a discharge of magic!"), \
							span_userdanger("Your [src] shatters in a discharge of magic!"))
	. = ..()

/*
	Rcd-ing shit with ur book
*/

/obj/item/hog_item/book/afterattack(atom/O, mob/user, proximity)
	. = ..()
	if(!proximity)
		return 
	if(!istype(O, /obj))
		return
	var/obj/target = O
	if(!target.hog_can_rcd())
		return
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(!cultie || cultie.cult != src.cult)
		return
	var/cost = target.hog_rcding_cost()
	if(cultie.energy < cost)
		to_chat(user, span_notice("You don't have enough energy to interact with the [target], you need atleast [cost]"))
		return
	to_chat(user, span_notice("You start unleashing trails of your magic into [target]..."))
	if(!do_after(user, target.hog_rcding_time(), target))
		to_chat(user, span_warning("You fail to influence the [target]."))
		return
	if(cultie.energy < cost)
		to_chat(user, span_notice("You fail to influence the [target]."))  ///We check again, because energy amount of the dude can change before the process is complete.
		return
	if(!target.hog_act(cultie.cult))
		to_chat(user, span_warning("You fail to influence the [target]."))
	else
		to_chat(user, span_notice("You succesfully influence the [target]!"))
		cultie.get_energy(-cost)

/atom/proc/hog_rcding_time()
	return 2 SECONDS

/atom/proc/hog_can_rcd()
	return FALSE

/atom/proc/hog_rcding_cost()
	return 15

/atom/proc/hog_act(var/datum/team/hog_cult/act_cult)
	return FALSE

