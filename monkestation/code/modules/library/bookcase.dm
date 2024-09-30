/obj/structure/bookcase/manuals/botany
	name = "botany manuals bookcase"

/obj/structure/bookcase/manuals/botany/Initialize(mapload)
	. = ..()
	for(var/i = 1 to /datum/job/botanist::total_positions)
		new /obj/item/book/manual/botanical_lexicon(src)
		new /obj/item/book/manual/chicken_encyclopedia(src)
		new /obj/item/book/manual/hydroponics_pod_people(src)
	update_appearance()
