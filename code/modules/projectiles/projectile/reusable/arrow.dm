/obj/item/projectile/bullet/reusable/arrow //Base arrow. Good against fauna, not perfect, but well-rounded.
	name = "arrow"
	desc = "Woosh!"
	damage = 35
	armour_penetration = -25 //Melee armor tends to be much higher, so this hurts
	speed = 0.6
	flag = MELEE
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	var/embed_chance = 0.4
	var/break_chance = 0
	var/fauna_damage_bonus = 10

	var/list/attached_parts
	var/obj/item/grenade/explosive
	var/obj/item/restraints/legcuffs/bola/bola
	var/flaming = FALSE

/obj/item/projectile/bullet/reusable/arrow/on_hit(atom/target, blocked = FALSE)
	..()
	if(!isliving(target) || (blocked == 100))
		return

	if(iscarbon(target))
		if(flaming)
			var/mob/living/carbon/M = target
			M.adjust_fire_stacks(1)
			M.IgniteMob()
		if(istype(bola))
			return bola.impactCarbon(target)

	if(istype(bola) && isanimal(target))
		return bola.impactAnimal(target)
			
	var/mob/living/L = target
	if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
		L.apply_damage(fauna_damage_bonus)

/obj/item/projectile/bullet/reusable/arrow/handle_drop(atom/target)
	if(prob(break_chance))
		for(var/obj/item/part in attached_parts)
			if(!part.forceMove(part.drop_location()))
				qdel(part)
		return
	var/obj/item/dropping = new ammo_type()
	dropping.CheckParts(attached_parts)
	if(iscarbon(target))
		var/mob/living/carbon/embede = target
		var/obj/item/bodypart/part = embede.get_bodypart(def_zone)
		if(prob(embed_chance * clamp((100 - (embede.getarmor(part, flag) - armour_penetration)), 0, 100)) && embede.embed_object(dropping, part, TRUE))
			dropped = TRUE
	
	// Icky code, but i dont want to create a new obj, delete it, then make a new one
	if(!dropped)
		dropping.forceMove(get_turf(src))
		dropped = TRUE


// Arrow Subtypes //

/obj/item/projectile/bullet/reusable/arrow/wood
	name = "wooden arrow"
	desc = "A wooden arrow, quickly made."
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood

/obj/item/projectile/bullet/reusable/arrow/ash //Fire-tempered head makes it tougher; more damage, but less likely to embed
	name = "ashen arrow"
	desc = "A wooden arrow tempered by fire. It's tougher, but less likely to embed."
	damage = 40
	embed_chance = 0.3
	ammo_type = /obj/item/ammo_casing/caseless/arrow/ash

/obj/item/projectile/bullet/reusable/arrow/bone_tipped //A fully upgraded normal arrow; it's got the stats to show. Still less damage than a slug, resolving against melee, fired less often, slower, and with negative AP
	name = "bone-tipped arrow"
	desc = "An arrow made from bone, wood, and sinew. Sturdy and sharp."
	damage = 45
	armour_penetration = -10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone_tipped

/obj/item/projectile/bullet/reusable/arrow/bone //Cheap, easy to make in bulk but mostly used for hunting fauna
	name = "bone arrow"
	desc = "An arrow made from bone and sinew. Better at hunting fauna."
	damage = 25
	armour_penetration = -10 //So it's not as terrible against miners; still bad
	fauna_damage_bonus = 35 //Significantly better for hunting fauna, but you don't get to instantly recharge your shots
	embed_chance = 0.33
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone

/obj/item/projectile/bullet/reusable/arrow/chitin //Most expensive arrow time and resource-wise, simply because of ash resin. Should be good
	name = "chitin-tipped arrow"
	desc = "An arrow made from chitin, bone, and sinew. Incredibly potent at puncturing armor and hunting fauna."
	damage = 35
	armour_penetration = 30 //Basically an AP arrow
	fauna_damage_bonus = 40 //Even better, since they're that much harder to make
	ammo_type = /obj/item/ammo_casing/caseless/arrow/chitin

