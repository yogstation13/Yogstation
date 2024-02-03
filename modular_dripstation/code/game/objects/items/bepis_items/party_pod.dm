/obj/item/circuitboard/machine/sleeper/party
	name = "Party Pod"
	build_path = /obj/machinery/party

/obj/machinery/party
	name = "party pod"
	desc = "'Sleeper' units were once known for their healing properties, until a lengthy investigation revealed they were also dosing patients with deadly lead acetate. This appears to be one of those old 'sleeper' units repurposed as a 'Party Pod'. It’s probably not a good idea to use it."
	icon_state = "partypod"
	base_icon_state = "partypod"
	icon = 'modular_dripstation/icons/obj/partypod.dmi'
	circuit = /obj/item/circuitboard/machine/sleeper/party

	density = FALSE
	state_open = TRUE
	payment_department = ACCOUNT_MED
	fair_market_price = 5

	///How much chems is allowed to be in a patient at once, before we force them to wait for the reagent to process.
	var/efficiency = 1
	///Whether the machine can be operated by the person inside of it.
	var/controls_inside = TRUE
	var/enter_message = "<span class='notice'><b>You're surrounded by some funky music inside the chamber. You zone out as you feel waves of krunk vibe within you.</b></span>"
	var/min_health = -25
	///List of currently available chems.
	var/list/available_chems = list()
	///Used when emagged to scramble which chem is used, eg: mutadone -> morphine
	var/list/chem_buttons
	//Exclusively uses non-lethal, "fun" chems. At an obvious downside.
	var/list/possible_chems = list(
		list(
			/datum/reagent/consumable/ethanol/beer,
			/datum/reagent/consumable/laughter,
		),
		list(
			/datum/reagent/spraytan,
			/datum/reagent/barbers_aid,
		),
		list(
			/datum/reagent/colorful_reagent,
			/datum/reagent/hair_dye,
		),
		list(
			/datum/reagent/drug/space_drugs,
			/datum/reagent/baldium,
		),
	)
	///Chemicals that need to have a touch or vapor reaction to be applied, not the standard chamber reaction.
	var/spray_chems = list(
		/datum/reagent/spraytan,
		/datum/reagent/hair_dye,
		/datum/reagent/baldium,
		/datum/reagent/barbers_aid,
	)

/obj/machinery/party/Initialize(mapload)
	. = ..()
	if(mapload)
		LAZYREMOVE(component_parts, circuit)
		QDEL_NULL(circuit)
	occupant_typecache = GLOB.typecache_living
	update_icon()
	reset_chem_buttons()

/obj/machinery/party/RefreshParts()
	. = ..()
	var/matterbin_rating
	for(var/obj/item/stock_parts/matter_bin/matterbins in component_parts)
		matterbin_rating += matterbins.rating
	efficiency = initial(efficiency) * matterbin_rating
	min_health = initial(min_health) * matterbin_rating

	available_chems.Cut()
	for(var/obj/item/stock_parts/manipulator/servos in component_parts)
		for(var/i in 1 to servos.rating)
			available_chems |= possible_chems[i]

	reset_chem_buttons()

/obj/machinery/party/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE

	balloon_alert(user, "interface scrambled")
	obj_flags |= EMAGGED

	var/list/av_chem = available_chems.Copy()
	for(var/chem in av_chem)
		chem_buttons[chem] = pick_n_take(av_chem) //no dupes, allow for random buttons to still be correct
	return TRUE

/obj/machinery/party/proc/inject_chem(chem, mob/user)
	if(obj_flags & EMAGGED)
		occupant.reagents.add_reagent(/datum/reagent/toxin/leadacetate, 4)
	else if (prob(20)) //You're injecting chemicals into yourself from a recalled, decrepit medical machine. What did you expect?
		occupant.reagents.add_reagent(/datum/reagent/toxin/leadacetate, rand(1,3))
	if(chem in spray_chems)
		var/datum/reagents/holder = new()
		holder.add_reagent(chem_buttons[chem], 10) //I hope this is the correct way to do this.
		holder.trans_to(occupant, 10)				//, methods = VAPOR untill proc trans_to remade
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		if(user)
			log_combat(user, occupant, "sprayed [chem] into", addition = "via [src]")
		return TRUE
	if((chem in available_chems) && chem_allowed(chem))
		occupant.reagents.add_reagent(chem_buttons[chem], 10) //emag effect kicks in here so that the "intended" chem is used for all checks, for extra FUUU
		if(user)
			log_combat(user, occupant, "injected [chem] into", addition = "via [src]")
		return TRUE

