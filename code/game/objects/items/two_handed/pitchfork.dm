/obj/item/pitchfork
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "pitchfork0"
	base_icon_state = "pitchfork"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("attacked", "impaled", "pierced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_POINTY
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

	///How much extra damage the pitchfork will do while wielded.
	var/force_wielded = 8

/obj/item/pitchfork/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
	)

/obj/item/pitchfork/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/pitchfork/trident
	icon_state = "trident"
	name = "trident"
	desc = "A trident recovered from the ruins of atlantis"
	slot_flags = ITEM_SLOT_BELT
	force = 14
	throwforce = 23

	force_wielded = 6

/obj/item/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "A red pitchfork, it looks like the work of the devil."
	force = 19
	throwforce = 24
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 6
	light_color = LIGHT_COLOR_RED

	force_wielded = 6

/obj/item/pitchfork/demonic/greater
	force = 24
	throwforce = 50

	force_wielded = 10

/obj/item/pitchfork/demonic/ascended
	force = 100
	throwforce = 100

	force_wielded = 500000 // Kills you DEAD.

/obj/item/pitchfork/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] impales [user.p_them()]self in [user.p_their()] abdomen with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/obj/item/pitchfork/demonic/pickup(mob/living/user)
	. = ..()
	if(isliving(user) && user.mind && user.owns_soul() && !is_devil(user))
		var/mob/living/U = user
		U.visible_message(span_warning("As [U] picks [src] up, [U]'s arms briefly catch fire."), \
			span_warning("\"As you pick up [src] your arms ignite, reminding you of all your past sins.\""))
		if(ishuman(U))
			var/mob/living/carbon/human/H = U
			H.apply_damage(rand(force/2, force), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		else
			U.adjustFireLoss(rand(force/2,force))

/obj/item/pitchfork/demonic/attack(mob/target, mob/living/carbon/human/user)
	if(user.mind && user.owns_soul() && !is_devil(user))
		to_chat(user, "<span class ='warning'>[src] burns in your hands.</span>")
		user.apply_damage(rand(force/2, force), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
	return ..()

/obj/item/pitchfork/demonic/ascended/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !HAS_TRAIT(src, TRAIT_WIELDED))
		return
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		user.visible_message(span_danger("[user] blasts \the [target] with \the [src]!"))
		playsound(target, 'sound/magic/disintegrate.ogg', 100, 1)
		W.break_wall()
		W.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
