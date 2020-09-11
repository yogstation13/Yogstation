/obj/machinery/sleep_console
	name = "sleeper console"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "console"
	density = FALSE

/obj/machinery/sleeper
	name = "sleeper"
	desc = "An enclosed machine used to stabilize and heal patients."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = FALSE
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/sleeper
	var/efficiency = 1
	var/min_health = -25
	var/list/available_chems
	var/controls_inside = FALSE
	var/list/possible_chems = list(
		list(/datum/reagent/medicine/epinephrine, /datum/reagent/medicine/morphine, /datum/reagent/medicine/perfluorodecalin, /datum/reagent/medicine/bicaridine, /datum/reagent/medicine/kelotane),
		list(/datum/reagent/medicine/oculine,/datum/reagent/medicine/inacusiate),
		list(/datum/reagent/medicine/antitoxin, /datum/reagent/medicine/mutadone, /datum/reagent/medicine/mannitol, /datum/reagent/medicine/salbutamol, /datum/reagent/medicine/pen_acid),
		list(/datum/reagent/medicine/omnizine)
	)
	var/list/chem_buttons	//Used when emagged to scramble which chem is used, eg: antitoxin -> morphine
	var/scrambled_chems = FALSE //Are chem buttons scrambled? used as a warning
	var/enter_message = "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>"
	payment_department = ACCOUNT_MED
	fair_market_price = 5
	var/static/UIbackup = FALSE  // yogs use html instead of tgui    set this to 1/TRUE when tgui breaks //Remember to disable this when we fix it for real
/obj/machinery/sleeper/Initialize() //yogs: doesn't port sleeper deletion because fuck that
	. = ..()
	occupant_typecache = GLOB.typecache_living
	update_icon()
	reset_chem_buttons()

/obj/machinery/sleeper/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	var/I
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		I += M.rating

	efficiency = initial(efficiency)* E
	min_health = initial(min_health) * E
	available_chems = list()
	for(var/i in 1 to I)
		available_chems |= possible_chems[i]
	reset_chem_buttons()

/obj/machinery/sleeper/update_icon()
	icon_state = initial(icon_state)
	if(state_open)
		icon_state += "-open"

/obj/machinery/sleeper/container_resist(mob/living/user)
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/sleeper/Exited(atom/movable/user)
	if (!state_open && user == occupant)
		container_resist(user)

/obj/machinery/sleeper/relaymove(mob/user)
	if (!state_open)
		container_resist(user)

/obj/machinery/sleeper/open_machine()
	if(!state_open && !panel_open)
		..()

/obj/machinery/sleeper/close_machine(mob/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, "[enter_message]")

/obj/machinery/sleeper/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(is_operational() && occupant)
		open_machine()

/obj/machinery/sleeper/MouseDrop_T(mob/target, mob/user)
	if(user.stat || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			return
	close_machine(target)

/obj/machinery/sleeper/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, "<span class='warning'>[src] is currently occupied!</span>")
		return
	if(state_open)
		to_chat(user, "<span class='warning'>[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!</span>")
		return
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		return
	return FALSE

/obj/machinery/sleeper/wrench_act(mob/living/user, obj/item/I)
	if(default_change_direction_wrench(user, I))
		return TRUE

