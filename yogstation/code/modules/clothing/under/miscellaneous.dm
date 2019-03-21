/obj/item/clothing/under/rank/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	item_state = "rainbow"
	item_color = "psyche"

/obj/item/clothing/under/yogs/scaryclown
	name = "scary clown suit"
	desc = "Clown suit often seen being worn by sewer clowns."
	icon_state = "scaryclownuniform"
	item_state = "scaryclownuniform"
	item_color = "scaryclownuniform"

/obj/item/clothing/under/rank/yogs/scaryclown/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, /datum/outputs/bikehorn, 50)