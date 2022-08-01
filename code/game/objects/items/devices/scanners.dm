
/*

CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
SLIME SCANNER
NANITE SCANNER
GENE SCANNER
*/

// Describes the three modes of scanning available for health analyzers
#define SCANMODE_HEALTH		0
#define SCANMODE_CHEMICAL 	1
#define SCANMODE_WOUND	 	2

/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	custom_price = 10
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	var/on = FALSE
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	materials = list(/datum/material/iron=150)

/obj/item/t_scanner/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to emit terahertz-rays into [user.p_their()] brain with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/t_scanner/proc/toggle_on()
	on = !on
	icon_state = copytext_char(icon_state, 1, -1) + "[on]"
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/t_scanner/attack_self(mob/user)
	toggle_on()

/obj/item/t_scanner/cyborg_unequip(mob/user)
	if(!on)
		return
	toggle_on()

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc)

/proc/t_ray_scan(mob/viewer, flick_time = 8, distance = 3)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/obj/O in orange(distance, viewer) )
		if(O.level != 1)
			continue

		if(O.invisibility == INVISIBILITY_MAXIMUM || HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I
	if(t_ray_images.len)
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

/obj/item/healthanalyzer
	name = "health analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=200)
	var/scanmode = 0
	var/advanced = FALSE
	var/beep_cooldown = 0

/obj/item/healthanalyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/obj/item/healthanalyzer/attack_self(mob/user)
	scanmode = (scanmode + 1) % 3
	switch(scanmode)
		if(SCANMODE_HEALTH)
			to_chat(user, span_notice("You switch the health analyzer to check physical health."))
		if(SCANMODE_CHEMICAL)
			to_chat(user, span_notice("You switch the health analyzer to scan chemical contents."))
		if(SCANMODE_WOUND)
			to_chat(user, span_notice("You switch the health analyzer to report extra info on wounds."))

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)
	flick("[icon_state]-scan", src)	//makes it so that it plays the scan animation upon scanning, including clumsy scanning
	if(beep_cooldown<world.time)
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		beep_cooldown = world.time+40

	// Clumsiness/brain damage check
	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		to_chat(user, span_notice("You stupidly try to analyze the floor's vitals!"))
		user.visible_message(span_warning("[user] has analyzed the floor's vitals!"))
		to_chat(user, span_info("Analyzing results for The floor:\n\tOverall status: <b>Healthy</b>"))
		to_chat(user, span_info("Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font>"))
		to_chat(user, span_info("\tDamage specifics: <font color='blue'>0</font>-<font color='green'>0</font>-<font color='#FF8000'>0</font>-<font color='red'>0</font>"))
		to_chat(user, span_info("Body temperature: ???"))
		return

	user.visible_message(span_notice("[user] has analyzed [M]'s vitals."))

	switch(scanmode)
		if(SCANMODE_HEALTH)
			healthscan(user, M, advanced)
		if(SCANMODE_CHEMICAL)
			chemscan(user, M)
		else
			woundscan(user, M, src)

	add_fingerprint(user)


