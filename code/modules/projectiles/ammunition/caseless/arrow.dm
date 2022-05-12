/obj/item/ammo_casing/caseless/arrow
	name = "arrow of questionable material"
	desc = "You shouldnt be seeing this arrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon_state = "arrow"
	throwforce = 3 //good luck hitting someone with the pointy end of the arrow
	throw_speed = 3

/obj/item/ammo_casing/caseless/arrow/wood
	name = "wooden arrow"
	desc = "An arrow made of wood, typically fired from a bow."

/obj/item/ammo_casing/caseless/arrow/ash
	name = "ashen arrow"
	desc = "An arrow made from wood, hardened by fire"
	icon_state = "ashenarrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/ash

/obj/item/ammo_casing/caseless/arrow/bone
	name = "bone arrow"
	desc = "An arrow made of bone and sinew. The tip is sharp enough to pierce goliath hide."
	icon_state = "bonearrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone

/obj/item/ammo_casing/caseless/arrow/bronze
	name = "bronze arrow"
	desc = "An arrow made from wood. tipped with bronze."
	icon_state = "bronzearrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bronze

/obj/item/ammo_casing/caseless/arrow/bola
	name = "bola arrow"
	desc = "An arrow made from wood, with a bola wrapped around it."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bola

/obj/item/ammo_casing/caseless/arrow/bola/Initialize()
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

	var/obj/item/restraints/legcuffs/bola/bola = locate(/obj/item/restraints/legcuffs/bola) in contents
	var/obj/item/projectile/bullet/reusable/arrow/bola/bola_arrow = BB
	if(!istype(bola))
		bola = new(src)
	if(istype(bola) && istype(bola_arrow))
		bola_arrow.bola = bola
	
	add_overlay(mutable_appearance(icon, "arrow_bola"), TRUE)

/obj/item/ammo_casing/caseless/arrow/explosive
	name = "explosive arrow"
	desc = "An arrow made from wood. An explosive is attached to it."
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
		var/obj/item/projectile/bullet/reusable/AA = A.BB
		var/obj/item/projectile/bullet/reusable/BBB = BB
		if(istype(AA) && istype(BBB))
			BBB.damage = AA.damage * 0.5
			BBB.armour_penetration = AA.armour_penetration * 0.5
			BBB.ammo_type = AA.ammo_type
	
	add_overlay(mutable_appearance(icon, "arrow_fire"), TRUE)

// Energy Arrows //

/obj/item/ammo_casing/caseless/arrow/energy
	name = "energy bolt"
	desc = "A hardlight arrow."
	icon_state = "arrow_energy"
	projectile_type = /obj/item/projectile/energy/arrow
	var/overlay_state = "redlight"

/obj/item/ammo_casing/caseless/arrow/energy/disabler
	name = "disabler bolt"
	desc = "A modified hardlight arrow. This one stuns the victim non-lethally."
	icon_state = "arrow_disable"
	overlay_state = "disable"
	projectile_type = /obj/item/projectile/energy/arrow/disabler

/obj/item/ammo_casing/caseless/arrow/energy/pulse
	name = "pulse bolt"
	desc = "A modified hardlight arrow. This one is extremely powerful, and can destroy most obstructions in a single shot."
	icon_state = "arrow_pulse"
	overlay_state = "pulse"
	projectile_type = /obj/item/projectile/energy/arrow/pulse

/obj/item/ammo_casing/caseless/arrow/energy/xray
	name = "X-ray bolt"
	desc = "A modified hardlight arrow. This one can pass right through obstructions."
	icon_state = "arrow_xray"
	overlay_state = "xray"
	projectile_type = /obj/item/projectile/energy/arrow/xray

/obj/item/ammo_casing/caseless/arrow/energy/clockbolt
	name = "redlight bolt"
	desc = "An arrow made from a strange energy."
	projectile_type = /obj/item/projectile/energy/arrow/clockbolt
