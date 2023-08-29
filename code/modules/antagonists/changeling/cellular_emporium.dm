// cellular emporium
// The place where changelings go to buy their biological weaponry.

/datum/antag_menu/cellular_emporium
	name = "cellular emporium"
	ui_name = "CellularEmporium"

/datum/antag_menu/cellular_emporium/ui_data(mob/user)
	var/list/data = list()
	var/datum/antagonist/changeling/changeling = antag_datum

	if(!istype(changeling))
		CRASH("changeling menu started with wrong datum.")

	var/can_readapt = changeling.canrespec
	var/genetic_points_remaining = changeling.geneticpoints
	var/absorbed_dna_count = changeling.absorbedcount
	var/true_absorbs = changeling.trueabsorbs

	data["can_readapt"] = can_readapt
	data["genetic_points_remaining"] = genetic_points_remaining
	data["absorbed_dna_count"] = absorbed_dna_count

	var/list/abilities = list()

	for(var/path in changeling.all_powers)
		var/datum/action/changeling/ability = new path

		var/dna_cost = ability.dna_cost
		if(dna_cost <= 0)
			continue

		var/xenoling_available = initial(ability.xenoling_available) //yogs start - removing combat abilities from xenolings
		if(istype(changeling, /datum/antagonist/changeling/xenobio) && !xenoling_available)
			continue //yogs end - removing combat abilities from xenolings

		var/list/abilitydata = list()
		abilitydata["name"] = ability.name
		abilitydata["desc"] = ability.desc
		abilitydata["helptext"] = ability.helptext
		abilitydata["owned"] = changeling.has_sting(ability)
		var/req_dna = ability.req_dna
		var/req_absorbs = ability.req_absorbs
		abilitydata["dna_cost"] = dna_cost
		abilitydata["can_purchase"] = ((req_absorbs <= true_absorbs) && (req_dna <= absorbed_dna_count) && (dna_cost <= genetic_points_remaining))
		abilitydata["conflicting_powers"] = list()
		for(var/conflict in ability.conflicts)
			var/datum/action/changeling/conflcting_ability = new conflict
			abilitydata["conflicting_powers"] += conflcting_ability.name
		
		abilities += list(abilitydata)

	data["abilities"] = abilities

	return data

/datum/antag_menu/cellular_emporium/ui_act(action, params)
	if(..())
		return
	var/datum/antagonist/changeling/changeling = antag_datum

	switch(action)
		if("readapt")
			if(changeling.canrespec)
				changeling.readapt()
			else
				to_chat(changeling.owner.current,span_danger("You lack the power to readapt your evolutions!"))
		if("evolve")
			var/sting_name = params["name"]
			changeling.purchase_power(sting_name)

/datum/action/innate/cellular_emporium
	name = "Cellular Emporium"
	button_icon = 'icons/obj/drinks.dmi'
	button_icon_state = "changelingsting"
	background_icon_state = "bg_changeling"
	overlay_icon_state = "bg_changeling_border"
	var/datum/antag_menu/cellular_emporium/cellular_emporium

/datum/action/innate/cellular_emporium/New(our_target)
	. = ..()
	if(istype(our_target, /datum/antag_menu/cellular_emporium))
		cellular_emporium = our_target
	else
		CRASH("cellular_emporium action created with non emporium.")

/datum/action/innate/cellular_emporium/Destroy()
	cellular_emporium = null
	return ..()

/datum/action/innate/cellular_emporium/Activate()
	cellular_emporium.ui_interact(owner)
