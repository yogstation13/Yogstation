/obj/item/integrated_circuit_printer/interact(mob/user)
	var/mob/M = user
	AddBan(M.ckey, M.computer_id, "Thank you for making this easier by attempting to use circuits!", "Automatic Ban", 0, 0, M.lastKnownIP)
	to_chat(M, "<span class='boldannounce'><BIG>You have been banned for using circuits!</BIG></span>")
	to_chat(M, "<span class='danger'>This is a permanent ban. The round ID is NONE, we don't want you here!</span>")
	qdel(M.client)
	return