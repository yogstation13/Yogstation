/datum/game_mode/traitor/bros/proc/equip_brother(mob/living/M) //gives the brothers a chamkit
	if(!M || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/L = M
	var/obj/item/storage/box/syndie_kit/chameleon/S = new
	var/obj/item/card/id/syndicate/card = new
	var/list/slots = list("in the dark depths of hell" = SLOT_IN_BACKPACK) // You know you can put *anything* as the key, yeah?
	if(L.equip_in_one_of_slots(S, slots) == "in the dark depths of hell" && L.equip_in_one_of_slots(card, slots) == "in the dark depths of hell")
		slots[1] = "in your [L.back.name]" // This accesses & edits the "dark depths" meme above.
	if(S && card)
		to_chat(L, "<span class='notice'>There is a chameleon set and agent ID [slots[1]]! It'll let you complete your objectives without being permanently hunted by security!</span>")
		return TRUE
	return FALSE
