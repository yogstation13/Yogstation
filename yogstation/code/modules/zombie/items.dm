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

/obj/item/zombie_hand/attack(mob/living/M, mob/living/user)

	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, user)

	if(item_flags & NOBLUDGEON)
		return

	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)

	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey

	if(force)
		M.last_damage = name

	user.do_attack_animation(M)
	var/successful_attack = M.attacked_by(src, user)

	log_combat(user, M, "attacked", src, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)

	take_damage(
		rand(weapon_stats[DAMAGE_LOW],
		weapon_stats[DAMAGE_HIGH]),
		sound_effect = FALSE
	)

	if(!successful_attack)
		return

	if(M.density && (M.stat != DEAD) && !M.grabbedby(user, 1)) //Can only infect those who are horizontal (no density) or dead (this is a fallback in case you try to cheese) or grabbed by you.
		return

	if(iszombie(M)) //Don't try to eat other zombies or infect them because that would be dumb.
		return

	if(!try_to_zombie_infect(M, user, inserted_organ))
		src.feast(M, user) //Feast on them if we can't infect them.

/proc/try_to_zombie_infect(mob/living/carbon/human/target, mob/living/user, organ) //Global proc because a simplemob uses this.

	if(target.hellbound || target.suiciding || (!target.key && !target.get_ghost())) //Can't infect people who aren't valid.
		return FALSE

	CHECK_DNA_AND_SPECIES(target)

	if(NOZOMBIE in target.dna.species.species_traits)
		return FALSE

	var/obj/item/organ/zombie_infection/infection = target.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(infection) //An inferction already exists.
		return FALSE

	infection = new organ()
	infection.Insert(target)
	log_combat(user, target, "infected", src)
	user.visible_message(span_danger("[user] bites [target]!"))

	return TRUE

/obj/item/zombie_hand/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(isliving(user))
		var/mob/living/L = user
		var/obj/item/organ/brain/B = L.getorganslot(ORGAN_SLOT_BRAIN)
		B.Remove(L)
		QDEL_NULL(B) //Bye bye brain.
	return (BRUTELOSS)

/obj/item/zombie_hand/proc/feast(mob/living/target, mob/living/user) //Eat their brains.
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	B.Remove(target)
	QDEL_NULL(B) //Bye bye brain.
	var/hp_gained = target.maxHealth
	user.adjustBruteLoss(-hp_gained, 0)
	user.adjustToxLoss(-hp_gained, 0)
	user.adjustFireLoss(-hp_gained, 0)
	user.adjustCloneLoss(-hp_gained, 0)
	user.updatehealth()
	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"
	user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))
	log_combat(user, target, "feasted on the brains of", src)
	user.visible_message(span_danger("[user] ripped and ate the brains out of [target]!"))

/obj/item/zombie_hand/gamemode
	inserted_organ = /obj/item/organ/zombie_infection/gamemode
	force = 15
	var/door_open_modifier = 1

/obj/item/zombie_hand/gamemode/runner
	force = 10
	door_open_modifier = 1.1

/obj/item/zombie_hand/gamemode/tank
	door_open_modifier = 0.8

/obj/item/zombie_hand/gamemode/necro
	force = 7
