/obj/item/zombie_hand
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles."
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	var/icon_left = "bloodhand_left"
	var/icon_right = "bloodhand_right"
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21 // Just enough to break airlocks with melee attacks
	sharpness = SHARP_EDGED
	wound_bonus = -30
	bare_wound_bonus = 15
	damtype = "brute"
	var/inserted_organ = /obj/item/organ/zombie_infection
	var/infect_chance = 100 //Before armor calculations
	var/scaled_infect_chance = FALSE //Do we use steeper armor infection block chance or linear?

/obj/item/zombie_hand/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/zombie_hand/equipped(mob/user, slot)
	. = ..()
	//these are intentionally inverted
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = icon_left
	else
		icon_state = icon_right

/obj/item/zombie_hand/attack(mob/living/M, mob/living/user)//overrides attack command to allow blocking of zombie claw to prevent infection
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, user)
	if(item_flags & NOBLUDGEON)
		return

	//"uh yes, i only eat vegan brain alternatives" Get out of here with that pacifism bullshit!

	//only the finest brain surgery tool, doesn't even need to check for surgical

	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)

	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey

	if(force)
		M.last_damage = name

	user.do_attack_animation(M)
	var/notBlocked = M.attacked_by(src, user)

	log_combat(user, M, "attacked", src.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)

	take_damage(rand(weapon_stats[DAMAGE_LOW], weapon_stats[DAMAGE_HIGH]), sound_effect = FALSE)

	if(!notBlocked)
		return
	else if(isliving(M))
		if(ishuman(M))				
			var/mob/living/carbon/human/H = M
			var/obj/item/bodypart/L = H.get_bodypart(check_zone(user.zone_selected))
			if(H.health <= HEALTH_THRESHOLD_FULLCRIT || (L && L.status != BODYPART_ROBOTIC))//no more infecting via metal limbs unless they're in hard crit and probably going to die
				var/flesh_wound = ran_zone(user.zone_selected)
				if(scaled_infect_chance)
					var/scaled_infection = ((100 - H.getarmor(flesh_wound, MELEE))/100) ^ 1.5	//20 armor -> 71.5% chance of infection
					if(prob(infect_chance * scaled_infection))									//40 armor -> 46.5% chance
						try_to_zombie_infect(M, inserted_organ)									//60 armor -> 25.3% chance
				else																			//80 armor -> 8.9% chance
					if(prob(infect_chance - H.getarmor(flesh_wound, MELEE)))
						try_to_zombie_infect(M, inserted_organ)
			else
				check_feast(M, user)

/proc/try_to_zombie_infect(mob/living/carbon/human/target, organ)
	CHECK_DNA_AND_SPECIES(target)

	if(NOZOMBIE in target.dna.species.species_traits)
		// cannot infect any NOZOMBIE subspecies (such as high functioning
		// zombies)
		return

	var/obj/item/organ/zombie_infection/infection
	infection = target.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new organ()
		infection.Insert(target)



/obj/item/zombie_hand/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(isliving(user))
		var/mob/living/L = user
		var/obj/item/bodypart/O = L.get_bodypart(BODY_ZONE_HEAD)
		if(O)
			O.dismember()
	return (BRUTELOSS)

/obj/item/zombie_hand/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		var/hp_gained = target.maxHealth
		target.gib()
		// zero as argument for no instant health update
		user.adjustBruteLoss(-hp_gained, 0)
		user.adjustToxLoss(-hp_gained, 0)
		user.adjustFireLoss(-hp_gained, 0)
		user.adjustCloneLoss(-hp_gained, 0)
		user.updatehealth()
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"
		user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))

/obj/item/zombie_hand/gamemode
	inserted_organ = /obj/item/organ/zombie_infection/gamemode
	infect_chance = 70
	scaled_infect_chance = TRUE
	force = 15
	var/door_open_modifier = 1

/obj/item/zombie_hand/gamemode/runner
	force = 10
	infect_chance = 35
	door_open_modifier = 1.1

/obj/item/zombie_hand/gamemode/tank
	door_open_modifier = 0.8

/obj/item/zombie_hand/gamemode/necro
	force = 7
	infect_chance = 30