// Used by the PDA medical scanner too
/proc/healthscan(mob/user, mob/living/M, advanced = FALSE)
	if(isliving(user) && (user.incapacitated() || user.eye_blind))
		return
	//Damage specifics
	var/oxy_loss = M.getOxyLoss()
	var/tox_loss = M.getToxLoss()
	var/fire_loss = M.getFireLoss()
	var/brute_loss = M.getBruteLoss()
	var/mob_status = (M.stat == DEAD ? span_alert("<b>Deceased</b>") : "<b>[round(M.health/M.maxHealth,0.01)*100] % healthy</b>")

	if(HAS_TRAIT(M, TRAIT_FAKEDEATH) && !advanced)
		mob_status = span_alert("<b>Deceased</b>")
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.undergoing_cardiac_arrest() && H.stat != DEAD)
			to_chat(user, span_danger("Subject suffering from heart attack: Apply defibrillation or other electric shock immediately!"))

	to_chat(user, span_info("Analyzing results for [M]:\n\tOverall status: [mob_status]"))

	// Damage descriptions
	if(brute_loss > 10)
		to_chat(user, "\t[span_alert("[brute_loss > 50 ? "Severe" : "Minor"] tissue damage detected.")]")
	if(fire_loss > 10)
		to_chat(user, "\t[span_alert("[fire_loss > 50 ? "Severe" : "Minor"] burn damage detected.")]")
	if(oxy_loss > 10)
		to_chat(user, "\t<span class='info'>[span_alert("[oxy_loss > 50 ? "Severe" : "Minor"] oxygen deprivation detected.")]")
	if(tox_loss > 10)
		to_chat(user, "\t[span_alert("[tox_loss > 50 ? "Severe" : "Minor"] amount of toxin damage detected.")]")
	if(M.getStaminaLoss())
		to_chat(user, "\t[span_alert("Subject appears to be suffering from fatigue.")]")
		if(advanced)
			to_chat(user, "\t[span_info("Fatigue Level: [M.getStaminaLoss()]%.")]")
	if (M.getCloneLoss())
		to_chat(user, "\t[span_alert("Subject appears to have [M.getCloneLoss() > 30 ? "Severe" : "Minor"] cellular damage.")]")
		if(advanced)
			to_chat(user, "\t[span_info("Cellular Damage Level: [M.getCloneLoss()].")]")
	if (!M.getorgan(/obj/item/organ/brain))
		to_chat(user, "\t[span_alert("Subject lacks a brain.")]")
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(LAZYLEN(C.get_traumas()))
			var/list/trauma_text = list()
			for(var/datum/brain_trauma/B in C.get_traumas())
				var/trauma_desc = ""
				switch(B.resilience)
					if(TRAUMA_RESILIENCE_SURGERY)
						trauma_desc += "severe "
					if(TRAUMA_RESILIENCE_LOBOTOMY)
						trauma_desc += "deep-rooted "
					if(TRAUMA_RESILIENCE_WOUND)
						trauma_desc += "fracture-derived "
					if(TRAUMA_RESILIENCE_MAGIC, TRAUMA_RESILIENCE_ABSOLUTE)
						trauma_desc += "permanent "
				trauma_desc += B.scan_desc
				trauma_text += trauma_desc
			to_chat(user, "\t[span_alert("Cerebral traumas detected: subject appears to be suffering from [english_list(trauma_text)].")]")
		if(C.roundstart_quirks.len)
			to_chat(user, "\t[span_info("Subject has the following physiological traits: [C.get_trait_string()].")]")
		if(C.has_quirk(/datum/quirk/allergic))
			to_chat(user, "\t[span_info("Subject is allergic to the chemical [C.allergies].")]")
	if(advanced)
		to_chat(user, "\t[span_info("Brain Activity Level: [(200 - M.getOrganLoss(ORGAN_SLOT_BRAIN))/2]%.")]")
		if(M.has_horror_inside())
			to_chat(user, "\t[span_alert("Detected parasitic organism residing in the cranial area.")]")
			to_chat(user, "\t[span_alert("Recommended course of action: <b>organ manipulation surgery performed on head.</b>.")]")

	if (M.radiation)
		to_chat(user, "\t[span_alert("Subject is irradiated.")]")
		if(advanced)
			to_chat(user, "\t[span_info("Radiation Level: [M.radiation]%.")]")

	if(advanced && M.hallucinating())
		to_chat(user, "\t[span_info("Subject is hallucinating.")]")

	//Eyes and ears
	if(advanced)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
			to_chat(user, "\t<span class='info'><b>==EAR STATUS==</b></span>")
			if(istype(ears))
				var/healthy = TRUE
				if(HAS_TRAIT_FROM(C, TRAIT_DEAF, GENETIC_MUTATION))
					healthy = FALSE
					to_chat(user, "\t[span_alert("Subject is genetically deaf.")]")
				else if(HAS_TRAIT(C, TRAIT_DEAF))
					healthy = FALSE
					to_chat(user, "\t[span_alert("Subject is deaf.")]")
				else
					if(ears.damage)
						to_chat(user, "\t[span_alert("Subject has [ears.damage > ears.maxHealth ? "permanent ": "temporary "]hearing damage.")]")
						healthy = FALSE
					if(ears.deaf)
						to_chat(user, "\t[span_alert("Subject is [ears.damage > ears.maxHealth ? "permanently ": "temporarily "] deaf.")]")
						healthy = FALSE
				if(healthy)
					to_chat(user, "\t[span_info("Healthy.")]")
			else
				to_chat(user, "\t[span_alert("Subject does not have ears.")]")
			var/obj/item/organ/eyes/eyes = C.getorganslot(ORGAN_SLOT_EYES)
			to_chat(user, "\t<span class='info'><b>==EYE STATUS==</b></span>")
			if(istype(eyes))
				var/healthy = TRUE
				if(HAS_TRAIT(C, TRAIT_BLIND))
					to_chat(user, "\t[span_alert("Subject is blind.")]")
					healthy = FALSE
				if(HAS_TRAIT(C, TRAIT_NEARSIGHT))
					to_chat(user, "\t[span_alert("Subject is nearsighted.")]")
					healthy = FALSE
				if(eyes.damage > 30)
					to_chat(user, "\t[span_alert("Subject has severe eye damage.")]")
					healthy = FALSE
				else if(eyes.damage > 20)
					to_chat(user, "\t[span_alert("Subject has significant eye damage.")]")
					healthy = FALSE
				else if(eyes.damage)
					to_chat(user, "\t[span_alert("Subject has minor eye damage.")]")
					healthy = FALSE
				if(healthy)
					to_chat(user, "\t[span_info("Healthy.")]")
			else
				to_chat(user, "\t[span_alert("Subject does not have eyes.")]")


	// Body part damage report
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/list/damaged = C.get_damaged_bodyparts(1,1)
		if(length(damaged)>0 || oxy_loss>0 || tox_loss>0 || fire_loss>0)
			to_chat(user, span_info("\tDamage: <span class='info'><font color='red'>Brute</font></span>-<font color='#FF8000'>Burn</font>-<font color='green'>Toxin</font>-<font color='blue'>Suffocation</font>\n\t\tSpecifics: <font color='red'>[brute_loss]</font>-<font color='#FF8000'>[fire_loss]</font>-<font color='green'>[tox_loss]</font>-<font color='blue'>[oxy_loss]</font>"))
			for(var/obj/item/bodypart/org in damaged)
				to_chat(user, "\t\t<span class='info'>[capitalize(org.name)]: [(org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font></span>" : "<font color='red'>0</font>"]-[(org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : "<font color='#FF8000'>0</font>"]")

	//Organ damages report
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/no_damage
		var/minor_damage
		var/major_damage
		var/max_damage
		var/report_organs = FALSE

		//Piece together the lists to be reported
		for(var/O in H.internal_organs)
			var/obj/item/organ/organ = O
			if(istype(O, /obj/item/organ/cyberimp))
				var/obj/item/organ/cyberimp/stealthcheck = O
				if(stealthcheck.syndicate_implant)
					continue
			if(organ.organ_flags & ORGAN_FAILING)
				report_organs = TRUE	//if we report one organ, we report all organs, even if the lists are empty, just for consistency
				if(max_damage)
					max_damage += ", "	//prelude the organ if we've already reported an organ
					max_damage += organ.name	//this just slaps the organ name into the string of text
				else
					max_damage = "\t<span class='alert'>Non-Functional Organs: "	//our initial statement
					max_damage += organ.name
			else if(organ.damage > organ.high_threshold)
				report_organs = TRUE
				if(major_damage)
					major_damage += ", "
					major_damage += organ.name
				else
					major_damage = "\t<span class='info'>Severely Damaged Organs: "
					major_damage += organ.name
			else if(organ.damage > organ.low_threshold)
				report_organs = TRUE
				if(minor_damage)
					minor_damage += ", "
					minor_damage += organ.name
				else
					minor_damage = "\t<span class='info'>Mildly Damaged Organs: "
					minor_damage += organ.name
			else if ((organ.damage < organ.low_threshold) && (organ.name != "festering ooze"))
				report_organs = TRUE // if no organs get reported, it means they have no organs
				if(no_damage)
					no_damage += ", "
					no_damage += organ.name
				else
					no_damage = "\t<span class='info'>Healthy Organs: "
					no_damage += organ.name

		if(report_organs)	//we either finish the list, or set it to be empty if no organs were reported in that category
			if(!max_damage)
				max_damage = "\t[span_alert("Non-Functional Organs: ")]"
			else
				max_damage += "</span>"
			if(!major_damage)
				major_damage = "\t[span_info("Severely Damaged Organs: ")]"
			else
				major_damage += "</span>"
			if(!minor_damage)
				minor_damage = "\t[span_info("Mildly Damaged Organs: ")]"
			else
				minor_damage += "</span>"
			if(!no_damage)
				no_damage = "\t[span_info("Healthy Organs: ")]"
			else
				no_damage += "</span>"
			to_chat(user, no_damage)
			to_chat(user, minor_damage)
			to_chat(user, major_damage)
			to_chat(user, max_damage)
		//Genetic damage
		if(advanced && H.has_dna())
			to_chat(user, "\t[span_info("Genetic Stability: [H.dna.stability]%.")]")

	// Species and body temperature
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/species/S = H.dna.species
		var/mutant = FALSE
		if (H.dna.check_mutation(HULK) || H.dna.check_mutation(ACTIVE_HULK))
			mutant = TRUE
		else if (S.mutantlungs != initial(S.mutantlungs))
			mutant = TRUE
		else if (S.mutant_brain != initial(S.mutant_brain))
			mutant = TRUE
		else if (S.mutant_heart != initial(S.mutant_heart))
			mutant = TRUE
		else if (S.mutanteyes != initial(S.mutanteyes))
			mutant = TRUE
		else if (S.mutantears != initial(S.mutantears))
			mutant = TRUE
		else if (S.mutanthands != initial(S.mutanthands))
			mutant = TRUE
		else if (S.mutanttongue != initial(S.mutanttongue))
			mutant = TRUE
		else if (S.mutanttail != initial(S.mutanttail))
			mutant = TRUE
		else if (S.mutantliver != initial(S.mutantliver))
			mutant = TRUE
		else if (S.mutantstomach != initial(S.mutantstomach))
			mutant = TRUE

		to_chat(user, span_info("Species: [S.name][mutant ? "-derived mutant" : ""]"))
	var/temp_span = "notice"
	if(M.bodytemperature <= BODYTEMP_HEAT_DAMAGE_LIMIT || M.bodytemperature >= BODYTEMP_COLD_DAMAGE_LIMIT)
		temp_span = "warning"
	
	to_chat(user, "<span_class = '[temp_span]'>Body temperature: [round(M.bodytemperature-T0C,0.1)] &deg;C ([round(M.bodytemperature*1.8-459.67,0.1)] &deg;F)</span>")

	// Time of death
	if(M.tod && (M.stat == DEAD || ((HAS_TRAIT(M, TRAIT_FAKEDEATH)) && !advanced)))
		to_chat(user, "[span_info("Time of Death:")] [M.tod]")
		var/tdelta = round(world.time - M.timeofdeath)
		if(tdelta < (DEFIB_TIME_LIMIT))
			to_chat(user, span_danger("Subject died [DisplayTimeText(tdelta)] ago, defibrillation may be possible!"))

	// Wounds
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/list/wounded_parts = C.get_wounded_bodyparts()
		for(var/i in wounded_parts)
			var/obj/item/bodypart/wounded_part = i
			var/render_list = "<span class='alert ml-1'><b>Warning: Physical trauma[LAZYLEN(wounded_part.wounds) > 1? "s" : ""] detected in [wounded_part.name]</b>"
			for(var/k in wounded_part.wounds)
				var/datum/wound/W = k
				render_list += "<div class='ml-2'>Type: [W.name]\nSeverity: [W.severity_text()]\nRecommended Treatment: [W.treat_text]</div>\n" // less lines than in woundscan() so we don't overload people trying to get basic med info
			render_list += "</span>"
			to_chat(render_list)

	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			to_chat(user, span_alert("<b>Warning: [D.form] detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text].")) //Yogs - Added a "."

	// Blood Level
	if(M.has_dna())
		var/mob/living/carbon/C = M
		var/blood_id = C.get_blood_id()
		if(blood_id)
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(H.is_bleeding())
					to_chat(user, span_danger("Subject is bleeding!"))
			var/blood_percent =  round((C.blood_volume / BLOOD_VOLUME_NORMAL(C))*100)
			var/blood_type = C.dna.blood_type
			if(blood_id != /datum/reagent/blood)//special blood substance
				var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
				if(R)
					blood_type = R.name
				else
					blood_type = blood_id
			if(HAS_TRAIT(M, TRAIT_MASQUERADE)) //bloodsuckers
				to_chat(user, span_info("Blood level 100%, 560 cl, type: [blood_type]"))
			else if(C.blood_volume <= BLOOD_VOLUME_SAFE(C) && C.blood_volume > BLOOD_VOLUME_OKAY(C))
				to_chat(user, "[span_danger("LOW blood level [blood_percent] %, [C.blood_volume] cl,")] [span_info("type: [blood_type]")]")
			else if(C.blood_volume <= BLOOD_VOLUME_OKAY(C))
				to_chat(user, "[span_danger("CRITICAL blood level [blood_percent] %, [C.blood_volume] cl,")] [span_info("type: [blood_type]")]")
			else
				to_chat(user, span_info("Blood level [blood_percent] %, [C.blood_volume] cl, type: [blood_type]"))

		var/cyberimp_detect
		for(var/obj/item/organ/cyberimp/CI in C.internal_organs)
			if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
				cyberimp_detect += "[C.name] is modified with a [CI.name].<br>"
		if(cyberimp_detect)
			to_chat(user, span_notice("Detected cybernetic modifications:"))
			to_chat(user, span_notice("[cyberimp_detect]"))
	SEND_SIGNAL(M, COMSIG_NANITE_SCAN, user, FALSE)

/proc/chemscan(mob/living/user, mob/living/M)
	if(istype(M))
		if(M.reagents)
			if(M.reagents.reagent_list.len)
				to_chat(user, span_notice("Subject contains the following reagents:"))
				for(var/datum/reagent/R in M.reagents.reagent_list)
					to_chat(user, "[span_notice("[round(R.volume, 0.001)] units of [R.name]")][R.overdosed == 1 ? "- [span_boldannounce("OVERDOSING")]" : "."]")
			else
				to_chat(user, span_notice("Subject contains no reagents."))
			if(M.reagents.addiction_list.len)
				to_chat(user, span_boldannounce("Subject is addicted to the following reagents:"))
				for(var/datum/reagent/R in M.reagents.addiction_list)
					to_chat(user, span_danger("[R.name]"))
			else
				to_chat(user, span_notice("Subject is not addicted to any reagents."))

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	icon_state = "health_adv"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	advanced = TRUE
	var/list/advanced_surgeries = list()

/obj/item/healthanalyzer/advanced/afterattack(obj/item/O, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(O, /obj/item/disk/surgery))
		to_chat(user, span_notice("You load the surgery protocol from [O] into [src]."))
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 1 SECONDS, O))
			advanced_surgeries |= D.surgeries
		return TRUE
	if(istype(O, /obj/machinery/computer/operating))
		to_chat(user, span_notice("You copy surgery protocols from [O] into [src]."))
		var/obj/machinery/computer/operating/OC = O
		if(do_after(user, 1 SECONDS, O))
			advanced_surgeries |= OC.advanced_surgeries
		return TRUE
	return

