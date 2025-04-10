/mob/living/carbon/human/getarmor(def_zone, type)
	if(def_zone)
		if(isnum(def_zone)) // allows using bodypart bitflags instead of zones
			return checkarmor(def_zone, type)
		var/obj/item/bodypart/affecting = isbodypart(def_zone) ? def_zone : get_bodypart(check_zone(def_zone))
		return checkarmor(affecting.body_part, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	var/armorval = 0
	var/organnum = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		armorval += min(checkarmor(limb.body_part, type), 100) // hey no you can't do that
		organnum++
	return (armorval/max(organnum, 1))


/mob/living/carbon/human/proc/checkarmor(bodypart_flag, armor_flag)
	if(!armor_flag)
		return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/obj/item/clothing/cover in body_parts)
		if(bodypart_flag & cover.body_parts_covered)
			protection += cover.armor.getRating(armor_flag)
		else if(bodypart_flag & cover.body_parts_partial_covered)
			protection += cover.armor.getRating(armor_flag) * 0.5
	protection += physiology.armor.getRating(armor_flag)
	if(armor_flag == MELEE)
		protection = 100 - ((100 - protection) * (50 - get_skill(SKILL_FITNESS)) / 50) // 8% multiplicative armor at EXP_MASTER
	return protection

///Get all the clothing on a specific body part
/mob/living/carbon/human/proc/clothingonpart(bodypart_flag)
	var/list/covering_part = list()
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/obj/item/clothing/cover in body_parts)
		if(bodypart_flag & cover.body_parts_covered)
			covering_part += cover
	return covering_part

/mob/living/carbon/human/on_hit(obj/projectile/P)
	if(dna && dna.species)
		dna.species.on_hit(P, src)


/mob/living/carbon/human/bullet_act(obj/projectile/P, def_zone)
	if(dna && dna.species)
		var/spec_return = dna.species.bullet_act(P, src)
		if(spec_return)
			return spec_return

	if(!(P.original == src && P.firer == src)) //can't block or reflect when shooting yourself
		var/shield_check = check_shields(P, P.damage, "the [P.name]", PROJECTILE_ATTACK, P.armour_penetration, P.damage_type)
		if(shield_check & SHIELD_DODGE) // skill issue, just dodge
			playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
			return BULLET_ACT_FORCE_PIERCE

		if(shield_check & SHIELD_REFLECT)
			if(P.hitscan) // hitscan check
				P.store_hitscan_collision(P.trajectory.copy_to())

			// Find a turf near or on the original location to bounce to
			if(!isturf(loc)) //Open canopy mech (ripley) check. if we're inside something and still got hit
				P.force_hit = TRUE //The thing we're in passed the bullet to us. Pass it back, and tell it to take the damage.
				loc.bullet_act(P)
				return BULLET_ACT_HIT

			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/turf/curloc = get_turf(src)

				// redirect the projectile
				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x

			P.firer = src
			var/new_angle_s = P.Angle + rand(120,240)
			while(new_angle_s > 180)	// Translate to regular projectile degrees
				new_angle_s -= 360
			P.setAngle(new_angle_s)
			playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
			return BULLET_ACT_FORCE_PIERCE
		
		if(shield_check & SHIELD_BLOCK)
			P.on_hit(src, 100, def_zone)
			return BULLET_ACT_HIT
		
		if(iscarbon(P.firer) && stat == CONSCIOUS) // gain experience from shooting people, more if they were far away and less if it wasn't a real gun
			var/mob/shooter = P.firer
			shooter.add_exp(SKILL_FITNESS, max(initial(P.range) - P.range, 1) * ((P.nodamage || !P.damage) ? 2 : 5))

	return ..(P, def_zone)

/mob/living/carbon/human/check_shields(atom/AM, damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0, damage_type = BRUTE)
	var/block_result = SEND_SIGNAL(src, COMSIG_HUMAN_CHECK_SHIELDS, AM, damage, attack_text, attack_type, armour_penetration, damage_type)
	SEND_SIGNAL(src, COMSIG_HUMAN_AFTER_BLOCK, block_result)
	return block_result

/mob/living/carbon/human/proc/check_block()
	if(mind)
		if(mind.martial_art && prob(mind.martial_art.block_chance) && mind.martial_art.can_use(src) && in_throw_mode && !incapacitated(FALSE, TRUE))
			return mind.martial_art //need to use this where blocks are handled to handle counters since check_block doesn't reference the attacker
	return FALSE

