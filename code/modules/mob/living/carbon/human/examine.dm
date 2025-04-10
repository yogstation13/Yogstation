#define ORGANIC_BRUTE "bruising"
#define ORGANIC_BURN "burns"
#define ROBOTIC_BRUTE "denting"
#define ROBOTIC_BURN "charring"

/mob/living/carbon/human/examine(mob/user)
//this is very slightly better than it was because you can use it more places. still can't do \his[src] though.
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()
	var/obscure_name
	var/robotic = FALSE //robotic mobs look different under certain circumstances
	if(mob_biotypes & MOB_ROBOTIC && !HAS_TRAIT(src, TRAIT_DISGUISED)) //if someone's trying to disguise, always use the default text, it's less obvious because people are used to it
		robotic = TRUE

	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_PROSOPAGNOSIA))
			obscure_name = TRUE

	. = list("<span class='info'>This is <EM>[!obscure_name ? name : "Unknown"]</EM>!")

	var/vampDesc = return_vamp_examine(user) // Fulpstation Bloodsuckers edit STARTS
	var/vassDesc = ReturnVassalExamine(user)
	if(vampDesc != "")
		. += vampDesc
	if(vassDesc != "")
		. += vassDesc // Fulpstation Bloodsucker edit ENDS

	var/list/obscured = check_obscured_slots()

	//uniform
	if(w_uniform && !(ITEM_SLOT_ICLOTHING in obscured))
		//accessory
		var/accessory_msg
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.attached_accessory)
				accessory_msg += " with [icon2html(U.attached_accessory, user)] \a [U.attached_accessory]"

		. += "[t_He] [t_is] wearing [w_uniform.get_examine_string(user)][accessory_msg]."
	//head
	if(head)
		. += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head."
	//suit/armor
	if(wear_suit)
		//badge
		var/badge_msg
		if(istype(wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/S = wear_suit
			if(S.attached_badge)
				badge_msg += " with [icon2html(S.attached_badge, user)] \a [S.attached_badge]"

		. += "[t_He] [t_is] wearing [wear_suit.get_examine_string(user)][badge_msg]."
		//suit/armor storage
		if(s_store && !(ITEM_SLOT_SUITSTORE in obscured))
			. += "[t_He] [t_is] carrying [s_store.get_examine_string(user)] on [t_his] [wear_suit.name]."
	//back
	if(back)
		. += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back."

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "[t_He] [t_is] holding [I.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(I))]."

	var/datum/component/forensics/FR = GetComponent(/datum/component/forensics)
	//gloves
	if(gloves && !(ITEM_SLOT_GLOVES in obscured))
		. += "[t_He] [t_has] [gloves.get_examine_string(user)] on [t_his] hands."
	else if(FR && length(FR.blood_DNA))
		var/hand_number = get_num_arms(FALSE)
		if(hand_number && blood_in_hands)
			. += span_warning("[t_He] [t_has][hand_number > 1 ? "" : " a"] blood-stained hand[hand_number > 1 ? "s" : ""]!")
		else
			. += span_warning("[t_He] [t_is] covered in blood!")

	//handcuffed?
	if(handcuffed)
		. += span_warning("[t_He] [t_is] handcuffed with [handcuffed.get_examine_string(user)]!")

	//legcuffed?
	if(legcuffed)
		. += span_warning("[t_He] [t_is] legcuffed with [legcuffed.get_examine_string(user)]!")

	//belt
	if(belt)
		. += "[t_He] [t_has] [belt.get_examine_string(user)] about [t_his] waist."

	//shoes
	if(shoes && !(ITEM_SLOT_FEET in obscured))
		. += "[t_He] [t_is] wearing [shoes.get_examine_string(user)] on [t_his] feet."

	//mask
	if(wear_mask && !(ITEM_SLOT_MASK in obscured))
		. += "[t_He] [t_has] [wear_mask.get_examine_string(user)] on [t_his] face."

	if(wear_neck && !(ITEM_SLOT_NECK in obscured))
		. += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck."

	//eyes
	if(!(ITEM_SLOT_EYES in obscured))
		if(glasses)
			. += "[t_He] [t_has] [glasses.get_examine_string(user)] covering [t_his] eyes."
		else if(eye_color == BLOODCULT_EYE && HAS_TRAIT(src, CULT_EYES))
			if(isipc(src))
				. += span_warning("<B>Their monitor hums quietly, with an underlying collection of blood-red pixels swirling faintly.</B>")
			else
				. += span_warning("<B>[t_His] eyes are glowing an unnatural red!</B>")

	//ears
	if(ears && !(ITEM_SLOT_EARS in obscured))
		. += "[t_He] [t_has] [ears.get_examine_string(user)] on [t_his] ears."

	//ID
	if(wear_id)
		. += "[t_He] [t_is] wearing [wear_id.get_examine_string(user)]."

	//Status effects
	. += status_effect_examines()

	if(islist(dna.features) && dna.features["wings"] && dna.features["wings"] != "None")
		var/badwings = ""
		if(mind?.martial_art && istype(mind.martial_art, /datum/martial_art/ultra_violence))
			badwings = "Weaponized "
		. += "[t_He] [t_has] a pair of [span_warning(badwings)][(dna.features["wings"])] wings on [t_his] back"

	if(user?.mind && HAS_TRAIT(user.mind, TRAIT_PSYCH) && LAZYLEN(get_traumas()))
		var/highest_trauma = 0
		for(var/datum/brain_trauma/B in get_traumas())
			if(istype(B, /datum/brain_trauma/magic))
				highest_trauma = 4
				break
			else if(istype(B, /datum/brain_trauma/special) && highest_trauma < 3)
				highest_trauma = 3
			else if(istype(B, /datum/brain_trauma/severe) && highest_trauma < 2)
				highest_trauma = 2
			else if(istype(B, /datum/brain_trauma/mild) && highest_trauma < 1)
				highest_trauma = 1

		switch(highest_trauma)
			if(1)
				. += span_warning("[t_His] behavior seems a bit off.")
			if(2)
				. += span_warning("[t_His] behavior is very clearly abnormal.")
			if(3)
				. += span_warning("[t_His] behavior is strange but intriguing.")
			if(4)
				. += span_warning("[t_His] behavior seems otherworldly.")

	var/appears_dead = 0
	if(stat == DEAD || (HAS_TRAIT(src, TRAIT_FAKEDEATH)))
		appears_dead = 1
		if(suiciding)
			. += span_warning("[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.")
		if(hellbound)
			. += span_warning("[t_His] soul seems to have been ripped out of [t_his] body.  Revival is impossible.")
		. += ""
		if(getorgan(/obj/item/organ/brain) && !key && !get_ghost())
			. += span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life and [t_his] soul has departed...")
		else
			. += span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life...")

	if(get_bodypart(BODY_ZONE_HEAD) && !getorgan(/obj/item/organ/brain))
		. += span_deadsay("It appears that [t_his] brain is missing...")

	var/temp = getBruteLoss() //no need to calculate each of these twice

	var/list/msg = list("")

	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/list/disabled = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/body_part = X
		if(body_part.bodypart_disabled)
			disabled += body_part
		missing -= body_part.body_zone
		for(var/obj/item/I in body_part.embedded_objects)
			msg += "<B>[t_He] [t_has] \a [icon2html(I, user)] [I] embedded in [t_his] [body_part.name]!</B>\n"
		for(var/i in body_part.wounds)
			var/datum/wound/iter_wound = i
			msg += "[iter_wound.get_examine_description(user)]\n"

	for(var/X in disabled)
		var/obj/item/bodypart/body_part = X
		var/damage_text
		if(HAS_TRAIT(body_part, TRAIT_DISABLED_BY_WOUND))
			continue // skip if it's disabled by a wound (cuz we'll be able to see the bone sticking out!)
		if(!(body_part.get_damage(stamina = FALSE) >= body_part.max_damage)) //we don't care if it's stamcritted
			damage_text = "limp and lifeless"
		else
			damage_text = (body_part.brute_dam >= body_part.burn_dam) ? body_part.heavy_brute_msg : body_part.heavy_burn_msg
		msg += "<B>[capitalize(t_his)] [body_part.name] is [damage_text]!</B>\n"

	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			msg += "<span class='deadsay'><B>[t_His] [parse_zone(t)] is missing!</B><span class='warning'>\n"
			continue
		if(t == BODY_ZONE_L_ARM || t == BODY_ZONE_L_LEG)
			l_limbs_missing++
		else if(t == BODY_ZONE_R_ARM || t == BODY_ZONE_R_LEG)
			r_limbs_missing++

		msg += "<B>[capitalize(t_his)] [parse_zone(t)] is missing!</B>\n"

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		msg += "[t_He] look[p_s()] all right now.\n"
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		msg += "[t_He] really keeps to the left.\n"
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		msg += "[t_He] [p_do()]n't seem all there.\n"

	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor [robotic ? ROBOTIC_BRUTE : ORGANIC_BRUTE].\n"
			else if(temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> [robotic ? ROBOTIC_BRUTE : ORGANIC_BRUTE]!\n"
			else if(src.dna.species.id == "egg" && temp >= 200)
				msg += "[t_He] look[p_s()] ready to crack into a million pieces!"
			else
				msg += "<B>[t_He] [t_has] severe [robotic ? ROBOTIC_BRUTE : ORGANIC_BRUTE]!</B>\n"

		temp = getFireLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor [robotic ? ROBOTIC_BURN : ORGANIC_BURN].\n"
			else if (temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> [robotic ? ROBOTIC_BURN : ORGANIC_BURN]!\n"
			else
				msg += "<B>[t_He] [t_has] severe [robotic ? ROBOTIC_BURN : ORGANIC_BURN]!</B>\n"

		temp = getCloneLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor cellular damage.\n"
			else if(temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> cellular damage!\n"
			else
				msg += "<b>[t_He] [t_has] severe cellular damage!</b>\n"

	if(surgeries.len)
		var/surgery_text
		for(var/datum/surgery/S in surgeries)
			if(!surgery_text)
				surgery_text = "[t_He] [t_is] being operated on in \the [S.operated_bodypart]"
			else
				surgery_text += ", [S.operated_bodypart]"
		msg += "[surgery_text].\n"

	if(has_status_effect(/datum/status_effect/fire_handler/fire_stacks))
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(has_status_effect(/datum/status_effect/fire_handler/wet_stacks))
		msg += "[t_He] look[p_s()] a little soaked.\n"

	if(visible_tumors)
		msg += "[t_He] [t_has] has growths all over [t_his] body...\n"

	if(pulledby && pulledby.grab_state)
		msg += "[t_He] [t_is] restrained by [pulledby]'s grip.\n"

	if(!HAS_TRAIT(src, TRAIT_POWERHUNGRY)) //robots don't visibly show their hunger
		if(nutrition < NUTRITION_LEVEL_STARVING - 50)
			msg += "[t_He] [t_is] severely malnourished.\n"
		else if(nutrition >= NUTRITION_LEVEL_FAT)
			if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
				msg += "[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"
			else
				msg += "[t_He] [t_is] quite chubby.\n"
		switch(disgust)
			if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
				msg += "[t_He] look[p_s()] a bit grossed out.\n"
			if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
				msg += "[t_He] look[p_s()] really grossed out.\n"
			if(DISGUST_LEVEL_DISGUSTED to INFINITY)
				msg += "[t_He] look[p_s()] extremely disgusted.\n"

	var/datum/quirk/allergic/allergen = has_quirk(/datum/quirk/allergic)
	if((allergen && reagents?.has_reagent(allergen.reagent_id)) || reagents?.has_reagent(/datum/reagent/toxin/histamine))
		msg += span_boldwarning("[t_His] face is very swollen!\n")

	var/apparent_blood_volume = blood_volume
	if(skin_tone == "albino")
		apparent_blood_volume -= 150 // enough to knock you down one tier
	// Fulp edit START - Bloodsuckers
	var/bloodDesc = ShowAsPaleExamine(user, apparent_blood_volume)
	if(bloodDesc == BLOODSUCKER_SHOW_BLOOD) // BLOODSUCKER_SHOW_BLOOD: Explicitly show the correct blood amount
		switch(get_blood_state())
			if(BLOOD_OKAY)
				msg += "[t_He] [t_has] pale skin.\n"
			if(BLOOD_BAD)
				msg += "<b>[t_He] look[p_s()] like pale death.</b>\n"
			if(BLOOD_DEAD to BLOOD_SURVIVE)
				msg += "<span class='deadsay'><b>[t_He] resemble[p_s()] a crushed, empty juice pouch.</b></span>\n"
	else if(bloodDesc != BLOODSUCKER_HIDE_BLOOD) // BLOODSUCKER_HIDE_BLOOD: Always show full blood
		msg += bloodDesc // Else: Show custom blood message

	if(bleedsuppress)
		msg += "[t_He] [t_is] imbued with a power that defies bleeding.\n" // only statues and highlander sword can cause this so whatever
	else if(is_bleeding())
		var/list/obj/item/bodypart/bleeding_limbs = list()
		var/list/obj/item/bodypart/grasped_limbs = list()

		for(var/i in bodyparts)
			var/obj/item/bodypart/body_part = i
			if(body_part.get_bleed_rate())
				bleeding_limbs += body_part
			if(body_part.grasped_by)
				grasped_limbs += body_part

		var/num_bleeds = LAZYLEN(bleeding_limbs)
		var/list/bleed_text
		if(appears_dead)
			bleed_text = list("<span class='deadsay'><B>Blood is visible in [t_his] open")
		else
			switch(get_total_bleed_rate() * physiology?.bleed_mod)
				if(0 to 1)
					bleed_text = list("<B>[t_He] [t_is] barely bleeding from [t_his]")
				if(1 to 2)
					bleed_text = list("<B>[t_He] [t_is] slowly bleeding from [t_his]")
				if(2 to 4)
					bleed_text = list("<B>[t_He] [t_is] bleeding from [t_his]")
				if(4 to 8)
					bleed_text = list("<B>[t_He] [t_is] greatly bleeding from [t_his]")
				if(8 to 12)
					bleed_text = list("<B>[t_He] [t_is] pouring blood from [t_his]")
				if(12 to INFINITY)
					bleed_text = list("<B>[t_He] [t_is] pouring blood like a fountain from [t_his]")
		switch(num_bleeds)
			if(1 to 2)
				bleed_text += " [bleeding_limbs[1].name][num_bleeds == 2 ? " and [bleeding_limbs[2].name]" : ""]"
			if(3 to INFINITY)
				for(var/i in 1 to (num_bleeds - 1))
					var/obj/item/bodypart/body_part = bleeding_limbs[i]
					bleed_text += " [body_part.name],"
				bleed_text += " and [bleeding_limbs[num_bleeds].name]"
		if(appears_dead)
			bleed_text += ", but it has pooled and is not flowing.</span></B>\n"
		else
			if(reagents.has_reagent(/datum/reagent/toxin/heparin, needs_metabolizing = TRUE))
				bleed_text += " incredibly quickly"

			bleed_text += "!</B>\n"
		msg += bleed_text.Join()

		for(var/i in grasped_limbs)
			var/obj/item/bodypart/grasped_part = i
			bleed_text += "[t_He] [t_is] holding [t_his] [grasped_part.name] to slow the bleeding!\n"

	if(reagents.has_reagent(/datum/reagent/teslium, needs_metabolizing = TRUE))
		msg += "[t_He] [t_is] emitting a gentle blue glow!\n"

	if(islist(stun_absorption))
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && stun_absorption[i]["examine_message"])
				msg += "[t_He] [t_is][stun_absorption[i]["examine_message"]]\n"

	if((!wear_suit && !w_uniform) && mind?.has_antag_datum(ANTAG_DATUM_THRALL))
		msg += "[t_His] whole body is covered in sigils!\n"

	if(!appears_dead)
		if(src != user)
			if(HAS_TRAIT(user, TRAIT_EMPATH) || user.skill_check(SKILL_PHYSIOLOGY, EXP_MID))
				if (combat_mode)
					msg += "[t_He] seem[p_s()] to be on guard.\n"
				if (getOxyLoss() >= 10)
					msg += "[t_He] seem[p_s()] winded.\n"
				if (getToxLoss() >= 10)
					msg += "[t_He] seem[p_s()] sickly.\n"
				var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
				if(mood && mood.sanity <= SANITY_DISTURBED)
					msg += "[t_He] seem[p_s()] distressed.\n"
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "empath", /datum/mood_event/sad_empath, src)
				if (HAS_TRAIT(src, TRAIT_BLIND))
					msg += "[t_He] appear[p_s()] to be staring off into space.\n"
				//Yogs -- Fixing being unable to detect some varieties of deafness
				var/obj/item/organ/ears/ears = src.getorganslot(ORGAN_SLOT_EARS)
				if (HAS_TRAIT(src, TRAIT_DEAF) || !istype(ears) || ears.deaf)
					msg += "[t_He] appear[p_s()] to not be responding to noises.\n"
				//Yogs end

			msg += "</span>"

			if(HAS_TRAIT(user, TRAIT_SPIRITUAL) && mind?.holy_role)
				msg += "[t_He] [t_has] a holy aura about [t_him].\n"
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "religious_comfort", /datum/mood_event/religiously_comforted)

		if(stat == UNCONSCIOUS)
			msg += "[t_He] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep.\n"
		else
			if(HAS_TRAIT(src, TRAIT_DUMB))
				msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"
			if(InCritical())
				msg += "[t_He] [t_is] barely conscious.\n"
		if(getorgan(/obj/item/organ/brain))
			if(!key)
				if(is_synth(src))
					msg += "The unit is indicating that it is currently inactive. Place this unit inside a synthetic storage unit to allow the onboard synthetic intelligences to control it.\n"
				else
					msg += "[span_deadsay("[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.")]\n"
			else if(!client && !fake_client)
				if(is_synth(src))
					msg += "The unit is indicating that it is currently inactive. Place this unit inside a synthetic storage unit to allow the onboard synthetic intelligences to control it.\n"
				else
					msg += "[t_He] [t_has] a blank, absent-minded stare and appears completely unresponsive to anything. [t_He] may snap out of it soon.\n"

		if(digitalcamo)
			msg += "[t_He] [t_is] moving [t_his] body in an unnatural and blatantly inhuman manner.\n"

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE, user, .)

	var/scar_severity = 0
	for(var/i in all_scars)
		var/datum/scar/S = i
		if(S.is_visible(user))
			scar_severity += S.severity

	switch(scar_severity)
		if(1 to 4)
			msg += "<span class='tinynoticeital'>[t_He] [t_has] visible scarring, you can look again to take a closer look...</span>\n"
		if(5 to 8)
			msg += "<span class='smallnoticeital'>[t_He] [t_has] several bad scars, you can look again to take a closer look...</span>\n"
		if(9 to 11)
			msg += "<span class='notice'><i>[t_He] [t_has] significantly disfiguring scarring, you can look again to take a closer look...</i></span>\n"
		if(12 to INFINITY)
			msg += "<span class='notice'><b><i>[t_He] [t_is] just absolutely fucked up, you can look again to take a closer look...</i></b></span>\n"

	if (length(msg))
		. += span_warning("[msg.Join("")]")

	var/trait_exam = common_trait_examine()
	if (!isnull(trait_exam))
		. += trait_exam

	var/traitstring = get_trait_string()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/cyberimp/eyes/hud/CIH = H.getorgan(/obj/item/organ/cyberimp/eyes/hud)
		if(H.can_see_reagents() && reagents?.total_volume > 0)
			. += "Reagents detected: [reagents.total_volume]u of [LAZYLEN(reagents.reagent_list)] chemicals."
		if(istype(H.glasses, /obj/item/clothing/glasses/hud) || CIH)
			var/perpname = get_face_name(get_id_name(""))
			if(perpname)
				var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
				if(R)
					. += "[span_deptradio("Rank:")] [R.fields["rank"]]\n<a href='byond://?src=[REF(src)];hud=1;photo_front=1'>\[Front photo\]</a><a href='byond://?src=[REF(src)];hud=1;photo_side=1'>\[Side photo\]</a>"
				if(istype(H.glasses, /obj/item/clothing/glasses/hud/health) || istype(CIH, /obj/item/organ/cyberimp/eyes/hud/medical))
					var/cyberimp_detect
					for(var/obj/item/organ/cyberimp/CI in internal_organs)
						if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
							cyberimp_detect += "[name] is modified with a [CI.name].\n"
					if(cyberimp_detect)
						. += "Detected cybernetic modifications:"
						. += cyberimp_detect
					if(R)
						var/health_r = R.fields["p_stat"]
						. += "<a href='byond://?src=[REF(src)];hud=m;p_stat=1'>\[[health_r]\]</a>"
						health_r = R.fields["m_stat"]
						. += "<a href='byond://?src=[REF(src)];hud=m;m_stat=1'>\[[health_r]\]</a>"
					R = find_record("name", perpname, GLOB.data_core.medical)
					if(R)
						. += "<a href='byond://?src=[REF(src)];hud=m;evaluation=1'>\[Medical evaluation\]</a><br>"
					if(traitstring)
						. += "<span class='info'>Detected physiological traits:\n[traitstring]"

				if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(CIH, /obj/item/organ/cyberimp/eyes/hud/security))
					if(!user.stat && user != src)
					//|| !user.canmove || user.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
						var/criminal = "None"

						R = find_record("name", perpname, GLOB.data_core.security)
						if(R)
							criminal = R.fields["criminal"]

						. += "[span_deptradio("Criminal status:")] <a href='byond://?src=[REF(src)];hud=s;status=1'>\[[criminal]\]</a>"
						. += jointext(list("[span_deptradio("Security record:")] <a href='byond://?src=[REF(src)];hud=s;view=1'>\[View\]</a>",
							"<a href='byond://?src=[REF(src)];hud=s;add_crime=1'>\[Add crime\]</a>",
							"<a href='byond://?src=[REF(src)];hud=s;view_comment=1'>\[View comment log\]</a>",
							"<a href='byond://?src=[REF(src)];hud=s;add_comment=1'>\[Add comment\]</a>"), "")
	else if(isobserver(user) && traitstring)
		. += "<span class='info'><b>Quirks:</b> [traitstring]</span><br>"
	. += "</span>"


	var/flavor_text_link
	/// The first 1-FLAVOR_PREVIEW_LIMIT characters in the mob's "flavor_text" DNA feature. FLAVOR_PREVIEW_LIMIT is defined in flavor_defines.dm.
	var/preview_text = copytext_char((dna.features["flavor_text"]), 1, FLAVOR_PREVIEW_LIMIT)
	// What examine_tgui.dm uses to determine if flavor text appears as "Obscured".
	var/face_obscured = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))

	if(HAS_TRAIT(src, TRAIT_HUSK)) //can't identify husk
		flavor_text_link = span_notice("This person has been husked, and is unrecognizable!")
	else if (HAS_TRAIT(src, TRAIT_DISFIGURED)) //can't identify disfigured
		flavor_text_link = span_notice("This person has been horribly disfigured, and is unrecognizable!")
	else if (face_obscured || HAS_TRAIT(src, TRAIT_DISGUISED)) //won't print flavour text of hidden
		flavor_text_link = span_notice("<a href='byond://?src=[REF(src)];lookup_info=open_examine_panel'>\[Examine closely...\]</a>")
	else //do it normally
		flavor_text_link = span_notice("[preview_text]... <a href='byond://?src=[REF(src)];lookup_info=open_examine_panel'>\[Look closer?\]</a>")
	if (flavor_text_link)
		. += flavor_text_link

