/datum/species/ethereal
	name = "Ethereal"
	id = "ethereal"
	attack_verb = "burn"
	attack_sound = 'sound/weapons/etherealhit.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/ethereal
	mutantlungs = /obj/item/organ/lungs/ethereal
	mutantstomach = /obj/item/organ/stomach/cell/ethereal
	mutantheart = /obj/item/organ/heart/ethereal
	mutanteyes = /obj/item/organ/eyes/ethereal
	exotic_blood = /datum/reagent/consumable/liquidelectricity //Liquid Electricity. fuck you think of something better gamer
	exotic_bloodtype = "E" //this isn't used for anything other than bloodsplatter colours
	siemens_coeff = 0.5 //They thrive on energy
	brutemod = 1.25 //Don't rupture their membranes
	burnmod = 0.8 //Bodies are resilient to heat and energy
	heatmod = 0.5 //Bodies are resilient to heat and energy
	coldmod = 2.0 //Don't extinguish the stars
	speedmod = -0.1 //Light and energy move quickly
	punchdamagehigh  = 11 //Fire hand more painful
	punchstunthreshold = 11 //Still stuns on max hit, but subsequently lower chance to stun overall
	attack_type = BURN //burn bish
	damage_overlay_type = "" //We are too cool for regular damage overlays
	species_traits = list(NOEYESPRITES, EYECOLOR, MUTCOLORS, AGENDER, HAIR, FACEHAIR, HAS_FLESH) // i mean i guess they have blood so they can have wounds too
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_traits = list(TRAIT_POWERHUNGRY, TRAIT_RADIMMUNE)
	mutant_bodyparts = list("ethereal_mark")
	default_features = list("ethereal_mark" = "Eyes", "mcolor" = "#ffffff")
	species_language_holder = /datum/language_holder/ethereal
	deathsound = 'yogstation/sound/voice/ethereal/deathsound.ogg'
	screamsound = list('sound/voice/ethereal/ethereal_scream_1.ogg', 'sound/voice/ethereal/ethereal_scream_2.ogg', 'sound/voice/ethereal/ethereal_scream_3.ogg')
	sexes = FALSE //no fetish content allowed
	toxic_food = NONE
	inert_mutation = RADIANTBURST
	hair_color = "fixedmutcolor"
	hair_alpha = 140
	swimming_component = /datum/component/swimming/ethereal
	wings_icon = "Ethereal"
	wings_detail = "Etherealdetails"

	var/max_range = 5
	var/max_power = 2
	var/current_color
	var/EMPeffect = FALSE
	var/EMP_timer = null
	var/emageffect = FALSE
	var/emag_timer = null
	var/emag_speed = 4 //how many deciseconds between each colour cycle
	var/r1
	var/g1
	var/b1
	var/static/r2 = 237
	var/static/g2 = 164
	var/static/b2 = 149
	//this is shit but how do i fix it? no clue.

	smells_like = "crackling sweetness"

	var/obj/effect/dummy/lighting_obj/moblight/species/ethereal_light

