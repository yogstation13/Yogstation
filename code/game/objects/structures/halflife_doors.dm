/obj/structure/mineral_door/halflife/wood
	name = "wood door"
	icon_state = "wood"
	openSound = 'sound/effects/doorcreaky.ogg'
	closeSound = 'sound/effects/doorcreaky.ogg'
	sheetType = /obj/item/stack/sheet/mineral/wood
	resistance_flags = FLAMMABLE
	max_integrity = 200
	rad_insulation = RAD_VERY_LIGHT_INSULATION

/obj/structure/mineral_door/halflife/wood/pickaxe_door(mob/living/user, obj/item/I)
	return

/obj/structure/mineral_door/halflife/wood/welder_act(mob/living/user, obj/item/I)
	return

/obj/structure/mineral_door/halflife/wood/crowbar_act(mob/living/user, obj/item/I)
	return crowbar_door(user, I)

/obj/structure/mineral_door/halflife/metal
	name = "metal door"
