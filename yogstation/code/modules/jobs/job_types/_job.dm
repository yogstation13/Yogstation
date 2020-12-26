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
			var/type = C.prefs.donor_hat
			if(type)
				var/obj/hat = new type()
				hat.forceMove(BP)

	if(C.prefs.donor_item)
		var/obj/item/storage/backpack/BP = locate(/obj/item/storage/backpack) in H.GetAllContents()
		if(BP)
			var/type = C.prefs.donor_item
			if(type)
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

/datum/job/proc/give_cape(mob/living/H, mob/M)
	var/client/C = M.client
	if(!C)
		C = H.client
		if(!C)
			return
	var/S = C.prefs.skillcape
	if(S != 1)
		var/datum/skillcape/A = GLOB.skillcapes[S]
		var/type = A.path
		var/obj/item/clothing/neck/skillcape/B = new type(get_turf(H))
		if(!H.equip_to_appropriate_slot(B))
			H.put_in_hands(B)

/datum/job/proc/give_map_flare(mob/living/H, mob/M)
	var/client/C = M.client
	if(!C)
		C = H.client
		if(!C)
			return
	var/SM = C.prefs.map
	var/F = C.prefs.flare
	var/obj/item/storage/backpack/BP = locate(/obj/item/storage/backpack) in H.GetAllContents()
	if(BP)
		var/obj/item/storage/box/box = locate(/obj/item/storage/box) in BP
		if(SM == 1)
			var/obj/item/map/station/map = new get_turf(H)
			if(box)
				map.forceMove(box)
			else
				map.forceMove(BP)
		if(F == 1)
			var/obj/item/flashlight/flare/emergency/flare = new get_turf(H)
			if(box)
				flare.forceMove(box)
			else
				flare.forceMove(BP)