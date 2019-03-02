/area
	var/atom/global_turf_object = null // for bluespace lockers

/area/metro/outside/process()
	for(var/mob/living/M in contents)
		if(istype(M.get_item_by_slot(SLOT_WEAR_MASK), /obj/item/clothing/mask/gas/metro))
			if(M.get_item_by_slot(SLOT_WEAR_MASK).CanBreathe())
				M.get_item_by_slot(SLOT_WEAR_MASK).Breathe(M)
			else
				M.adjustOxyLoss(rand(3,4))
				M.adjustToxLoss(rand(1,2))
		else
			M.adjustOxyLoss(rand(3,4))
			M.adjustToxLoss(rand(2,3))
