//IPC PUNISHMENT SYSTEM//
/datum/quirk/item_quirk/food_allergic/add()
	if(!isipc(quirk_holder)) // this checks ishuman too
		return ..()
	var/mob/living/carbon/human/ipc_holder = quirk_holder
	ipc_holder.physiology?.brute_mod *= 1.3
	ipc_holder.physiology?.burn_mod *= 1.3

/datum/quirk/item_quirk/food_allergic/remove()
	if(!isipc(quirk_holder)) // this checks ishuman too
		return ..()
	var/mob/living/carbon/human/ipc_holder = quirk_holder
	ipc_holder.physiology?.brute_mod /= 1.3
	ipc_holder.physiology?.burn_mod /= 1.3

/datum/quirk/item_quirk/food_allergic/post_add()
	. = ..()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels frail."))

/datum/quirk/item_quirk/food_allergic/add_unique()
	if(!isipc(quirk_holder))
		return ..()
