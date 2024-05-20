/datum/game_mode/traitor/bros/proc/equip_brother(mob/living/M) //gives the brothers a bundle
	if(!M || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/L = M
	var/obj/item/storage/box/syndicate/bundle_B/S = new
	var/list/slots = list("in the dark depths of hell" = SLOT_IN_BACKPACK) // You know you can put *anything* as the key, yeah?
	if(L.equip_in_one_of_slots(S, slots) == "in the dark depths of hell")
		slots[1] = "in your [L.back.name]" // This accesses & edits the "dark depths" meme above.
	if(S)
		to_chat(L, "<span class='notice'>There is a syndicate bundle [slots[1]]! It'll help you get a slight leg-up on your objectives, but do not expect it to make things too easy!</span>")
		return TRUE
	return FALSE
