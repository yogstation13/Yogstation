/datum/species/preternis
	name = "Preternis"
	plural_form = "Preterni"
	id = SPECIES_PRETERNIS
	monitor_icon = "robot"
	monitor_color = "#edee1b"

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_traits = list(TRAIT_POWERHUNGRY, TRAIT_RADIMMUNE, TRAIT_MEDICALIGNORE, TRAIT_NO_BLOOD_REGEN)
	species_traits = list(NOEYESPRITES, DYNCOLORS, EYECOLOR, NOHUSK, NO_UNDERWEAR)//they're fleshy metal machines, they are efficient, and the outside is metal, no getting husked
	inherent_biotypes = MOB_ORGANIC|MOB_ROBOTIC|MOB_HUMANOID
	possible_genders = list(PLURAL) //they're basically ken dolls, come straight out of a printer
	no_equip = list(ITEM_SLOT_FEET)

	say_mod = "intones"
	attack_verbs = list("assault")
	toxic_food = NONE
	liked_food = FRIED | SUGAR | JUNKFOOD
	disliked_food = GROSS | VEGETABLES

	//stat mods
	coldmod = 3 //The plasteel around them saps their body heat quickly if it gets cold
	heatmod = 2 //Once the heat gets through it's gonna BURN
	tempmod = 0.15 //The high heat capacity of the plasteel makes it take far longer to heat up or cool down
	stunmod = 1.2 //Big metal body has difficulty getting back up if it falls down
	staminamod = 1.1 //Big metal body has difficulty holding it's weight if it gets tired
	action_speed_coefficient = 0.9 //worker drone do the fast
	punchdamagehigh = 7 //not built for large high speed acts like punches
	punchstunchance = 0.2 //technically better stunning
	siemens_coeff = 1.75 //Circuits REALLY don't like extra electricity flying around

	//organs
	mutanteyes = /obj/item/organ/eyes/robotic/preternis
	mutantlungs = /obj/item/organ/lungs/preternis
	mutantstomach = /obj/item/organ/stomach/cell/preternis

	//misc things
	species_language_holder = /datum/language_holder/machine
	inert_mutation = RAVENOUS
	smells_like = "lemony steel" //transcendent olfaction
	skinned_type = /obj/item/stack/sheet/plasteel{amount = 5} //coated in plasteel
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/synthmeat
	exotic_bloodtype = "Synthetic" //synthetic blood

	//sounds
	special_step_sounds = list('sound/effects/footstep/catwalk1.ogg', 'sound/effects/footstep/catwalk2.ogg', 'sound/effects/footstep/catwalk3.ogg', 'sound/effects/footstep/catwalk4.ogg')
	attack_sound = 'sound/items/trayhit2.ogg'
	screamsound = 'goon/sound/robot_scream.ogg' //change this when sprite gets reworked
	//deathsound = //change this when sprite gets reworked
	
	mutant_bodyparts = list("preternis_weathering", "preternis_antenna", "preternis_eye", "preternis_core")
	default_features = list("weathering" = "None", "antenna" = "None", "preternis_eye" = "Standard", "preternis_core" = "Core")
	wings_icon = "Elytra"

	species_abilities = list(/datum/action/cooldown/spell/toggle/maglock)

	//new variables
	var/eating_msg_cooldown = FALSE
	var/emag_lvl = 0
	var/soggy = FALSE
	var/low_power_warning = FALSE


/datum/species/preternis/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(!C.dna.features["pretcolor"])
		C.dna.features["pretcolor"] = pick(GLOB.color_list_preternis)
	fixed_mut_color = C.dna.features["pretcolor"]

	for (var/obj/item/bodypart/BP in C.bodyparts)
		BP.render_like_organic = TRUE 	// Makes limbs render like organic limbs instead of augmented limbs, check bodyparts.dm
		BP.emp_reduction = EMP_LIGHT
		BP.burn_reduction = 1
		if(BP.body_zone == BODY_ZONE_CHEST)
			continue
		if(BP.body_zone == BODY_ZONE_HEAD)
			continue
		BP.max_damage = 35

	RegisterSignal(C, COMSIG_MOB_ALTCLICKON, PROC_REF(drain_power_from))

/datum/species/preternis/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	for (var/V in C.bodyparts)
		var/obj/item/bodypart/BP = V
		BP.change_bodypart_status(ORGAN_ORGANIC,FALSE,TRUE)
		BP.emp_reduction = initial(BP.emp_reduction)
		BP.burn_reduction = initial(BP.burn_reduction)

	UnregisterSignal(C, COMSIG_MOB_ALTCLICKON)

	C.clear_alert("preternis_emag") //this means a changeling can transform from and back to a preternis to clear the emag status but w/e i cant find a solution to not do that
	C.clear_fullscreen("preternis_emag")
	C.remove_movespeed_modifier("preternis_water")

