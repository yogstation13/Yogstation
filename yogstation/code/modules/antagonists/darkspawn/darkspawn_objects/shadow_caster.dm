/obj/item/gun/ballistic/bow/energy/shadow_caster
	name = "shadow caster"
	desc = "A bow made of solid darkness. The arrows it shoots seem to suck light out of the surroundings."
	icon_state = "bow_hardlight"
	item_state = "bow_hardlight"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/shadow
	no_pin_required = TRUE
	recharge_time = 5 SECONDS

/obj/item/gun/ballistic/bow/energy/shadow_caster/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/light_eater)

/obj/item/ammo_box/magazine/internal/bow/shadow
	ammo_type = /obj/item/ammo_casing/reusable/arrow/shadow

/obj/item/ammo_casing/reusable/arrow/shadow
	name = "shadow arrow"
	desc = "it seem to suck light out of the surroundings."
	light_system = MOVABLE_LIGHT
	light_power = -0.5
	light_color = COLOR_VELVET
	light_range = 3.5
	projectile_type = /obj/projectile/bullet/reusable/arrow/shadow

/obj/item/ammo_casing/reusable/arrow/shadow/on_land(obj/projectile/old_projectile)
	. = ..()
	QDEL_IN(src, 10 SECONDS)

/obj/projectile/bullet/reusable/arrow/shadow
	name = "shadow arrow"
	light_system = MOVABLE_LIGHT
	light_power = -0.5
	light_color = COLOR_VELVET
	light_range = 3.5