/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(dna && dna.species)
		var/spec_return = dna.species.spec_hitby(AM, src)
		if(spec_return)
			return spec_return
	var/obj/item/I
	var/throwpower = 30
	if(istype(AM, /obj/item))
		I = AM
		throwpower = I.throwforce
		if(I.thrownby == src) //No throwing stuff at yourself to trigger hit reactions
			return ..()
	if(check_shields(AM, throwpower, "\the [AM.name]", THROWN_PROJECTILE_ATTACK))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE
	return ..()

/mob/living/carbon/human/grippedby(mob/living/user, instant = FALSE)
	if(w_uniform)
		w_uniform.add_fingerprint(user)
	. = ..()


/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user)
	if(!I || !user)
		return 0
	
	var/obj/item/bodypart/affecting
	if(user == src)
		affecting = get_bodypart(check_zone(user.zone_selected)) //stabbing yourself always hits the right target
	else
		var/zone_hit_chance = 80
		if(!(mobility_flags & MOBILITY_STAND)) // half as likely to hit a different zone if they're on the ground
			zone_hit_chance += 10
		affecting = get_bodypart(ran_zone(user.zone_selected, zone_hit_chance))
	var/target_area = parse_zone(check_zone(user.zone_selected)) //our intended target

	SSblackbox.record_feedback("nested tally", "item_used_for_combat", 1, list("[I.force]", "[I.type]"))
	SSblackbox.record_feedback("tally", "zone_targeted", 1, target_area)

	// the attacked_by code varies among species
	. = dna.species.spec_attacked_by(I, user, affecting, src)

	if(!.) // failed
		return
	
	if(affecting)
		if(I.force && I.damtype != STAMINA && affecting.status == BODYPART_ROBOTIC) // Bodpart_robotic sparks when hit, but only when it does real damage
			if(I.force >= 5 && !isinsurgent(src)) //small change, insurgent ipcs don't give off sparks if hit
				do_sparks(1, FALSE, loc)

	SEND_SIGNAL(I, COMSIG_ITEM_ATTACK_ZONE, src, user, affecting)

/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.combat_mode)
		var/hulk_verb = pick("smash","pummel")
		if(check_shields(user, 15, "the [hulk_verb]ing"))
			return
		..(user, 1)
		playsound(loc, user.dna.species.attack_sound, 25, 1, -1)
		var/message = "[user] has [hulk_verb]ed [src]!"
		visible_message(span_danger("[message]"), \
								span_userdanger("[message]"))
		apply_damage(15, BRUTE, wound_bonus=10)
		return 1

/mob/living/carbon/human/attack_hand(mob/living/user, modifiers)
	if(..())	//to allow surgery to return properly.
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.combat_mode && handle_vamp_biting(H)) // yogs start -- vampire biting
			return // yogs end
		if(H.combat_mode)
			last_damage = "fist"
		dna.species.spec_attack_hand(H, src, user.mind?.martial_art, modifiers)