/obj/item/healthanalyzer/advanced/debug/Initialize()
	. = ..()
	advanced_surgeries = subtypesof(/datum/surgery)

/// Displays wounds with extended information on their status vs medscanners
/proc/woundscan(mob/user, mob/living/carbon/patient, obj/item/healthanalyzer/wound/scanner)
	if(!istype(patient))
		return

	var/render_list = ""
	for(var/i in patient.get_wounded_bodyparts())
		var/obj/item/bodypart/wounded_part = i
		render_list += "<span class='alert ml-1'><b>Warning: Physical trauma[LAZYLEN(wounded_part.wounds) > 1? "s" : ""] detected in [wounded_part.name]</b>"
		for(var/k in wounded_part.wounds)
			var/datum/wound/W = k
			render_list += "<div class='ml-2'>[W.get_scanner_description()]</div>\n"
		render_list += "</span>"

	if(render_list == "")
		if(istype(scanner))
			// Only emit the cheerful scanner message if this scan came from a scanner
			playsound(scanner, 'sound/machines/ping.ogg', 50, FALSE)
			to_chat(user, span_notice("\The [scanner] makes a happy ping and briefly displays a smiley face with several exclamation points! It's really excited to report that [patient] has no wounds!"))
		else
			to_chat(user, "<span class='notice ml-1'>No wounds detected in subject.</span>")
	else
		to_chat(user, jointext(render_list, ""))

