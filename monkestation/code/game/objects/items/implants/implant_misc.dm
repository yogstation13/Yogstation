/obj/item/implanter/weapons_auth
	name = "implanter (Weapons Authorization)"
	imp_type = /obj/item/implant/weapons_auth

/obj/item/storage/box/syndie_kit/weapons_auth
	name = "Weapons Authorization kit"

/obj/item/storage/box/syndie_kit/weapons_auth/PopulateContents()
	new /obj/item/implanter/weapons_auth(src)