/mob/living/carbon/human/attack_paw(mob/living/carbon/monkey/M, modifiers)
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)

	if(modifiers && modifiers[RIGHT_CLICK]) //Always drop item in hand, if no item, get stunned instead.
		var/obj/item/I = get_active_held_item()
		if(I && dropItemToGround(I))
			playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			visible_message(span_danger("[M] disarmed [src]!"), \
					span_userdanger("[M] disarmed [src]!"))
		else if(!M.client || prob(5)) // only natural monkeys get to stun reliably, (they only do it occasionaly)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			if (src.IsKnockdown() && !src.IsParalyzed())
				Paralyze(40)
				log_combat(M, src, "pinned")
				visible_message(span_danger("[M] has pinned down [src]!"), \
					span_userdanger("[M] has pinned down [src]!"))
			else
				Knockdown(30)
				log_combat(M, src, "tackled")
				visible_message(span_danger("[M] has tackled down [src]!"), \
					span_userdanger("[M] has tackled down [src]!"))
		return
	
	if(!M.combat_mode)
		..() //shaking
		return 0

	if(M.limb_destroyer)
		dismembering_strike(M, affecting.body_zone)

	if(can_inject(M, 1, affecting))//Thick suits can stop monkey bites.
		if(..()) //successful monkey bite, this handles disease contraction.
			var/damage = rand(1, 3)
			if(check_shields(M, damage, "the [M.name]", UNARMED_ATTACK))
				return 0
			if(stat != DEAD)
				apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, MELEE))
		return 1

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M, modifiers)
	if(check_shields(M, 0, "the [M.name]", UNARMED_ATTACK))
		visible_message(span_danger("[M] attempted to touch [src]!"))
		return 0

	if(..())
		if(modifiers && modifiers[RIGHT_CLICK]) //Always drop item in hand, if no item, get stun instead.
			var/obj/item/I = get_active_held_item()
			if(I && dropItemToGround(I))
				playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
				visible_message(span_danger("[M] disarmed [src]!"), \
						span_userdanger("[M] disarmed [src]!"))
			else
				//yogs start
				var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
				if(!affecting)
					affecting = get_bodypart(BODY_ZONE_CHEST)
				var/armour = run_armor_check(affecting, MELEE)
				if(prob(armour))
					to_chat(M, span_notice("[src]'s armour shields the blow!"))
					return
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				if(armour > 0)
					Paralyze(50 + armour)
				else
					Paralyze(50)
				//yogs end
				log_combat(M, src, "tackled")
				visible_message(span_danger("[M] has tackled down [src]!"), \
					span_userdanger("[M] has tackled down [src]!"))
		else if(M.combat_mode)
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = prob(90) ? 20 : 0
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message(span_danger("[M] has lunged at [src]!"), \
					span_userdanger("[M] has lunged at [src]!"))
				return 0
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			var/armor_block = run_armor_check(affecting, MELEE,"","",10)

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message(span_danger("[M] has slashed at [src]!"), \
				span_userdanger("[M] has slashed at [src]!"))
			log_combat(M, src, "attacked")
			if(!dismembering_strike(M, M.zone_selected)) //Dismemberment successful
				return 1
			apply_damage(damage, BRUTE, affecting, armor_block)		


/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L, modifiers)

	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(check_shields(L, damage, "the [L.name]", UNARMED_ATTACK))
			return 0
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(L.zone_selected))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			var/armor_block = run_armor_check(affecting, MELEE)
			apply_damage(damage, BRUTE, affecting, armor_block)


/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(check_shields(M, damage, "the [M.name]", MELEE_ATTACK, M.armour_penetration))
			return FALSE
		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return TRUE
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor = run_armor_check(affecting, MELEE, armour_penetration = M.armour_penetration)
		var/attack_direction = get_dir(M, src)
		apply_damage(damage, M.melee_damage_type, affecting, armor, wound_bonus = M.wound_bonus, bare_wound_bonus = M.bare_wound_bonus, sharpness = M.sharpness, attack_direction = attack_direction)


/mob/living/carbon/human/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 25)
		var/wound_mod = -45 // 25^1.4=90, 90-45=45
		if(M.is_adult)
			damage = rand(10, 35)
			wound_mod = -90 // 35^1.4=145, 145-90=55

		if(check_shields(M, damage, "the [M.name]", UNARMED_ATTACK))
			return 0

		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return 1

		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, MELEE)
		apply_damage(damage, BRUTE, affecting, armor_block, wound_bonus=wound_mod)

/mob/living/carbon/human/mech_melee_attack(obj/mecha/M, punch_force, equip_allowed = TRUE)
	if(M.selected?.melee_override && equip_allowed)
		M.selected.action(src)
	else if(M.occupant.combat_mode)
		M.do_attack_animation(src)
		if(check_shields(M, punch_force, "[M]", MELEE_ATTACK, damage_type = M.damtype)) // you sure can try
			return
		if(M.damtype == BRUTE)
			step_away(src,M,15)
		var/obj/item/bodypart/temp = get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_HEAD))
		if(temp)
			var/update = 0
			var/dmg = rand(M.force/2, M.force)
			switch(M.damtype)
				if(BRUTE)
					if(M.force >= 20)
						Knockdown(1.5 SECONDS)//the victim could get up before getting hit again
						var/throwtarget = get_edge_target_turf(M, get_dir(M, get_step_away(src, M)))
						src.throw_at(throwtarget, 5, 2, src)//one tile further than mushroom punch/psycho brawling
					update |= temp.receive_damage(dmg, 0)
					if(M.meleesound)
						playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
				if(BURN)
					update |= temp.receive_damage(0, dmg)
					if(M.meleesound)
						playsound(src, 'sound/items/welder.ogg', 50, 1)
				if(TOX)
					M.mech_toxin_damage(src)
				else
					return
			if(update)
				update_damage_overlays()
			updatehealth()

		visible_message(span_danger("[M.name] has hit [src]!"), \
								span_userdanger("[M.name] has hit [src]!"), null, COMBAT_MESSAGE_RANGE)
		log_combat(M.occupant, src, "attacked", M, "(COMBAT MODE: [M.occupant.combat_mode]) (DAMTYPE: [uppertext(M.damtype)])")

	else
		..()