/obj/item/healthanalyzer/wound
	name = "first aid analyzer"
	icon_state = "adv_spectrometer"
	desc = "A prototype MeLo-Tech medical scanner used to diagnose injuries and recommend treatment for serious wounds, but offers no further insight into the patient's health. You hope the final version is less annoying to read!"
	var/next_encouragement
	var/greedy

/obj/item/healthanalyzer/wound/attack_self(mob/user)
	if(next_encouragement < world.time)
		playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
		var/list/encouragements = list("briefly displays a happy face, gazing emptily at you", "briefly displays a spinning cartoon heart", "displays an encouraging message about eating healthy and exercising", \
				"reminds you that everyone is doing their best", "displays a message wishing you well", "displays a sincere thank-you for your interest in first-aid", "formally absolves you of all your sins")
		to_chat(user, span_notice("\The [src] makes a happy ping and [pick(encouragements)]!"))
		next_encouragement = world.time + 10 SECONDS
		greedy = FALSE
	else if(!greedy)
		to_chat(user, span_warning("\The [src] displays an eerily high-definition frowny face, chastizing you for asking it for too much encouragement."))
		greedy = TRUE
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		if(isliving(user))
			var/mob/living/L = user
			if(L.getBruteLoss() >= 10)
				to_chat(L, span_warning("\The [src] makes a disappointed buzz, chastizing you for asking it for too much encouragement."))
				return
			to_chat(L, span_warning("\The [src] makes a disappointed buzz and pricks your finger for being greedy. Ow!"))
			L.adjustBruteLoss(4)
			L.dropItemToGround(src)

