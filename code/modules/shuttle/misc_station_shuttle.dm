/obj/machinery/computer/shuttle/ai_ship
	name = "ai ship shuttle console"
	desc = "Used to control the remote AI satellite shuttle."
	circuit = /obj/item/circuitboard/computer/ai_ship
	shuttleId = "ai_ship"
	possible_destinations = "ai_station;ai_ship"
	no_destination_swap = TRUE

/obj/machinery/computer/shuttle/divepod_a // Arrivals
	name = "D.I.V.E.R. A control console"
	desc = "Used to send D.I.V.E.R. transport pods up and down."
	circuit = /obj/item/circuitboard/computer/divepod_a
	shuttleId = "doretta"
	possible_destinations = "doretta_up;doretta_down"
	no_destination_swap = TRUE

/obj/machinery/computer/shuttle/divepod_b // Biodome and E. Maintenance
	name = "D.I.V.E.R. B control console"
	desc = "Used to send D.I.V.E.R. transport pods up and down."
	circuit = /obj/item/circuitboard/computer/divepod_b
	shuttleId = "molly"
	possible_destinations = "molly_up;molly_down"
	no_destination_swap = TRUE

/obj/machinery/computer/shuttle/divepod_c // Mining
	name = "D.I.V.E.R. C control console"
	desc = "Used to send D.I.V.E.R. transport pods up and down."
	circuit = /obj/item/circuitboard/computer/divepod_c
	shuttleId = "betsy"
	possible_destinations = "betsy_up;betsy_down"
	no_destination_swap = TRUE
