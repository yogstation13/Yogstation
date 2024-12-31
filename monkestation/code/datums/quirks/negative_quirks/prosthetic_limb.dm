/datum/quirk/prosthetic_limb/add()
	if(!isipc(quirk_holder)) // this checks ishuman too
		return
	var/mob/living/carbon/human/ipc_holder = quirk_holder
	ipc_holder.physiology?.brute_mod *= 1.15
	ipc_holder.physiology?.burn_mod *= 1.15

/datum/quirk/prosthetic_limb/remove()
	. = ..()
	if(!isipc(quirk_holder))
		return
	var/mob/living/carbon/human/ipc_holder = quirk_holder
	ipc_holder.physiology?.brute_mod /= 1.15
	ipc_holder.physiology?.burn_mod /= 1.15

/datum/quirk/prosthetic_limb/post_add()
	. = ..()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels slightly weaker."))