/mob/living/proc/status_effect_examines(pronoun_replacement) //You can include this in any mob's examine() to show the examine texts of status effects!
	var/list/dat = list()
	if(!pronoun_replacement)
		pronoun_replacement = p_they(TRUE)
	for(var/V in status_effects)
		var/datum/status_effect/E = V
		if(E.examine_text)
			var/new_text = replacetext(E.examine_text, "SUBJECTPRONOUN", pronoun_replacement)
			new_text = replacetext(new_text, "[pronoun_replacement] is", "[pronoun_replacement] [p_are()]") //To make sure something become "They are" or "She is", not "They are" and "She are"
			dat += "[new_text]\n" //dat.Join("\n") doesn't work here, for some reason
	if(dat.len)
		return dat.Join()



/mob/living/carbon/human/proc/examine_simple(mob/user)
//this is very slightly better than it was because you can use it more places. still can't do \his[src] though.
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_has = p_have()
	var/t_is = p_are()

	. = list("<span class='info'>This is <EM>[name]</EM>!")

	var/list/obscured = check_obscured_slots()

	//uniform
	if(w_uniform && !(ITEM_SLOT_ICLOTHING in obscured))
		//accessory
		var/accessory_msg
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.attached_accessory)
				accessory_msg += " with [icon2html(U.attached_accessory, user)] \a [U.attached_accessory]"

		. += "[t_He] [t_is] wearing [w_uniform.get_examine_string(user)][accessory_msg]."
	//head
	if(head)
		. += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head."
	//suit/armor
	if(wear_suit)
		//badge
		var/badge_msg
		if(istype(wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/S = wear_suit
			if(S.attached_badge)
				badge_msg += " with [icon2html(S.attached_badge, user)] \a [S.attached_badge]"

		. += "[t_He] [t_is] wearing [wear_suit.get_examine_string(user)][badge_msg]."
	//back
	if(back)
		. += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back."

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "[t_He] [t_is] holding a [weightclass2text(I.w_class)] item in [t_his] [get_held_index_name(get_held_index_of_item(I))]."

	//gloves
	if(gloves && !(ITEM_SLOT_GLOVES in obscured))
		. += "[t_He] [t_has] [gloves.get_examine_string(user)] on [t_his] hands."


	//handcuffed?
	if(handcuffed)
		. += span_warning("[t_He] [t_is] handcuffed with [handcuffed.get_examine_string(user)]!")

	//legcuffed?
	if(legcuffed)
		. += span_warning("[t_He] [t_is] legcuffed with [legcuffed.get_examine_string(user)]!")

	//belt
	if(belt)
		. += "[t_He] [t_has] [belt.get_examine_string(user)] about [t_his] waist."

	//shoes
	if(shoes && !(ITEM_SLOT_FEET in obscured))
		. += "[t_He] [t_is] wearing [shoes.get_examine_string(user)] on [t_his] feet."

	//mask
	if(wear_mask && !(ITEM_SLOT_MASK in obscured))
		. += "[t_He] [t_has] [wear_mask.get_examine_string(user)] on [t_his] face."

	if(wear_neck && !(ITEM_SLOT_NECK in obscured))
		. += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck."

	//eyes
	if(!(ITEM_SLOT_EYES in obscured))
		if(glasses)
			. += "[t_He] [t_has] [glasses.get_examine_string(user)] covering [t_his] eyes."
		else if(eye_color == BLOODCULT_EYE && HAS_TRAIT(src, CULT_EYES))
			if(isipc(src))
				. += span_warning("<B>Their monitor hums quietly, with an underlying collection of blood-red pixels swirling faintly.</B>")
			else
				. += span_warning("<B>[t_His] eyes are glowing an unnatural red!</B>")
	//ears
	if(ears && !(ITEM_SLOT_EARS in obscured))
		. += "[t_He] [t_has] [ears.get_examine_string(user)] on [t_his] ears."


	var/list/msg = list("")

	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	for(var/X in bodyparts)
		var/obj/item/bodypart/body_part = X
		missing -= body_part.body_zone


	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			msg += "<span class='deadsay'><B>[t_His] [parse_zone(t)] is missing!</B><span class='warning'>\n"
			continue
		if(t == BODY_ZONE_L_ARM || t == BODY_ZONE_L_LEG)
			l_limbs_missing++
		else if(t == BODY_ZONE_R_ARM || t == BODY_ZONE_R_LEG)
			r_limbs_missing++

		msg += "<B>[capitalize(t_his)] [parse_zone(t)] is missing!</B>\n"

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		msg += "[t_He] look[p_s()] all right now.\n"
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		msg += "[t_He] really keeps to the left.\n"
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		msg += "[t_He] [p_do()]n't seem all there.\n"

	if (length(msg))
		. += span_warning("[msg.Join("")]")

	. += "</span>"

#undef ORGANIC_BRUTE
#undef ROBOTIC_BRUTE