/mob/living/carbon/human/ex_act(severity, target, origin)
	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_BOMBIMMUNE))
		return
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if (!severity || QDELETED(src))
		return
	var/brute_loss = 0
	var/burn_loss = 0
	var/bomb_armor = getarmor(null, BOMB)

	switch (severity)
		if (EXPLODE_DEVASTATE)
			if(bomb_armor < EXPLODE_GIB_THRESHOLD)	//gibs the mob if their bomb armor is lower than EXPLODE_GIB_THRESHOLD
				for(var/thing in contents)
					switch(severity)
						if(EXPLODE_DEVASTATE)
							SSexplosions.high_mov_atom += thing
						if(EXPLODE_HEAVY)
							SSexplosions.med_mov_atom += thing
						if(EXPLODE_LIGHT)
							SSexplosions.low_mov_atom += thing
				gib()
				return
			else
				brute_loss = 200*(2 - round(bomb_armor/100, 0.05))	//0-50% damage reduction because this should still kill you
				burn_loss = brute_loss/2 //don't wanna husk people	
				var/atom/throw_target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(throw_target, 200, 4)
				damage_clothes(400 - bomb_armor, BRUTE, BOMB)

		if (EXPLODE_HEAVY)
			brute_loss = 60
			burn_loss = 60
			if(bomb_armor)
				brute_loss = 30*(2 - round(bomb_armor/60, 0.05))	//0-83% damage reduction
				burn_loss = brute_loss					//40-120 total combined brute + burn
			damage_clothes(200 - bomb_armor, BRUTE, BOMB)
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(30, 120)
			if(bomb_armor < 60)
				Unconscious(20)						//Sufficient protection will stop you from being knocked out
			Knockdown(200 - (bomb_armor * 1.6)) 	//between ~4 and ~20 seconds of knockdown depending on bomb armor

		if (EXPLODE_LIGHT)
			brute_loss = 24
			if(bomb_armor)
				brute_loss = 12*(2 - round(bomb_armor/60, 0.05))	//4-24 damage total depending on bomb armor
			damage_clothes(max(40 - bomb_armor, 0), BRUTE, BOMB)
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(15,60)
			Knockdown(max(120 - (bomb_armor * 2),0))	//60 bomb armor prevents knockdown entirely

	take_overall_damage(brute_loss,burn_loss)

	//attempt to dismember bodyparts
	if(severity <= 2 || HAS_TRAIT(src, TRAIT_EASYDISMEMBER)) //light explosions only can dismember those with easy dismember
		var/max_limb_loss = round(4/severity) //so you don't lose more than 2 limbs on severity 2
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(50/severity) && !prob(getarmor(BP, BOMB)) && BP.body_zone != BODY_ZONE_HEAD && BP.body_zone != BODY_ZONE_CHEST)
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break


/mob/living/carbon/human/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	show_message(span_userdanger("The blob attacks you!"))
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, MELEE))


//Added a safety check in case you want to shock a human mob directly through electrocute_act.
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, zone = HANDS, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE)
	if(!override)
		siemens_coeff *= physiology.siemens_coeff
	. = ..()
	if(.)
		electrocution_animation(40)

/mob/living/carbon/human/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(dna)
		return dna.species.spec_emag_act(src, user, emag_card)

/mob/living/carbon/human/emp_act(severity)
	severity *= physiology.emp_mod
	return ..(severity)

/mob/living/carbon/human/rad_act(amount, collectable_radiation)
	. = ..()
	dna?.species.spec_rad_act(src, amount, collectable_radiation)

