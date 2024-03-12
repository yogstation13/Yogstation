/datum/species/human
	name = "Human"
	id = "human"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,HAS_FLESH,HAS_BONE)
	default_features = list("mcolor" = "#FFFFFF", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW | MICE
	liked_food = JUNKFOOD | FRIED | GRILLED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/english

	var/list/female_screams = list('sound/voice/human/femalescream_1.ogg', 'sound/voice/human/femalescream_2.ogg', 'sound/voice/human/femalescream_3.ogg', 'sound/voice/human/femalescream_4.ogg', 'sound/voice/human/femalescream_5.ogg')
	var/list/male_screams = list('sound/voice/human/malescream_1.ogg', 'sound/voice/human/malescream_2.ogg', 'sound/voice/human/malescream_3.ogg', 'sound/voice/human/malescream_4.ogg', 'sound/voice/human/malescream_5.ogg')

	smells_like = "soap and superiority"

/datum/species/human/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.

/datum/species/human/has_toes()
	return TRUE

/datum/species/human/get_butt_sprite(mob/living/carbon/human/human)
	var/butt_sprite = human.gender == FEMALE ? BUTT_SPRITE_HUMAN_FEMALE : BUTT_SPRITE_HUMAN_MALE
	var/obj/item/organ/tail/tail = human.getorganslot(ORGAN_SLOT_TAIL)
	return tail?.get_butt_sprite() || butt_sprite

/datum/species/human/get_scream_sound(mob/living/carbon/human/H)
	if(H.gender == FEMALE)
		return pick(female_screams)
	else
		if(prob(1))
			return 'sound/voice/human/wilhelm_scream.ogg'
		return pick(male_screams)

/datum/species/human/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hair_style = "Business Hair"
	human.hair_color = "b96" // brown
	human.update_hair()

/datum/species/human/get_species_description()
	return "Humans are the dominant species within Sol Interplanetary Coalition space, which primarily occupies the Sol and Val systems. Ingenuous, \
		determined, and capable of rapid acclimation to various situations due to their prowess with technology, humanity finds itself one of the most \
		curious species in the known galaxy."

/datum/species/human/get_species_lore()
	return list(
		"Humanity in the setting of Yogstation 13 are much the same as the humans we know. Descended from primates, humans went on to conquer Earth, before they would turn to conquer themselves for several centuries. The official split from real history \
		begins in 2050. With the pressing concerns of climate change and scarcity pressing humanity toward colonization in space, it was not long before a third Space Race broke out in 2084. At this time, coastal waters were still rising, and \
		several settlements on coasts without flood gates were abandoned. Rates of urbanization and population growth only continued to rise, and the terraforming of Luna began in about 2126. The invention of various alternative energies \
		and optimization of combustion engines eventually opened the gates to mass colonization not only of Luna, but Mars too. As the richest corporations and governments began to establish their influences on the separate planets, the rest of humanity \
		on Earth faced pandemics, the development of upper city platforms (causing the infamous development of \"Lower Cities\" in metropoli such as Tokyo, Delhi, Chicago, and Cairo), and energy panics.",

		"In 2174, the Martian Colonies took advantage of high tensions between Earth nations to declare independence, with Luna following suit two years later. While both were offered a seat within the UN, the global organization fell apart in \
		2205, with the remaining non-Earth powers of the Martian Cartel, the Democracy of Luna, the Belter Collective, and the Ganymede Republic all combining into the \"Coalition\". The United Federation of Earth, or EarthFed for short, was quickly formed \
		in response by some UN remnants. Over the next seventy-five years, human corporations would move to grow, including the expansion of companies such as Nanotrasen, Cybersun Industries, Donk Co., Aussec Armaments, Sano-Waltfield Industries, \
		and Blueshield Security Services. A skirmish on Luna between Martian marines, Lunis troopers, and EarthFed soldiers then sparked the Great Sol War in 2280. The first conflict that saw the usage of laser weaponry, casual nuclear armaments in spatial \
		warfare, and intense military cybernetics, the Great Sol War quickly paved the way for a variety of conventions to prevent devastating planetary attacks. Despite this, the war came to a close in 2288 after Mars fails to land seventeen different meteors \
		into Earth, the latter threatening to glass the red planet entirely.",
		
		"In 2294, after tensions have declined further, the Coalition rebranded into the SIC, or the Sol Interplanetary Coalition, made up of a four-member council system that includes Earth, Mars, \
		planetoids (such as Ganymede or Ceres), and space stations (such as Venus or Pluto). A variety of colony ship projects failed, despite the combined assets of each member of the SIC. It is only in 2400, during a time known as the Great Embarkment, that a \
		colony ship successfully arrived in the adjacent Val system, greatly enabling humanity's access to the revolutionary material known as baroxuldium, or plasma. The next one hundred years would see a wonderful golden age of humanity setting out into the stars, \
		encountering a variety of alien species. While most are non-sapient fauna, the discovery of the vuulen on the warmer planet of Sangris marked first contact with another intelligent alien species. While humanity's relationship with the reptilian species would \
		prove to be complicated over the next several decades, humans are more than enthused to effect their infrastructure, culture, and efforts wherever they go.",

		"Human communities are still traditionally organized, with an emphasis placed on the family unit within most cultures. In the vast deepness of space, the necessity of trust and discovery of alien specieshas only further amplified a variety of social \
		powers, such as religion, philosophy, and nationalism. The invention of new technologies such as cybernetics, MMIs, and cloning yield only further questions for human thinkers to ask and for the public to reflect on. Cultural analyses of various speculative \
		fiction of the past only grow in number as humanity moves forward, the same warnings being issued about topics such as silicon life, transhumanism, and the increasing ability of anyone to establish surveilance on anyone. Language and dialects are highly volatile \
		due to several platforms for engagement and the increasing distance between differing human groups. It is only through the universal education of Galactic Common, a mixture of Latin-based languages and Mandarin Chinese, that widespread communication is possible.",

		"By the year 2517, the SIC has declined to a shade of its former self. As discontent from member nations yields greater conflict and paralysis within the flawed governmental system, several human powers are moving to secure their own assets and peoples. The \
		dream of a nation without ties to the SIC on the Frontier is currently being dashed by the territorial and hostile efforts of the Remnants of Vxtvul, an organized government comprised of preterni, the children of an ancient, now-dead precursor species known \
		as the Vxtrin. Despite this, humanity still finds itself with a variety of unclaimed bounties at its hands. Though their ideas may differ on how to proceed and some opt for the weapon over the tongue, the future of humanity is largely unwritten. The only \
		thing known for certain is that their insatiable curiosity will always hold. As increased bluespace usage further invites extraplanar powers into the galaxy, it is unknown how humans will fare against the powers beyond the Veil.",
	)

/datum/species/human/create_pref_unique_perks()
	var/list/to_add = list()

	if(CONFIG_GET(number/default_laws) == 0) // Default lawset is set to Asimov
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "robot",
			SPECIES_PERK_NAME = "Asimov Superiority",
			SPECIES_PERK_DESC = "The AI and their cyborgs are, by default, subservient only \
				to humans. As a human, silicons are required to both protect and obey you.",
		))

	if(CONFIG_GET(flag/enforce_human_authority))
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bullhorn",
			SPECIES_PERK_NAME = "Chain of Command",
			SPECIES_PERK_DESC = "Nanotrasen only recognizes humans for Captain and Head of Personel. In addition to this, humans get more than other species.",
		))

	return to_add
