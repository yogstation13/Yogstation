/obj/item/clothing/head/fishingcap
	name = "fishing cap"
	desc = "damn"
	icon_state = "fishing_cap"
	item_state = "fishing_cap"
	alternate_worn_icon = 'yogstation/icons/mob/head.dmi'
	icon = 'yogstation/icons/obj/clothing/hats.dmi'

/obj/item/clothing/head/fishingcap/Initialize()
	. = ..()
	AddComponent(/datum/component/fishingbonus,5)


/obj/item/clothing/suit/fishingvest
	name = "fishing vest"
	desc = "damn"
	icon_state = "fishing_vest"
	item_state = "fishing_vest"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi' //idk why this isn't working

/obj/item/clothing/suit/fishingvest/Initialize()
	. = ..()
	AddComponent(/datum/component/fishingbonus,10)
