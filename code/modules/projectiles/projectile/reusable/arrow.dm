/obj/item/projectile/bullet/reusable/arrow
	name = "Arrow"
	desc = "Woosh!"
	damage = 20
	flag = MELEE
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	var/embed_chance = 0.5
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
	if(ishuman(target))
		var/mob/living/carbon/human/embede = target
		var/obj/item/bodypart/part = embede.get_bodypart(def_zone)
		if(prob(embed_chance * clamp((100 - (embede.checkarmor(part, flag) - armour_penetration)), 0, 100)) && embede.embed_object(dropping, part, TRUE))
			dropped = TRUE
	
	// Icky code, but i dont want to create a new obj, delete it, then make a new one
	if(!dropped)
		dropping.forceMove(get_turf(src))
		dropped = TRUE

/obj/item/projectile/bullet/reusable/arrow/wood
	name = "Wooden arrow"
	desc = "Wooden arrow."
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood

/obj/item/projectile/bullet/reusable/arrow/ash
	name = "Ashen arrow"
	desc = "Fire Hardened arrow."
	damage = 25
	embed_chance = 0.3
	break_chance = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/ash

/obj/item/projectile/bullet/reusable/arrow/bone_tipped //AP for ashwalkers
	name = "Bone tipped arrow"
	desc = "An arrow made from bone, wood, and sinew."
	damage = 30
	armour_penetration = 15
	embed_chance = 0.4
	break_chance = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone_tipped

/obj/item/projectile/bullet/reusable/arrow/bone
	name = "Bone arrow"
	desc = "An arrow made from bone and sinew."
	damage = 10
	fauna_damage_bonus = 30
	embed_chance = 0.6
	break_chance = 50
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone

/obj/item/projectile/bullet/reusable/arrow/chitin
	name = "Chitin tipped arrow"
	desc = "An arrow made from chitin, bone, and sinew."
	damage = 20
	fauna_damage_bonus = 40
	armour_penetration = 30
	embed_chance = 0.5
	break_chance = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/chitin

/obj/item/projectile/bullet/reusable/arrow/bamboo
	name = "Bamboo arrow"
	desc = "An arrow made from bamboo."
	damage = 8
	fauna_damage_bonus = 27
	embed_chance = 0.7
	break_chance = 67
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bamboo

/obj/item/projectile/bullet/reusable/arrow/bronze
	name = "Bronze arrow"
	desc = "Bronze tipped arrow"
	damage = 25
	armour_penetration = 10
	embed_chance = 0.3
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bronze

/obj/item/projectile/bullet/reusable/arrow/glass
	name = "Glass arrow"
	desc = "Glass tipped arrow"
	damage = 15
	embed_chance = 0.3
	break_chance = 20
	ammo_type = /obj/item/ammo_casing/caseless/arrow/glass

/obj/item/projectile/bullet/reusable/arrow/glass/plasma
	name = "Plasma Glass arrow"
	desc = "Plasma Glass tipped arrow"
	damage = 10
	armour_penetration = 10
	embed_chance = 0.3
	break_chance = 10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/glass/plasma

/obj/item/projectile/bullet/reusable/arrow/bola
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
/obj/item/projectile/bullet/reusable/arrow/flaming
	name = "Flaming arrow"
	desc = "A burning arrow"

/obj/item/projectile/bullet/reusable/arrow/flaming/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/item/projectile/energy/arrow
	name = "energy bolt"
	icon_state = "arrow_energy"
	damage = 30
	damage_type = BURN

/obj/item/projectile/energy/arrow/disabler
	name = "disabler bolt"
	icon_state = "arrow_disable"
	light_color = LIGHT_COLOR_BLUE
	damage = 40
	damage_type = STAMINA

/*
/obj/item/projectile/energy/arrow/pulse
	name = "pulse bolt"
	icon_state = "arrow_pulse"
	light_color = LIGHT_COLOR_BLUE
	damage = 50
	damage_type = BURN

/obj/item/projectile/energy/arrow/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || istype(target, /obj/structure/)))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target
*/

/obj/item/projectile/energy/arrow/xray
	name = "X-ray bolt"
	icon_state = "arrow_xray"
	light_color = LIGHT_COLOR_GREEN
	damage = 20
	irradiate = 300
	range = 20
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF

/obj/item/projectile/energy/arrow/clockbolt
	name = "redlight bolt"
