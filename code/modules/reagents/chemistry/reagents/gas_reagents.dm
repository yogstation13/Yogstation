/datum/reagent/gas
	name = "Gas"
	description = "A colorless, odorless, tasteless gas that should not exist."
	taste_description = "bad code"
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // handled through gas breathing, metabolism must be lower for breathcode to keep up
	reagent_state = GAS
	///The ID of the gas created when this is splashed
	var/gas_type

/datum/reagent/gas/reaction_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, permeability = 1)
	if(methods & BREATH)
		reac_volume = min(2, reac_volume) // make sure it only adds at most 2 units of it when breathed, to prevent infinite buildup
	return ..(exposed_mob, methods, reac_volume, show_message, permeability)

/datum/reagent/gas/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("[gas_type]=[reac_volume/2];TEMP=[temp]")
	return

/datum/reagent/gas/oxygen
	name = "Oxygen"
	description = "A colorless, odorless gas. Grows on trees but is still pretty valuable."
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0 // odorless and tasteless
	gas_type = GAS_O2

/datum/reagent/gas/nitrogen
	name = "Nitrogen"
	description = "A colorless, odorless, tasteless gas. A simple asphyxiant that can silently displace vital oxygen."
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0
	gas_type = GAS_N2

/datum/reagent/gas/hydrogen
	name = "Hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0
	gas_type = GAS_H2

/datum/reagent/gas/carbondioxide
	name = "Carbon Dioxide"
	description = "A gas commonly produced by burning carbon fuels. You're constantly producing this in your lungs."
	color = "#B0B0B0" // rgb : 192, 192, 192
	taste_description = "something unknowable"
	gas_type = GAS_CO2

/datum/reagent/gas/nitrous_oxide
	name = "Nitrous Oxide"
	description = "A potent anaesthetic used during surgery."
	reagent_state = LIQUID
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#808080"
	taste_description = "sweetness"
	gas_type = GAS_NITROUS

/datum/reagent/gas/nitrous_oxide/reaction_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, permeability = 1)
	if(methods & VAPOR)
		// apply 2 seconds of drowsiness per unit applied, with a min duration of 4 seconds
		var/drowsiness_to_apply = max(round(reac_volume, 1) * 2 SECONDS, 4 SECONDS)
		exposed_mob.adjust_drowsiness(drowsiness_to_apply)
	return ..()

/datum/reagent/gas/nitrous_oxide/on_mob_life(mob/living/carbon/M)
	M.adjust_drowsiness(4 SECONDS * REM)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.blood_volume = max(H.blood_volume - 5, 0)
	if(prob(20))
		M.losebreath += 2
		M.adjust_confusion_up_to(2 SECONDS, 5 SECONDS)
	return ..()

/datum/reagent/gas/nitrium
	name = "Nitrium"
	description = "A highly reactive gas that stops you from sleeping."
	reagent_state = GAS
	color = "#E1A116"
	can_synth = FALSE
	taste_description = "sourness"
	gas_type = GAS_NITRIUM

/datum/reagent/gas/nitrium/reaction_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, permeability = 1)
	if(reac_volume > 5 || (methods & INGEST|INJECT))
		var/datum/reagent/metabolite = new /datum/reagent/gas/nitrosyl_plasmide()
		metabolite.reaction_mob(exposed_mob, methods, reac_volume, show_message, permeability)
		if(reac_volume * permeability > 8 && prob(reac_volume * permeability * 5) && (methods & VAPOR))
			exposed_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, reac_volume * permeability / 2)
			to_chat(exposed_mob, span_alert("You feel a burning sensation in your chest"))
		qdel(metabolite)
	return ..()

/datum/reagent/gas/nitrium/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.physiology.burn_mod *= 1.5

/datum/reagent/gas/nitrium/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	if(ishuman(L)) // physiology gets reset anyway if you get turned into something that doesn't have it
		var/mob/living/carbon/human/H = L
		H.physiology.burn_mod /= 1.5
	return ..()

/datum/reagent/gas/nitrium/on_mob_life(mob/living/carbon/M)
	if(M.getStaminaLoss() > 0)
		M.adjustStaminaLoss(-2 * REM, FALSE)
		M.adjustToxLoss(1.5 *REM, FALSE)
	M.adjust_jitter(15 SECONDS)
	return ..()

/datum/reagent/gas/nitrosyl_plasmide
	name = "Nitrosyl plasmide"
	description = "A highly reactive substance that makes you feel faster."
	reagent_state = LIQUID // not actually a gas
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	color = "#90560B"
	can_synth = FALSE
	gas_type = GAS_NITRIUM
	taste_description = "burning"

/datum/reagent/gas/nitrosyl_plasmide/reaction_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, permeability = 1)
	if(methods & VAPOR)
		exposed_mob.adjustFireLoss(reac_volume * REM / 2.5)
		exposed_mob.adjustToxLoss(reac_volume * REM / 5)
	return ..()

/datum/reagent/gas/nitrosyl_plasmide/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-1, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/gas/nitrosyl_plasmide/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	return ..()

