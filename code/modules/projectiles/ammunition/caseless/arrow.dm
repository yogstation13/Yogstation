/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "An arrow, typically fired from a bow."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon_state = "arrow"
	force = 5
	throwforce = 5 //If, if you want to throw the arrow since you don't have a bow?
	throw_speed = 3
	sharpness = SHARP_POINTY
	embedding = list("embed_chance" = 25, "embedded_fall_chance" = 0)

/obj/item/ammo_casing/caseless/arrow/wood
	name = "wooden arrow"
	desc = "A wooden arrow, quickly made."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/wood

/obj/item/ammo_casing/caseless/arrow/ash
	name = "ashen arrow"
	desc = "A wooden arrow tempered by fire. It's tougher, but less likely to embed."
	icon_state = "ashenarrow"
	force = 7
	throwforce = 7
	embedding = list("embed_chance" = 15, "embedded_fall_chance" = 0)
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/ash

/obj/item/ammo_casing/caseless/arrow/bone_tipped
	name = "bone-tipped arrow"
	desc = "An arrow made from bone, wood, and sinew. Sturdy and sharp."
	icon_state = "bonetippedarrow"
	force = 9
	throwforce = 9
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone_tipped

/obj/item/ammo_casing/caseless/arrow/bone
	name = "bone arrow"
	desc = "An arrow made from bone and sinew. Better at hunting fauna."
	icon_state = "bonearrow"
	force = 4
	throwforce = 4
	embedding = list("embed_chance" = 20, "embedded_fall_chance" = 0)
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone

/obj/item/ammo_casing/caseless/arrow/chitin
	name = "chitin-tipped arrow"
	desc = "An arrow made from chitin, bone, and sinew. Incredibly potent at puncturing armor and hunting fauna."
	icon_state = "chitinarrow"
	armour_penetration = 25 //Ah yes the 25 AP on a 5 force hit
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/chitin

/obj/item/ammo_casing/caseless/arrow/bamboo
	name = "bamboo arrow"
	desc = "An arrow made from bamboo. Incredibly fragile and weak, but prone to shattering in unarmored targets."
	icon_state = "bambooarrow"
	force = 3
	throwforce = 3
	armour_penetration = -10
	embedding = list("embed_chance" = 35, "embedded_fall_chance" = 0)
	variance = 10
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bamboo

/obj/item/ammo_casing/caseless/arrow/bronze
	name = "bronze arrow"
	desc = "An arrow tipped with bronze. Better against armor than iron."
	icon_state = "bronzearrow"
	armour_penetration = 10 
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bronze

/obj/item/ammo_casing/caseless/arrow/glass
	name = "glass arrow"
	desc = "A shoddy arrow with a broken glass shard as its tip. Can break upon impact."
	icon_state = "glassarrow"
	force = 4
	throwforce = 4
	embedding = list("embed_chance" = 15, "embedded_fall_chance" = 0)
	variance = 5
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/glass

/obj/item/ammo_casing/caseless/arrow/glass/plasma
	name = "plasmaglass arrow"
	desc = "An arrow with a plasmaglass shard affixed to its head. Incredibly capable of puncturing armor."
	icon_state = "plasmaglassarrow"
	armour_penetration = 40 //Ah yes the 40 AP on a 4 force hit
	embedding = list("embed_chance" = 25, "embedded_fall_chance" = 0)
	variance = 5
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/glass/plasma

/obj/item/ammo_casing/caseless/arrow/bola
	name = "bola arrow"
	desc = "An arrow with a bola wrapped around it. Will automatically wrap around any target hit."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bola

/obj/item/ammo_casing/caseless/arrow/bola/Initialize()
	..()
	var/obj/item/ammo_casing/caseless/arrow/A = locate(/obj/item/ammo_casing/caseless/arrow) in contents
	if(istype(A))
		icon = A.icon
		icon_state = A.icon_state
		var/obj/item/projectile/bullet/reusable/arrow/AA = A.BB
		var/obj/item/projectile/bullet/reusable/arrow/BBB = BB
		if(istype(AA) && istype(BBB))
			BBB.damage = AA.damage * 0.5
			BBB.armour_penetration = AA.armour_penetration * 0.5
			BBB.embed_chance = AA.embed_chance * 0.5
			BBB.ammo_type = AA.ammo_type

	var/obj/item/restraints/legcuffs/bola/bola = locate(/obj/item/restraints/legcuffs/bola) in contents
	var/obj/item/projectile/bullet/reusable/arrow/bola/bola_arrow = BB
	if(!istype(bola))
		bola = new(src)
	if(istype(bola) && istype(bola_arrow))
		bola_arrow.bola = bola
	
	add_overlay(mutable_appearance(icon, "arrow_bola"), TRUE)