/datum/species/ethereal/Destroy(force)
	QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(C))
		return

	var/mob/living/carbon/human/ethereal = C
	setup_color(ethereal)

	ethereal_light = ethereal.mob_light(light_type = /obj/effect/dummy/lighting_obj/moblight/species)
	RegisterSignal(ethereal, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	spec_updatehealth(ethereal)

	var/obj/item/organ/heart/ethereal/ethereal_heart = ethereal.getorganslot(ORGAN_SLOT_HEART)
	if(ethereal_heart)
		ethereal_heart.ethereal_color = default_color
	var/obj/item/organ/eyes/ethereal/ethereal_eyes = ethereal.getorganslot(ORGAN_SLOT_EYES)
	if(ethereal_eyes)
		ethereal_eyes.ethereal_color = default_color

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	UnregisterSignal(C, COMSIG_LIGHT_EATER_ACT)
	QDEL_NULL(ethereal_light)
	C.set_light(0)
	deltimer(EMP_timer)
	deltimer(emag_timer)
	return ..()

/datum/species/ethereal/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_ethereal_name()

	var/randname = ethereal_name()

	return randname

/datum/species/ethereal/proc/setup_color(mob/living/carbon/human/ethereal)
	default_color = ethereal.dna.features["mcolor"]
	r1 = GETREDPART(default_color)
	g1 = GETGREENPART(default_color)
	b1 = GETBLUEPART(default_color)
	var/list/hsl = rgb2hsl(r1, g1, b1)
	//both saturation and lightness are a scale of 0 to 1
	hsl[2] = min(hsl[2], 0.7) //don't let saturation be too high or it's overwhelming
	hsl[3] = max(hsl[3], 0.5) //don't let lightness be too low or it looks like a void of light
	var/list/rgb = hsl2rgb(hsl[1], hsl[2], hsl[3]) //terrible way to do it, but it works
	r1 = rgb[1]
	g1 = rgb[2]
	b1 = rgb[3]

/datum/species/ethereal/spec_updatehealth(mob/living/carbon/human/ethereal)
	. = ..()
	if(!ethereal_light)
		return
	if(default_color != ethereal.dna.features["mcolor"])
		setup_color(ethereal)

	if(ethereal.stat != DEAD && !EMPeffect)
		var/healthpercent = max(ethereal.health, 0) / ethereal.maxHealth//scale with the lower of health and hunger
		var/hungerpercent = min((ethereal.nutrition / NUTRITION_LEVEL_FED), 1)//scale only when below a certain hunger threshold
		var/light_range = max_range * min(healthpercent, hungerpercent)
		var/light_power = max_power * min(healthpercent, hungerpercent)
		if(!emageffect)
			current_color = rgb(r2 + ((r1-r2)*healthpercent), g2 + ((g1-g2)*healthpercent), b2 + ((b1-b2)*healthpercent))
			ethereal_light.set_light_color(current_color) //emag effect handles colour changes
		ethereal_light.set_light_range(light_range)
		ethereal_light.set_light_power(light_power)
		ethereal_light.set_light_on(TRUE)
		ethereal.set_light(light_range + 1, 0.1, current_color)//this just controls actual view range, not the overlay
		fixed_mut_color = current_color
	else
		ethereal.set_light(0)
		ethereal_light.set_light_on(FALSE)
		fixed_mut_color = rgb(128,128,128)
	ethereal.update_body()

/// Special handling for getting hit with a light eater
/datum/species/ethereal/proc/on_light_eater(mob/living/carbon/human/source, datum/light_eater)
	SIGNAL_HANDLER
	spec_emp_act(source, EMP_LIGHT)
	return COMPONENT_BLOCK_LIGHT_EATER

/datum/species/ethereal/spec_emp_act(mob/living/carbon/human/H, severity)
	.=..()
	if(!EMPeffect)
		to_chat(H, span_notice("You feel the light of your body leave you."))
	EMPeffect = TRUE
	spec_updatehealth(H)
	EMP_timer = addtimer(CALLBACK(src, PROC_REF(stop_emp), H), 20 * severity, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE) //We're out for 2 to 20 seconds depending on severity

/datum/species/ethereal/proc/stop_emp(mob/living/carbon/human/H)
	EMPeffect = FALSE
	spec_updatehealth(H)
	to_chat(H, span_notice("You feel more energized as your shine comes back."))

/datum/species/ethereal/spec_emag_act(mob/living/carbon/human/H, mob/user, obj/item/card/emag/emag_card)
	if(emageffect)
		return FALSE
	to_chat(user, span_notice("You tap [H] on the back with your card."))
	H.visible_message(span_danger("[H] starts pulsing random colors!"))
	current_color = rgb(255,255,255)
	spec_updatehealth(H)//set the colour to white for the duration
	current_color = rgb(255,0,0)
	emageffect = TRUE
	handle_emag(H)
	emag_timer = addtimer(CALLBACK(src, PROC_REF(stop_emag), H), 30 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE) //Disco mode for 30 seconds! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.
	return TRUE

/datum/species/ethereal/proc/handle_emag(mob/living/carbon/human/H)//please change this to use animate() if you ever figure out how to animate light colours
	if(!emageffect)
		return
	current_color = HSVtoRGB(RotateHue(RGBtoHSV(current_color), 75)) //rotate through the colours
	var/datum/component/overlay_lighting/light = ethereal_light.GetComponent(/datum/component/overlay_lighting)
	if(light?.visible_mask)
		animate(light.visible_mask, emag_speed, color = current_color)
	animate(H, emag_speed, color = current_color)
	addtimer(CALLBACK(src, PROC_REF(handle_emag), H), emag_speed) //Call ourselves every 0.4 seconds to continue the animation

/datum/species/ethereal/proc/stop_emag(mob/living/carbon/human/H)
	emageffect = FALSE
	spec_updatehealth(H)
	var/datum/component/overlay_lighting/light = ethereal_light.GetComponent(/datum/component/overlay_lighting)
	if(light?.visible_mask)
		animate(light.visible_mask, emag_speed, color = current_color)
	animate(H, emag_speed, color = null) //back to boring
	H.visible_message(span_danger("[H]'s light goes back to it's normal state!"))

/datum/species/ethereal/spec_rad_act(mob/living/carbon/human/H, amount, collectable_radiation)
	if(!collectable_radiation)
		return
	if(amount <= RAD_BACKGROUND_RADIATION)
		return
	var/rad_percent = 1 - (H.getarmor(null, RAD) / 100)
	if(!rad_percent)
		return
	H.adjust_nutrition(min(amount / 2500, 5) * rad_percent)

/datum/species/ethereal/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	. = ..()
	if(istype(P, /obj/projectile/energy/nuclear_particle))
		H.visible_message(span_warning("[H] absorbs [P]!"), span_userdanger("You absorb [P]!"))
		H.adjust_nutrition(P.damage * (1 - (H.getarmor(null, RAD) / 100)))
		return TRUE

/datum/species/ethereal/spec_life(mob/living/carbon/human/H)
	.=..()
	if(H.stat == DEAD)
		return
	if(H.nutrition > NUTRITION_LEVEL_FULL && prob(10))//10% each tick for ethereals to explosively release excess energy if it reaches dangerous levels
		discharge_process(H)
	else if(H.nutrition < NUTRITION_LEVEL_STARVING && H.health > 10.5)
		apply_damage(0.65, TOX, null, 0, H)

/datum/species/ethereal/get_hunger_alert(mob/living/carbon/human/H)
	switch(H.nutrition)
		if(0)
			H.throw_alert("ethereal_charge", /atom/movable/screen/alert/etherealcharge, 3)
		if(0 to NUTRITION_LEVEL_STARVING)
			H.throw_alert("ethereal_charge", /atom/movable/screen/alert/etherealcharge, 2)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			H.throw_alert("ethereal_charge", /atom/movable/screen/alert/etherealcharge, 1)
		if(NUTRITION_LEVEL_MOSTLY_FULL to NUTRITION_LEVEL_FULL)
			H.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 1)
		if(NUTRITION_LEVEL_FULL to NUTRITION_LEVEL_FAT)
			H.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 2)
		else
			H.clear_alert("ethereal_charge")
			H.clear_alert("ethereal_overcharge")

