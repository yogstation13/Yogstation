//-----------------------
// Standard 40mm Grenade
// ----------------------
/obj/item/ammo_casing/a40mm
	name = "40mm HE grenade"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = CALIBER_40MM
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmHE"
	projectile_type = /obj/projectile/bullet/a40mm
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)

/obj/item/ammo_casing/a40mm/update_icon_state()
	. = ..()
	if(!loaded_projectile)
		var/random_angle = rand(0,360)
		transform = transform.Turn(random_angle)

/obj/item/ammo_casing/a40mm/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	var/obj/item/gun/ballistic/shotgun/china_lake/firing_launcher = fired_from
	if(istype(firing_launcher))
		loaded_projectile.range = firing_launcher.target_range
	. = ..()

/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	damage = 60
	embedding = null
	shrapnel_type = null
	range = 30

/obj/projectile/bullet/a40mm/Range() //because you lob the grenade to achieve the range :)
	if(!has_gravity(get_area(src)))
		range++
	return ..()

/obj/projectile/bullet/a40mm/proc/payload(atom/target)
	explosion(target, devastation_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 2, adminlog = FALSE, explosion_cause = src)

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	payload(target)
	return BULLET_ACT_HIT

/obj/projectile/bullet/a40mm/on_range()
	payload(get_turf(src))
	return ..()

/obj/projectile/bullet/a40mm/proc/valid_turf(turf1, turf2)
	for(var/turf/line_turf in get_line(turf1, turf2))
		if(line_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = src))
			return FALSE
	return TRUE

//--------------------------
// 40mm Rubber Slug Grenade
// -------------------------
/obj/item/ammo_casing/a40mm/rubber
	name = "40mm rubber slug shell"
	desc = "A cased rubber slug. The big brother of the beanbag slug, this thing will knock someone out in one. Doesn't do so great against anyone in armor."
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmRUBBER"
	projectile_type = /obj/projectile/bullet/shotgun_beanbag/a40mm

/obj/projectile/bullet/shotgun_beanbag/a40mm
	name = "40mm rubber slug"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmRUBBER_projectile"
	damage = 20
	stamina = 250 //BONK
	paralyze = 5 SECONDS
	wound_bonus = 30
	weak_against_armour = TRUE

//-------------------
// Weak 40mm Grenade
// ------------------
/obj/item/ammo_casing/a40mm/weak
	name = "light 40mm HE grenade"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher. It seems rather light."
	icon_state = "40mm"
	projectile_type = /obj/projectile/bullet/a40mm/weak

/obj/projectile/bullet/a40mm/weak
	name ="light 40mm grenade"
	damage = 30

/obj/projectile/bullet/a40mm/weak/payload(atom/target)
	explosion(target, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 1, adminlog = FALSE, explosion_cause = src)

//-------------------------
// 40mm Incendiary Grenade
// ------------------------
/obj/item/ammo_casing/a40mm/incendiary
	name = "40mm incendiary grenade"
	desc = "A cased incendiary grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmINCEN"
	projectile_type = /obj/projectile/bullet/a40mm/incendiary

/obj/projectile/bullet/a40mm/incendiary
	name ="40mm incendiary grenade"
	damage = 15

