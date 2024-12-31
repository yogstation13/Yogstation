/datum/quirk/light_drinker/add()
	if(!isipc(quirk_holder)) // this checks ishuman too
		return
	var/mob/living/carbon/human/ipc_holder = quirk_holder
	ipc_holder.physiology?.brute_mod *= 1.1
	ipc_holder.physiology?.burn_mod *= 1.1
	to_chat(quirk_holder, span_boldnotice("Your chassis feels very slightly weaker."))

/datum/quirk/light_drinker/remove()
	if(!isipc(quirk_holder))
		return
	var/mob/living/carbon/human/ipc_holder = quirk_holder
	ipc_holder.physiology?.brute_mod /= 1.1
	ipc_holder.physiology?.burn_mod /= 1.1

