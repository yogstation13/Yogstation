GLOBAL_LIST_EMPTY(expansion_card_holders)

/obj/machinery/ai/expansion_card_holder
	name = "Expansion Card Bus"
	desc = "A simple rack of bPCIe slots for installing expansion cards."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"
	
	var/list/installed_cards

	var/max_cards = 2


/obj/machinery/ai/expansion_card_holder/Initialize()
	..()
	installed_cards = list()
	GLOB.expansion_card_holders += src

/obj/machinery/ai/expansion_card_holder/Destroy()
	installed_cards = list()
	GLOB.expansion_card_holders -= src
	//Recalculate all the CPUs :)
	/*
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		AI.update_hardware() */
	GLOB.ai_os.update_hardware()
	..()

/obj/machinery/ai/expansion_card_holder/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/processing_card) || istype(W, /obj/item/memory_card))
		if(installed_cards.len >= max_cards)
			to_chat(user, "<span class='warning'>[src] cannot fit the [W]!</span>")
			return ..()
		to_chat(user, "<span class='notice'>You install [W] into [src].</span>")
		W.forceMove(src)
		installed_cards += W
		GLOB.ai_os.update_hardware()
		return FALSE

	return ..()

/obj/machinery/ai/expansion_card_holder/examine()
	. = ..()
	. += "The machine has [installed_cards.len] cards out of a maximum of [max_cards] installed."
	for(var/C in installed_cards)
		. += "There is a [C] installed."
	. += "Use a crowbar to remove cards."
