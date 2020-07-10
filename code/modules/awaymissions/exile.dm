
/obj/structure/closet/secure_closet/exile
	name = "exile implants"
	req_access = list(ACCESS_HOS)

/obj/structure/closet/secure_closet/exile/PopulateContents()
	new /obj/item/implanter/exile(src)
	for(var/i in TRUE to 5)
		new /obj/item/implantcase/exile(src)
