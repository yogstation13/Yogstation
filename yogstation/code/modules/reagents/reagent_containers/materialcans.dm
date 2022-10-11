/obj/reagentcan
	name = "Reagent Canister"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "basiccan"
	density = TRUE
	var/datum/reagent/agent

/obj/reagentcan/Initialize()
	. = ..()
	reagents = new(2500, AMOUNT_VISIBLE|NO_REACT|DRAINABLE)
	reagents.add_reagent(agent, 2500)

/obj/reagentcan/Destroy(force)
	var/turf/T = get_turf(src)
	// Turns it into 250u released
	message_admins("[src] has been destroyed at [ADMIN_VERBOSEJMP(T)]")
	investigate_log("[src] has been destroyed.", INVESTIGATE_ATMOS)
	chem_splash(T, 5, list(reagents), threatscale=0.1)
	. = ..()

/obj/reagentcan/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		if(I.force)
			investigate_log("was smacked with \a [I] by [key_name(user)].", INVESTIGATE_ATMOS)
			add_fingerprint(user)
		return ..()

/obj/reagentcan/iron
	name = "Iron Canister"
	icon_state = "ironcan"
	desc = "Contains a huge amount of iron"
	agent = /datum/reagent/iron

/obj/reagentcan/plasma
	name = "Plasma Canister"
	icon_state = "plasmacan"
	desc = "Contains a huge amount of plasma"
	agent = /datum/reagent/toxin/plasma

/obj/reagentcan/gold
	name = "Gold Canister"
	icon_state = "goldcan"
	desc = "Contains a huge amount of gold"
	agent = /datum/reagent/gold

/obj/reagentcan/uranium
	name = "Uranium Canister"
	icon_state = "uraniumcan"
	desc = "Contains a huge amount of uranium"
	agent = /datum/reagent/uranium

