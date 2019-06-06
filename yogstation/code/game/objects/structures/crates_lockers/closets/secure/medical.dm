/obj/structure/closet/secure_closet/paramedic
	name = "paramedical closet"
	desc = "It's a secure storage unit for paramedical supplies."
	icon = 'yogstation/icons/obj/closet.dmi'
	icon_state = "paramed"
	req_access = list(ACCESS_PARAMEDIC)

/obj/structure/closet/secure_closet/paramedic/PopulateContents()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel/med(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	switch(pick("blue", "green", "purple"))
		if ("blue")
			new /obj/item/clothing/under/rank/medical/blue(src)
		if ("green")
			new /obj/item/clothing/under/rank/medical/green(src)
		if ("purple")
			new /obj/item/clothing/under/rank/medical/purple(src)
	switch(pick("blue", "green", "purple"))
		if ("blue")
			new /obj/item/clothing/under/rank/medical/blue(src)
		if ("green")
			new /obj/item/clothing/under/rank/medical/green(src)
		if ("purple")
			new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/suit/toggle/labcoat/emt(src)
	new /obj/item/clothing/head/soft/emt(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/storage/belt/medical(src)

/obj/structure/closet/secure_closet/mmedical
	name = "mining medic's locker"
	req_access = list(ACCESS_MEDICAL)
	icon = 'yogstation/icons/obj/closet.dmi'
	icon_state = "medic"

/obj/structure/closet/secure_closet/mmedical/PopulateContents()
	..()
	new /obj/item/reagent_containers/hypospray/mixi(src)
	new /obj/item/reagent_containers/hypospray/derm(src)
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel/med(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/clothing/suit/toggle/labcoat/emt/explorer(src)
	new /obj/item/clothing/under/yogs/rank/miner/medic(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/cartridge/medical(src)
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/storage/firstaid/toxin(src)
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/pickaxe(src)
	new /obj/item/sensor_device(src)
	new /obj/item/storage/box/bodybags(src)
	new /obj/item/extinguisher/mini(src)
	new /obj/item/clothing/glasses/hud/health(src)
	var/obj/item/key/K = new(src)
	K.name = "ATV key"
	K.desc = "It's a small grey key. Don't let those goddamn ashwalkers get it."