/datum/species/preternis/spec_emag_act(mob/living/carbon/human/H, mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(emag_lvl == 2)
		return FALSE
	emag_lvl = min(emag_lvl + 1,2)
	playsound(H.loc, 'sound/machines/warning-buzzer.ogg', 50, 1, 1)
	H.Paralyze(60)
	switch(emag_lvl)
		if(1)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50) //HALP AM DUMB
			to_chat(H,span_danger("ALERT! MEMORY UNIT [rand(1,5)] FAILURE.NERVEOUS SYSTEM DAMAGE."))
		if(2)
			H.overlay_fullscreen("preternis_emag", /atom/movable/screen/fullscreen/high)
			H.throw_alert("preternis_emag", /atom/movable/screen/alert/high/preternis)
			to_chat(H,span_danger("ALERT! OPTIC SENSORS FAILURE.VISION PROCESSOR COMPROMISED."))
	return TRUE
	
/datum/species/preternis/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if (istype(chem,/datum/reagent/consumable) && !istype(chem, /datum/reagent/consumable/liquidelectricity))
		var/datum/reagent/consumable/food = chem
		if (food.nutriment_factor)
			H.adjust_nutrition(food.nutriment_factor * 0.2)
			if (!eating_msg_cooldown)
				eating_msg_cooldown = TRUE
				addtimer(VARSET_CALLBACK(src, eating_msg_cooldown, FALSE), 2 MINUTES)
				to_chat(H,span_info("NOTICE: Digestive subroutines are inefficient. Seek sustenance via power-cell C.O.N.S.U.M.E. technology induction."))

	// remove 4% of existing reagent, minimum of 0.1 units at a time
	H.reagents.remove_reagent(chem.type, max(round(chem.volume / 25, 0.1), 0.1))

	return FALSE

/datum/species/preternis/spec_fully_heal(mob/living/carbon/human/H)
	. = ..()
	emag_lvl = 0
	H.clear_alert("preternis_emag")
	H.clear_fullscreen("preternis_emag")
	
/datum/species/preternis/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return

	handle_wetness(H)

	if(H.nutrition < NUTRITION_LEVEL_STARVING)
		if(prob(NUTRITION_LEVEL_STARVING - H.nutrition) / 3)
			if(!low_power_warning)
				low_power_warning = TRUE
				to_chat(H, span_userdanger("You feel difficulty breathing as your lungs start powering down!"))
			H.losebreath = max(H.losebreath, 2) // slowly start suffocating when out of power instead of instant death
	else
		low_power_warning = FALSE

/datum/species/preternis/proc/handle_wetness(mob/living/carbon/human/H)
	var/datum/status_effect/fire_handler/wet_stacks/wetness = H.has_status_effect(/datum/status_effect/fire_handler/wet_stacks)
	if(wetness && wetness.stacks >= 1) // needs at least 1 wetness stack to do anything
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "preternis_wet", /datum/mood_event/wet_preternis)
		H.add_movespeed_modifier("preternis_water", update = TRUE, priority = 102, multiplicative_slowdown = 0.5, blacklisted_movetypes=(FLYING|FLOATING))
		//damage has a flat amount with an additional amount based on how wet they are
		H.adjustStaminaLoss(4 - (H.fire_stacks / 2))
		H.clear_stamina_regen()
		H.adjustFireLoss(1.5 - (H.fire_stacks / 3))
		H.set_jitter_if_lower(10 SECONDS)
		H.set_stutter_if_lower(1 SECONDS)
		if(!soggy)//play once when it starts
			H.emote("scream")
			to_chat(H, span_userdanger("Your entire being screams in agony as your wires short from getting wet!"))
		if(prob(50))
			playsound(get_turf(H), "sparks", 30, 1)
			do_sparks(rand(1,3), FALSE, H)
		H.adjust_wet_stacks(-1)
		soggy = TRUE
		H.throw_alert("preternis_wet", /atom/movable/screen/alert/preternis_wet)
	else if(soggy)
		H.remove_movespeed_modifier("preternis_water")
		to_chat(H, "You breathe a sigh of relief as you dry off.")
		soggy = FALSE
		H.clear_alert("preternis_wet")

/datum/species/preternis/has_toes()//their toes are mine, they shall never have them back
	return FALSE

/datum/species/preternis/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	// called before a projectile hit
	if(istype(P, /obj/projectile/energy/nuclear_particle))
		H.fire_nuclear_particle()
		H.visible_message(span_danger("[P] deflects off of [H]!"), span_userdanger("[P] deflects off of you!"))
		return 1
	return 0

/datum/species/preternis/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_preternis_name()
	return preternis_name()

/datum/species/preternis/get_features()
	var/list/features = ..()

	features += "feature_pretcolor"
	features += "feature_preternis_weathering"
	features += "feature_preternis_antenna"
	features += "feature_preternis_eye"

	return features

