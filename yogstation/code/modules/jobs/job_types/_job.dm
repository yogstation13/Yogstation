/datum/job/proc/give_donor_stuff(mob/living/H, mob/M)
	var/client/C = M.client
	if(!C)
		C = H.client
		if(!C)
			return // nice

	if(!is_donator(C))
		return

	if(C.prefs.purrbation)
		purrbation_toggle(H)

	if(C.prefs.donor_hat)
		var/obj/item/storage/backpack/BP = locate(/obj/item/storage/backpack) in H.GetAllContents()
		if(BP)
			var/type = donor_start_items[C.prefs.donor_hat]
			var/obj/hat = new type()
			hat.forceMove(BP)

	if(C.prefs.donor_item)
		var/obj/item/storage/backpack/BP = locate(/obj/item/storage/backpack) in H.GetAllContents()
		if(BP)
			var/type = donor_start_tools[C.prefs.donor_item]
			var/obj/item = new type()
			H.put_in_hands(item)

	switch(C.prefs.donor_pda)
		if(2)//transparent
			var/obj/item/pda/PDA = locate(/obj/item/pda) in H.GetAllContents()
			if(PDA)
				PDA.icon = 'yogstation/icons/obj/pda.dmi'
				PDA.icon_state = "pda-clear"
		if(3)//pip-boy
			var/obj/item/pda/PDA = locate(/obj/item/pda) in H.GetAllContents()
			if(PDA)
				PDA.icon = 'yogstation/icons/obj/pda.dmi'
				PDA.icon_state = "pda-pipboy"
				PDA.slot_flags |= ITEM_SLOT_GLOVES
		if(4)//rainbow
			var/obj/item/pda/PDA = locate(/obj/item/pda) in H.GetAllContents()
			if(PDA)
				PDA.icon = 'yogstation/icons/obj/pda.dmi'
				PDA.icon_state = "pda-rainbow"
