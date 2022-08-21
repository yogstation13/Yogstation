//Mining Medic
/obj/item/clothing/suit/toggle/labcoat/emt/explorer
	name = "mining medics jacket"
	desc = "A protective jacket for medical emergencies on off-world planets. Has MM embossed into it."
	armor = list(melee = 10, bullet = 10, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0, fire = 50, acid = 50)
	allowed = list(/obj/item/analyzer,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_containers/dropper,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/autoinjector,/obj/item/healthanalyzer,/obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/pill,/obj/item/storage/pill_bottle,/obj/item/paper,/obj/item/melee/classic_baton/telescopic,/obj/item/soap,/obj/item/sensor_device,/obj/item/tank/internals)

//Brig Physician
/obj/item/clothing/suit/toggle/labcoat/emt/physician
	name = "brig physicians jacket"
	desc = "A protective jacket for medical emergencies on off-world planets. Has BP embossed into it."
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "labcoat_emtsec"

/obj/item/clothing/suit/toggle/labcoat/physician
	name = "brig physician's labcoat"
	desc = "A white labcoat with red medical crosses. Has BP embossed into it."
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "labcoat_sec"
	item_state = "labcoat_sec"