/mob/living/carbon/human/acid_act(acidpwr, acid_volume, bodyzone_hit) //todo: update this to utilize check_obscured_slots() //and make sure it's check_obscured_slots(TRUE) to stop aciding through visors etc
	var/list/damaged = list()
	var/list/inventory_items_to_kill = list()
	var/acidity = acidpwr * min(acid_volume*0.005, 0.1)
	//HEAD//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD) //only if we didn't specify a zone or if that zone is the head.
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			if(!(head_clothes.resistance_flags & UNACIDABLE))
				head_clothes.acid_act(acidpwr, acid_volume)
				update_inv_glasses()
				update_inv_wear_mask()
				update_inv_neck()
				update_inv_head()
			else
				to_chat(src, span_notice("Your [head_clothes.name] protects your head and face from the acid!"))
		else
			. = get_bodypart(BODY_ZONE_HEAD)
			if(.)
				damaged += .
			if(ears)
				inventory_items_to_kill += ears

	//CHEST//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			if(!(chest_clothes.resistance_flags & UNACIDABLE))
				chest_clothes.acid_act(acidpwr, acid_volume)
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, span_notice("Your [chest_clothes.name] protects your body from the acid!"))
		else
			. = get_bodypart(BODY_ZONE_CHEST)
			if(.)
				damaged += .
			if(wear_id)
				inventory_items_to_kill += wear_id
			if(r_store)
				inventory_items_to_kill += r_store
			if(l_store)
				inventory_items_to_kill += l_store
			if(s_store)
				inventory_items_to_kill += s_store


	//ARMS & HANDS//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_ARM || bodyzone_hit == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit

		if(arm_clothes)
			if(!(arm_clothes.resistance_flags & UNACIDABLE))
				arm_clothes.acid_act(acidpwr, acid_volume)
				update_inv_gloves()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, span_notice("Your [arm_clothes.name] protects your arms and hands from the acid!"))
		else
			. = get_bodypart(BODY_ZONE_R_ARM)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_ARM)
			if(.)
				damaged += .


	//LEGS & FEET//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_LEG || bodyzone_hit == BODY_ZONE_R_LEG || bodyzone_hit == "feet")
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (w_uniform.body_parts_covered & LEGS))))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (wear_suit.body_parts_covered & LEGS))))
			leg_clothes = wear_suit
		if(leg_clothes)
			if(!(leg_clothes.resistance_flags & UNACIDABLE))
				leg_clothes.acid_act(acidpwr, acid_volume)
				update_inv_shoes()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, span_notice("Your [leg_clothes.name] protects your legs and feet from the acid!"))
		else
			. = get_bodypart(BODY_ZONE_R_LEG)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_LEG)
			if(.)
				damaged += .


	//DAMAGE//
	var/damagemod = (dna && dna.species) ? dna.species.acidmod : 1 // yogs - Old Plant People
	for(var/obj/item/bodypart/affecting in damaged)
		affecting.receive_damage(acidity*damagemod, 2*acidity*damagemod)

		if(affecting.name == BODY_ZONE_HEAD)
			if(prob(min(acidpwr*acid_volume*damagemod/10, 90))) //Applies disfigurement
				affecting.receive_damage(acidity*damagemod, 2*acidity*damagemod) // yogs - Old Plant People
				emote("scream")
				facial_hair_style = "Shaved"
				hair_style = "Bald"
				update_hair()
				ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)

		update_damage_overlays()

	//MELTING INVENTORY ITEMS//
	//these items are all outside of armour visually, so melt regardless.
	if(!bodyzone_hit)
		if(back)
			inventory_items_to_kill += back
		if(belt)
			inventory_items_to_kill += belt

		inventory_items_to_kill += held_items

	for(var/obj/item/I in inventory_items_to_kill)
		I.acid_act(acidpwr, acid_volume)
	return 1