/obj/projectile/bullet/a40mm/incendiary/payload(atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/extra_crispy_carbon = target
		extra_crispy_carbon.adjust_fire_stacks(20)
		extra_crispy_carbon.ignite_mob()
		extra_crispy_carbon.apply_damage(30, BURN)

	var/turf/our_turf = get_turf(src)

	for(var/turf/nearby_turf as anything in circle_range_turfs(src, 3))
		if(valid_turf(our_turf, nearby_turf))
			var/obj/effect/hotspot/fire_tile = locate(nearby_turf) || new(nearby_turf)
			fire_tile.temperature = CELCIUS_TO_KELVIN(800 CELCIUS)
			nearby_turf.hotspot_expose(CELCIUS_TO_KELVIN(800 CELCIUS), 125, 1)
			for(var/mob/living/crispy_living in nearby_turf.contents)
				crispy_living.apply_damage(30, BURN)
				if(iscarbon(crispy_living))
					var/mob/living/carbon/crispy_carbon = crispy_living
					crispy_carbon.adjust_fire_stacks(10)
					crispy_carbon.ignite_mob()

	explosion(target, flame_range = 1, flash_range = 3, adminlog = FALSE, explosion_cause = src)

//--------------------
// 40mm Smoke Grenade
// -------------------
/obj/item/ammo_casing/a40mm/smoke
	name = "40mm smoke grenade"
	desc = "A cased smoke grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmSMOKE"
	projectile_type = /obj/projectile/bullet/a40mm/smoke

/obj/projectile/bullet/a40mm/smoke
	name ="40mm smoke grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	damage = 15

/obj/projectile/bullet/a40mm/smoke/payload(atom/target)
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(4, holder = src, location = src)
	smoke.start()

//--------------------
// 40mm Stun Grenade
// -------------------
/obj/item/ammo_casing/a40mm/stun
	name = "40mm stun grenade"
	desc = "A cased stun grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmSTUN"
	projectile_type = /obj/projectile/bullet/a40mm/stun

/obj/projectile/bullet/a40mm/stun
	name ="40mm stun grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	damage = 15

/obj/projectile/bullet/a40mm/stun/payload(atom/target)
	playsound(src, 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)

	explosion(target, flash_range = 3, adminlog = FALSE, explosion_cause = src)
	do_sparks(rand(5, 9), FALSE, src)

	var/turf/our_turf = get_turf(src)

	for(var/turf/nearby_turf as anything in circle_range_turfs(src, 3))
		if(valid_turf(our_turf, nearby_turf))
			if(prob(50))
				do_sparks(rand(1, 9), FALSE, nearby_turf)
			for(var/mob/living/stunned_living in nearby_turf.contents)
				stunned_living.Paralyze(5 SECONDS)
				stunned_living.Knockdown(8 SECONDS)
				stunned_living.soundbang_act(1, 200, 10, 15)

//-------------------
// 40mm HEDP Grenade
// ------------------
/obj/item/ammo_casing/a40mm/hedp
	name = "40mm HEDP grenade"
	desc = "A cased HEDP grenade that can only be activated once fired out of a grenade launcher. The destroyer of mechs and silicons alike."
	icon_state = "40mmHEDP"
	projectile_type = /obj/projectile/bullet/a40mm/hedp

/obj/projectile/bullet/a40mm/hedp
	name ="40mm HEDP grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmHEDP_projectile"
	damage = 50
	var/anti_material_damage_bonus = 75

/obj/projectile/bullet/a40mm/hedp/payload(atom/target)
	explosion(target, heavy_impact_range = 0, light_impact_range = 2,  flash_range = 1, adminlog = FALSE, explosion_cause = src)

	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/mecha = target
		mecha.take_damage(anti_material_damage_bonus)
	if(issilicon(target))
		var/mob/living/silicon/borgo = target
		borgo.gib()

	if(isstructure(target) || isvehicle (target) || isclosedturf (target) || ismachinery (target)) //if the target is a structure, machine, vehicle or closed turf like a wall, explode that shit
		if(isclosedturf(target)) //walls get blasted
			explosion(target, heavy_impact_range = 1, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			return
		if(target.density) //Dense objects get blown up a bit harder
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			target.take_damage(anti_material_damage_bonus)
			return
		else
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			target.take_damage(anti_material_damage_bonus)

//--------------------
// 40mm Frag Grenade
// -------------------
/obj/item/ammo_casing/a40mm/frag
	name = "40mm fragmentation grenade"
	desc = "A cased stun grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmFRAG"
	projectile_type = /obj/projectile/bullet/a40mm/frag

/obj/projectile/bullet/a40mm/frag
	name ="40mm fragmentation grenade"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"

/obj/projectile/bullet/a40mm/frag/payload(atom/target)
	var/obj/item/grenade/shrapnel_maker = new /obj/item/grenade/a40mm_frag(drop_location())

	shrapnel_maker.detonate()
	qdel(shrapnel_maker)

/obj/item/grenade/a40mm_frag
	name = "40mm fragmentation payload"
	desc = "An anti-personnel fragmentation payload. How the heck did this get here?"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	shrapnel_type = /obj/projectile/bullet/shrapnel/a40mm_frag
	shrapnel_radius = 4
	det_time = 0
	display_timer = FALSE
	ex_light = 2

/obj/projectile/bullet/shrapnel/a40mm_frag
	name = "flying shrapnel hunk"
	range = 4
	dismemberment = 15
	ricochets_max = 6
	ricochet_chance = 75
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 0.9

// GRENADE BOX!
//--------------------
// Read above comment
//--------------------
#define A40MM_GRENADE_INBOX_SPRITE_WIDTH 3

/obj/item/storage/fancy/a40mm_box
	name = "40mm grenade box"
	desc = "A metal box designed to hold 40mm grenades."
	icon =  'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_box"
	base_icon_state = "40mm_box"
	spawn_type = /obj/item/ammo_casing/a40mm
	spawn_count = 4
	open_status = FALSE
	appearance_flags = KEEP_TOGETHER|LONG_GLIDE
	contents_tag = "grenade"
	foldable_result = null
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5)
	flags_1 = CONDUCT_1
	force = 8
	throwforce = 12
	throw_speed = 2
	throw_range = 7
	resistance_flags = null

	hitsound = 'sound/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'

/obj/item/storage/fancy/a40mm_box/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/ammo_casing/a40mm))

