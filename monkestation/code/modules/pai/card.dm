/obj/item/pai_card/examine(mob/user)
	. = ..()
	. += span_notice("<i>There's a sticker on the back. You can look again to take a closer look...</i>")

/obj/item/pai_card/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You examine [src] closer, and note the following...</i>")
	. += "\"Nanotrasen silicon units are incompatible with magic of any form, including but not limited to: Heretical runes, wizard spells, and blood summonings. Nanotrasen takes no responsibility for any damage that may occur to the device as a result of trying to combine Nanotrasen silicon and magic.\""
