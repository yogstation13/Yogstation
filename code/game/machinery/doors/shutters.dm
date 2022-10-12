/obj/machinery/door/poddoor/shutters
	gender = PLURAL
	name = "shutters"
	desc = "Heavy duty metal shutters that open mechanically."
	icon = 'icons/obj/doors/shutters.dmi'
	layer = SHUTTER_LAYER
	closingLayer = SHUTTER_LAYER
	damage_deflection = 20
	armor = list(MELEE = 50, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 70)

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0
