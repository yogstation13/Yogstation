/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING
	nonlethal = TRUE

/datum/martial_art/boxing/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_warning("Can't disarm while boxing!"))
	return 1

/datum/martial_art/boxing/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_warning("Can't grab while boxing!"))
	return 1

/datum/martial_art/boxing/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(5, 8) + A.dna.species.punchdamagelow
	if(!damage)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message(span_warning("[A] has attempted to [atk_verb] [D]!"), \
			span_userdanger("[A] has attempted to [atk_verb] [D]!"), null, COMBAT_MESSAGE_RANGE)
		log_combat(A, D, "attempted to hit", atk_verb)
		return 0


	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)

	D.visible_message(span_danger("[A] has [atk_verb]ed [D]!"), \
			span_userdanger("[A] has [atk_verb]ed [D]!"), null, COMBAT_MESSAGE_RANGE)

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(A, D, "punched (boxing) ")
	if(D.getStaminaLoss() >= 100)
		if((D.stat != DEAD))
			D.visible_message(span_danger("[A] has knocked [D] out with a haymaker!"), \
								span_userdanger("[A] has knocked [D] out with a haymaker!"))
			D.forcesay(GLOB.hit_appends)
			D.apply_effect(200,EFFECT_KNOCKDOWN,armor_block)
			D.SetSleeping(100)
			log_combat(A, D, "knocked out (boxing) ")
		else if(!(D.mobility_flags & MOBILITY_STAND))
			D.forcesay(GLOB.hit_appends)
	return 1

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_GLOVES) == src)
		style.remove(H)
	return
