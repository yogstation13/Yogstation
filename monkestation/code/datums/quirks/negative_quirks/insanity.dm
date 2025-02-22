//IPC PUNISHMENT SYSTEM//
/datum/quirk/insanity/add()
	. = ..()
	if(!isipc(quirk_holder)) // this checks ishuman too
		var/mob/living/carbon/human/ipc_holder = quirk_holder
		ipc_holder.physiology?.brute_mod *= 1.3
		ipc_holder.physiology?.burn_mod *= 1.3

/datum/quirk/insanity/remove()
	. = ..()
	if(!isipc(quirk_holder)) // this checks ishuman too
		var/mob/living/carbon/human/ipc_holder = quirk_holder
		ipc_holder.physiology?.brute_mod /= 1.3
		ipc_holder.physiology?.burn_mod /= 1.3

/datum/quirk/insanity/post_add()
	. = ..()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels frail."))
