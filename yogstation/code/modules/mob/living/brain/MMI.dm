/obj/item/mmi/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/organ/brain)) //Time to stick a brain in it --NEO´
		var/obj/item/organ/brain/newbrain = O
		if(newbrain.decoy_override && !brain && user.transferItemToLoc(O, src))
			user.changeNext_move(CLICK_CD_MELEE)

			brain = newbrain
			name = "[initial(name)]: [brain.real_name]"
			to_chat(brainmob, "(<span class='notice'>If your brain was removed after your  you don't remember how you died, or who killed you. <a href='https://forums.yogstation.net/help/rules/#rule-1_6'>See rule 1.6</a>.</span>") //yogs
			update_icon()
			return

	.=..()

/obj/item/mmi/eject_brain(mob/user)
	if(brain.decoy_override)
		if(user)
			user.put_in_hands(brain) //puts brain in the user's hand or otherwise drops it on the user's turf
		else
			brain.forceMove(get_turf(src))
		brain = null //No more brain in here
		return
	.=..()
