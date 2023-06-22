/datum/component/swimming/felinid/enter_pool()
	var/mob/living/L = parent
	L.emote("scream")
	to_chat(parent, "<span class='userdanger'>You get covered in water and start panicking!</span>")

/datum/component/swimming/felinid/process()
	..()
	var/mob/living/L = parent
	var/obj/item/pool/helditem = L.get_active_held_item()
	if(istype(helditem) && HAS_TRAIT(helditem, TRAIT_WIELDED))
		return
	switch(rand(1, 100))
		if(1 to 4)
			to_chat(parent, "<span class='userdanger'>You can't touch the bottom!</span>")
			L.emote("scream")
		if(5 to 7)
			L.adjust_confusion_up_to(1 SECONDS, 5 SECONDS)
		if(8 to 12)
			L.adjust_jitter(10 SECONDS)
		if(13 to 14)
			shake_camera(L, 15, 1)
			L.emote("whimper")
			L.Paralyze(10)
			to_chat(parent, "<span class='userdanger'>You feel like you are never going to get out...</span>")
		if(15 to 17)
			L.emote("cry")
		else
			return