/datum/species/ethereal/proc/discharge_process(mob/living/carbon/human/H)
	to_chat(H, "<span class='warning'>You begin to lose control over your charge!</span>")
	H.visible_message("<span class='danger'>[H] begins to spark violently!</span>")
	var/static/mutable_appearance/overcharge //shameless copycode from lightning spell copied from another codebase copied from another codebase
	overcharge = overcharge || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	H.add_overlay(overcharge)
	if(do_after(H, 5 SECONDS, timed_action_flags = IGNORE_ALL))
		H.flash_lighting_fx(5, 7, current_color)
		playsound(H, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
		H.cut_overlay(overcharge)
		tesla_zap(H, 2, H.nutrition * 5, TESLA_OBJ_DAMAGE | TESLA_MOB_DAMAGE | TESLA_ALLOW_DUPLICATES)
		H.nutrition = NUTRITION_LEVEL_MOSTLY_FULL
		to_chat(H, "<span class='warning'>You violently discharge energy!</span>")
		H.visible_message("<span class='danger'>[H] violently discharges energy!</span>")
		H.electrocute_act(0, "discharge bolt", override = TRUE, stun = TRUE)
		return

/datum/species/ethereal/get_features()
	var/list/features = ..()

	features += "feature_ethcolor"

	return features

/datum/species/ethereal/get_species_description()
	return "Ethereals are one of the two other spacefaring species encountered by the SIC. Strange slime-based humanoids that emit light based on their \
		general health, ethereals are also well-known for their general benevolence and naivety. While not common within SIC space, they are still \
		a relatively accepted species in its borders."

/datum/species/ethereal/get_species_lore()
	return list(
		"On their homeplanet of Borealia, the ethereal people came to being through the bizarre process known as electro-organic attunement (or EOA). While still not fully understood, the process occurs through the combination of slime, \
		meat, and lightning in highly specific barometric conditions. As Borealia's atmosphere is highly unstable, beyond reliably long summers and even longer winters, the ethereal people grew within the underground, crystalline caverns that sprawl \
		the high-g planet. Settling near bodies of water and electric crystal packets, the absence of any light but their own created a great emphasis on an individual's light as reflective of their health, mood, and literal location. While the creation \
		of new ethereals was slow, and the number of ethereals who managed to migrate to existing settlements was even lower, the long lifespans of the strange entities meant that knowledge and organization quickly grew.",

		"Above all else, a kinship with the stars began to develop within the various cultures of ethereals. As parchment and writing were almost non-existent, the oral traditions of a group known as the Lightseers quickly became dominant as the ethereal \
		people moved toward their ultimate goal to reach the divine bodies in the skies. Conflict was rare, and, with the massive abundance of stabilized bluespace crystals, it's estimated that ethereal vehicles made of crystals, metal, and stone broke \
		the planet's atmosphere in about 1541 C.E.. FTL travel became available much sooner as well, and though their numbers grew slowly, ethereals worked their way around the Elix system. As the discovery of wood and paper finally came into their civilization, \
		cultural splits that were quickly occurring due to differences in oral tellings were quenched with the spread of literacy. By 2323, ethereals encountered the ex'hau, and the two species quickly established friendly relations. Over a century later, they \
		would also go on to meet the SIC through the ex'hau, despite their many voyages into deep space, arriving in systems such as Alpha Centauri or Palt.",

		"Ethereals are highly communal and altruistic, though they tend toward theocratic authority from their own people. Survival is not difficult within temperate environments, thus ethereals often focus on spiritual or other fulfilling measures \
		to fill their long lifespans. Older, priestly ethereals are universally respected among their people, often sought out for wisdom in both active and future affairs. Entertainment in the form of drama and visual arts are highly revered among them, \
		and those creative are considered to be more valuable than those more pragmatic. While not exceptionally prideful or violent, ethereals tend to be honest and genuine in their interactions with others, seeking not only to reward themselves with meaningful \
		conversations, but also enrich others in the great journey of life that all walk.",

		"Today, most ethereals in SIC are generally found in passing, either on a pilgrimage or working to earn enough assets to permit one. While the ethereal people have been tempered slightly by threats of piracy, they still remain largely unmolested \
		by the widespread conflicts that fraught SIC and ex'hau space. Most concerns that exist currently involve the inexplicable disappearance of a variety of ships after bluespace jumping: ones that simply do not re-appear. Investigations into these \
		vanishing ships are still ongoing, but they're largely dismissed by the other species in the nearly-formed Innergalactic Union.",
	)

/datum/species/ethereal/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Disco Ball",
			SPECIES_PERK_DESC = "Ethereals passively generate their own light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Nuclear-Powered",
			SPECIES_PERK_DESC = "Ethereals can gain charge when absorbing certain kinds of radiation.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Starving Artist",
			SPECIES_PERK_DESC = "Ethereals take toxin damage while starving.",
		),
	)

	return to_add
