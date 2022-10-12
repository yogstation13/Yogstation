/*

CONTAINS:
TRICORDER

*/



//Tricorder
//The tricorder is a child of a multitool for the sole purpose to make it work with Tcomms

/obj/item/multitool/tricorder
	name = "tricorder"
	desc = "A multifunction handheld device useful for data sensing, analysis, and recording."
	icon = 'yogstation/icons/obj/device.dmi'
	icon_state = "tricorder"
	item_state = "tricorder"
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
	materials = list(/datum/material/iron=500,/datum/material/silver=300,/datum/material/gold=300)

	var/medicalTricorder = FALSE	//Set to TRUE for normal medical scanner, set to FALSE for a gutted version


/obj/item/multitool/tricorder/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] thinks today IS a good day to die!"))
	return BRUTELOSS


//Tricorder differentiates from slimes and nonslimes
/obj/item/multitool/tricorder/attack(mob/living/M, mob/living/user, obj/item/I)
	add_fingerprint(user)
	var/turf/U = get_turf(I)
	atmosanalyzer_scan(U.return_air(), user, I)
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

//Gas Analyzer Tank Scan
/obj/item/multitool/tricorder/afterattack(atom/A as obj, mob/user, proximity)
	if(!proximity)
		return
	A.analyzer_act(user, src)

//Gas Analyzer Turf Scan
/obj/item/multitool/tricorder/attack_self(mob/user)
	scangasses(user)

//If medicalTricorder is set to FALSE then the tricorder will not be as effective as a regular medical scanner
/obj/item/proc/lesserhealthscan(mob/user, mob/living/M)
	if(isliving(user) && (user.incapacitated() || user.eye_blind))
		return
	//Damage specifics
	var/oxy_damage = M.getOxyLoss()
	var/tox_damage = M.getToxLoss()
	var/fire_damage = M.getFireLoss()
	var/brute_damage = M.getBruteLoss()
	var/brain_status = M.getOrganLoss(ORGAN_SLOT_BRAIN)

	// Status Readout
	// Tricorder can detect damage but can only give estimates in most cases
	//Temperature
	to_chat(user, span_info("Body temperature: [round(M.bodytemperature-T0C,0.1)] &deg;C ([round(M.bodytemperature*1.8-459.67,0.1)] &deg;F)"))
	//Brute
	to_chat(user, "\t <font color='red'>*</font> Brute Damage: <font color ='orange'>[brute_damage > 100 ? "<font color='red'>Critical</font>" : brute_damage > 75 ? "Catastrophic" : brute_damage > 50 ? "Extreme" : brute_damage > 25 ? "Severe" : brute_damage > 0 ? "Minor" : "<font color='blue'>None</font>"]</font></span>")
	//Burn
	to_chat(user, "\t <font color='#FF8000'>*</font> Burn damage: <font color ='orange'>[fire_damage > 100 ? "<font color='red'>Critical</font>" : fire_damage > 75 ? "Catastrophic" : fire_damage > 50 ? "Extreme" : fire_damage > 25 ? "Severe" : fire_damage > 0 ? "Minor" : "<font color='blue'>None</font>"]</font></span>")
	//Oxygen
	to_chat(user, "\t <font color='blue'>*</font> Blood Oxygen Concentration: <font color ='orange'>[oxy_damage > 100 ? "<font color='red'>Critical</font>" : oxy_damage > 75 ? "Dangerous" : oxy_damage > 50 ? "Low" : oxy_damage > 25 ? "Concerning" : oxy_damage > 0 ? "High" : "<font color='blue'>Full</font>"]</font></span>")
	//Toxin
	to_chat(user, "\t <font color='green'>*</font> Blood Toxin Levels: <font color ='orange'>[tox_damage > 100 ? "<font color='red'>Critical</font>" : tox_damage > 75 ? "Catastrophic" : tox_damage > 50 ? "Extreme" : tox_damage > 25 ? "Severe" : tox_damage > 0 ? "Minor" : "<font color='blue'>None</font>"]</font></span>")
	//Brain
	to_chat(user, "\t <font color='Fuchsia'>*</font> Brain Activity: <font color ='orange'>[brain_status >= 200 ? "<font color='red'>Not Detected</font>" : brain_status > 100 ? "Low" : brain_status > 0 ? "High" : "<font color='blue'>Full</font>"]</font></span>")
	//Radiation
	to_chat(user, "\t <font color='yellow'>*</font> Radiation Levels: [M.radiation ? "<font color='red'>[M.radiation]</font>" : "<font color='blue'>None</font>"]</span>")
