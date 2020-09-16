/obj/item/gun/energy/laser
	name = "laser gun"
	desc = "A basic energy-based laser gun that fires concentrated beams of light which pass through glass and thin metal."
	icon_state = "laser"
	item_state = "laser"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=2000)
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	ammo_x_offset = 1
	shaded_charge = 1

/obj/item/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0
	item_flags = NONE

/obj/item/gun/energy/laser/retro
	name ="retro laser gun"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	ammo_x_offset = 3

/obj/item/gun/energy/laser/retro/old
	name ="laser gun"
	icon_state = "retro"
	desc = "First generation lasergun, developed by Nanotrasen. Suffers from ammo issues but its unique ability to recharge its ammo without the need of a magazine helps compensate. You really hope someone has developed a better lasergun while you were in cryo."
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/old)
	ammo_x_offset = 3

/obj/item/gun/energy/laser/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	item_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	ammo_x_offset = 3
	selfcharge = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/gun/energy/laser/captain/scattershot
	name = "scatter shot laser rifle"
	icon_state = "lasercannon"
	item_state = "laser"
	desc = "An industrial-grade heavy-duty laser rifle with a modified laser lens to scatter its shot into multiple smaller lasers. The inner-core can self-charge for theoretically infinite use."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/laser/cyborg
	can_charge = FALSE
	desc = "An energy-based laser gun that self charges. So this is what freedom looks like?"
	charge_delay = 5
	selfcharge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser/cyborg)

/obj/item/gun/energy/laser/cyborg/emp_act()
	return

/obj/item/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/laser/scatter/shotty
	name = "energy shotgun"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "cshotgun"
	item_state = "shotgun"
	desc = "A combat shotgun gutted and refitted with an internal disabler system."
	shaded_charge = 0
	pin = /obj/item/firing_pin/implant/mindshield
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter/disabler)

///Laser Cannon

/obj/item/gun/energy/lasercannon
	name = "accelerator laser cannon"
	desc = "An advanced laser cannon that does more damage the farther away the target is."
	icon_state = "lasercannon"
	item_state = "laser"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/accelerator)
	pin = null
	ammo_x_offset = 3

/obj/item/ammo_casing/energy/laser/accelerator
	projectile_type = /obj/item/projectile/beam/laser/accelerator
	select_name = "accelerator"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/projectile/beam/laser/accelerator
	name = "accelerator laser"
	icon_state = "scatterlaser"
	range = 255
	damage = 6

/obj/item/projectile/beam/laser/accelerator/Range()
	..()
	damage += 7
	transform *= 1 + ((damage/7) * 0.2)//20% larger per tile

/obj/item/gun/energy/xray
	name = "\improper X-ray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated X-ray blasts that pass through multiple soft targets and heavier materials."
	icon_state = "xray"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/xray)
	pin = null
	ammo_x_offset = 3

////////Laser Tag////////////////////

/obj/item/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "A retro laser gun modified to fire harmless blue beams of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/blue
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/bluetag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag/hitscan)

/obj/item/gun/energy/laser/redtag
	name = "laser tag gun"
	icon_state = "redtag"
	desc = "A retro laser gun modified to fire harmless beams red of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/red
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/redtag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag/hitscan)
	
/obj/item/gun/energy/laser/makeshiftlasrifle
	name = "makeshift laser rifle"
	desc = "A makeshift rifle that shoots lasers. Lacks factory precision, but the screwable bulb allows modulating the photonic output."
	icon_state = "lasrifle"
	item_state = "makeshiftlas"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = list(/obj/item/ammo_casing/energy/laser/makeshiftlasrifle, /obj/item/ammo_casing/energy/laser/makeshiftlasrifle/weak)
	icon = 'icons/obj/guns/energy.dmi'
	can_charge = TRUE
	charge_sections = 1
	ammo_x_offset = 2
	shaded_charge = FALSE //if this gun uses a stateful charge bar for more detail

/obj/item/ammo_casing/energy/laser/makeshiftlasrifle
	e_cost = 1000 //The amount of energy a cell needs to expend to create this shot.
	projectile_type = /obj/item/projectile/beam/laser/makeshiftlasrifle
	select_name = "strong"
	variance = 2

/obj/item/projectile/beam/laser/makeshiftlasrifle
	damage = 17

/obj/item/ammo_casing/energy/laser/makeshiftlasrifle/weak
	e_cost = 100 //The amount of energy a cell needs to expend to create this shot.
	projectile_type = /obj/item/projectile/beam/laser/makeshiftlasrifle/weak
	select_name = "weak"
	fire_sound = 'sound/weapons/laser2.ogg'

/obj/item/projectile/beam/laser/makeshiftlasrifle/weak
	name = "weak laser"
	damage = 5 

/obj/item/gun/energy/watcherprojector
	name = "watcher projector"
	desc = "A spiny, gruesome tool which reproduces the icy beam of a watcher, shattering rock and freezing individuals."
	icon_state = "watcherprojector"
	icon = 'icons/obj/guns/energy.dmi'
	item_state = "watcherprojector"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/watcher)
	attack_verb = list("bashed", "stared down", "whacked", "smashed")
	force = 10
	can_charge = 0
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/energy/watcherprojector/examine(mob/user)
	. = ..()
	if(cell)
		. +="<span class='notice'>[src]'s diamond core is [round(cell.percent())]% energized.</span>"

/obj/item/gun/energy/watcherprojector/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sheet/mineral/plasma))
		I.use(1)
		cell.give(cell.maxcharge)
		to_chat(user, "<span class='notice'>You feed [I] to [src], recharging it.</span>")
	else if(istype(I, /obj/item/stack/ore/plasma))
		I.use(1)
		cell.give(cell.maxcharge/2)
		to_chat(user, "<span class='notice'>You feed [I] to [src], recharging it.</span>")
	else
		..()

/obj/item/gun/energy/watcherprojector/use(amount)
	return cell.use(amount * 100)

/obj/item/gun/energy/watcherprojector/update_icon()
	return

/obj/item/ammo_casing/energy/plasma/watcher
	projectile_type = /obj/item/projectile/plasma/watcher
	select_name = "freezing blast shot"
	fire_sound = 'sound/weapons/pierce.ogg'
	delay = 15
	e_cost = 250 //four shots before running out

/obj/item/projectile/plasma/watcher
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	flag = "energy"
	damage_type = BURN
	range = 4 //terrible range
	mine_range = 4 //serves as a mining tool... a rather shit one
	var/temperature = 50 //half what a normal watcher does
	dismemberment = FALSE

/obj/item/projectile/plasma/watcher/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.adjust_bodytemperature(((100-blocked)/100)*(temperature - L.bodytemperature)) // the new body temperature is adjusted by 100-blocked % of the delta between body temperature and the bullet's effect temperature

/obj/item/gun/energy/pumpaction/musket
	name = "laser musket"
	desc = "Another settlment needs your help."
	icon = 'icons/obj/guns/lasermusket.dmi'
	icon_state = "musket"
	item_state = "musket"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	shaded_charge = FALSE
	w_class = WEIGHT_CLASS_BULKY
	cell_type = /obj/item/stock_parts/cell/pumpaction/musket
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/disabler)
	obj_flags = UNIQUE_RENAME
	fire_delay = 10
	spread = 7.5
	recoil = 1

/obj/item/stock_parts/cell/pumpaction/musket
	name = "laser musket internal cell"
	maxcharge = 800 //20 disabler shots or 8 lethal shots... not too incredible