/obj/item/healthanalyzer/wound/attack(mob/living/carbon/patient, mob/living/carbon/human/user)
	add_fingerprint(user)
	user.visible_message(span_notice("[user] scans [patient] for serious injuries."), span_notice("You scan [patient] for serious injuries."))

	if(!istype(patient))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		to_chat(user, span_notice("\The [src] makes a sad buzz and briefly displays a frowny face, indicating it can't scan [patient]."))
		return

	woundscan(user, patient, src)

/obj/item/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels. Alt-Click to use the built in barometer function."
	name = "analyzer"
	custom_price = 10
	icon = 'icons/obj/device.dmi'
	icon_state = "analyzer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	tool_behaviour = TOOL_ANALYZER
	materials = list(/datum/material/iron=30, /datum/material/glass=20)
	grind_results = list(/datum/reagent/mercury = 5, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to activate the barometer function.")

/obj/item/analyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/obj/item/analyzer/attackby(obj/O, mob/living/user)
	if(istype(O, /obj/item/bodypart/l_arm/robot) || istype(O, /obj/item/bodypart/r_arm/robot))
		to_chat(user, "<span class='notice'>You add [O] to [src].</span>")
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/atmosbot)
	else
		..()
		
/obj/item/analyzer/attack_self(mob/user)
	add_fingerprint(user)
	scangasses(user)			//yogs start: Makes the gas scanning able to be used elseware

