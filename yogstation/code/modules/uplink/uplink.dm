/datum/component/uplink/MakePurchase(mob/user, datum/uplink_item/U)
	if(U.hijack_only)
		if(!(locate(/datum/objective/hijack) in user.mind.objectives))
			to_chat(usr, "<span class='warning'>The Syndicate lacks resources to provide you with this item.</span>")
			return
	..()