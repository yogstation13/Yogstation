/obj/item/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/ratchet.ogg'
	materials = list(/datum/material/iron=150)
	drop_sound = 'sound/items/handling/wrench_drop.ogg'
	pickup_sound =  'sound/items/handling/wrench_pickup.ogg'

	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	tool_behaviour = TOOL_WRENCH
	toolspeed = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)

/obj/item/wrench/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM || !attempt_initiate_surgery(src, M, user))
		..()

/obj/item/wrench/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/wrench/cyborg
	name = "automatic wrench"
	desc = "An advanced robotic wrench. Can be found in construction cyborgs."
	toolspeed = 0.5

/obj/item/wrench/brass
	name = "brass wrench"
	desc = "A brass wrench. It's faintly warm to the touch."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "wrench_brass"
	toolspeed = 0.5

/obj/item/wrench/abductor
	name = "alien wrench"
	desc = "A polarized wrench. It causes anything placed between the jaws to turn."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wrench_alien"
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.1

/obj/item/wrench/medical
	name = "medical wrench"
	desc = "A medical wrench with common(medical?) uses. Can be found in your hand."
	icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4

	attack_verb = list("wrenched", "medicaled", "tapped", "jabbed", "whacked")

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is praying to the medical wrench to take [user.p_their()] soul. It looks like [user.p_theyre()] trying to commit suicide!"))
	// TODO Make them glow with the power of the M E D I C A L W R E N C H
	// during their ascension

	// Stun stops them from wandering off
	user.Stun(10 SECONDS, ignore_canstun = TRUE)
	playsound(loc, 'sound/effects/pray.ogg', 50, 1, -1)

	// Let the sound effect finish playing
	sleep(2 SECONDS)

	if(!user)
		return

	for(var/obj/item/W in user)
		user.dropItemToGround(W)

	var/obj/item/wrench/medical/W = new /obj/item/wrench/medical(loc)
	W.add_fingerprint(user)
	W.desc += " For some reason, it reminds you of [user.name]."

	if(!user)
		return

	user.dust()

/obj/item/wrench/makeshift
	name = "makeshift wrench"
	desc = "A crude, self-wrought wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "wrench_makeshift"
	toolspeed = 0.5

/obj/item/wrench/makeshift/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(prob(5))
		to_chat(user, span_danger("[src] crumbles apart in your hands!"))
		qdel(src)
		return

	return OXYLOSS
