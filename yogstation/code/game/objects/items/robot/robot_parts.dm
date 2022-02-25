/obj/item/robot_suit/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/mmi))
		var/obj/item/mmi/M = W
		if(check_completion())
			if(!chest.cell)
				to_chat(user, span_warning("The endoskeleton still needs a power cell!"))
				return
			if(!isturf(loc))
				to_chat(user, span_warning("You can't put [M] in, the frame has to be standing on the ground to be perfectly precise!"))
				return

			if(M.brain && M.brain.decoy_override) //same message as them being jobbanned.
				to_chat(user, span_warning("This [M.name] does not seem to fit!"))
				return

	.=..()