
/obj/machinery/portable_atmospherics/canister/bluespace
	name = "A bluespace canister"
	desc = "A canister for storing adn moving all of the gas."
	icon_state = "yellow"

	volume = 3000

/obj/machinery/portable_atmospherics/canister/update_icon()
	if(stat & BROKEN)
		cut_overlays()
		icon_state = "[icon_state]-1"
		add_overlay("bluespace-1")
		return

	var/last_update = update
	update = 0
	..()
	add_overlay("bluespace")


/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/metal (loc, 10)
		else
			new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)
