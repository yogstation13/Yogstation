/obj/item/aluminum_cylinder
	name = "aluminum cylinder"
	desc = "A soda can that has had the top and bottom cut out."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "cutoutcan"
	w_class = WEIGHT_CLASS_TINY

/obj/item/cylinder_assembly
	name = "cylinder assembly"
	desc = "Two aluminum cylinders stuck together. Doesn't look very secure."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "cutoutcan_assembly"

/obj/item/gun_barrel
	name = "barrel"
	desc = "A decently-sized strong metal tube."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "gun_barrel"

/obj/item/metal_gun_stock
	name = "gun stock"
	desc = "A metal gun stock. Not terribly comfortable."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "metal_stock"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/fuel_reservoir
	name = "fuel reservoir"
	desc = "A grenade casing with a hole poked through, allowing it to hold fuel."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "reservoir"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/metal_blade
	name = "metal blade"
	desc = "A simple blade made of sturdy metal."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "metal_blade"
	w_class = WEIGHT_CLASS_TINY

/obj/item/large_metal_blade
	name = "large metal blade"
	desc = "A large blade comprised of two smaller ones. Doesn't appear to be held together very well."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "large_metal_blade_assembly"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/rail_assembly
	name = "rail assembly"
	desc = "A set of metal rails."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "rail_assembly"

/obj/item/cylinder
	name = "beaker"
	desc = "A beaker. There appear to be six holes drilled through the bottom."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	w_class = WEIGHT_CLASS_TINY

//gun assemblies
/obj/item/gun_assembly //master gun assembly
	name = "gun assembly"
	desc = "It's a thing."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "stock_reservoir"

/obj/item/gun_assembly/stock_reservoir_assembly
	name = "general gun assembly"
	desc = "A metal gun stock. There is a fuel reservoir fastened to it."
	icon_state = "stock_reservoir"

/obj/item/gun_assembly/stock_reservoir_barrel_assembly
	name = "general barreled gun assembly"
	desc = "It looks like it could be some type of gun. The barrel is secured to the body."
	icon_state = "stock_reservoir_barrel_assembly"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun_assembly/blunderbuss_assembly
	name = "blunderbuss assembly"
	desc = "It looks like it could be some type of gun. The firing mechanism is tightly secured."
	icon_state = "blunderbuss_assembly"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun_assembly/railgun_assembly
	name = "railgun assembly"
	desc = "It looks like it could be some type of gun. The triggering mechanism is secured."
	icon_state = "railgun_assembly"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun_assembly/stock_pipe_assembly
	name = "pipe gun assembly"
	desc = "A metal gun stock. There is a bent pipe tightly fitted to it."
	icon_state = "stock_pipe_assembly"

/obj/item/gun_assembly/stock_ansible_amplifier_transmitter_assembly
	name = "subspace gun assembly"
	desc = "It looks like it could be some type of gun. The subspace transmitter affixed to the front of it is secured."
	icon_state = "stock_ansible_amplifier_transmitter_assembly"


//tomahawk
/obj/item/wrench_wired
	name = "wired wrench"
	desc = "A wrench with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "wrench"
	righthand_file = 'icons/mob/inhands/vg/vg_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/vg/vg_righthand.dmi'
	hitsound = "sound/weapons/smash.ogg"
	siemens_coefficient = 1
	force = 5.0
	throwforce = 7.0
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashes", "batters", "bludgeons", "whacks")

//Cannon
/obj/vehicle/ridden/wheelchair/wheelchair_assembly
	name = "wheelchair assembly"
	desc = "A wheelchair with a secured barrel on it."
	icon = 'icons/obj/vg_weaponsmithing.dmi'
	icon_state = "wheelchair_assembly"
	max_occupants = 0
	max_drivers = 0
