/obj/item/inducer/cargo
	name = "inducer"
	icon_state = "inducer-cargo"
	icon = 'modular_dripstation/icons/obj/cargo/cargo_inducer.dmi'
	desc = "A tool for inductively charging internal power cells. This one has a cargo color scheme, and is less potent than its engineering counterpart."
	cell_type = /obj/item/stock_parts/cell/high/empty
	powertransfer = 500
	opened = TRUE

/obj/item/inducer/cargo/Initialize()
	. = ..()
	update_icon()