/obj/machinery/sleeper/crowbar_act(mob/living/user, obj/item/I)
	if(default_pry_open(I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/sleeper/default_pry_open(obj/item/I) //wew
	. = !(state_open || panel_open || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[usr] pries open [src].</span>", "<span class='notice'>You pry open [src].</span>")
		open_machine()

/obj/machinery/sleeper/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.notcontained_state)
	if(!UIbackup) //yogs
		if(controls_inside && state == GLOB.notcontained_state)
			state = GLOB.default_state // If it has a set of controls on the inside, make it actually controllable by the mob in it.

		ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
		if(!ui)
			ui = new(user, src, ui_key, "Sleeper", name, 375, 550, master_ui, state)
			ui.open()
	else //yogs start   aplly backup UI
		var/mob/living/mob_occupant = occupant
		if(isOperable(user, mob_occupant))
			return
		var/dat
		dat += "<H2>Ocupant: "
		if(mob_occupant)
			dat += "[mob_occupant.name]"
			switch(mob_occupant.stat)
				if(CONSCIOUS)
					dat += "  <font color = #32E632>Conscious</font>"
				if(SOFT_CRIT)
					dat += "  <font color = #DAE632>Conscious</font>"
				if(UNCONSCIOUS)
					dat += "  <font color = #DAE632>Unconscious</font>"
				if(DEAD)
					dat += "  <font color = #C13131>Dead</font>"
		else
			dat += "No Occupant"

		dat += "</H2>"

		dat += "Door: <a href='?src=[REF(src)];input=1'>[state_open ? "Open" : "Closed"]</a>"

		if(mob_occupant)
			dat += "<H3>Status  <a href='?src=[REF(src)];refresh=1'>(refresh)</a></H3>"
			dat += 	   "	Health:			[mob_occupant.health] / [mob_occupant.maxHealth]"
			dat += "<br>	Brute:			[mob_occupant.getBruteLoss()]"
			dat += "<br>	Sufocation:		[mob_occupant.getOxyLoss()]"
			dat += "<br>	Toxin:			[mob_occupant.getToxLoss()]"
			dat += "<br>	Burn:			[mob_occupant.getFireLoss()]"
			dat += "<br>	Brain:			"
			if(mob_occupant.getOrganLoss(ORGAN_SLOT_BRAIN))
				dat += "abnormal"
			else
				dat += "normal"

			dat += "<br>	Cells:			"
			if(mob_occupant.getCloneLoss())
				dat += "abnormal"
			else
				dat += "normal"

			var/table = ""
			table += "<table style='width:100%'>"
			table += "<tr>"
			table += "<td style='width:50%'><H2>Reagents</H2></td>"
			table += "<td style='width:50%'><H2>Inject</H2></td>"
			table += "</tr>"
			for(var/chem in available_chems)
				table += "<tr><td style='width:50%' valign='top'>"
				var/datum/reagent/R = mob_occupant.reagents.has_reagent(chem)
				if(R)
					table += "[R.name]	[R.volume] units"
				table += "</td>"

				table += "<td style='width:50%' valign='top'>"
				table += "<a href='?src=[REF(src)];inject=[chem]'>"
				if(mob_occupant.health < min_health && chem != /datum/reagent/medicine/epinephrine)
					table += "<font color=\"red\">"
				var/datum/reagent/thing = GLOB.chemical_reagents_list[chem]
				table += "[thing.name]</a>"
				table += "</td></tr>"

			if(mob_occupant.reagents && mob_occupant.reagents.reagent_list.len)
				for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
					var/found = FALSE
					for(var/chem in available_chems)
						var/datum/reagent/thing = GLOB.chemical_reagents_list[chem]
						if(R.name == thing.name)  // Shit code, i know that please make it better if know how
							found = TRUE
					if(!found)
						table += "<tr><td style='width:50%' valign='top'>"
						table += "[R.name]	[R.volume] units"
						table += "</td></tr>"

			table += "</table>"
			dat += "<tt>[table]</tt>"

		dat += "</font>"
		var/datum/browser/popup = new(user, "Sleeper", "Sleeper Control", 400, 500)
		popup.set_content(dat)
		popup.open()
		onclose(user, "Sleeper")

/obj/machinery/sleeper/Topic(href, href_list)
	if(..())
		return
	var/mob/living/mob_occupant = occupant
	if(isOperable(usr, mob_occupant))
		return
	if(href_list["input"])
		if(state_open)
			close_machine()
		else
			open_machine()

	if(href_list["inject"])
		if(!is_operational() || !mob_occupant)
			return
		else
			for(var/chem in available_chems)
				if("[chem]" == href_list["inject"])
					if(inject_chem(chem, usr))
						. = TRUE
						if(scrambled_chems && prob(5))
							to_chat(usr, "<span class='warning'>Chemical system re-route detected, results may not be as expected!</span>")
					break

	usr.set_machine(src)
	ui_interact(usr)

/obj/machinery/sleeper/proc/isOperable(mob/user, mob/living/mob_inside)// returns false if it is
	if(!is_operational())
		return TRUE
	if(issilicon(user))
		return FALSE
	if(!in_range(user, src))
		return TRUE
	if(mob_inside != usr)
		return FALSE
	if(controls_inside)
		return FALSE
	if(!istype(mob_inside,/mob/living/carbon/human))
		to_chat(usr, "<span class='warning'>You cant reach the controls from inside!</span>")
		return TRUE
	var/mob/living/carbon/human/HU = mob_inside
	if(!HU.dna.check_mutation(TK))
		to_chat(usr, "<span class='warning'>You cant reach the controls from inside!</span>")
		return TRUE
	return FALSE
	 // yogs end

/obj/machinery/sleeper/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/sleeper/examine(mob/user)
	.=..()
	. += "<span class='notice'>Alt-click [src] to [state_open ? "close" : "open"] it.</span>"

/obj/machinery/sleeper/process()
	..()
	check_nap_violations()

/obj/machinery/sleeper/nap_violation(mob/violator)
	open_machine()

/obj/machinery/sleeper/ui_data()
	var/list/data = list()
	data["occupied"] = occupant ? 1 : 0
	data["open"] = state_open

	data["chems"] = list()
	for(var/chem in available_chems)
		var/datum/reagent/R = GLOB.chemical_reagents_list[chem]
		data["chems"] += list(list("name" = R.name, "id" = "[chem]", "allowed" = chem_allowed(chem)))   //yogs modifies id

	data["occupant"] = list()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(SOFT_CRIT)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "average"
			if(UNCONSCIOUS)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = mob_occupant.health
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = HEALTH_THRESHOLD_DEAD
		data["occupant"]["bruteLoss"] = mob_occupant.getBruteLoss()
		data["occupant"]["oxyLoss"] = mob_occupant.getOxyLoss()
		data["occupant"]["toxLoss"] = mob_occupant.getToxLoss()
		data["occupant"]["fireLoss"] = mob_occupant.getFireLoss()
		data["occupant"]["cloneLoss"] = mob_occupant.getCloneLoss()
		data["occupant"]["brainLoss"] = mob_occupant.getOrganLoss(ORGAN_SLOT_BRAIN)
		data["occupant"]["reagents"] = list()
		if(mob_occupant.reagents && mob_occupant.reagents.reagent_list.len)
			for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
				data["occupant"]["reagents"] += list(list("name" = R.name, "volume" = R.volume))
	return data

/obj/machinery/sleeper/ui_act(action, params)
	if(..())
		return
	var/mob/living/mob_occupant = occupant
	check_nap_violations()
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("inject")
			if(!is_operational() || !mob_occupant)				//yogs start
				return
			for(var/chem in available_chems)
				if("[chem]" == params["chem"])
					if(inject_chem(chem, usr))
						. = TRUE
						if(scrambled_chems && prob(5))
							to_chat(usr, "<span class='warning'>Chemical system re-route detected, results may not be as expected!</span>")
					break				//yogs end

/obj/machinery/sleeper/emag_act(mob/user)
	scramble_chem_buttons()
	to_chat(user, "<span class='warning'>You scramble the sleeper's user interface!</span>")

/obj/machinery/sleeper/proc/inject_chem(chem, mob/user)
	if((chem in available_chems) && chem_allowed(chem))
		occupant.reagents.add_reagent(chem_buttons[chem], 10) //emag effect kicks in here so that the "intended" chem is used for all checks, for extra FUUU
		if(user)
			log_combat(user, occupant, "injected [chem] into", addition = "via [src]")
		return TRUE

/obj/machinery/sleeper/proc/chem_allowed(chem)
	var/mob/living/mob_occupant = occupant
	if(!mob_occupant || !mob_occupant.reagents)
		return
	if(mob_occupant.reagents.get_reagent_amount(chem) + 10 <= 20 * efficiency)			//yogs start
		if(mob_occupant.health > min_health || chem == /datum/reagent/medicine/epinephrine)
			return TRUE
	return FALSE				//yogs end

/obj/machinery/sleeper/proc/reset_chem_buttons()
	scrambled_chems = FALSE
	LAZYINITLIST(chem_buttons)
	for(var/chem in available_chems)
		chem_buttons[chem] = chem

/obj/machinery/sleeper/proc/scramble_chem_buttons()
	scrambled_chems = TRUE
	var/list/av_chem = available_chems.Copy()
	for(var/chem in av_chem)
		chem_buttons[chem] = pick_n_take(av_chem) //no dupes, allow for random buttons to still be correct


/obj/machinery/sleeper/syndie
	icon_state = "sleeper_s"
	controls_inside = TRUE

/obj/machinery/sleeper/syndie/fullupgrade/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/sleeper(null) //yogs: no deletion :>)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	RefreshParts()

/obj/machinery/sleeper/clockwork
	name = "soothing sleeper"
	desc = "A large cryogenics unit built from brass. Its surface is pleasantly cool the touch."
	icon_state = "sleeper_clockwork"
	enter_message = "<span class='bold inathneq_small'>You hear the gentle hum and click of machinery, and are lulled into a sense of peace.</span>"
	possible_chems = list(list(/datum/reagent/medicine/epinephrine, /datum/reagent/medicine/salbutamol, /datum/reagent/medicine/bicaridine, /datum/reagent/medicine/kelotane, /datum/reagent/medicine/oculine, /datum/reagent/medicine/inacusiate, /datum/reagent/medicine/mannitol))

/obj/machinery/sleeper/clockwork/process()
	if(occupant && isliving(occupant))
		var/mob/living/L = occupant
		if(GLOB.clockwork_vitality) //If there's Vitality, the sleeper has passive healing
			GLOB.clockwork_vitality = max(0, GLOB.clockwork_vitality - 1)
			L.adjustBruteLoss(-1)
			L.adjustFireLoss(-1)
			L.adjustOxyLoss(-5)

/obj/machinery/sleeper/old
	icon_state = "oldpod"