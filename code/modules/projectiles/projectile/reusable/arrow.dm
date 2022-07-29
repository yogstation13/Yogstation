/obj/item/projectile/bullet/reusable/arrow //Base arrow. Good against fauna, not perfect, but well-rounded.
	name = "Arrow"
	desc = "Woosh!"
	damage = 20
	flag = MELEE
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	var/embed_chance = 0.4
	var/break_chance = 10
	var/fauna_damage_bonus = 20

/obj/item/projectile/bullet/reusable/arrow/on_hit(atom/target, blocked = FALSE)
    . = ..()
    if(isliving(target))
        var/mob/living/L = target
        if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
            L.apply_damage(fauna_damage_bonus)

/obj/item/projectile/bullet/reusable/arrow/handle_drop(atom/target)
	if(prob(break_chance))
		return
	var/obj/item/dropping = new ammo_type()
	if(iscarbon(target))
		var/mob/living/carbon/embede = target
		var/obj/item/bodypart/part = embede.get_bodypart(def_zone)
		if(prob(embed_chance * clamp((100 - (embede.getarmor(part, flag) - armour_penetration)), 0, 100)) && embede.embed_object(dropping, part, TRUE))
			dropped = TRUE
	
	// Icky code, but i dont want to create a new obj, delete it, then make a new one
	if(!dropped)
		dropping.forceMove(get_turf(src))
		dropped = TRUE

/obj/item/projectile/bullet/reusable/arrow/wood
	name = "Wooden arrow"
	desc = "Wooden arrow."
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood

/obj/item/projectile/bullet/reusable/arrow/ash //Fire-tempered head makes it tougher; more damage, but less likely to shatter and embed
	name = "Ashen arrow"
	desc = "Fire Hardened arrow."
	damage = 25
	embed_chance = 0.25
	break_chance = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/ash

/obj/item/projectile/bullet/reusable/arrow/bone_tipped //Highest damage; fully upgraded normal arrow, simply well-crafted
	name = "Bone tipped arrow"
	desc = "An arrow made from bone, wood, and sinew."
	damage = 30
	armour_penetration = 20
	embed_chance = 0.33
	break_chance = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone_tipped

/obj/item/projectile/bullet/reusable/arrow/bone //Cheap, easy to make in bulk but mostly capable of being used to hunt fauna
	name = "Bone arrow"
	desc = "An arrow made from bone and sinew."
	damage = 15
	fauna_damage_bonus = 35
	embed_chance = 0.33
	break_chance = 10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone

/obj/item/projectile/bullet/reusable/arrow/chitin //Most expensive arrow, but powerful for those who put in the time. Greater AP alternative to bone-tipped. Very robust against fauna.
	name = "Chitin tipped arrow"
	desc = "An arrow made from chitin, bone, and sinew."
	damage = 25
	fauna_damage_bonus = 40
	armour_penetration = 35
	embed_chance = 0.4
	break_chance = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/chitin

/obj/item/projectile/bullet/reusable/arrow/bamboo //Very brittle, very fragile, but very potent at splintering into targets assuming it isn't broken on impact
	name = "Bamboo arrow"
	desc = "An arrow made from bamboo."
	damage = 10
	embed_chance = 0.5
	break_chance = 50
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bamboo

/obj/item/projectile/bullet/reusable/arrow/bronze //Inferior metal. Slightly better than ashen
	name = "Bronze arrow"
	desc = "Bronze tipped arrow"
	damage = 25
	armour_penetration = 10
	embed_chance = 0.3
	break_chance = 10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bronze

/obj/item/projectile/bullet/reusable/arrow/glass //Fragile, but sharp and light. Not as effective as metal but cheaper.
	name = "Glass arrow"
	desc = "Glass tipped arrow"
	damage = 15
	embed_chance = 0.3
	break_chance = 25
	ammo_type = /obj/item/ammo_casing/caseless/arrow/glass

/obj/item/projectile/bullet/reusable/arrow/glass/plasma //Immensely capable of puncturing through materials; plasma is a robust material, more capable of slicing through protection
	name = "Plasma Glass arrow"
	desc = "Plasma Glass tipped arrow"
	damage = 18
	armour_penetration = 60
	embed_chance = 0.4
	break_chance = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/glass/plasma

/obj/item/projectile/bullet/reusable/arrow/bola //More of a blunt impact of the bola, still an arrow. Only able to be crafted with makeshift weaponry
	name = "Bola arrow"
	desc = "An arrow with a bola wrapped around it"
	var/obj/item/restraints/legcuffs/bola/bola

/obj/item/projectile/bullet/reusable/arrow/bola/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		return bola.impactCarbon(target)
	if(isanimal(target))
		return bola.impactAnimal(target)
/*
/obj/item/projectile/bullet/reusable/arrow/explosive
	name = "Explosive arrow"
	desc = "An arrow with an explosive attached to it"
	damage = 20
	armour_penetration = 10
	var/obj/item/grenade/explosive = null

/obj/item/projectile/bullet/reusable/arrow/explosive/prehit(atom/target)
	. = ..()
	explosive.forceMove(target)
	explosive.prime()
	visible_message("[explosive]")
*/
/obj/item/projectile/bullet/reusable/arrow/flaming //Normal arrow, but it also sets people on fire. Simple
	name = "Flaming arrow"
	desc = "A burning arrow"

/obj/item/projectile/bullet/reusable/arrow/flaming/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.apply_damage(8, BURN)
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/item/projectile/energy/arrow //Hardlight projectile. Slightly more robust than a standard laser. Capable of hardening in target's flesh
	name = "energy bolt"
	icon_state = "arrow_energy"
	damage = 25
	damage_type = BURN
	var/embed_chance = 0.4
	var/obj/item/embed_type = /obj/item/ammo_casing/caseless/arrow/energy
	
/obj/item/projectile/energy/arrow/on_hit(atom/target, blocked = FALSE)
	..()
	if(!blocked && iscarbon(target))
		var/mob/living/carbon/embede = target
		var/obj/item/bodypart/part = embede.get_bodypart(def_zone)
		if(prob(embed_chance * clamp((100 - (embede.getarmor(part, flag) - armour_penetration)), 0, 100)))
			embede.embed_object(new embed_type(), part, FALSE)

/obj/item/projectile/energy/arrow/disabler //Hardlight projectile. Forceful impact makes the impact more draining than a standard disabler. Needs to be competitive in DPS
	name = "disabler bolt"
	icon_state = "arrow_disable"
	light_color = LIGHT_COLOR_BLUE
	damage = 40
	damage_type = STAMINA
	embed_type = /obj/item/ammo_casing/caseless/arrow/energy/disabler

/obj/item/projectile/energy/arrow/xray //Slightly weakened arrow capable of passing through material; also irradiates targets moderately
	name = "X-ray bolt"
	icon_state = "arrow_xray"
	light_color = LIGHT_COLOR_GREEN
	damage = 15
	irradiate = 300
	range = 20
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF
	embed_type = /obj/item/ammo_casing/caseless/arrow/energy/xray

/obj/item/projectile/energy/arrow/clockbolt
	name = "redlight bolt"
	damage = 16
	embed_type = /obj/item/ammo_casing/caseless/arrow/energy/clockbolt