/datum/reagent/gas/freon
	name = "Freon"
	description = "A powerful heat absorbant."
	color = "#0B9089"
	can_synth = FALSE
	taste_description = "burning"
	gas_type = GAS_FREON

/datum/reagent/gas/freon/reaction_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, permeability = 1)
	if(!(methods & VAPOR))
		return ..()
	if(prob(reac_volume*5))
		to_chat(exposed_mob, span_alert("Your mouth feels like it's burning!"))
		exposed_mob.emote("gasp")
	if(reac_volume > 10)
		exposed_mob.adjustFireLoss(15)
		if(prob(reac_volume*2) && ishuman(exposed_mob))
			var/mob/living/carbon/human/human_mob = exposed_mob
			to_chat(human_mob, span_alert("Your throat closes up!"))
			human_mob.silent = max(human_mob.silent, 3)
	else
		exposed_mob.adjustFireLoss(reac_volume/5)
	return ..()

/datum/reagent/gas/freon/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=1.6, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/gas/freon/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	return ..()

/datum/reagent/gas/hypernoblium
	name = "Hyper-Noblium"
	description = "A suppressive gas that stops gas reactions on those who inhale or consume it."
	color = "#0B9073"
	can_synth = FALSE
	compatible_biotypes = ALL_BIOTYPES // works in open air, don't think it cares what kind of body it's in
	taste_description = "searingly cold"
	gas_type = GAS_HYPERNOB

/datum/reagent/gas/hypernoblium/on_mob_add(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_NOFIRE, type) // prevents you from being on fire, but doesn't actually make you take less damage from heat (which is what actually does the damage to you)
	ADD_TRAIT(L, TRAIT_PRESERVED_ORGANS, type) // no reactions means no decay

/datum/reagent/gas/hypernoblium/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_NOFIRE, type)
	REMOVE_TRAIT(L, TRAIT_PRESERVED_ORGANS, type)
	return ..()

/datum/reagent/gas/hypernoblium/reaction_mob(mob/living/M, method, reac_volume, show_message = TRUE, permeability = 1)
	. = ..()
	if(reac_volume >= REACTION_OPPRESSION_THRESHOLD)
		M.extinguish_mob()

/datum/reagent/gas/antinoblium
	name = "Anti-Noblium"
	description = "A rare gas that reacts violently with everything it touches, especially hyper-noblium."
	color = "#000000"
	can_synth = FALSE
	compatible_biotypes = ALL_BIOTYPES // BURN IT ALLLLLL
	taste_description = "searingly hot"
	self_consuming = TRUE
	gas_type = GAS_ANTINOB
	var/flame_timer = 0

/datum/reagent/gas/antinoblium/reaction_mob(mob/living/M, method, reac_volume, show_message = TRUE, permeability = 1)
	. = ..()
	M.fire_stacks = max(reac_volume, M.fire_stacks)

/datum/reagent/gas/antinoblium/on_mob_life(mob/living/carbon/M)
	flame_timer++
	M.fire_stacks = max(0, M.fire_stacks)
	M.adjust_fire_stacks(0.5) // perpetually flammable
	if(M.reagents.has_reagent(/datum/reagent/gas/hypernoblium))
		var/annihilation_amount = min(M.reagents.get_reagent_amount(/datum/reagent/gas/hypernoblium), M.reagents.get_reagent_amount(/datum/reagent/gas/hypernoblium))
		M.reagents.remove_reagent(/datum/reagent/gas/hypernoblium, annihilation_amount)
		M.reagents.remove_reagent(/datum/reagent/gas/antinoblium, annihilation_amount)
		M.adjust_fire_stacks(annihilation_amount)
		M.adjustFireLoss(annihilation_amount * 5) // fireproof suits will not protect you
		if(M.reagents.get_reagent_amount(/datum/reagent/gas/hypernoblium) <= 0)
			REMOVE_TRAIT(M, TRAIT_NOFIRE, /datum/reagent/gas/hypernoblium) // remove the trait early so they can actually catch fire
		flame_timer = INFINITY
	if(flame_timer >= rand(5, 30))
		if(!M.on_fire)
			M.visible_message(span_warning("[M] suddenly bursts into flames!"), span_userdanger("You feel a searing pain throughout your very being as you start to burn from the inside out!"))
		M.fire_stacks = max(0.5, M.fire_stacks) // make sure they're able to catch fire
		M.ignite_mob()
		flame_timer = 0
		if(isplasmaman(M) && M.dna?.species) // the fire is INSIDE YOU
			var/datum/species/plasmaman/P = M.dna.species
			P.internal_fire = TRUE
	..()

/datum/reagent/gas/healium
	name = "Healium"
	description = "A Powerful sleeping agent with healing properties."
	color = "#25AF37"
	can_synth = FALSE
	taste_description = "rubbery"
	gas_type = GAS_HEALIUM
	///Funny voice
	var/helium_speech = FALSE

/datum/reagent/gas/healium/reaction_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, permeability = 1)
	if(methods & VAPOR)
		helium_speech = TRUE
	return ..()

