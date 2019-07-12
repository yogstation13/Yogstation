
/*

CONTAINS:
TRICORDER

*/



//Tricorder
//The tricorder is a child of a multitool for the sole purpose to make it work with Tcomms

/obj/item/multitool/tricorder
	name = "tricorder"
	icon = 'yogstation/icons/obj/device.dmi'
	icon_state = "tricorder"
	item_state = "analyzer"
	desc = "A multifunction hand-held device useful for data sensing, analysis, and recording"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	tool_behaviour = TOOL_MULTITOOL
	usesound = 'sound/weapons/etherealhit.ogg'
	toolspeed = 0.2
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=500,MAT_SILVER=300,MAT_GOLD=300)

	var/medicalTricorder = FALSE	//Set to TRUE for normal medical scanner, set to FALSE for a gutted version


obj/item/multitool/tricorder/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] thinks today IS a good day to die!</span>")
	return BRUTELOSS


//Tricorder differentiates from slimes and nonslimes
/obj/item/multitool/tricorder/attack(mob/living/M, mob/living/user, obj/item/I)
	add_fingerprint(user)
	atmosanalyzer_scan()
	if(user.stat || user.eye_blind)
		return
	if (isslime(M))
		var/mob/living/simple_animal/slime/T = M
		slime_scan(T, user)
	else if (medicalTricorder)
		healthscan(user, M)
		return
	else
		lesserhealthscan(user, M)
		return

//Gas Analyzer functions
/obj/item/multitool/tricorder/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	if(!proximity)
		return
	A.analyzer_act(user, src)

/obj/item/multitool/tricorder/attack_self(mob/user)
	//Copy + Pasted right off the Gas Analyzer
	add_fingerprint(user)

	if (user.stat || user.eye_blind)
		return

	var/turf/location = user.loc
	if(!istype(location))
		return

	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	to_chat(user, "<span class='info'><B>Results:</B></span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(user, "<span class='info'>Pressure: [round(pressure, 0.01)] kPa</span>")
	else
		to_chat(user, "<span class='alert'>Pressure: [round(pressure, 0.01)] kPa</span>")
	if(total_moles)
		var/list/env_gases = environment.gases

		environment.assert_gases(arglist(GLOB.hardcoded_gases))
		var/o2_concentration = env_gases[/datum/gas/oxygen][MOLES]/total_moles
		var/n2_concentration = env_gases[/datum/gas/nitrogen][MOLES]/total_moles
		var/co2_concentration = env_gases[/datum/gas/carbon_dioxide][MOLES]/total_moles
		var/plasma_concentration = env_gases[/datum/gas/plasma][MOLES]/total_moles

		if(abs(n2_concentration - N2STANDARD) < 20)
			to_chat(user, "<span class='info'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/nitrogen][MOLES], 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='alert'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/nitrogen][MOLES], 0.01)] mol)</span>")

		if(abs(o2_concentration - O2STANDARD) < 2)
			to_chat(user, "<span class='info'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/oxygen][MOLES], 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='alert'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/oxygen][MOLES], 0.01)] mol)</span>")

		if(co2_concentration > 0.01)
			to_chat(user, "<span class='alert'>CO2: [round(co2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/carbon_dioxide][MOLES], 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='info'>CO2: [round(co2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/carbon_dioxide][MOLES], 0.01)] mol)</span>")

		if(plasma_concentration > 0.005)
			to_chat(user, "<span class='alert'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/plasma][MOLES], 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='info'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/plasma][MOLES], 0.01)] mol)</span>")

		environment.garbage_collect()

		for(var/id in env_gases)
			if(id in GLOB.hardcoded_gases)
				continue
			var/gas_concentration = env_gases[id][MOLES]/total_moles
			to_chat(user, "<span class='alert'>[env_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_concentration*100, 0.01)] % ([round(env_gases[id][MOLES], 0.01)] mol)</span>")
		to_chat(user, "<span class='info'>Temperature: [round(environment.temperature-T0C, 0.01)] &deg;C ([round(environment.temperature, 0.01)] K)</span>")

//If medicalTricorder is set to 0 then the tricorder will not be as effective as a regular medical scanner
proc/lesserhealthscan(mob/user, mob/living/M)
	if(isliving(user) && (user.incapacitated() || user.eye_blind))
		return
	//Damage specifics
	var/oxy_loss = M.getOxyLoss()
	var/tox_loss = M.getToxLoss()
	var/fire_loss = M.getFireLoss()
	var/brute_loss = M.getBruteLoss()

	//Health analyzers (and thus tricorders) warn you about very cold people, like thralls or victims of shadowlings.
	if(M.mind?.has_antag_datum(ANTAG_DATUM_THRALL) || M.bodytemperature < (11 + T0C))
		//Thralls get a fake temperature so they always read as too cold.
		var/faketemp = (M.mind?.has_antag_datum(ANTAG_DATUM_THRALL) ? M.bodytemperature - rand(25, 26) : M.bodytemperature)
		to_chat(user, "<span class='danger'>Body temperature: [round(faketemp - T0C,0.1)] &deg;C ([round(faketemp*1.8-459.67,0.1)] &deg;F)</span>")
		to_chat(user, "<span class='danger'>Internal temperature hazardously low.</span>")
	else
		to_chat(user, "<span class='info'>Body temperature: [round(M.bodytemperature-T0C,0.1)] &deg;C ([round(M.bodytemperature*1.8-459.67,0.1)] &deg;F)</span>")

	// Damage descriptions
	// Tricorder can detect damage but can only give estimates in most cases
	if(brute_loss > 5)
		to_chat(user, "\t[brute_loss > 100 ? "Catastrophic" : brute_loss > 75 ? "Extreme" : brute_loss > 50 ? "Severe" : "Minor"] tissue damage detected.</span>")
	if(fire_loss > 5)
		to_chat(user, "\t[fire_loss > 100 ? "Catastrophic" : fire_loss > 75 ? "Extreme" : fire_loss > 50 ? "Severe" : "Minor"] burn damage detected.</span>")
	if(oxy_loss > 5)
		to_chat(user, "\t[oxy_loss > 100 ? "Catastrophic" : oxy_loss > 75 ? "Extreme" : oxy_loss > 50 ? "Severe" : "Minor"] oxygen deprivation detected.</span>")
	if(tox_loss > 5)
		to_chat(user, "\t[tox_loss > 100 ? "Catastrophic" : tox_loss > 75 ? "Extreme" : tox_loss > 50 ? "Severe" : "Minor"] blood toxin levels detected.</span>")
	if (M.getBrainLoss() >= 200 || !M.getorgan(/obj/item/organ/brain))
		to_chat(user, "\t<span class='alert'>Subject's brain function is non-existent.</span>")
	else if (M.getBrainLoss() >= 120)
		to_chat(user, "\t<span class='alert'>Severe brain damage detected. Subject likely to have mental traumas.</span>")
	else if (M.getBrainLoss() >= 45)
		to_chat(user, "\t<span class='alert'>Brain damage detected.</span>")
	if (M.radiation)
		to_chat(user, "\t<span class='alert'>Subject is irradiated.</span>")
		to_chat(user, "\t<span class='info'>Radiation Level: [M.radiation]%.</span>")

	// Time of death
	if(M.tod && (M.stat == DEAD))
		to_chat(user, "<span class='info'>Time of Death:</span> [M.tod]")
