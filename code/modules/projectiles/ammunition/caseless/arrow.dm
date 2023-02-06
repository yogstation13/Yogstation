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

	/// List of all attached parts to move to the projectile when fired
	var/list/attached_parts
	/// Attached explosive
	var/obj/item/grenade/explosive
	/// Attached bola
	var/obj/item/restraints/legcuffs/bola/bola
	/// Attached syringe
	var/obj/item/reagent_containers/syringe/syringe
	/// If the arrow is on fire
	var/flaming = FALSE

/obj/item/ammo_casing/caseless/arrow/Initialize()
	var/list/new_parts
	if(ispath(explosive))
		LAZYADD(new_parts, new explosive())
	if(ispath(bola))
		LAZYADD(new_parts, new bola())
	..()
	if(LAZYLEN(new_parts))
		CheckParts(new_parts)

/obj/item/ammo_casing/caseless/arrow/update_icon(force_update)
	..()
	cut_overlays()
	if(istype(explosive))
		add_overlay(mutable_appearance(icon, "arrow_explosive[explosive.active ? "_active" : ""]"), TRUE)
	if(istype(bola))
		add_overlay(mutable_appearance(icon, "arrow_bola"), TRUE)
	if(istype(syringe))
		add_overlay(mutable_appearance(icon, "arrow_bola"), TRUE)
	if(flaming)
		add_overlay(mutable_appearance(icon, "arrow_fire"), TRUE)

/obj/item/ammo_casing/caseless/arrow/examine(mob/user)
	. = ..()
	if(explosive)
		. += "It has [explosive.active ? "an armed " : ""][explosive] attached."
	if(bola)
		. += "It has [bola] attached."
	if(LAZYLEN(attached_parts))
		. += "The added parts can be removed with a wirecutter."
	if(flaming)
		. += "It is on fire."

/obj/item/ammo_casing/caseless/arrow/attack_self(mob/user)
	if(istype(explosive))
		explosive.attack_self(user)
		add_fingerprint(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.throw_mode_off()
		update_icon()
	return ..()

/obj/item/ammo_casing/caseless/arrow/wirecutter_act(mob/living/user, obj/item/I)
	var/obj/item/projectile/bullet/reusable/arrow/arrow = BB
	if(!istype(arrow))
		return
	if(!LAZYLEN(attached_parts))
		to_chat(user, span_warning("There is nothing to remove!"))
		return
	if(explosive)
		explosive = null
		arrow.explosive = null
	if(bola)
		bola = null
		arrow.bola = null
	attached_parts = null
	for(var/obj/item/part in attached_parts)
		if(!part.forceMove(part.drop_location()))
			qdel(part)
	to_chat(user, span_notice("You remove the attached parts."))

			
/obj/item/ammo_casing/caseless/arrow/CheckParts(list/parts_list)
	var/obj/item/ammo_casing/caseless/arrow/A = locate(/obj/item/ammo_casing/caseless/arrow) in parts_list
	if(A)
		LAZYREMOVE(parts_list, A)
		if(flaming)
			add_flame()
		A.CheckParts(parts_list)
		qdel(src)
	for(var/obj/item/grenade/G in parts_list)
		if(G)
			if(istype(explosive))
				G.forceMove(G.drop_location())
			else
				add_explosive(G)
	for(var/obj/item/restraints/legcuffs/bola/B in parts_list)
		if(B)
			if(istype(bola))
				B.forceMove(B.drop_location())
			else
				add_bola(B)
	for(var/obj/item/restraints/handcuffs/cable/C in parts_list)
		LAZYADD(attached_parts, C)
	if(LAZYLEN(attached_parts))
		var/obj/item/projectile/bullet/reusable/arrow/arrow = BB
		arrow.attached_parts = attached_parts
	..()

/obj/item/ammo_casing/caseless/arrow/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	if (..())
		var/obj/item/projectile/bullet/reusable/arrow/arrow = BB
		if(istype(arrow))
			arrow.CheckParts(attached_parts)
		return TRUE
	return FALSE

/obj/item/ammo_casing/caseless/arrow/proc/add_explosive(obj/item/grenade/new_explosive)
	var/obj/item/projectile/bullet/reusable/arrow/arrow = BB
	if(istype(new_explosive) && istype(arrow))
		explosive = new_explosive
		arrow.explosive = new_explosive
		LAZYADD(attached_parts, new_explosive)
	update_icon()

/obj/item/ammo_casing/caseless/arrow/proc/add_bola(obj/item/restraints/legcuffs/bola/new_bola)
	var/obj/item/projectile/bullet/reusable/arrow/arrow = BB
	if(istype(new_bola) && istype(arrow))
		bola = new_bola
		arrow.bola = new_bola
		LAZYADD(attached_parts, new_bola)
	update_icon()

/obj/item/ammo_casing/caseless/arrow/proc/add_flame()
	var/obj/item/projectile/bullet/reusable/arrow/arrow = BB
	if(istype(arrow))
		flaming = TRUE
		arrow.flaming = TRUE
	update_icon()


// Arrow Subtypes //

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


// Toy //

/obj/item/ammo_casing/caseless/arrow/toy
	name = "toy arrow"
	desc = "A plastic arrow with a blunt tip covered in velcro to allow it to stick to whoever it hits."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/toy
	force = 0
	throwforce = 0
	sharpness = SHARP_NONE
	embedding = list(100, 0, 0, 0, 0, 0, 0, 0.5, TRUE)
	taped = TRUE

/obj/item/ammo_casing/caseless/arrow/toy/blue
	name = "blue toy arrow"
	desc = "A plastic arrow with a blunt tip covered in velcro to allow it to stick to whoever it hits. This one is made to resemble a blue hardlight arrow."
	icon_state = "arrow_toy_blue"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/toy/blue

/obj/item/ammo_casing/caseless/arrow/toy/red
	name = "red toy arrow"
	desc = "A plastic arrow with a blunt tip covered in velcro to allow it to stick to whoever it hits. This one is made to resemble a red hardlight arrow."
	icon_state = "arrow_toy_red"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/toy/red


// Utility //

/obj/item/ammo_casing/caseless/arrow/bola
	bola = /obj/item/restraints/legcuffs/bola

/obj/item/ammo_casing/caseless/arrow/explosive
	explosive = /obj/item/grenade/iedcasing

/obj/item/ammo_casing/caseless/arrow/flaming/Initialize()
	..()
	add_flame()


// Hardlight //

/obj/item/ammo_casing/caseless/arrow/energy
	name = "energy bolt"
	desc = "An arrow made from hardlight."
	icon_state = "arrow_energy"
	item_flags = DROPDEL
	embedding = list("embedded_pain_chance" = 0, "embedded_pain_multiplier" = 0, "embedded_unsafe_removal_pain_multiplier" = 0, "embedded_pain_chance" = 0, "embedded_fall_chance" = 0)
	projectile_type = /obj/item/projectile/energy/arrow

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
	projectile_type = /obj/item/projectile/energy/arrow/disabler
	harmful = FALSE
	tick_damage_type = STAMINA
	
/obj/item/ammo_casing/caseless/arrow/energy/xray
	name = "X-ray bolt"
	desc = "An arrow made from hardlight. This one can pass through obstructions."
	icon_state = "arrow_xray"
	projectile_type = /obj/item/projectile/energy/arrow/xray
	tick_damage_type = TOX

/obj/item/ammo_casing/caseless/arrow/energy/clockbolt
	name = "redlight bolt"
	desc = "An arrow made from a strange energy."
	projectile_type = /obj/item/projectile/energy/arrow/clockbolt
