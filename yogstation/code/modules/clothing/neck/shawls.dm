//Shawls
/obj/item/clothing/neck/yogs/shawl
	name = "leather shawl"
	desc = "A leather shawl made to protect the wearer from the dangers of lavaland."
	icon_state = "leathershawl"
	item_state = "leathershawl"
	actions_types = list(/datum/action/item_action/toggle_hood) //This doesnt work and I dont know why
	var/suittoggled = FALSE
	var/obj/item/clothing/head/yogs/shawl/hood
	var/hoodtype = /obj/item/clothing/head/yogs/shawl
	var/with_hood = "leathershawl" 
	var/without_hood = "leathershawl-hood"

/obj/item/clothing/neck/yogs/shawl/Initialize() //Most of this is copied from code\modules\clothing\suits\toggles.dm so the hoods can be toggled
	. = ..()
	MakeHood()

/obj/item/clothing/neck/yogs/shawl/Destroy()
	. = ..()
	qdel(hood)
	hood = null

/obj/item/clothing/neck/yogs/shawl/proc/MakeHood()
	if(!hood)
		var/obj/item/clothing/head/yogs/shawl/newhood = new hoodtype(src)
		newhood.shawl = src
		hood = newhood

/obj/item/clothing/neck/yogs/shawl/ui_action_click() //This doesnt work and I dont know why
	ToggleHood()

/obj/item/clothing/neck/yogs/shawl/item_action_slot_check(slot, mob/user)
	if(slot == SLOT_WEAR_SUIT)
		return 1

/obj/item/clothing/neck/yogs/shawl/equipped(mob/user, slot)
	if(slot != SLOT_WEAR_SUIT)
		RemoveHood()
	..()

/obj/item/clothing/neck/yogs/shawl/proc/RemoveHood()
	src.icon_state = with_hood
	suittoggled = FALSE
	if(ishuman(hood.loc))
		var/mob/living/carbon/H = hood.loc
		H.transferItemToLoc(hood, src, TRUE)
		H.update_inv_wear_suit()
	else
		hood.forceMove(src)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/neck/yogs/shawl/dropped()
	..()
	RemoveHood()

/obj/item/clothing/neck/yogs/shawl/proc/ToggleHood()
	if(suittoggled)
		RemoveHood()
		return		
	if(!ishuman(src.loc))
		return
	var/mob/living/carbon/human/wearer = src.loc
	if(wearer.wear_neck != src)
		to_chat(wearer, "<span class='warning'>You must be wearing [src] to put up the hood!</span>")
		return
	if(wearer.head)
		to_chat(wearer, "<span class='warning'>You're already wearing something on your head!</span>")
		return
	if(!wearer.equip_to_slot_if_possible(hood,SLOT_HEAD,0,0,1))
		return
	suittoggled = TRUE
	src.icon_state = without_hood
	wearer.update_inv_wear_suit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/neck/yogs/shawl/AltClick(mob/user)
	..()
	ToggleHood()

