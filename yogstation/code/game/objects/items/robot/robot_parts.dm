/obj/item/robot_suit/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/mmi))
		var/obj/item/mmi/M = W
		if(check_completion())
			if(!chest.cell)
				to_chat(user, "<span class='warning'>The endoskeleton still needs a power cell!</span>")
				return
			if(!isturf(loc))
				to_chat(user, "<span class='warning'>You can't put [M] in, the frame has to be standing on the ground to be perfectly precise!</span>")
				return

			if(M.brain && M.brain.decoy_override) //same message as them being jobbanned.
				to_chat(user, "<span class='warning'>This [M.name] does not seem to fit!</span>")
				return

	.=..()