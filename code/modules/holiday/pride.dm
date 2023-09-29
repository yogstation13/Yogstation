/datum/holiday/pride
	name = "Pride Week"
	begin_month = JUNE
	begin_day = 15
	end_day = 22 //pride week :(

/datum/holiday/pride/celebrate()
	. = ..()
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(become_gay_destroyer_of_worlds)))

/datum/holiday/pride/proc/become_gay_destroyer_of_worlds()
	for(var/i in 1 to FACTOR_GAS_VISIBLE_MAX) //I DON'T LIKE EM PUTTING CHEMICALS IN THE GAS THAT TURN THE FRIGGIN PLASMA GAY!
		var/obj/effect/overlay/gas/G = GLOB.meta_gas_info[/datum/gas/plasma][META_GAS_OVERLAY][i]
		G.icon_state = "pridesma"
		animate(G, color = rgb(255, 0, 0), time = 5, loop = -1)
		animate(color = rgb(0, 255, 0), time = 5, loop = -1)
		animate(color = rgb(0, 0, 255), time = 5, loop = -1)
