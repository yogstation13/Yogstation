/mob/living/carbon/alien/humanoid/(gibbed)
	if(stat == DEAD)
		return

	. = ..()

	update_icons()
	status_flags |= CANPUSH

	for(var/mob/S in GLOB.player_list)
		if(!S.stat && S.hivecheck())
			to_chat(S, span_alien("You sense through your hivemind that [src] has died."))

//When the alien queen dies, all others must pay the price for letting her die.
/mob/living/carbon/alien/humanoid/royal/queen/(gibbed)
	if(stat == DEAD)
		return

	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
		if(C == src) //Make sure not to proc it on ourselves.
			continue
		var/obj/item/organ/alien/hivenode/node = C.getorgan(/obj/item/organ/alien/hivenode)
		if(istype(node)) // just in case someone would ever add a diffirent node to hivenode slot
			node.queen_()

	return ..()
