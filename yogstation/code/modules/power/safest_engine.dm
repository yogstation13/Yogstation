/obj/machinery/power/safest
	name = "best engine"
	desc = "An extremely complex and advanced engine, not for the faint of heart."
	icon = 'yogstation/icons/obj/hugbox_engine.dmi'
	icon_state = "hug_me"
	density = TRUE
	anchored = TRUE
	can_be_unanchored = FALSE
	use_power = NO_POWER_USE

/obj/machinery/power/safest/Initialize()
	..()
	connect_to_network()

/obj/machinery/power/safest/process()
	add_avail(10000000)

/obj/machinery/power/safest/attack_hand(mob/user)
	START_PROCESSING(SSobj, src)
	if(user.mind)
		if(!user.mind.objectives || !(locate(/datum/objective/hijack) in user.mind.objectives))
			return
		to_chat("<span class='warning'>You quickly sabotage the cooling and gasmix.</span>")
		addtimer(CALLBACK(src, ./proc/explosion, get_turf(src), 1, 2, 4, ignorecap=TRUE), 30 SECONDS)