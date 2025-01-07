//NEW TRAITOR SHOTGUN AMMO BOXES (WHAT YOU GET FROM THE UPLINK WHEN YOU BUY AMMO)
/obj/item/storage/box/trickshot
	name = "box of trickshot shells"
	desc = "A box full of illegal trickshot shells, made for the sharpest of shooters."
	icon = 'monkestation/icons/obj/storage/boxes.dmi'
	icon_state = "trickshot_box"
	illustration = null

/obj/item/storage/box/trickshot/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/trickshot(src)

/obj/item/storage/box/uraniumpen
	name = "box of depleted uranium penetrators"
	desc = "A box full of illegal depleted uranium penetrators, not radioactive, but strong enough to punch through walls."
	icon = 'monkestation/icons/obj/storage/boxes.dmi'
	icon_state = "depleteduranium_box"
	illustration = null

/obj/item/storage/box/uraniumpen/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/uraniumpen(src)

/obj/item/storage/box/beeshot
	name = "box of beeshot"
	desc = "A box full of illegal bee like shells. You swear you can hear buzzing inside of the box."
	icon = 'monkestation/icons/obj/storage/boxes.dmi'
	icon_state = "beeshot_box"
	illustration = null

/obj/item/storage/box/beeshot/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/beeshot(src)