/obj/item/proc/scangasses(mob/user)
	//yogs stop

	if (user.stat || user.eye_blind)
		return

	if(!isopenturf(get_turf(user)))
		return

	var/datum/gas_mixture/environment = user.return_air()

	if(!environment)
		to_chat(user, span_info("No air detected."))
		return

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	to_chat(user, span_info("<B>Results:</B>"))
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(user, span_info("Pressure: [round(pressure, 0.01)] kPa"))
	else
		to_chat(user, span_alert("Pressure: [round(pressure, 0.01)] kPa"))
	if(total_moles)
		var/o2_concentration = environment.get_moles(GAS_O2)/total_moles
		var/n2_concentration = environment.get_moles(GAS_N2)/total_moles
		var/co2_concentration = environment.get_moles(GAS_CO2)/total_moles
		var/plasma_concentration = environment.get_moles(GAS_PLASMA)/total_moles

		if(abs(n2_concentration - N2STANDARD) < 20)
			to_chat(user, span_info("Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_N2), 0.01)] mol)"))
		else
			to_chat(user, span_alert("Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_N2), 0.01)] mol)"))

		if(abs(o2_concentration - O2STANDARD) < 2)
			to_chat(user, span_info("Oxygen: [round(o2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_O2), 0.01)] mol)"))
		else
			to_chat(user, span_alert("Oxygen: [round(o2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_O2), 0.01)] mol)"))

		if(co2_concentration > 0.01)
			to_chat(user, span_alert("CO2: [round(co2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_CO2), 0.01)] mol)"))
		else
			to_chat(user, span_info("CO2: [round(co2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_CO2), 0.01)] mol)"))

		if(plasma_concentration > 0.005)
			to_chat(user, span_alert("Plasma: [round(plasma_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_PLASMA), 0.01)] mol)"))
		else
			to_chat(user, span_info("Plasma: [round(plasma_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_PLASMA), 0.01)] mol)"))

		for(var/id in environment.get_gases())
			if(id in GLOB.hardcoded_gases)
				continue
			var/gas_concentration = environment.get_moles(id)/total_moles
			to_chat(user, span_alert("[GLOB.gas_data.names[id]]: [round(gas_concentration*100, 0.01)] % ([round(environment.get_moles(id), 0.01)] mol)"))
		to_chat(user, span_info("Temperature: [round(environment.return_temperature()-T0C, 0.01)] &deg;C ([round(environment.return_temperature(), 0.01)] K)"))

/obj/item/analyzer/AltClick(mob/user) //Barometer output for measuring when the next storm happens
	..()

	if(user.canUseTopic(src, BE_CLOSE))

		if(cooldown)
			to_chat(user, span_warning("[src]'s barometer function is preparing itself."))
			return

		var/turf/T = get_turf(user)
		if(!T)
			return

		playsound(src, 'sound/effects/pop.ogg', 100)
		var/area/user_area = T.loc
		var/datum/weather/ongoing_weather = null

		if(!user_area.outdoors)
			to_chat(user, span_warning("[src]'s barometer function won't work indoors!"))
			return

		for(var/V in SSweather.processing)
			var/datum/weather/W = V
			if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
				ongoing_weather = W
				break

		if(ongoing_weather)
			if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
				to_chat(user, span_warning("[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]"))
				return

			to_chat(user, span_notice("The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)]."))
			if(ongoing_weather.aesthetic)
				to_chat(user, span_warning("[src]'s barometer function says that the next storm will breeze on by."))
		else
			var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
			var/fixed = next_hit ? next_hit - world.time : -1
			if(fixed < 0)
				to_chat(user, span_warning("[src]'s barometer function was unable to trace any weather patterns."))
			else
				to_chat(user, span_warning("[src]'s barometer function says a storm will land in approximately [butchertime(fixed)]."))
		cooldown = TRUE
		addtimer(CALLBACK(src,/obj/item/analyzer/proc/ping), cooldown_time)

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_notice("[src]'s barometer function is ready!"))
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(accuracy)
		var/inaccurate = round(accuracy*(1/3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1,amount))

