/obj/structure/flora/tree/dead/jungle
	icon = 'icons/obj/flora/deadtrees.dmi'
	desc = "A dead tree. How it died, you know not."
	icon_state = "nwtree_1"

/obj/structure/flora/tree/dead/jungle/Initialize()
	. = ..()
	icon_state = "nwtree_[rand(1, 6)]"

/obj/structure/herb
	name = "generic herb"
	desc = "generic herb of some origin"
	icon = 'yogstation/icons/obj/jungle.dmi'
	var/herb_index = 0
	var/identification_response = list(TRUE = list("yeah this some herb right there"), FALSE = list("dunno looks like a fucking plant to me"))

/obj/structure/herb/examine(mob/user)
	. = ..()
	icon_state = "herb"
	var/selection = HAS_TRAIT_FROM(user,get_trait(),JUNGLELAND_TRAIT)
	. += pick(identification_response[selection])

/obj/structure/herb/proc/get_trait()
	return TRAIT_HERB_IDENTIFIED + "_[name]"