/datum/species/preternis/get_species_description()
	return "Sentient tools left by the bygone Vxtvul Empire, preterni are a complex weaving of flesh and \
		cybernetics encased in a plasteel shell. Now left to their own devices among the forgotten ruins of their old civilization, \
		the preterni have formed their own nation and have established tense but stable relations with the SIC."

/datum/species/preternis/get_species_lore()
	return list(
		"Preterni were built by the Vxtrin to work in hazardous environments with minimal monitoring. Combining \
		the durability of metal with the versatility of organic matter, preterni worked in factories, engines, \
		and research facilities, enduring radiations, toxins, and extreme temperature- similarly to the silicon \
		units of this time, while able to adapt and improvise when faced with new problems and changing environments.",

		"Approximately seventeen millennia ago, the entire Vxtrin population disappeared along with the preterni, \
		leaving only deactivated factories and abandoned facilities. The first preternis factory was reactivated by \
		accident in 2431 by SIC colonists on the planet of Ur'lan. Communication between the newly-created preterni \
		and the colonists was made possible by the silicon units built using the MMI technology that had been uncovered \
		previously in Vxtvul ruins. Upon hearing of the discovery of preterni on Ur'lan, Nanotrasen immediately \
		bought the property of the colony for more than a thousand time its original value and attempted to claim \
		the preterni as their property. The scheme was unsuccessful and preterni formed the Remnants of Vxtvul as \
		a unifying government",

		"The SIC decided it was best if preterni and humanity worked together to uncover the secrets of the Vxtrin. \
		While SIC authorities desired an alliance, several groups and companies pillaged or sabotaged Vxtvul ruins \
		before the preterni could recover them, destroying hardware and stealing technologies. Such acts outraged \
		the Remnants and have led to great tension between them and the SIC. Using Vxtvul technology, the preterni \
		developed a navy and ground military forces to defend their ruins from scavengers, and while humans are \
		accepted among Remnant territories and stations, they are monitored constantly.",

		"Preterni strive for excellence and tend to be extremely work-focused. They tend to be slightly distrustful \
		of humans and prefer to rely on themselves for any important task. As silicon units are derived from Vxtrin \
		technology, preterni tend to have some affection and respect for them, even though silicon lawsets can mean \
		these relationships are one-sided.",

		"Preternis culture was lost for the most part along with their masters. Current customs involve was recovered \
		through archeological works, perpetuated in remembrance of the golden age when Vxtrin were still with them, \
		then combined with human practices that have been adopted due to the species' proximity to humanity. \
		Preterni have no hair naturally, but many have installed synthetic hairs on their head to better \
		differentiate themselves and mimic humans.",

		"The SIC and the Remnants are still wary of each others, but they nonetheless exchange goods, \
		and travel between the two empire is relatively unhindered. Preterni can be seen working in SIC \
		space, often hired to work in hazardous environments. Some join exploration crews and travel to far \
		away facilities in the hopes of stumbling upon ruins of their fallen empire.",
	)

/datum/species/preternis/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thunderstorm", //if we update font awesome, please swap to bolt-slash
			SPECIES_PERK_NAME = "Faraday \"Skin\"",
			SPECIES_PERK_DESC = "Preterni have an outer plasteel shell that can block low-intensity EM interference.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "cookie-bite",
			SPECIES_PERK_NAME = "Stone Eater",
			SPECIES_PERK_DESC = "Preterni are fitted with grinders in their stomach, letting them eat and process ores to replenish their metal skin. \
								All ores are not created equal.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wrench",
			SPECIES_PERK_NAME = "Worker Drone",
			SPECIES_PERK_DESC = "Preterni were designed to be quick and efficient workers. \
								They use tools and items faster than most races.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "low-vision",
			SPECIES_PERK_NAME = "Augmented Sight",
			SPECIES_PERK_DESC = "Preterni have a night vision lens they can toggle built into their eyes. \
								This lens will drain power while active.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lungs",
			SPECIES_PERK_NAME = "Nanovapor Filters",
			SPECIES_PERK_DESC = "Preterni have bioengineered lungs that require little oxygen, and filter trace amounts of toxic gases from the air. \
								However, they're prone to being damaged from breathing in cold air.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "flask",
			SPECIES_PERK_NAME = "Chemical Purge",
			SPECIES_PERK_DESC = "Preterni have an elaborate system of filters for decontaminating their organic parts. \
								A percentage of all foreign chemicals in their bloodstream are purged every few seconds.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shower",
			SPECIES_PERK_NAME = "Keep Dry",
			SPECIES_PERK_DESC = "Preterni have exposed circuitry under the cracks in their outer shell. \
								Contact with water will short their electronics, causing weakness in the limbs and burns.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "droplet-slash",
			SPECIES_PERK_NAME = "Metal Marrow",
			SPECIES_PERK_DESC = "Preterni have solid metal bones with no internal marrow. Their body will not create blood to replace any lost."
		),
	)

	return to_add