/proc/atmosanalyzer_scan(mixture, mob/living/user, atom/target = src)
	var/icon = target
	user.visible_message("[user] has used the analyzer on [icon2html(icon, viewers(user))] [target].", span_notice("You use the analyzer on [icon2html(icon, user)] [target]."))
	to_chat(user, span_boldnotice("Results of analysis of [icon2html(icon, user)] [target]."))

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	for(var/g in airs)
		if(airs.len > 1) //not a unary gas mixture
			to_chat(user, span_boldnotice("Node [airs.Find(g)]"))
		var/datum/gas_mixture/air_contents = g

		var/total_moles = air_contents.total_moles()
		var/pressure = air_contents.return_pressure()
		var/volume = air_contents.return_volume() //could just do mixture.volume... but safety, I guess?
		var/temperature = air_contents.return_temperature()
		var/cached_scan_results = air_contents.analyzer_results

		if(total_moles > 0)
			to_chat(user, span_notice("Moles: [round(total_moles, 0.01)] mol"))
			to_chat(user, span_notice("Volume: [volume] L"))
			to_chat(user, span_notice("Pressure: [round(pressure,0.01)] kPa"))

			for(var/id in air_contents.get_gases())
				var/gas_concentration = air_contents.get_moles(id)/total_moles
				to_chat(user, span_notice("[GLOB.gas_data.names[id]]: [round(gas_concentration*100, 0.01)] % ([round(air_contents.get_moles(id), 0.01)] mol)"))
			to_chat(user, span_notice("Temperature: [round(temperature - T0C,0.01)] &deg;C ([round(temperature, 0.01)] K)"))

		else
			if(airs.len > 1)
				to_chat(user, span_notice("This node is empty!"))
			else
				to_chat(user, span_notice("[target] is empty!"))

		if(cached_scan_results && cached_scan_results["fusion"]) //notify the user if a fusion reaction was detected
			var/instability = round(cached_scan_results["fusion"], 0.01)
			to_chat(user, span_boldnotice("Large amounts of free neutrons detected in the air indicate that a fusion reaction took place."))
			to_chat(user, span_notice("Instability of the last fusion reaction: [instability]."))
	return

//slime scanner

/obj/item/slime_scanner
	name = "slime scanner"
	desc = "A device that analyzes a slime's internal composition and measures its stats."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=30, /datum/material/glass=20)

/obj/item/slime_scanner/attack(mob/living/M, mob/living/user)
	if(user.stat || user.eye_blind)
		return
	if (!isslime(M))
		to_chat(user, span_warning("This device can only scan slimes!"))
		return
	var/mob/living/simple_animal/slime/T = M
	playsound(src, 'sound/effects/scanbeep.ogg', 30)
	slime_scan(T, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	to_chat(user, "========================")
	to_chat(user, "<b>Slime scan results:</b>")
	to_chat(user, span_notice("[T.colour] [T.is_adult ? "adult" : "baby"] slime"))
	to_chat(user, "Nutrition: [T.nutrition]/[T.get_max_nutrition()]")
	if (T.nutrition < T.get_starve_nutrition())
		to_chat(user, span_warning("Warning: slime is starving!"))
	else if (T.nutrition < T.get_hunger_nutrition())
		to_chat(user, span_warning("Warning: slime is hungry"))
	to_chat(user, "Electric charge strength: [T.powerlevel]")
	to_chat(user, "Health: [round(T.health/T.maxHealth,0.01)*100]%")
	if (T.slime_mutation[4] == T.colour)
		to_chat(user, "This slime does not evolve any further.")
	else
		if (T.slime_mutation[3] == T.slime_mutation[4])
			if (T.slime_mutation[2] == T.slime_mutation[1])
				to_chat(user, "Possible mutation: [T.slime_mutation[3]]")
				to_chat(user, "Genetic instability: [T.mutation_chance/2] % chance of mutation on splitting")
			else
				to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)")
				to_chat(user, "Genetic instability: [T.mutation_chance] % chance of mutation on splitting")
		else
			to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]")
			to_chat(user, "Genetic instability: [T.mutation_chance] % chance of mutation on splitting")
	if (T.cores > 1)
		to_chat(user, "Multiple cores detected")
	to_chat(user, "Growth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")
	if(T.effectmod)
		to_chat(user, span_notice("Core mutation in progress: [T.effectmod]"))
		to_chat(user, "<span class = 'notice'>Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]</span>")
	to_chat(user, "========================")


/obj/item/nanite_scanner
	name = "nanite scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_scanner"
	item_state = "nanite_remote"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner able to detect nanites and their programming."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=200)

/obj/item/nanite_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	user.visible_message(span_notice("[user] has analyzed [M]'s nanites."))

	add_fingerprint(user)

	var/response = SEND_SIGNAL(M, COMSIG_NANITE_SCAN, user, TRUE)
	if(!response)
		to_chat(user, span_info("No nanites detected in the subject."))