/mob/living/carbon/human/singularity_act()
	var/gain = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer") )
			gain = 100
		if(mind.assigned_role == "Clown")
			gain = rand(-1000, 1000)
	investigate_log("([key_name(src)]) has been consumed by the singularity.", INVESTIGATE_SINGULO) //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(!istype(M))
		return

	if(try_extinguish(M)) //mostly redundant since it's called in species.dm also, but this allows alternative forms of help act calling to extinguish
		return

	if(src == M)
		if(has_status_effect(STATUS_EFFECT_CHOKINGSTRAND))
			to_chat(src, span_notice("You attempt to remove the durathread strand from around your neck."))
			if(do_after(src, 3.5 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
				to_chat(src, span_notice("You succesfuly remove the durathread strand."))
				remove_status_effect(STATUS_EFFECT_CHOKINGSTRAND)
			return
		else if(creamed)
			if(istype(getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/lizard))
				visible_message(span_notice("[src] eats the pie off [p_their()] face with [p_their()] forked tongue."), 
								span_notice("You eat the pie off your face with your forked tongue."))
				reagents.add_reagent(/datum/reagent/consumable/banana, 1)

			else if(M.get_num_arms()) //make sure you have arms with which to wipe
				visible_message(span_notice("[src] wipes the pie off [p_their()] face with [p_their()] hand."), 
								span_notice("You wipe the pie off your face with your hand."))
			wash_cream()
			return
		check_self_for_injuries()


	else
		if(wear_suit)
			wear_suit.add_fingerprint(M)
		else if(w_uniform)
			w_uniform.add_fingerprint(M)

		..()

/mob/living/carbon/human/proc/check_self_for_injuries()
	if(stat >= UNCONSCIOUS)
		return
	var/list/combined_msg = list()

	visible_message(span_notice("[src] examines [p_them()]self."))

	combined_msg += span_notice("<b>You check yourself for injuries.</b>")

	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	for(var/X in bodyparts)
		var/obj/item/bodypart/LB = X
		missing -= LB.body_zone
		if(LB.is_pseudopart) //don't show injury text for fake bodyparts; ie chainsaw arms or synthetic armblades
			continue
		var/self_aware = FALSE
		if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
			self_aware = TRUE
		var/limb_max_damage = LB.max_damage
		var/status = ""
		var/brutedamage = LB.brute_dam
		var/burndamage = LB.burn_dam
		if(has_status_effect(/datum/status_effect/hallucination))
			if(prob(30))
				brutedamage += rand(30,40)
			if(prob(30))
				burndamage += rand(30,40)

		if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
			status = "[brutedamage] brute damage and [burndamage] burn damage"
			if(!brutedamage && !burndamage)
				status = "no damage"

		else
			if(brutedamage > 0)
				status = LB.light_brute_msg
			if(brutedamage > (limb_max_damage*0.4))
				status = LB.medium_brute_msg
			if(brutedamage > (limb_max_damage*0.8))
				status = LB.heavy_brute_msg
			if(brutedamage > 0 && burndamage > 0)
				status += " and "

			if(burndamage > (limb_max_damage*0.8))
				status += LB.heavy_burn_msg
			else if(burndamage > (limb_max_damage*0.2))
				status += LB.medium_burn_msg
			else if(burndamage > 0)
				status += LB.light_burn_msg

			if(status == "")
				status = "OK"
		var/no_damage
		if(status == "OK" || status == "no damage")
			no_damage = TRUE
		var/isdisabled = ""
		if(LB.bodypart_disabled)
			isdisabled = " is disabled"
			if(no_damage)
				isdisabled += " but otherwise"
			else
				isdisabled += " and"
		combined_msg += "\t <span class='[no_damage ? "notice" : "warning"]'>Your [LB.name][isdisabled][self_aware ? " has " : " is "][status].</span>"

		for(var/thing in LB.wounds)
			var/datum/wound/W = thing
			var/msg
			switch(W.severity)
				if(WOUND_SEVERITY_TRIVIAL)
					msg = "\t <span class='danger'>Your [LB.name] is suffering [W.a_or_from] [lowertext(W.name)].</span>"
				if(WOUND_SEVERITY_MODERATE)
					msg = "\t <span class='warning'>Your [LB.name] is suffering [W.a_or_from] [lowertext(W.name)]!</span>"
				if(WOUND_SEVERITY_SEVERE)
					msg = "\t <span class='warning'><b>Your [LB.name] is suffering [W.a_or_from] [lowertext(W.name)]!</b></span>"
				if(WOUND_SEVERITY_CRITICAL)
					msg = "\t <span class='warning'><b>Your [LB.name] is suffering [W.a_or_from] [lowertext(W.name)]!!</b></span>"
			to_chat(src, msg)

		for(var/obj/item/I in LB.embedded_objects)
			combined_msg += "\t <a href='byond://?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(LB)]' class='warning'>There is \a [I] embedded in your [LB.name]!</a>"

	for(var/t in missing)
		combined_msg += span_boldannounce("Your [parse_zone(t)] is missing!")

	if(is_bleeding())
		var/list/obj/item/bodypart/bleeding_limbs = list()
		for(var/i in bodyparts)
			var/obj/item/bodypart/BP = i
			if(BP.get_bleed_rate())
				bleeding_limbs += BP

		var/num_bleeds = LAZYLEN(bleeding_limbs)
		var/bleed_text = "<span class='danger'>You are bleeding from your"
		switch(num_bleeds)
			if(1 to 2)
				bleed_text += " [bleeding_limbs[1].name][num_bleeds == 2 ? " and [bleeding_limbs[2].name]" : ""]"
			if(3 to INFINITY)
				for(var/i in 1 to (num_bleeds - 1))
					var/obj/item/bodypart/BP = bleeding_limbs[i]
					bleed_text += " [BP.name],"
				bleed_text += " and [bleeding_limbs[num_bleeds].name]"
		bleed_text += "!</span>"
		to_chat(src, bleed_text)

	if(getStaminaLoss())
		if(getStaminaLoss() > 30)
			combined_msg += span_info("You're completely exhausted.")
		else
			combined_msg += span_info("You feel fatigued.")
	if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
		if(toxloss)
			if(toxloss > 10)
				combined_msg += span_danger("You feel sick.")
			else if(toxloss > 20)
				combined_msg += span_danger("You feel nauseated.")
			else if(toxloss > 40)
				combined_msg += span_danger("You feel very unwell!")
		if(oxyloss)
			if(oxyloss > 10)
				combined_msg += span_danger("You feel lightheaded.")
			else if(oxyloss > 20)
				combined_msg += span_danger("Your thinking is clouded and distant.")
			else if(oxyloss > 30)
				combined_msg += span_danger("You're choking!")

	if(!HAS_TRAIT(src, TRAIT_NOHUNGER))
		if(HAS_TRAIT(src, TRAIT_POWERHUNGRY))
			switch(nutrition)
				if(NUTRITION_LEVEL_WELL_FED to INFINITY)
					combined_msg += span_info("You're fully charged!")
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					combined_msg += span_info("You're not low on charge.")
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					combined_msg += span_info("You could use a bit more charge.")
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					combined_msg += span_info("You feel low on charge.")
				if(0 to NUTRITION_LEVEL_STARVING)
					combined_msg += span_danger("You're almost out of power!")
		else
			switch(nutrition)
				if(NUTRITION_LEVEL_FULL to INFINITY)
					combined_msg += span_info("You're completely stuffed!")
				if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
					combined_msg += span_info("You're well fed!")
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					combined_msg += span_info("You're not hungry.")
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					combined_msg += span_info("You could use a bite to eat.")
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					combined_msg += span_info("You feel quite hungry.")
				if(0 to NUTRITION_LEVEL_STARVING)
					combined_msg += span_danger("You're starving!")

	if(isskeleton(src))
		var/obj/item/clothing/under/under = w_uniform
		if((!under || under.adjusted) && (!wear_suit))
			play_xylophone()


	//Compiles then shows the list of damaged organs and broken organs
	var/list/broken = list()
	var/list/damaged = list()
	var/broken_message
	var/damaged_message
	var/broken_plural
	var/damaged_plural
	//Sets organs into their proper list
	for(var/O in internal_organs)
		var/obj/item/organ/organ = O
		if(organ.organ_flags & ORGAN_FAILING)
			if(broken.len)
				broken += ", "
			broken += organ.name
		else if(organ.damage > organ.low_threshold)
			if(damaged.len)
				damaged += ", "
			damaged += organ.name
	//Checks to enforce proper grammar, inserts words as necessary into the list
	if(broken.len)
		if(broken.len > 1)
			broken.Insert(broken.len, "and ")
			broken_plural = TRUE
		else
			var/holder = broken[1]	//our one and only element
			if(holder[length(holder)] == "s")
				broken_plural = TRUE
		//Put the items in that list into a string of text
		for(var/B in broken)
			broken_message += B
		combined_msg += span_warning(" Your [broken_message] [broken_plural ? "are" : "is"] non-functional!")
	if(damaged.len)
		if(damaged.len > 1)
			damaged.Insert(damaged.len, "and ")
			damaged_plural = TRUE
		else
			var/holder = damaged[1]
			if(holder[length(holder)] == "s")
				damaged_plural = TRUE
		for(var/D in damaged)
			damaged_message += D
		combined_msg += span_info("Your [damaged_message] [damaged_plural ? "are" : "is"] hurt.")

	if(roundstart_quirks.len)
		combined_msg += span_notice("You have these quirks: [get_trait_string()].")

	to_chat(src, examine_block(combined_msg.Join("\n")))

/mob/living/carbon/human/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5 //0.5 multiplier for balance reason, we don't want clothes to be too easily destroyed
	var/list/torn_items = list()

	//HEAD//
	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			torn_items += head_clothes
		else if(ears)
			torn_items += ears

	//CHEST//
	if(!def_zone || def_zone == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			torn_items += chest_clothes

	//ARMS & HANDS//
	if(!def_zone || def_zone == BODY_ZONE_L_ARM || def_zone == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit
		if(arm_clothes)
			torn_items |= arm_clothes

	//LEGS & FEET//
	if(!def_zone || def_zone == BODY_ZONE_L_LEG || def_zone == BODY_ZONE_R_LEG)
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (w_uniform.body_parts_covered & LEGS)))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (wear_suit.body_parts_covered & LEGS)))
			leg_clothes = wear_suit
		if(leg_clothes)
			torn_items |= leg_clothes

	for(var/obj/item/I in torn_items)
		I.take_damage(damage_amount, damage_type, damage_flag, 0)

