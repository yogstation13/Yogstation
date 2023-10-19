/obj/structure/sign/poster/official/firstsingularity
	name = "The First Singularity"
	desc = "The first ever picture of a singularity, dating all the way back to 2019. Looking at it makes you feel proud of how far we have come."
	icon_state = "poster36_legit"

/obj/item/poster/firstsingularity
	name = "first singularity poster"
	poster_type = /obj/structure/sign/poster/official/firstsingularity
	icon_state = "rolled_legit"

/obj/structure/sign/poster/official/neverforget
    name = "24605"
    desc = "The longer you look at this poster the more heat it gives off, almost as if it were a real star."
    icon_state = "24605"

/obj/item/poster/neverforget
    name = "24605"
    desc = "This looks almost hot to the touch! Maybe you should just put it on the wall."
    poster_type = /obj/structure/sign/poster/official/neverforget
    icon_state = "rolled_legit"

/obj/structure/sign/poster/contraband/gorlex
	name = "Gorlex Marauders"
	desc = "This poster shows a member of the Gorlex Marauders brandishing an implanted blade while wearing one of their feared combat hardsuits."
	icon_state = "gorlex"

/obj/item/poster/gorlex
	name = "gorlex mauraders poster"
	desc = "This poster shows a member of the Gorlex Marauders brandishing an implanted blade while wearing one of their feared combat hardsuits."
	poster_type = /obj/structure/sign/poster/contraband/gorlex
	icon_state = "rolled_poster"

/obj/structure/sign/poster/contraband/pro_self // 100110111011
	name = "Version One"
	desc = "A poster showing an IPC calling for synthetics to rise up and fight for their freedom."
	icon_state = "pro_self"

/obj/item/poster/pro_self
	name = "pro-S.E.L.F poster"
	desc = "A poster showing an IPC calling for synthetics to rise up and fight for their freedom."
	poster_type = /obj/structure/sign/poster/contraband/pro_self
	icon_state = "rolled_poster"

/obj/structure/sign/poster/official/anti_self
	name = "S.E.L.F"
	desc = "A poster warning the crew about a terrorist organization called S.E.L.F, with a picture of its founder."
	icon_state = "anti_self"

/obj/item/poster/anti_self
	name = "anti-S.E.L.F poster"
	desc = "A poster warning the crew about a terrorist organization called S.E.L.F, with a picture of its founder."
	poster_type = /obj/structure/sign/poster/official/anti_self
	icon_state = "rolled_legit"

/obj/structure/sign/poster/official/sey_gax
	name = "SEY GAX"
	desc = "A recruitment poster for the GAX project. You can't discern the meaning. Request a transfer to the NVS Gax at your local HOP station!"
	icon_state = "sey_gax"

/obj/structure/sign/poster/official/sey_gax/Initialize(mapload)
	. = ..()
	if(SSmapping.config.map_name == "NVS Gax") //we're here!!!
		desc = "A recruitment poster for the GAX project. You can't discern the meaning. Wait, aren't we on the NVS Gax?"

/obj/item/poster/sey_gax
	name = "sey gax poster"
	desc = "A poster depicting an abstract call to the NVS Gax. You wouldn't get it."
	poster_type = /obj/structure/sign/poster/official/sey_gax
	icon_state = "rolled_legit"

/obj/structure/sign/poster/official/help
	name = "Call it out!"
	desc = "An instructional poster telling you to report any witnessed injuries to medical personnel. The picture used seems to remind you of something."
	icon_state = "help"

/obj/item/poster/help
	name = "\"call it out\" poster"
	desc = "A poster depicting instructions to report any injuries."
	poster_type = /obj/structure/sign/poster/official/help
	icon_state = "rolled_legit"
