/obj/item/gun/ballistic/bow/energy/shadow_caster
	name = "shadow caster"
	desc = "A bow made of solid darkness. The arrows it shoots seem to suck light out of the surroundings."
	icon = 'yogstation/icons/obj/darkspawn_items.dmi'
	icon_state = "shadow_caster"
	item_state = "shadow_caster"
	lefthand_file = 'yogstation/icons/mob/inhands/antag/darkspawn_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/antag/darkspawn_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/bow/shadow
	no_pin_required = TRUE
	recharge_time = 2 SECONDS
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/ballistic/bow/energy/shadow_caster/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

// the thing that holds the ammo inside the bow
/obj/item/ammo_box/magazine/internal/bow/shadow
	ammo_type = /obj/item/ammo_casing/reusable/arrow/shadow

//the object that appears when the arrow finishes flying
/obj/item/ammo_casing/reusable/arrow/shadow
	name = "shadow arrow"
	desc = "it seem to suck light out of the surroundings."
	icon = 'yogstation/icons/obj/darkspawn_projectiles.dmi'
	icon_state = "caster_arrow"
	item_state = "caster_arrow"
	light_system = MOVABLE_LIGHT
	light_power = -1
	light_color = COLOR_VELVET
	light_range = 2
	embedding = list("embed_chance" = 100, "embedded_fall_chance" = 0) //always embeds if it hits someone
	projectile_type = /obj/projectile/bullet/reusable/arrow/shadow

/obj/item/ammo_casing/reusable/arrow/shadow/on_land(obj/projectile/old_projectile)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(dissipate)), 10 SECONDS, TIMER_UNIQUE)

/obj/item/ammo_casing/reusable/arrow/shadow/proc/dissipate()
	if(QDELETED(src))
		return
	if(iscarbon(loc)) //if it's embedded, remove the embedding properly or it'll cause funkiness
		var/mob/living/carbon/holder = loc
		if(holder.get_embedded_part(src))
			holder.remove_embedded_object(src, get_turf(holder), TRUE, TRUE, FALSE)
	qdel(src)

//the projectile being shot from the bow
/obj/projectile/bullet/reusable/arrow/shadow
	name = "shadow arrow"
	icon = 'yogstation/icons/obj/darkspawn_projectiles.dmi'
	icon_state = "caster_arrow"
	damage = 25 //reduced damage per arrow compared to regular ones
	light_system = MOVABLE_LIGHT
	light_power = -1
	light_color = COLOR_VELVET
	light_range = 2
	embed_chance = 1 //always embeds if it hits someone

/obj/projectile/bullet/reusable/arrow/shadow/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/projectile/bullet/reusable/arrow/shadow/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)
