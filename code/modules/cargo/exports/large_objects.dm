/datum/export/large/crate
	cost = 30
	unit_name = "crate"
	export_types = list(/obj/structure/closet/crate)
	exclude_types = list(/obj/structure/closet/crate/large, /obj/structure/closet/crate/wooden, /obj/structure/closet/crate/mail, /obj/structure/closet/crate/coffin, /obj/structure/closet/crate/secure/cheap, /obj/structure/closet/crate/secure/owned/cheap)

/datum/export/large/crate/total_printout(datum/export_report/ex, notes = TRUE) // That's why a goddamn metal crate costs that much.
	. = ..()
	if(. && notes)
		. += " Thanks for participating in Nanotrasen Crates Recycling Program."

/datum/export/large/crate/cheap
	cost = 20
	export_types = list(/obj/structure/closet/crate/secure/cheap, /obj/structure/closet/crate/secure/owned/cheap)
	exclude_types = list()
