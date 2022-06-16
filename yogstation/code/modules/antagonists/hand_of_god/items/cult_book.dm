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
	
/obj/item/hog_item/book/attack_self(mob/user)
	return ///Here will be code for making spells

/obj/item/hog_item/book/attack(mob/M, mob/living/carbon/human/user)
	if(!iscarbon(M))
		return ..()
	var/mob/living/carbon/C = M
	if(user == C)
		return
	if(user.a_intent == INTENT_DISARM)
		if(iscultist(C) || C.anti_magic_check() || HAS_TRAIT(C, TRAIT_MINDSHIELD) || is_servant_of_ratvar(C))  ///Mindshielded nerds just get attacked, antimagic dudes and enemy cult members also
			return ..()
		var/stamina_damage = C.getStaminaLoss()
		if(stamina_damage >= 85)
			var/stunforce = 7 SECONDS //A bit less if alredy stunned
			if(!C.IsParalyzed())
				to_chat(C, span_cult("You feel pure horror inflitrating your mind!"))
				stunforce = 11 SECONDS
			C.Paralyze(stunforce)
		else
			C.apply_damage(stam_damage, STAMINA, BODY_ZONE_CHEST, 0)
			addtimer(CALLBACK(src, C,  .proc/calm_down), 2 SECONDS)	
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
					to_chat(user, span_notice("You shackle [C]."))
					log_combat(user, C, "restrained")
				else
					to_chat(user, span_warning("[C] is already restrained."))
			else
				to_chat(user, span_warning("You fail to restrain [C]."))
		else
			to_chat(user, span_warning("[C] is already restrained."))
		return

	if(user.a_intent == INTENT_HELP)
		return  ///Here will be giving power to allies and allied structures.
	. = ..()

/obj/item/hog_item/book/proc/calm_down(mob/living/carbon/target)
	if(!target)
		return
	target.apply_damage(stam_damage, STAMINA, BODY_ZONE_CHEST, 0)

			





/obj/item/restraints/handcuffs/energy/hogcult
	name = "celestial bound"
	desc = "Divine energy field that binds the wrists with celestial magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/hogcult/used/dropped(mob/user)
	user.visible_message(span_danger("[user]'s shackles shatter in a discharge of dark magic!"), \
							span_userdanger("Your [src] shatters in a discharge of dark magic!"))
	. = ..()