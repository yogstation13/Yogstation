/obj/item/clothing/head/fishing
	name = "fishing cap"
	desc = "She said she's down to fish!"
	icon_state = "fishing_cap"
	item_state = "fishing_cap"
	alternate_worn_icon = 'yogstation/icons/mob/head.dmi'
	icon = 'yogstation/icons/obj/clothing/hats.dmi'

/obj/item/clothing/head/fishing/Initialize()
	. = ..()
	AddComponent(/datum/component/fishingbonus,5)

/obj/item/clothing/suit/fishing
	name = "fishing vest"
	desc = "As she banging my line, she wastin my time."
	icon_state = "fishing_vest"
	item_state = "fishing_vest"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'

/obj/item/clothing/suit/fishing/Initialize()
	. = ..()
	AddComponent(/datum/component/fishingbonus,10)

/obj/item/clothing/gloves/fishing
	name = "fishing gloves"
	desc = "Packin my tackle box down by the brook."
	icon_state = "fishing_gloves"
	item_state = "fishing_gloves"
	alternate_worn_icon = 'yogstation/icons/mob/hands.dmi'
	icon = 'yogstation/icons/obj/clothing/gloves.dmi'

/obj/item/clothing/gloves/fishing/Initialize()
	. = ..()
	AddComponent(/datum/component/fishingbonus,5)

/obj/item/clothing/shoes/fishing
	name = "fishing sandals"
	desc = "We livin' the life, if we ain't going fishing then don't waste my time."
	icon_state = "fishing_sandals"
	item_state = "fishing_sandals"
	alternate_worn_icon = 'yogstation/icons/mob/feet.dmi'
	icon = 'yogstation/icons/obj/clothing/shoes.dmi'

/obj/item/clothing/shoes/fishing/Initialize()
	. = ..()
	AddComponent(/datum/component/fishingbonus,5)