/**
 * Used by fire code to damage worn items.
 *
 * Arguments:
 * - seconds_per_tick
 * - times_fired
 * - stacks: Current amount of firestacks
 *
 */

/mob/living/carbon/human/proc/burn_clothing(seconds_per_tick, stacks)
	var/list/burning_items = list()
	var/obscured = check_obscured_slots(TRUE)
	//HEAD//

	if(glasses && !(obscured & ITEM_SLOT_EYES))
		burning_items += glasses
	if(wear_mask && !(obscured & ITEM_SLOT_MASK))
		burning_items += wear_mask
	if(wear_neck && !(obscured & ITEM_SLOT_NECK))
		burning_items += wear_neck
	if(ears && !(obscured & ITEM_SLOT_EARS))
		burning_items += ears
	if(head)
		burning_items += head

	//CHEST//
	if(w_uniform && !(obscured & ITEM_SLOT_ICLOTHING))
		burning_items += w_uniform
	if(wear_suit)
		burning_items += wear_suit

	//ARMS & HANDS//
	var/obj/item/clothing/arm_clothes = null
	if(gloves && !(obscured & ITEM_SLOT_GLOVES))
		arm_clothes = gloves
	else if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
		arm_clothes = wear_suit
	else if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
		arm_clothes = w_uniform
	if(arm_clothes)
		burning_items |= arm_clothes

	//LEGS & FEET//
	var/obj/item/clothing/leg_clothes = null
	if(shoes && !(obscured & ITEM_SLOT_FEET))
		leg_clothes = shoes
	else if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (wear_suit.body_parts_covered & LEGS)))
		leg_clothes = wear_suit
	else if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (w_uniform.body_parts_covered & LEGS)))
		leg_clothes = w_uniform
	if(leg_clothes)
		burning_items |= leg_clothes

	for(var/obj/item/burning in burning_items)
		burning.fire_act((stacks * 25 * seconds_per_tick)) //damage taken is reduced to 2% of this value by fire_act()

/mob/living/carbon/human/on_fire_stack(seconds_per_tick, datum/status_effect/fire_handler/fire_stacks/fire_handler)
	SEND_SIGNAL(src, COMSIG_HUMAN_BURNING)
	burn_clothing(seconds_per_tick, fire_handler.stacks)
	var/no_protection = FALSE
	if(dna && dna.species)
		no_protection = dna.species.handle_fire(src, seconds_per_tick, no_protection)
	fire_handler.harm_human(seconds_per_tick, no_protection)
