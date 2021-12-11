//Shawls
/obj/item/clothing/neck/yogs/shawl
	name = "leather shawl"
	desc = "A leather shawl made to protect the wearer from the dangers of lavaland."
	icon_state = "leathershawl"
	item_state = "leathershawl"
	var/alticon_state = null
	var/altitem_state = null

/obj/item/clothing/neck/yogs/shawl/AltClick(mob/user)
	var/mob/living/carbon/human/human_user = null
	if(..())
		return 1

	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(istype(user, /mob/living/carbon/human))
		human_user = user
		if(human_user.wear_neck == src)
			to_chat(user, span_warning("You can't adjust [src] while wearing it!"))
			return
	if(alticon_state)
		toggle_alt(user)

/obj/item/clothing/neck/yogs/shawl/proc/toggle_alt(mob/user)
	if(!altitem_state)
		altitem_state = alticon_state
	if(icon_state == alticon_state)
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	else
		icon_state = alticon_state
		item_state = altitem_state

/obj/item/clothing/neck/yogs/shawl/examine(mob/user)
	. = ..()
	if(alticon_state)
		. += "[src] has a different design on the inside. You can wear it inside out with alt click."
		
//Head's Shawls - These are replacements for the old head cloaks. Leaving them here so I dont have to copy code over for the functionality.
/obj/item/clothing/neck/yogs/shawl/cap
	name = "captain's cloak"
	desc = "A hand crafted cloak made for the captain to protect them from the dangers of the station."
	icon_state = "capshawl"
	item_state = "capshawl"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/hop
	name = "head of personnel's cloak"
	desc = "A hand crafted cloak made for the head of personnel to protect them from the dangers of paperwork."
	icon_state = "hopshawl"
	item_state = "hopshawl"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/hos
	name = "head of security's cloak"
	desc = "A hand crafted cloak made for the head of security to protect them from the dangers of looking unrobust."
	icon_state = "hosshawl"
	item_state = "hosshawl"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/cmo
	name = "chief medical officer's cloak"
	desc = "A hand crafted cloak made for the chief medical officer to protect them from the dangers of the medicine."
	icon_state = "cmoshawl"
	item_state = "cmoshawl"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/ce
	name = "chief engineer's cloak"
	desc = "A hand crafted cloak made for the chief engineer to protect them from the dangers of the engineering."
	icon_state = "ceshawl"
	item_state = "ceshawl"
	resistance_flags = FIRE_PROOF
	alticon_state = "ceshawlalt" //Uses an orange shawl that I dint use originaly, gives a little diversity

/obj/item/clothing/neck/yogs/shawl/rd
	name = "research director's cloak"
	desc = "A hand crafted cloak made for the research director to protect them from the dangers of the science."
	icon_state = "rdshawl"
	item_state = "rdshawl"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/qm
	name = "quartermaster's cloak"
	desc = "A hand crafted cloak made for the quarter master to protect them from the dangers of lavaland."
	icon_state = "qmshawl"
	item_state = "qmshawl"
	resistance_flags = FIRE_PROOF
	alticon_state = "leathershawl" //I originaly made this icon for the QM's cloak before I noticed the curent one, this is for the people who prefer the old QM cloak