/datum/reagent/gas/healium/on_mob_add(mob/living/carbon/L)
	. = ..()
	for(var/obj/item/organ/organs in L.internal_organs)
		if(organs.status == ORGAN_ORGANIC)
			organs.applyOrganDamage(-20)
			if(organs.organ_flags & ORGAN_FAILING)
				organs.organ_flags &= ~ORGAN_FAILING
	if(L.stat == DEAD)
		if(L.getBruteLoss() >= MAX_REVIVE_BRUTE_DAMAGE)
			L.adjustBruteLoss(-(L.getBruteLoss() - MAX_REVIVE_FIRE_DAMAGE + 50))
		if(L.getFireLoss() >= MAX_REVIVE_FIRE_DAMAGE)
			L.adjustFireLoss(-(L.getFireLoss() - MAX_REVIVE_FIRE_DAMAGE + 50))
	ADD_TRAIT(L, TRAIT_PRESERVED_ORGANS, "healium")

/datum/reagent/gas/healium/on_mob_delete(mob/living/carbon/L)
	REMOVE_TRAIT(L, TRAIT_PRESERVED_ORGANS, "healium")
	return ..()

/datum/reagent/gas/healium/on_mob_metabolize(mob/living/carbon/L)
	. = ..()
	L.SetSleeping(1000)
	L.SetUnconscious(1000)
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=0.5, blacklisted_movetypes=(FLYING|FLOATING)) // slowdown for if you're awake
	ADD_TRAIT(L, TRAIT_SURGERY_PREPARED, "healium")
	if(helium_speech)
		RegisterSignal(L, COMSIG_MOB_SAY, PROC_REF(handle_helium_speech))

/datum/reagent/gas/healium/on_mob_life(mob/living/carbon/M)
	M.SetSleeping(100)
	M.SetUnconscious(100)
	var/heal_factor = 1
	if(M.stat == CONSCIOUS) // if you're awake it gives you side effects and heals a lot less (not enough to outheal nitrium)
		heal_factor *= 0.1
		M.adjust_disgust((40 - M.disgust) / 10) // makes you sick
		M.adjust_jitter_up_to(2, 10)
	else if(M.bodytemperature < T0C)
		var/power = -0.00009 * (M.bodytemperature ** 2) + 9
		heal_factor *= (100 + max(T0C - M.bodytemperature, 200)) / 100 // if you're asleep, you get healed faster when you're cold (up to 3x at 73 kelvin)
		for(var/i in M.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_healium(power)

		if(M.blood_volume < BLOOD_VOLUME_SAFE(M))
			M.blood_volume = BLOOD_VOLUME_SAFE(M)

	M.adjustOxyLoss(-10*heal_factor*REM)
	M.adjustFireLoss(-7*heal_factor*REM)
	M.adjustToxLoss(-5*heal_factor*REM)
	M.adjustBruteLoss(-5*heal_factor*REM)
	M.adjustCloneLoss(-5*heal_factor*REM)
	for(var/obj/item/organ/organs in M.internal_organs)
		if(organs.status == ORGAN_ORGANIC)
			organs.applyOrganDamage(-2*heal_factor*REM)
	REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
	return ..()

/datum/reagent/gas/healium/on_mob_end_metabolize(mob/living/L)
	L.SetSleeping(1 SECONDS)
	L.SetUnconscious(1 SECONDS)
	L.remove_movespeed_modifier(type)
	REMOVE_TRAIT(L, TRAIT_SURGERY_PREPARED, "healium")
	if(helium_speech)
		UnregisterSignal(L, COMSIG_MOB_SAY)
	return ..()

/datum/reagent/gas/healium/proc/handle_helium_speech(owner, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= SPAN_HELIUM

/datum/reagent/gas/halon
	name = "Halon"
	description = "A firefighter gas that removes oxygen and cools down an area."
	reagent_state = GAS
	color = "#850B90"
	can_synth = FALSE
	taste_description = "minty"
	gas_type = GAS_HALON

/datum/reagent/gas/halon/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=1.8, blacklisted_movetypes=(FLYING|FLOATING))
	ADD_TRAIT(L, TRAIT_RESISTHEAT, type)

/datum/reagent/gas/halon/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(0.5)
	return ..()

/datum/reagent/gas/halon/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	REMOVE_TRAIT(L, TRAIT_RESISTHEAT, type)
	return ..()

/datum/reagent/gas/hexane
	name = "Hexane"
	description = "A filtering gas, don't breathe it if you suffer from brain conditions."
	color = "#5B0B90"
	can_synth = FALSE
	taste_description = "fresh"
	gas_type = GAS_HEXANE

/datum/reagent/gas/hexane/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=1.8, blacklisted_movetypes=(FLYING|FLOATING))
	ADD_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)
	ADD_TRAIT(L, TRAIT_RADIMMUNE, type)

/datum/reagent/gas/hexane/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	REMOVE_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)
	REMOVE_TRAIT(L, TRAIT_RADIMMUNE, type)
	return ..()

/datum/reagent/gas/hexane/on_mob_life(mob/living/carbon/M)
	M.adjust_hallucinations_up_to(12 SECONDS, 2 MINUTES)
	if(prob(33))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5, 150)
	return ..()