/obj/machinery/party/proc/chem_allowed(chem)
	var/mob/living/mob_occupant = occupant
	if(!mob_occupant || !mob_occupant.reagents)
		return
	var/amount = mob_occupant.reagents.get_reagent_amount(chem) + 10 <= 20 * efficiency
	var/occ_health = mob_occupant.health > min_health || chem == /datum/reagent/medicine/epinephrine
	return amount && occ_health

/obj/machinery/party/proc/reset_chem_buttons()
	obj_flags &= ~EMAGGED
	LAZYINITLIST(chem_buttons)
	for(var/chem in available_chems)
		chem_buttons[chem] = chem


/obj/machinery/party/update_icon()
	icon_state = "[base_icon_state][state_open ? "-open" : null]"
	return ..()

/obj/machinery/party/proc/container_resist_act(mob/living/user)
	visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"))
	open_machine()

/obj/machinery/party/Exited(atom/movable/gone, direction)
	. = ..()
	if (!state_open && gone == occupant)
		container_resist_act(gone)

/obj/machinery/party/relaymove(mob/living/user, direction)
	if (!state_open)
		container_resist_act(user)

/obj/machinery/party/open_machine(drop = TRUE, density_to_set = FALSE)
	if(!state_open && !panel_open)
		flick("[initial(icon_state)]-anim", src)
	return ..()

/obj/machinery/party/close_machine(mob/user, density_to_set = TRUE)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("[initial(icon_state)]-anim", src)
		..()
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(mob_occupant, "[enter_message]")

/obj/machinery/party/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(stat & (NOPOWER|BROKEN|MAINT)) && occupant)
		open_machine()


/obj/machinery/party/MouseDrop_T(mob/target, mob/user)
	if(HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	close_machine(target)

/obj/machinery/party/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(occupant)
		to_chat(user, span_warning("[src] is currently occupied!"))
		return TRUE
	if(state_open)
		to_chat(user, span_warning("[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!"))
		return TRUE
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		return TRUE
	return FALSE

/obj/machinery/party/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_change_direction_wrench(user, I))
		return TRUE
	return FALSE

/obj/machinery/party/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_pry_open(I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	return FALSE

/obj/machinery/party/default_pry_open(obj/item/I) //wew
	. = !(state_open || panel_open || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open [src]."), span_notice("You pry open [src]."))
		open_machine()

/obj/machinery/party/ui_state(mob/user)
	if(!controls_inside)
		return GLOB.notcontained_state
	return GLOB.default_state

/obj/machinery/party/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Party", name)
		ui.open()

/obj/machinery/party/AltClick(mob/user)
	. = ..()
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/party/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to [state_open ? "close" : "open"] it.")

/obj/machinery/party/process()
	..()
	use_power(idle_power_usage)

/obj/machinery/party/nap_violation(mob/violator)
	. = ..()
	open_machine()

/obj/machinery/party/ui_data()
	var/list/data = list()
	data["occupied"] = !!occupant
	data["open"] = state_open

	data["chems"] = list()
	for(var/chem in available_chems)
		var/datum/reagent/R = GLOB.chemical_reagents_list[chem]
		data["chems"] += list(
			list(
				"name" = R.name,
				"id" = R.type,
				"allowed" = chem_allowed(chem),
			),
		)

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
				data["occupant"]["reagents"] += list(
					list(
						"name" = R.name,
						"volume" = R.volume,
					),
				)

	return data

/obj/machinery/party/ui_act(action, params)
	. = ..()
	if(.)
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
			var/chem = text2path(params["chem"])
			if((stat & (NOPOWER|BROKEN|MAINT)) || !mob_occupant || isnull(chem))
				return
			if(mob_occupant.health < min_health && !ispath(chem, /datum/reagent/medicine/epinephrine))
				return
			if(inject_chem(chem, usr))
				. = TRUE
				if((obj_flags & EMAGGED) && prob(5))
					to_chat(usr, span_warning("Chemical system re-route detected, results may not be as expected!"))