/obj/item/projectile/bullet/reusable/arrow/bamboo //Very brittle, very fragile, but very potent at splintering into targets assuming it isn't broken on impact
	name = "bamboo arrow"
	desc = "An arrow made from bamboo. Incredibly fragile and weak, but prone to shattering in unarmored targets."
	damage = 20
	armour_penetration = -40
	embed_chance = 0.6 //Reminder that this resolves against melee armor
	break_chance = 33 //Doesn't embed if it breaks
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bamboo

/obj/item/projectile/bullet/reusable/arrow/bronze //Bronze > iron, that's why they called it the bronze age
	name = "bronze arrow"
	desc = "An arrow tipped with bronze. Better against armor than iron."
	armour_penetration = -10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bronze

/obj/item/projectile/bullet/reusable/arrow/glass //Basically just a downgrade for people who can't get their hands on wood/cloth
	name = "glass arrow"
	desc = "A shoddy arrow with a broken glass shard as its tip. Can break upon impact."
	damage = 25
	embed_chance = 0.3
	break_chance = 10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/glass

/obj/item/projectile/bullet/reusable/arrow/glass/plasma //It's HARD to get plasmaglass shards without an axe, so this should be GOOD
	name = "plasmaglass arrow"
	desc = "An arrow with a plasmaglass shard affixed to its head. Incredibly capable of puncturing armor."
	damage = 25
	armour_penetration = 45 //18.75 damage against elite hardsuit assuming chest shot (and that's a long reload, draw, projectile speed, etc.)
	ammo_type = /obj/item/ammo_casing/caseless/arrow/glass/plasma


// Toy //

/obj/item/projectile/bullet/reusable/arrow/toy //Toy arrow with velcro tip that safely embeds into target
	name = "toy arrow"
	damage = 0
	embed_chance = 0.9
	break_chance = 0
	ammo_type = /obj/item/ammo_casing/caseless/arrow/toy

/obj/item/projectile/bullet/reusable/arrow/toy/blue
	name = "toy disabler bolt"
	icon_state = "arrow_disable"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/toy/blue

/obj/item/projectile/bullet/reusable/arrow/toy/red
	name = "toy energy bolt"
	icon_state = "arrow_energy"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/toy/red


// Hardlight //

/obj/item/projectile/energy/arrow //Hardlight projectile. Significantly more robust than a standard laser. Capable of hardening in target's flesh
	name = "energy bolt"
	icon_state = "arrow_energy"
	damage = 40
	wound_bonus = -60
	speed = 0.6
	var/embed_chance = 0.4
	var/obj/item/embed_type = /obj/item/ammo_casing/caseless/arrow/energy
	
/obj/item/projectile/energy/arrow/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/embede = target
		var/obj/item/bodypart/part = embede.get_bodypart(def_zone)
		if(prob(embed_chance * clamp((100 - (embede.getarmor(part, flag) - armour_penetration)), 0, 100)))
			embede.embed_object(new embed_type(), part, FALSE)
	return ..()

/obj/item/projectile/energy/arrow/disabler //Hardlight projectile. Much more draining than a standard disabler. Needs to be competitive in DPS
	name = "disabler bolt"
	icon_state = "arrow_disable"
	light_color = LIGHT_COLOR_BLUE
	damage = 50
	damage_type = STAMINA
	embed_type = /obj/item/ammo_casing/caseless/arrow/energy/disabler

/obj/item/projectile/energy/arrow/xray //Hardlight projectile. Weakened arrow capable of passing through material. Massive irradiation on hit.
	name = "X-ray bolt"
	icon_state = "arrow_xray"
	light_color = LIGHT_COLOR_GREEN
	damage = 30
	wound_bonus = -30
	irradiate = 500
	range = 20
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF
	embed_type = /obj/item/ammo_casing/caseless/arrow/energy/xray

/obj/item/projectile/energy/arrow/clockbolt
	name = "redlight bolt"
	damage = 18
	wound_bonus = 5
	embed_type = /obj/item/ammo_casing/caseless/arrow/energy/clockbolt
