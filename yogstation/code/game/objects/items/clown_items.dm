/obj/item/soap/infinite
	desc = "A heavy duty bar of Nanotrasen brand soap. Smells of plasma."
	grind_results = list(/datum/reagent/toxin/plasma = 10, /datum/reagent/lye = 10)
	icon_state = "soapnt"
	cleanspeed = 28
	uses = INFINITY

/obj/item/bikehorn/rubber_pigeon
	name = "Rubber Pigeon"
	desc = "Rubber chickens are so 2316."
	lefthand_file = 'yogstation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/righthand.dmi'
	icon = 'yogstation/icons/obj/items.dmi'
	icon_state = "rubber_pigeon"
	item_state = "rubber_pigeon"
	attack_verb = list("Pigeoned")

/obj/item/bikehorn/rubber_pigeon/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('yogstation/sound/items/rubber_pigeon.ogg'=1), 50)