/obj/item/sequence_scanner
	name = "genetic sequence scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "gene"
	item_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held scanner for analyzing someones gene sequence on the fly. Hold near a DNA console to update the internal database."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=200)
	var/list/discovered = list() //hit a dna console to update the scanners database
	var/list/buffer
	var/ready = TRUE
	var/cooldown = 200

/obj/item/sequence_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	add_fingerprint(user)
	if (!HAS_TRAIT(M, TRAIT_GENELESS) && !HAS_TRAIT(M, TRAIT_BADDNA)) //no scanning if its a husk or DNA-less Species
		user.visible_message(span_notice("[user] has analyzed [M]'s genetic sequence."))
		gene_scan(M, user)

	else
		user.visible_message(span_notice("[user] failed to analyse [M]'s genetic sequence."), span_warning("[M] has no readable genetic sequence!"))

/obj/item/sequence_scanner/attack_self(mob/user)
	display_sequence(user)

/obj/item/sequence_scanner/attack_self_tk(mob/user)
	return

/obj/item/sequence_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return

	if(istype(O, /obj/machinery/computer/scan_consolenew))
		var/obj/machinery/computer/scan_consolenew/C = O
		if(C.stored_research)
			to_chat(user, span_notice("[name] database updated."))
			discovered = C.stored_research.discovered_mutations
		else
			to_chat(user,span_warning("No database to update from."))

/obj/item/sequence_scanner/proc/gene_scan(mob/living/carbon/C, mob/living/user)
	if(!iscarbon(C) || !C.has_dna())
		return
	buffer = C.dna.mutation_index
	to_chat(user, span_notice("Subject [C.name]'s DNA sequence has been saved to buffer."))
	if(LAZYLEN(buffer))
		for(var/A in buffer)
			to_chat(user, span_notice("[get_display_name(A)]"))


/obj/item/sequence_scanner/proc/display_sequence(mob/living/user)
	if(!LAZYLEN(buffer) || !ready)
		return
	var/list/options = list()
	for(var/A in buffer)
		options += get_display_name(A)

	var/answer = input(user, "Analyze Potential", "Sequence Analyzer")  as null|anything in options
	if(answer && ready && user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		var/sequence
		for(var/A in buffer) //this physically hurts but i dont know what anything else short of an assoc list
			if(get_display_name(A) == answer)
				sequence = buffer[A]
				break

		if(sequence)
			var/display
			for(var/i in 0 to length_char(sequence) / DNA_MUTATION_BLOCKS-1)
				if(i)
					display += "-"
				display += copytext_char(sequence, 1 + i*DNA_MUTATION_BLOCKS, DNA_MUTATION_BLOCKS*(1+i) + 1)

			to_chat(user, "[span_boldnotice("[display]")]<br>")

		ready = FALSE
		icon_state = "[icon_state]_recharging"
		addtimer(CALLBACK(src, .proc/recharge), cooldown, TIMER_UNIQUE)

/obj/item/sequence_scanner/proc/recharge()
	icon_state = initial(icon_state)
	ready = TRUE

/obj/item/sequence_scanner/proc/get_display_name(mutation)
	var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(mutation)
	if(!HM)
		return "ERROR"
	if(mutation in discovered)
		return  "[HM.name] ([HM.alias])"
	else
		return HM.alias

/obj/item/scanner_wand
	name = "kiosk scanner wand"
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner_wand"
	item_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A wand that medically scans people. Inserting it into a medical kiosk makes it able to perform a health scan on the patient."
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_BULKY
	var/selected_target = null

/obj/item/scanner_wand/attack(mob/living/M, mob/living/carbon/human/user)
	flick("[icon_state]_active", src) //nice little visual flash when scanning someone else.

	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(25))
		user.visible_message(span_warning("[user] targets himself for scanning."), \
		to_chat(user, span_info("You try scanning [M], before realizing you're holding the scanner backwards. Whoops.")))
		selected_target = user
		return

	if(!ishuman(M))
		to_chat(user, span_info("You can only scan human-like, non-robotic beings."))
		selected_target = null
		return

	user.visible_message(span_notice("[user] targets [M] for scanning."), \
						span_notice("You target [M] vitals."))
	selected_target = M
	return

/obj/item/scanner_wand/attack_self(mob/user)
	to_chat(user, span_info("You clear the scanner's target."))
	selected_target = null

/obj/item/scanner_wand/proc/return_patient()
	var/returned_target = selected_target
	return returned_target

#undef SCANMODE_HEALTH
#undef SCANMODE_CHEMICAL
#undef SCANMODE_WOUND
