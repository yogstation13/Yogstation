
/obj/item/disk/tech_disk
	name = "technology disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk0"
	materials = list(MAT_METAL=300, MAT_GLASS=100)
	var/datum/techweb/stored_research

/obj/item/disk/tech_disk/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	stored_research = new /datum/techweb

/obj/item/disk/tech_disk/debug
	name = "\improper CentCom technology disk"
	desc = "A debug item for research"
	materials = list()

/obj/item/disk/tech_disk/debug/Initialize()
	. = ..()
	stored_research = new /datum/techweb/admin

/obj/item/disk/tech_disk/major
	name = "Reformatted technology disk"
	desc = "A disk containing a new, completed tech from the B.E.P.I.S. Upload the disk to an R&D Console to redeem the tech."
	icon_state = "rndmajordisk"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)

/obj/item/disk/tech_disk/major/Initialize()
	. = ..()
	stored_research = new /datum/techweb/bepis
