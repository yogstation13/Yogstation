/datum/species/plasmaman
	name = "Plasmaman"
	id = "plasmaman"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/stack/sheet/mineral/plasma
	species_traits = list(NOBLOOD,NOTRANSSTING,HAS_BONE)
	// plasmemes get hard to wound since they only need a severe bone wound to dismember, but unlike skellies, they can't pop their bones back into place.
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_RADIMMUNE,TRAIT_GENELESS,TRAIT_NOHUNGER,TRAIT_CALCIUM_HEALER,TRAIT_ALWAYS_CLEAN,TRAIT_HARDLY_WOUNDED)
	inherent_biotypes = list(MOB_INORGANIC, MOB_HUMANOID)
	mutantlungs = /obj/item/organ/lungs/plasmaman
	mutanttongue = /obj/item/organ/tongue/bone/plasmaman
	mutantliver = /obj/item/organ/liver/plasmaman
	mutantstomach = /obj/item/organ/stomach/plasmaman
	burnmod = 1.5 //Lives in suits and burns easy. Lasers are bad for this
	heatmod = 1.5 //Same goes for hot hot hot
	brutemod = 1.2 //Rattle me bones, but less because plasma bones are very hard
	siemens_coeff = 1.5 //Sparks are bad for the combustable race, mkay?
	punchdamagehigh = 7 //Bone punches are weak and usually inside soft suit gloves
	punchstunthreshold = 7 //Stuns on max hit as usual, somewhat higher stun chance because math
	payday_modifier = 0.8 //Useful to NT for plasma research
	breathid = "tox"
	damage_overlay_type = ""//let's not show bloody wounds or burns over bones.
	var/internal_fire = FALSE //If the bones themselves are burning clothes won't help you much
	disliked_food = NONE
	liked_food = DAIRY
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	species_language_holder = /datum/language_holder/plasmaman

/datum/species/plasmaman/spec_life(mob/living/carbon/human/H)
	var/datum/gas_mixture/environment = H.loc.return_air()
	var/atmos_sealed = FALSE
	if (H.wear_suit && H.head && istype(H.wear_suit, /obj/item/clothing) && istype(H.head, /obj/item/clothing))
		var/obj/item/clothing/CS = H.wear_suit
		var/obj/item/clothing/CH = H.head
		if (CS.clothing_flags & CH.clothing_flags & STOPSPRESSUREDAMAGE)
			atmos_sealed = TRUE
	if((!istype(H.w_uniform, /obj/item/clothing/under/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/plasmaman)) && !atmos_sealed)
		if(environment)
			if(environment.total_moles())
				if(environment.get_moles(/datum/gas/oxygen) >= 1) //Same threshhold that extinguishes fire
					H.adjust_fire_stacks(0.5)
					if(!H.on_fire && H.fire_stacks > 0)
						H.visible_message(span_danger("[H]'s body reacts with the atmosphere and bursts into flames!"),span_userdanger("Your body reacts with the atmosphere and bursts into flame!"))
					H.IgniteMob()
					internal_fire = TRUE
	else
		if(H.fire_stacks)
			var/obj/item/clothing/under/plasmaman/P = H.w_uniform
			if(istype(P))
				P.Extinguish(H)
				internal_fire = FALSE
		else
			internal_fire = FALSE
	H.update_fire()

/datum/species/plasmaman/handle_fire(mob/living/carbon/human/H, no_protection)
	if(internal_fire)
		no_protection = TRUE
	. = ..()

/datum/species/plasmaman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/plasmaman/O = new /datum/outfit/plasmaman
	switch(current_job)
		if("Bartender")
			O = new /datum/outfit/job/plasmaman/bartender

		if("Cook")
			O = new /datum/outfit/job/plasmaman/cook

		if("Botanist")
			O = new /datum/outfit/job/plasmaman/botanist

		if("Curator")
			O = new /datum/outfit/job/plasmaman/curator

		if("Chaplain")
			O = new /datum/outfit/job/plasmaman/chaplain

		if("Janitor")
			O = new /datum/outfit/job/plasmaman/janitor

		if("Security Officer")
			O = new /datum/outfit/job/plasmaman/security

		if("Detective")
			O = new /datum/outfit/job/plasmaman/detective

		if("Warden")
			O = new /datum/outfit/job/plasmaman/warden

		if("Cargo Technician")
			O = new /datum/outfit/job/plasmaman/cargo_tech

		if("Quartermaster")
			O = new /datum/outfit/job/plasmaman/quartermaster

		if("Shaft Miner")
			O = new /datum/outfit/job/plasmaman/miner

		if("Lawyer")
			O = new /datum/outfit/job/plasmaman/lawyer

		if("Medical Doctor")
			O = new /datum/outfit/job/plasmaman/doctor

		if("Virologist")
			O = new /datum/outfit/job/plasmaman/virologist

		if("Chemist")
			O = new /datum/outfit/job/plasmaman/chemist

		if("Geneticist")
			O = new /datum/outfit/job/plasmaman/geneticist

		if("Scientist")
			O = new /datum/outfit/job/plasmaman/scientist

		if("Roboticist")
			O = new /datum/outfit/job/plasmaman/roboticist

		if("Station Engineer")
			O = new /datum/outfit/job/plasmaman/engineer

		if("Atmospheric Technician")
			O = new /datum/outfit/job/plasmaman/atmos

		if("Mime")
			O = new /datum/outfit/job/plasmaman/mime

		if("Clown")
			O = new /datum/outfit/job/plasmaman/clown

		if("Network Admin")
			O = new /datum/outfit/job/plasmaman/sigtech

		if("Mining Medic")
			O = new /datum/outfit/job/plasmaman/miningmedic

		if("Paramedic")
			O = new /datum/outfit/job/plasmaman/paramedic

		if("Psychiatrist")
			O = new /datum/outfit/job/plasmaman/psych

		if("Brig Physician")
			O = new /datum/outfit/job/plasmaman/brigphysician

		if("Clerk")
			O = new /datum/outfit/job/plasmaman/clerk

		if("Tourist")
			O = new /datum/outfit/job/plasmaman/tourist

		if("Assistant")
			O = new /datum/outfit/job/plasmaman/assistant

		if("Artist")
			O = new /datum/outfit/job/plasmaman/artist

		if("Chief Engineer")
			O = new /datum/outfit/job/plasmaman/ce

		if("Research Director")
			O = new /datum/outfit/job/plasmaman/rd

	H.equipOutfit(O, visualsOnly)
	H.internal = H.get_item_for_held_index(2)
	H.update_internals_hud_icon(1)
	return 0

/datum/species/plasmaman/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_plasmaman_name()

	var/randname = plasmaman_name()

	if(lastname)
		randname += " [lastname]"

	return randname