/obj/item/storage/fancy/a40mm_box/attack_self(mob/user)
	..()
	if(open_status == FANCY_CONTAINER_OPEN)
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)

/obj/item/storage/fancy/a40mm_box/PopulateContents()
	. = ..()
	update_appearance()

/obj/item/storage/fancy/a40mm_box/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][open_status ? "_open" : null]"

/obj/item/storage/fancy/a40mm_box/update_overlays()
	. = ..()
	if(!open_status)
		return

	var/grenades = 0
	for(var/_grenade in contents)
		var/obj/item/ammo_casing/a40mm/grenade = _grenade
		if (!istype(grenade))
			continue
		. += image(icon = initial(icon), icon_state = (initial(grenade.icon_state) + "_inbox"), pixel_x = grenades * A40MM_GRENADE_INBOX_SPRITE_WIDTH)
		grenades += 1

#undef A40MM_GRENADE_INBOX_SPRITE_WIDTH

/obj/item/storage/fancy/a40mm_box/rubber
	spawn_type = /obj/item/ammo_casing/a40mm/rubber

/obj/item/storage/fancy/a40mm_box/weak
	spawn_type = /obj/item/ammo_casing/a40mm/weak

/obj/item/storage/fancy/a40mm_box/incendiary
	spawn_type = /obj/item/ammo_casing/a40mm/incendiary

/obj/item/storage/fancy/a40mm_box/smoke
	spawn_type = /obj/item/ammo_casing/a40mm/smoke

/obj/item/storage/fancy/a40mm_box/stun
	spawn_type = /obj/item/ammo_casing/a40mm/stun

/obj/item/storage/fancy/a40mm_box/hedp
	spawn_type = /obj/item/ammo_casing/a40mm/hedp

/obj/item/storage/fancy/a40mm_box/frag
	spawn_type = /obj/item/ammo_casing/a40mm/frag

////////////////////////////////////
//		DESIGNS
////////////////////////////////////
/datum/design/a40MM
	name = "Light 40mm HE Grenade"
	id = "a40mm"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/a40mm/weak
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
