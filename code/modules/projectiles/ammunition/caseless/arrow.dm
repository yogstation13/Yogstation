/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "An arrow, typically fired from a bow."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon_state = "arrow"
	force = 5
	throwforce = 5 //good luck hitting someone with the pointy end of the arrow
	throw_speed = 3
	sharpness = SHARP_POINTY
	embedding = list("embed_chance" = 25, "embedded_fall_chance" = 0)

/obj/item/ammo_casing/caseless/arrow/wood
	name = "wooden arrow"
	desc = "An arrow made of wood, typically fired from a bow."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/wood

/obj/item/ammo_casing/caseless/arrow/ash
	name = "ashen arrow"
	desc = "An arrow made from wood, hardened by fire"
	icon_state = "ashenarrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/ash
	embedding = list("embed_chance" = 30, "embedded_fall_chance" = 0)

/obj/item/ammo_casing/caseless/arrow/bone_tipped
	name = "bone tipped arrow"
	desc = "An arrow made of bone, wood, and sinew. The tip is sharp enough to pierce goliath hide."
	icon_state = "bonetippedarrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone_tipped
	embedding = list("embed_chance" = 10, "embedded_fall_chance" = 0)

/obj/item/ammo_casing/caseless/arrow/bone
	name = "bone arrow"
	desc = "A flimsy arrow made of bone. Not strong or durable, but is easy to make."
	icon_state = "bonearrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone
	embedding = list("embed_chance" = 10, "embedded_fall_chance" = 0)

/obj/item/ammo_casing/caseless/arrow/chitin
	name = "chitin tipped arrow"
	desc = "A sharp arrow made of the guts of lavaland monsters. The tip is sharp and jagged, making it easier to get stuck into your target."
	icon_state = "chitinarrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/chitin
	embedding = list("embed_chance" = 10, "embedded_fall_chance" = 0)

/obj/item/ammo_casing/caseless/arrow/bamboo
	name = "bamboo arrow"
	desc = "A flimsy arrow made of bamboo. Not strong or durable, but is easy to make."
	icon_state = "bambooarrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bamboo
	embedding = list("embed_chance" = 15, "embedded_fall_chance" = 0)

/obj/item/ammo_casing/caseless/arrow/bronze
	name = "bronze arrow"
	desc = "An arrow made from wood. tipped with bronze."
	icon_state = "bronzearrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bronze
	embedding = list("embed_chance" = 15, "embedded_fall_chance" = 0)

/obj/item/ammo_casing/caseless/arrow/glass
	name = "glass arrow"
	desc = "An arrow made from a metal rod, wrapped in wires, and tipped with glass."
	icon_state = "glassarrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/glass
	variance = 10

/obj/item/ammo_casing/caseless/arrow/glass/plasma
	name = "plasma glass arrow"
	desc = "An arrow made from a metal rod, wrapped in wires, and tipped with plasma glass."
	icon_state = "plasmaglassarrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/glass/plasma
	variance = 10

/obj/item/ammo_casing/caseless/arrow/bola
	name = "bola arrow"
	desc = "An arrow made from wood. a bola is wrapped around it."
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
/*
/obj/item/ammo_casing/caseless/arrow/explosive
	name = "explosive arrow"
	desc = "An arrow made from wood. an explosive is attached to it."
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
			BBB.ammo_type = AA.ammo_type

	var/obj/item/grenade/explosive = locate(/obj/item/grenade) in contents
	var/obj/item/projectile/bullet/reusable/arrow/explosive/explosive_arrow = BB
	if(!istype(explosive))
		explosive = new /obj/item/grenade/plastic/c4(src)
	if(istype(explosive) && istype(explosive_arrow))
		explosive_arrow.explosive = explosive
	
	add_overlay(mutable_appearance(icon, "arrow_explosive"), TRUE)
*/
/obj/item/ammo_casing/caseless/arrow/flaming
	name = "flaming arrow"
	desc = "An arrow made from wood. lit on fire."
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
