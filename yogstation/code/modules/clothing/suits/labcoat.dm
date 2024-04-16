//Mining Medic
/obj/item/clothing/suit/toggle/labcoat/emt/explorer
	name = "mining medic's jacket"
	desc = "A protective jacket for medical emergencies on off-world planets. Has MM embossed into it."
	armor = list(MELEE = 25, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 50, WOUND = 10)
	allowed = list(/obj/item/analyzer,/obj/item/multitool/tricorder,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_containers/dropper,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/autoinjector,/obj/item/healthanalyzer,/obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/pill,/obj/item/storage/pill_bottle,/obj/item/paper,/obj/item/melee/classic_baton/telescopic,/obj/item/soap,/obj/item/sensor_device,/obj/item/tank/internals, /obj/item/hypospray)

/obj/item/clothing/suit/toggle/labcoat/explorer
	name = "mining medic's labcoat"
	desc = "A protective labcoat for medical emergencies on off-world planets."
	armor = list(MELEE = 25, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 50, WOUND = 10)
	allowed = list(/obj/item/analyzer,/obj/item/multitool/tricorder,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_containers/dropper,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/autoinjector,/obj/item/healthanalyzer,/obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/pill,/obj/item/storage/pill_bottle,/obj/item/paper,/obj/item/melee/classic_baton/telescopic,/obj/item/soap,/obj/item/sensor_device,/obj/item/tank/internals, /obj/item/hypospray)
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon_state = "labcoat_mining"
	item_state = "labcoat_mining"

//Brig Physician
/obj/item/clothing/suit/toggle/labcoat/emt/physician
	name = "brig physician's jacket"
	desc = "A protective jacket for medical emergencies on off-world planets. Has BP embossed into it."
	icon_state = "labcoat_emtsec"

/obj/item/clothing/suit/toggle/labcoat/physician
	name = "brig physician's labcoat"
	desc = "A white labcoat with red medical crosses. Has BP embossed into it."
	icon_state = "labcoat_sec"
	item_state = "labcoat_sec"
