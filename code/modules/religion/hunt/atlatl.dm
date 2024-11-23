/obj/item/gun/ballistic/atlatl
	desc = "An ancient type of spear thrower used by the chosen hunters"
	name = "hunter's atlatl"
	icon = 'icons/obj/weapons/guns/atlatl/atlatl.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/atlatl_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/atlatl_righthand.dmi'
	icon_state = "atlatl"
	inhand_icon_state = "atlatl"
	//uncomment when ready to merge fully, sprites for belt and belt_mirror is in atlatl.dmi
//	worn_icon_state = "atlatl"
	load_sound = null
	fire_sound = null
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/atlatl
	force = 25
	attack_verb_continuous = list("strikes", "cracks", "beats")
	attack_verb_simple = list("strike", "crack", "beat")
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY
	internal_magazine = TRUE
	cartridge_wording = "spear"
	bolt_type = BOLT_TYPE_NO_BOLT
	slot_flags = ITEM_SLOT_BELT

/obj/item/gun/ballistic/atlatl/update_icon_state()
	. = ..()
	icon_state = chambered ? "atlatl_notched" : "atlatl"

/obj/item/gun/ballistic/atlatl/proc/drop_spear()
	if(chambered)
		chambered.forceMove(drop_location())
		magazine.get_round(keep = FALSE)
		chambered = null
	update_appearance()


/obj/item/gun/ballistic/atlatl/equipped(mob/user, slot, initial)
	. = ..()
	if((slot == ITEM_SLOT_BELT && chambered) || (slot == ITEM_SLOT_SUITSTORE && chambered))
		balloon_alert(user, "the spear falls off!")
		drop_spear()
		update_appearance()

/obj/item/gun/ballistic/atlatl/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!chambered)
		return
	. = ..() //fires, removing the spear
	update_appearance()

/obj/item/gun/ballistic/atlatl/shoot_with_empty_chamber(mob/living/user)
	return //no clicking sounds please


/obj/item/ammo_box/magazine/internal/atlatl
	name = "notch"
	ammo_type = /obj/item/ammo_casing/caseless/thrownspear
	max_ammo = 1
	start_empty = TRUE
	caliber = CALIBER_SPEAR

/obj/item/ammo_casing/caseless/thrownspear
	name = "throwing spear"
	desc = "A light spear made for throwing from an atlatl"
	icon = 'icons/obj/weapons/guns/atlatl/thrownspear.dmi'
	icon_state = "thrownspear"
	custom_materials = "wood"
	inhand_icon_state = null
	projectile_type = /obj/projectile/bullet/reusable/thrownspear
	flags_1 = NONE
	throwforce = 25
	w_class = WEIGHT_CLASS_BULKY
	firing_effect_type = null
	caliber = CALIBER_SPEAR
	heavy_metal = FALSE

/obj/item/ammo_casing/caseless/thrownspear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/element/envenomable_casing)


/obj/projectile/bullet/reusable/thrownspear
	name = "thrown spear"
	desc = "Beasts be felled!"
	icon = 'icons/obj/weapons/guns/atlatl/thrownspear.dmi'
	icon_state = "spear_projectile"
	ammo_type = /obj/item/ammo_casing/caseless/thrownspear
	damage = 75
	speed = 1.5
	range = 20
	/// How much the damage is multiplied by when we hit a mob with the correct biotype
	var/biotype_damage_multiplier = 5
	/// What biotype we look for
	var/biotype_we_look_for = MOB_BEAST

/obj/projectile/bullet/reusable/thrownspear/on_hit(atom/target, blocked, pierce_hit)
	if(ismineralturf(target))
		var/turf/closed/mineral/mineral_turf = target
		mineral_turf.gets_drilled(firer, FALSE)
		if(range > 0)
			return BULLET_ACT_FORCE_PIERCE
		return ..()
	if(!isliving(target) || (damage > initial(damage)))
		return ..()
	var/mob/living/target_mob = target
	if(target_mob.mob_biotypes & biotype_we_look_for || istype(target_mob, /mob/living/simple_animal/hostile/megafauna))
		damage *= biotype_damage_multiplier
	return ..()


/obj/item/storage/bag/spearquiver
	name = "large quiver"
	desc = "A large quiver to hold a few spears for your atlatl"
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/obj/weapons/guns/atlatl/spearquivers.dmi'
	icon_state = "spearquiver"
	inhand_icon_state = null
	worn_icon_state = "spearquiver"
	/// type of arrow the quiver should hold
	var/arrow_path = /obj/item/ammo_casing/caseless/thrownspear

/obj/item/storage/bag/spearquiver/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_slots = 5
	atom_storage.max_total_storage = 100
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/caseless/thrownspear,
	))

/obj/item/storage/bag/spearquiver/PopulateContents()
	. = ..()
	for(var/i in 1 to 3)
		new arrow_path(src)
