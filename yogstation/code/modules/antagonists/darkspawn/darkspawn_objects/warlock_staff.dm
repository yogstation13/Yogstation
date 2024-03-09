#define STAFF_UPGRADE_CONFUSION 	(1<<0)
#define STAFF_UPGRADE_HEAL 			(1<<1)
#define STAFF_UPGRADE_LIGHTEATER 	(1<<2)
#define STAFF_UPGRADE_EXTINGUISH	(1<<3)

//////////////////////////////////////////////////////////////////////////
//---------------------Upgradeable warlock staff------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/item/gun/magic/darkspawn
	name = "staff of shadows"
	desc = "This staff is boring to watch because even though it came first you've seen everything it can do in other staves for years."
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "spearglass0"
	item_state = "spearglass0"
	base_icon_state = "spearglass"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'

	fire_sound = 'sound/weapons/emitter2.ogg'
	fire_delay = 2 SECONDS

	antimagic_flags = MAGIC_RESISTANCE_MIND
	ammo_type = /obj/item/ammo_casing/magic/darkspawn
	var/obj/item/darkspawn_extinguish/bopper
	/// Flags used for different effects that apply when a projectile hits something
	var/effect_flags

/obj/item/gun/magic/darkspawn/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)
	RegisterSignal(src, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
	AddComponent(/datum/component/two_handed, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)
	bopper = new(src)

/obj/item/gun/magic/darkspawn/Destroy()
	qdel(bopper)
	. = ..()

///////////////////FANCY PROJECTILE EFFECTS//////////////////////////
/obj/item/gun/magic/darkspawn/proc/on_projectile_hit(datum/source, atom/movable/firer, atom/target, angle)
	if(isliving(target))
		var/mob/living/M = target
		if(is_darkspawn_or_veil(M))
			if(effect_flags & STAFF_UPGRADE_HEAL)
				M.heal_ordered_damage(30, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
			if(effect_flags & STAFF_UPGRADE_EXTINGUISH)
				M.extinguish_mob()
		else
			M.apply_damage(40, STAMINA)
			if(effect_flags & STAFF_UPGRADE_CONFUSION)
				M.adjust_confusion(6 SECONDS)
			if(effect_flags & STAFF_UPGRADE_LIGHTEATER)
				SEND_SIGNAL(bopper, COMSIG_ITEM_AFTERATTACK, M, firer, TRUE) //just use a light eater attack on the target

////////////////////////TWO-HANDED BLOCKING//////////////////////////
/obj/item/gun/magic/darkspawn/update_icon_state()
	. = ..()
	item_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]"
	icon_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/gun/magic/darkspawn/proc/on_wield()
	block_chance = 50

/obj/item/gun/magic/darkspawn/proc/on_unwield()
	block_chance = 0

/obj/item/gun/magic/darkspawn/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type != PROJECTILE_ATTACK)
		final_block_chance = 0 //don't bring a staff to a knife fight
	return ..()

////////////////////////INFINITE AMMO//////////////////////////
/obj/item/gun/magic/darkspawn/process_chamber()
	. = ..()
	charges = max_charges //infinite charges
	
////////////////////////OTHER STUFF//////////////////////////
/obj/item/ammo_casing/magic/darkspawn
	projectile_type = /obj/projectile/magic/darkspawn	
	firing_effect_type = null

/obj/projectile/magic/darkspawn
	name = "bolt of nothingness"
	icon_state = "kinetic_blast"
	damage = 0
	damage_type = STAMINA
	nodamage = FALSE
	antimagic_flags = MAGIC_RESISTANCE_MIND
	speed = 1.4 //watch out, it fucks you up

/obj/projectile/magic/darkspawn/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)
