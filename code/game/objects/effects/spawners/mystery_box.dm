/obj/structure/closet/crate/mystery_box
	name = "Supply Crate"
	icon_state = "trashcart"
	color = "#644a11"
	var/guncost = 950
	var/list/gunlist = list()

/obj/structure/closet/crate/mystery_box/Initialize(mapload)
	. = ..()
	gunlist |= subtypesof(/obj/item/gun) //huge fucking list, don't spawn too many of these @hisa

/obj/structure/closet/crate/mystery_box/open(mob/living/user)
	if(opened || !can_open(user) || !ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard()
	if(!id_card)
		H.balloon_alert(H, "Need an id card")
		return
	if(!id_card.registered_account)
		H.balloon_alert(H, "Need a bank account")
		return
	if(!id_card.registered_account.account_balance < guncost)
		H.balloon_alert(H, "Not enough money")
		return

	id_card.registered_account.account_balance -= guncost
	var/gunpath = pick(gunlist)
	new gunpath(src)

	playsound(loc, open_sound, 15, 1, -3)
	opened = TRUE
	dump_contents()
	animate_door(FALSE)
	update_appearance(UPDATE_ICON)
	update_airtightness()

	addtimer(CALLBACK(src, PROC_REF(userless_close)), 5 SECONDS, TIMER_UNIQUE)
	
//can't close
/obj/structure/closet/crate/mystery_box/close(mob/living/user)
	return FALSE

/obj/structure/closet/crate/mystery_box/proc/userless_close()
	playsound(loc, close_sound, 15, 1, -3)
	opened = FALSE
	density = TRUE
	animate_door(TRUE)
	update_appearance(UPDATE_ICON)
	update_airtightness()