/obj/item/ammo_casing/caseless/arrow/explosive
	name = "explosive arrow"
	desc = "An arrow with an explosive attached to it, ready to prime upon impact."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/explosive

/obj/item/ammo_casing/caseless/arrow/explosive/Initialize()
	..()
	var/obj/item/ammo_casing/caseless/arrow/A = locate(/obj/item/ammo_casing/caseless/arrow) in contents
	if(istype(A))
		icon = A.icon
		icon_state = A.icon_state
		var/obj/item/projectile/bullet/reusable/AA = A.BB
		var/obj/item/projectile/bullet/reusable/BBB = BB
		if(istype(AA) && istype(BBB))
			BBB.damage = AA.damage * 0.5
			BBB.armour_penetration = AA.armour_penetration * 0.5
			BBB.embed_chance = AA.embed_chance * 0.5
			BBB.ammo_type = AA.ammo_type

	var/obj/item/grenade/explosive = locate(/obj/item/grenade) in contents
	var/obj/item/projectile/bullet/reusable/arrow/explosive/explosive_arrow = BB
	if(!istype(explosive))
		explosive = new /obj/item/grenade/plastic/c4(src)
	if(istype(explosive) && istype(explosive_arrow))
		explosive_arrow.explosive = explosive
	
	add_overlay(mutable_appearance(icon, "arrow_explosive"), TRUE)

/obj/item/ammo_casing/caseless/arrow/flaming
	name = "fire arrow"
	desc = "An arrow set ablaze, ready to ignite a target."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/flaming

/obj/item/ammo_casing/caseless/arrow/flaming/Initialize()
	..()
	var/obj/item/ammo_casing/caseless/arrow/A = locate(/obj/item/ammo_casing/caseless/arrow) in contents
	if(istype(A))
		icon = A.icon
		icon_state = A.icon_state
		var/obj/item/projectile/bullet/reusable/arrow/AA = A.BB
		var/obj/item/projectile/bullet/reusable/arrow/BBB = BB
		if(istype(AA) && istype(BBB))
			BBB.damage = AA.damage * 0.5
			BBB.armour_penetration = AA.armour_penetration * 0.5
			BBB.embed_chance = AA.embed_chance * 0.5
			BBB.ammo_type = AA.ammo_type
	
	add_overlay(mutable_appearance(icon, "arrow_fire"), TRUE)

// Energy Arrows //

/obj/item/ammo_casing/caseless/arrow/energy
	name = "energy bolt"
	desc = "An arrow made from hardlight."
	icon_state = "arrow_energy"
	item_flags = DROPDEL
	embedding = list("embedded_pain_chance" = 0, "embedded_pain_multiplier" = 0, "embedded_unsafe_removal_pain_multiplier" = 0, "embedded_pain_chance" = 0, "embedded_fall_chance" = 0)
	projectile_type = /obj/item/projectile/energy/arrow
	var/overlay_state = "redlight"

	var/ticks = 0
	var/tick_max = 10
	var/tick_damage = 1
	var/tick_damage_type = FIRE
	var/tick_sound = 'sound/effects/sparks4.ogg'

/obj/item/ammo_casing/caseless/arrow/energy/on_embed_removal(mob/living/carbon/human/embedde)
	qdel(src)

/obj/item/ammo_casing/caseless/arrow/energy/embed_tick(mob/living/carbon/human/embedde, obj/item/bodypart/part)
	if(ticks >= tick_max)
		embedde.remove_embedded_object(src, , TRUE, TRUE)
		return
	ticks++
	playsound(embedde, tick_sound , 10, 0)
	embedde.apply_damage(tick_damage, BB.damage_type, part.body_zone)

/obj/item/ammo_casing/caseless/arrow/energy/disabler
	name = "disabler bolt"
	desc = "An arrow made from hardlight. This one stuns the victim in a non-lethal way."
	icon_state = "arrow_disable"
	overlay_state = "disable"
	projectile_type = /obj/item/projectile/energy/arrow/disabler
	harmful = FALSE
	tick_damage_type = STAMINA
	
/obj/item/ammo_casing/caseless/arrow/energy/xray
	name = "X-ray bolt"
	desc = "An arrow made from hardlight. This one can pass through obstructions."
	icon_state = "arrow_xray"
	overlay_state = "xray"
	projectile_type = /obj/item/projectile/energy/arrow/xray
	tick_damage_type = TOX

/obj/item/ammo_casing/caseless/arrow/energy/clockbolt
	name = "redlight bolt"
	desc = "An arrow made from a strange energy."
	projectile_type = /obj/item/projectile/energy/arrow/clockbolt