//Head's Shawls - These are replacements for the old head cloaks. Leaving them here so I dont have to copy code over for the functionality.
/obj/item/clothing/neck/yogs/shawl/cap
	name = "captain's cloak"
	desc = "A hand crafted cloak made for the captain to protect them from the dangers of the station."
	icon_state = "capshawl"
	item_state = "capshawl"
	with_hood = "capshawl"
	without_hood = "capshawl-hood"
	hoodtype = /obj/item/clothing/head/yogs/shawl/cap
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/hop
	name = "head of personnel's cloak"
	desc = "A hand crafted cloak made for the captain to protect them from the dangers of paperwork."
	icon_state = "hopshawl"
	item_state = "hopshawl"
	with_hood = "hopshawl"
	without_hood = "hopshawl-hood"
	hoodtype = /obj/item/clothing/head/yogs/shawl/hop
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/hos
	name = "head of security's cloak"
	desc = "A hand crafted cloak made for the head of security to protect them from the dangers of looking unrobust."
	icon_state = "hosshawl"
	item_state = "hosshawl"
	with_hood = "hosshawl"
	without_hood = "hosshawl-hood"
	hoodtype = /obj/item/clothing/head/yogs/shawl/hos
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/cmo
	name = "chief medical officer's cloak"
	desc = "A hand crafted cloak made for the chief medical officer to protect them from the dangers of the medicine."
	icon_state = "cmoshawl"
	item_state = "cmoshawl"
	with_hood = "cmoshawl"
	without_hood = "cmoshawl-hood"
	hoodtype = /obj/item/clothing/head/yogs/shawl/cmo
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/ce
	name = "chief engineer's cloak"
	desc = "A hand crafted cloak made for the chief engineer to protect them from the dangers of the engineering."
	icon_state = "ceshawl"
	item_state = "ceshawl"
	with_hood = "ceshawl"
	without_hood = "ceshawl-hood"
	hoodtype = /obj/item/clothing/head/yogs/shawl/ce
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/rd
	name = "research director's cloak"
	desc = "A hand crafted cloak made for the research director to protect them from the dangers of the science."
	icon_state = "rdshawl"
	item_state = "rdshawl"
	with_hood = "rdshawl"
	without_hood = "rdshawl-hood"
	hoodtype = /obj/item/clothing/head/yogs/shawl/rd
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/yogs/shawl/qm
	name = "quartermaster's cloak"
	desc = "A hand crafted cloak made for the quarter master to protect them from the dangers of lavaland."
	icon_state = "qmshawl"
	item_state = "qmshawl"
	with_hood = "qmshawl"
	without_hood = "qmshawl-hood"
	hoodtype = /obj/item/clothing/head/yogs/shawl/qm
	resistance_flags = FIRE_PROOF

//Hoods
/obj/item/clothing/head/yogs/shawl
	name = "leather shawl hood"
	desc = "A protectective hood from a leather shawl."
	icon_state = "leather-hood"
	item_state = "leather-hood"
	var/obj/item/clothing/neck/yogs/shawl/shawl = null
	flags_inv = HIDEEARS|HIDEHAIR

/obj/item/clothing/head/yogs/shawl/Destroy()
	shawl = null
	return ..()

/obj/item/clothing/head/yogs/shawl/dropped()
	..()
	if(shawl)
		shawl.RemoveHood()

/obj/item/clothing/head/yogs/shawl/equipped(mob/user, slot)
	..()
	if(slot == SLOT_HEAD)
		return
	if(shawl)
		shawl.RemoveHood()
	else
		qdel(src)

//Head's Shawls Hoods
/obj/item/clothing/head/yogs/shawl/cap
	name = "captain's cloak hood"
	desc = "A hood attached to the captain's hand crafted cloak."
	icon_state = "cap-hood"
	item_state = "cap-hood"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/yogs/shawl/hop
	name = "head of personnel's cloak hood"
	desc = "A hood attached to the head of personnel's hand crafted cloak."
	icon_state = "hop-hood"
	item_state = "hop-hood"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/yogs/shawl/hos
	name = "head of security's cloak hood"
	desc = "A hood attached to the head of security's hand crafted cloak."
	icon_state = "hos-hood"
	item_state = "hos-hood"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/yogs/shawl/cmo
	name = "chief medical officer's cloak hood"
	desc = "A hood attached to the chief medical officer's hand crafted cloak."
	icon_state = "cmo-hood"
	item_state = "cmo-hood"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/yogs/shawl/ce
	name = "chief engineer's cloak hood"
	desc = "A hood attached to the chief engineer's hand crafted cloak."
	icon_state = "ce-hood"
	item_state = "ce-hood"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/yogs/shawl/rd
	name = "research director's cloak hood"
	desc = "A hood attached to the research director's hand crafted cloak."
	icon_state = "rd-hood"
	item_state = "rd-hood"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/yogs/shawl/qm
	name = "quartermaster's cloak hood"
	desc = "A hood attached to the quartermaster's hand crafted cloak."
	icon_state = "qm-hood"
	item_state = "qm-hood"
	resistance_flags = FIRE_PROOF
