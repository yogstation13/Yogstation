/datum/quirk/item_quirk/allergic/add()
	if(!isipc(quirk_holder)) // this checks ishuman too
		return
	var/mob/living/carbon/human/ipc_holder = quirk_holder
	ipc_holder.physiology?.brute_mod *= 1.3
	ipc_holder.physiology?.burn_mod *= 1.3

/datum/quirk/item_quirk/allergic/remove()
	if(!isipc(quirk_holder))
		return
	var/mob/living/carbon/human/ipc_holder = quirk_holder
	ipc_holder.physiology?.brute_mod /= 1.3
	ipc_holder.physiology?.burn_mod /= 1.3

/datum/quirk/item_quirk/allergic/post_add()
	. = ..()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels frail."))
