// modular shitcode but it works:tm:

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/multitool_act(mob/living/user, obj/item/multitool/I)
	if(istype(I))
		to_chat(user, "<span class='notice'>You add \the [src]'s ID into the multitool's buffer.</span>")
		I.buffer = src.id
		return TRUE
/obj/machinery/computer/reactor/multitool_act(mob/living/user, obj/item/multitool/I)
	if(istype(I))
		to_chat(user, "<span class='notice'>You add the reactor's ID to \the [src]>")
		src.id = I.buffer
		return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/cargo // easier on the brain

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/cargo/New()
	id = rand(1, 1000000) // cmon, what are the chances?

// Cargo varients can be wrenched down and don't start linked to the default RMBK reactor

/obj/machinery/computer/reactor/cargo
	anchored = FALSE
	id = null

/obj/machinery/computer/reactor/stats/cargo
	anchored = FALSE
	id = null

/obj/machinery/computer/reactor/fuel_rods/cargo
	anchored = FALSE
	id = null
