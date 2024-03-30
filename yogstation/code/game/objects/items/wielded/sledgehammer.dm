#define SLEDGEHAMMER_THROWN_STAGGER "sledgehammer_throw"
#define SLEDGEHAMMER_HIT_STAGGER "sledgehammer_hit"

/obj/item/melee/sledgehammer
	name = "sledgehammer"
	desc = "An archaic tool used to drive nails and break down hollow walls."
	icon = 'icons/obj/weapons/misc.dmi'
	mob_overlay_icon = 'yogstation/icons/mob/clothing/back.dmi'
	icon_state = "sledgehammer"
	item_state = "sledgehammer"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	force = 3 /// The weapon requires two hands
	throwforce = 18
	throw_range = 3 /// Doesn't throw very far
	sharpness = SHARP_NONE
	demolition_mod = 3 // BREAK THINGS
	armour_penetration = -20
	hitsound = 'sound/weapons/smash.ogg' /// Hitsound when thrown at someone
	attack_verb = list("attacked", "hit", "struck", "bludgeoned", "bashed", "smashed")
	materials = list(/datum/material/iron=6000)
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	wound_bonus = -15
	bare_wound_bonus = 15

/obj/item/melee/sledgehammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = 15, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
		require_twohands = TRUE, \
		wielded_stats = list(SWING_SPEED = 1.5, ENCUMBRANCE = 0.5, ENCUMBRANCE_TIME = 1 SECONDS, REACH = 1, DAMAGE_LOW = 0, DAMAGE_HIGH = 0), \
	)
	AddComponent(/datum/component/cleave_attack, \
		arc_size=180, \
		requires_wielded=TRUE, \
		no_multi_hit=TRUE, \
	) // big and heavy hammer makes wide arc

/obj/item/melee/sledgehammer/proc/on_wield(atom/source, mob/living/user)
	hitsound = "swing_hit"

/obj/item/melee/sledgehammer/proc/on_unwield(atom/source, mob/living/user)
	hitsound = initial(hitsound)

/obj/item/melee/sledgehammer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && user)
		/// This will already do low damage, so it doesn't need to be intercepted earlier
		to_chat(user, span_danger("\The [src] is too heavy to attack effectively without being wielded!"))
		return

	if(!proximity_flag)
		return

	if(target.uses_integrity)
		if(!QDELETED(target))
			if(istype(target, /obj/structure/window)) // Sledgehammer really good at smashing windows. 2-7 hits to kill a window
				target.take_damage(target.max_integrity/2, BRUTE, MELEE, FALSE, null, armour_penetration)
			if(iswallturf(target))
				target.take_damage(force * demolition_mod, BRUTE, MELEE, FALSE, null, armour_penetration) // Sledgehammers are quite good at smashing walls
		playsound(src, 'sound/effects/bang.ogg', 50, 1)

/obj/item/melee/sledgehammer/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, quickstart)
	. = ..()
	if(iscarbon(thrower))
		var/mob/living/carbon/C = thrower
		C.add_movespeed_modifier(SLEDGEHAMMER_THROWN_STAGGER, update=TRUE, priority=101, multiplicative_slowdown=1)
		addtimer(CALLBACK(C, TYPE_PROC_REF(/mob, remove_movespeed_modifier), SLEDGEHAMMER_THROWN_STAGGER), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		to_chat(target, span_danger("You are staggered from throwing such a heavy object!"))
