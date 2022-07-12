//Clerk
/obj/item/clothing/head/yogs/clerkcap
	name = "clerk's hat"
	desc = "It's a hat used by clerk's to help keep dust out of their eyes."
	icon_state = "clerkcap"
	item_state = "clerkcap"

//Mining Medic
/obj/item/clothing/head/soft/emt/mining
	name = "Mining Medic's cap"
	desc = "It's a baseball hat with a dark turquoise color and a reflective cross on the top. Has MM embossed into it."

//Brig Physician
/obj/item/clothing/head/soft/emt/phys
	name = "Brig Physician's cap"
	desc = "It's a baseball hat with a dark brown color and a reflective cross on the top. Has BP embossed into it."
	icon = 'yogstation/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'yogstation/icons/mob/clothing/head/head.dmi'
	icon_state = "emtsecsoft"
	soft_type = "emtsec"

/obj/item/clothing/head/beret/med/phys
	name = "Brig Physician's beret"
	desc = "A white beret with a red cross finely threaded into it. It has that sterile smell about it."
	icon_state = "beret_phys"

/obj/item/clothing/head/beret/corpsec/phys
	name = "corporate physician beret"
	desc = "A special black beret for the mundane life of a corporate brig physician."
	icon = 'yogstation/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'yogstation/icons/mob/clothing/head/head.dmi'
	icon_state = "beret_corporate_phys"
	armor = list(BIO = 20) //So it isnt a direct upgrade over the normal berret
