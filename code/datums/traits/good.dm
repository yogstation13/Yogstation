//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

/datum/quirk/no_taste
	name = "Ageusia"
	desc = "You can't taste anything! Toxic food will still poison you."
	icon = "meh-blank"
	value = 2
	mob_trait = TRAIT_AGEUSIA
	gain_text = span_notice("You can't taste anything!")
	lose_text = span_notice("You can taste again!")
	medical_record_text = "Patient suffers from ageusia and is incapable of tasting food or reagents."

/datum/quirk/no_taste/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOMOUTH in species.species_traits) // Cant drink
	qdel(species)

	if(disallowed_trait)
		return "You don't have the ability to eat!"
	return FALSE

/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	icon = "beer"
	value = 2
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = span_notice("You feel like you could drink a whole keg!")
	lose_text = span_danger("You don't feel as resistant to alcohol anymore. Somehow.")
	medical_record_text = "Patient demonstrates a high tolerance for alcohol."

/datum/quirk/alcohol_tolerance/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOMOUTH in species.species_traits) // Cant drink
	qdel(species)

	if(disallowed_trait)
		return "You don't have the ability to drink!"
	return FALSE

/datum/quirk/apathetic
	name = "Apathetic"
	desc = "You just don't care as much as other people. That's nice to have in a place like this, I guess."
	icon = "meh"
	value = 2
	mood_quirk = TRUE
	medical_record_text = "Patient was administered the Apathy Evaluation Scale but did not bother to complete it."

/datum/quirk/apathetic/add()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier -= 0.2

/datum/quirk/apathetic/remove()
	if(quirk_holder)
		var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
		if(mood)
			mood.mood_modifier += 0.2

/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make you feel on top of the world. Whenever you're drunk, you slowly recover from injuries."
	icon = "wine-bottle"
	value = 4
	mob_trait = TRAIT_DRUNK_HEALING
	gain_text = span_notice("You feel like a drink would do you good.")
	lose_text = span_danger("You no longer feel like drinking would ease your pain.")
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."

/datum/quirk/drunkhealing/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOMOUTH in species.species_traits) // Cant drink
	qdel(species)

	if(disallowed_trait) // Cant drink
		return "You don't have the ability to drink!"
	return FALSE

/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	icon = "smile-beam"
	value = 1
	mob_trait = TRAIT_EMPATH
	gain_text = span_notice("You feel in tune with those around you.")
	lose_text = span_danger("You feel isolated from others.")
	medical_record_text = "Patient is highly perceptive of and sensitive to social cues, or may possibly have ESP. Further testing needed."

/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly."
	icon = "running"
	value = 4
	mob_trait = TRAIT_FREERUNNING
	gain_text = span_notice("You feel lithe on your feet!")
	lose_text = span_danger("You feel clumsy again.")
	medical_record_text = "Patient scored highly on cardio tests."

/datum/quirk/friendly
	name = "Friendly"
	desc = "You give the best hugs, especially when you're in the right mood."
	icon = "hands-helping"
	value = 1
	mob_trait = TRAIT_FRIENDLY
	gain_text = span_notice("You want to hug someone.")
	lose_text = span_danger("You no longer feel compelled to hug others.")
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates low-inhibitions for physical contact and well-developed arms. Requesting another doctor take over this case."

/datum/quirk/jolly
	name = "Jolly"
	desc = "You sometimes just feel happy, for no reason at all."
	icon = "grin"
	value = 2
	mob_trait = TRAIT_JOLLY
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates constant euthymia irregular for environment. It's a bit much, to be honest."

/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step; stepping on sharp objects is quieter, less painful and you won't leave footprints behind you."
	icon = "shoe-prints"
	value = 2
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = span_notice("You walk with a little more litheness.")
	lose_text = span_danger("You start tromping around like a barbarian.")
	medical_record_text = "Patient's dexterity belies a strong capacity for stealth."

/datum/quirk/musician
	name = "Musician"
	desc = "You can tune handheld musical instruments to play melodies that clear certain negative effects and soothe the soul."
	icon = "guitar"
	value = 1
	mob_trait = TRAIT_MUSICIAN
	gain_text = span_notice("You know everything about musical instruments.")
	lose_text = span_danger("You forget how musical instruments work.")
	medical_record_text = "Patient brain scans show a highly-developed auditory pathway."

/datum/quirk/musician/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/choice_beacon/music/B = new(get_turf(H))
	var/list/slots = list (
		"backpack" = SLOT_IN_BACKPACK,
		"hands" = SLOT_HANDS,
	)
	H.equip_in_one_of_slots(B, slots , qdel_on_fail = TRUE)

/datum/quirk/night_vision
	name = "Night Vision"
	desc = "You can see slightly more clearly in full darkness than most people."
	icon = "eye"
	value = 2
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = span_notice("The shadows seem a little less dark.")
	lose_text = span_danger("Everything seems a little darker.")
	medical_record_text = "Patient's eyes show above-average acclimation to darkness."

/datum/quirk/night_vision/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/eyes/eyes = H.getorgan(/obj/item/organ/eyes)
	if(!eyes || eyes.lighting_alpha)
		return
	eyes.Insert(H) //refresh their eyesight and vision

/datum/quirk/photographer
	name = "Photographer"
	desc = "You know how to handle a camera, shortening the delay between each shot."
	icon = "camera"
	value = 1
	mob_trait = TRAIT_PHOTOGRAPHER
	gain_text = span_notice("You know everything about photography.")
	lose_text = span_danger("You forget how photo cameras work.")
	medical_record_text = "Patient mentions photography as a stress-relieving hobby."

/datum/quirk/photographer/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/camera/camera = new(get_turf(H))
	H.put_in_hands(camera)
	H.equip_to_slot(camera, SLOT_NECK)
	H.regenerate_icons()

/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "You know your body well, and can accurately assess the extent of your wounds."
	icon = "bone"
	value = 4
	mob_trait = TRAIT_SELF_AWARE
	medical_record_text = "Patient demonstrates an uncanny knack for self-diagnosis."

/datum/quirk/skittish
	name = "Skittish"
	desc = "You can conceal yourself in danger. Ctrl-shift-click a closed locker to jump into it, as long as you have access."
	icon = "trash"
	value = 4
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Patient demonstrates a high aversion to danger and has described hiding in containers out of fear."

/datum/quirk/spiritual
	name = "Spiritual"
	desc = "You hold a spiritual belief, whether in God, nature or the arcane rules of the universe. You gain comfort from the presence of holy people, and believe that your prayers are more special than others."
	icon = "bible"
	value = 1
	mob_trait = TRAIT_SPIRITUAL
	gain_text = span_notice("You have faith in a higher power.")
	lose_text = span_danger("You lose faith!")
	medical_record_text = "Patient reports a belief in a higher power."

/datum/quirk/spiritual/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.equip_to_slot_or_del(new /obj/item/storage/box/fancy/candle_box(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), SLOT_IN_BACKPACK)

/datum/quirk/toxic_tastes
	name = "Toxic Tastes"
	desc = "You have a taste for normally dangerous foods."
	icon = "face-grin-tongue"
	value = 2
	gain_text = span_notice("Your stomach feels robust.")
	lose_text = span_notice("Your stomach feels normal again.")
	medical_record_text = "Patient demonstrates abnormal ability to process certain toxins."

/datum/quirk/toxic_tastes/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	var/toxic = species.toxic_food
	species.liked_food |= toxic
	species.toxic_food = null //removes toxic foods

/datum/quirk/toxic_tastes/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		var/datum/species/species = H.dna.species
		species.toxic_food = initial(species.toxic_food)
		species.liked_food = initial(species.liked_food)

/datum/quirk/toxic_tastes/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOMOUTH in species.species_traits) // Cant drink
	qdel(species)

	if(disallowed_trait) // Cant eat
		return "You don't have the ability to eat!"
	return FALSE

/datum/quirk/tagger
	name = "Tagger"
	desc = "You're an experienced artist. While drawing graffiti, you can get twice as many uses out of drawing supplies."
	icon = "spray-can"
	value = 1
	mob_trait = TRAIT_TAGGER
	gain_text = span_notice("You know how to tag walls efficiently.")
	lose_text = span_danger("You forget how to tag walls properly.")
	medical_record_text = "Patient was recently seen for possible paint huffing incident."

/datum/quirk/tagger/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/toy/crayon/spraycan/spraycan = new(get_turf(H))
	H.put_in_hands(spraycan)
	H.equip_to_slot(spraycan, SLOT_IN_BACKPACK)
	H.regenerate_icons()

/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine."
	icon = "drumstick-bite"
	value = 1
	mob_trait = TRAIT_VORACIOUS
	gain_text = span_notice("You feel HONGRY.")
	lose_text = span_danger("You no longer feel HONGRY.")
	medical_record_text = "Patient demonstrates a disturbing capacity for eating."

/datum/quirk/voracious/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOMOUTH in species.species_traits) // Cant drink
	qdel(species)

	if(disallowed_trait) // Cant eat
		return "You don't have the ability to eat!"
	return FALSE

/datum/quirk/efficient_metabolism //about 25% slower hunger
	name = "Efficient Metabolism"
	desc = "Your metabolism is unusually efficient, allowing you to better process your food and go longer periods without eating."
	icon = "utensils"
	value = 1
	mob_trait = TRAIT_EAT_LESS
	gain_text = span_notice("You don't feel very hungry.")
	lose_text = span_danger("You feel a bit peckish.")
	medical_record_text = "Patient has unusually efficient stomach metabolism and requires less sustenance to survive."

/datum/quirk/crafty //about 25% faster crafting
	name = "Crafty"
	desc = "You're very good at making stuff, and can craft faster than others."
	icon = "wrench"
	value = 2
	mob_trait = TRAIT_CRAFTY
	gain_text = span_notice("You feel like crafting some stuff.")
	lose_text = span_danger("You lose the itch to craft.")
	medical_record_text = "Patient is unusually speedy when creating crafts."

/datum/quirk/cyberorgan //random upgraded cybernetic organ
	name = "Cybernetic Organ"
	desc = "Due to a past incident you lost function of one of your organs, but now have a fancy upgraded cybernetic organ!"
	icon = "building-ngo"
	value = 6
	var/slot_string = "organ"
	medical_record_text = "During physical examination, patient was found to have an upgraded cybernetic organ."

/datum/quirk/cyberorgan/on_spawn()
	var/organ_slot = pick(ORGAN_SLOT_LUNGS, ORGAN_SLOT_HEART, ORGAN_SLOT_LIVER)
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/old_part = H.getorganslot(organ_slot)
	var/obj/item/organ/prosthetic
	switch(organ_slot)
		if(ORGAN_SLOT_LUNGS)
			prosthetic = new/obj/item/organ/lungs/cybernetic/upgraded(quirk_holder)
			slot_string = "lungs"
		if(ORGAN_SLOT_HEART)
			prosthetic = new/obj/item/organ/heart/cybernetic/upgraded(quirk_holder)
			slot_string = "heart"
		if(ORGAN_SLOT_LIVER)
			prosthetic = new/obj/item/organ/liver/cybernetic/upgraded(quirk_holder)
			slot_string = "liver"
	prosthetic.Insert(H)
	qdel(old_part)
	H.regenerate_icons()

/datum/quirk/cyberorgan/post_add()
	to_chat(quirk_holder, "<span class='boldannounce'>Your [slot_string] has been replaced with an upgraded cybernetic variant.</span>")

/datum/quirk/cyberorgan/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)

	if(species_type == /datum/species/ipc) // IPCs are already cybernetic
		return "You already have cybernetic organs!"
	return FALSE

/datum/quirk/telomeres_long
	name = "Long Telomeres"
	desc = "You haven't been cloned much, if at all. Your DNA's telomeres are still largely unaffected by repeated cloning, enabling cloners to work faster."
	icon = "magnifying-glass-plus"
	value = 2
	mob_trait = TRAIT_LONG_TELOMERES
	medical_record_text = "DNA analysis indicates that the patient's DNA telomeres are still naturally long."

/datum/quirk/telomeres_long/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NO_DNA_COPY in species.species_traits) //Can't pick if you have no DNA bruv.
	qdel(species)

	if(disallowed_trait) 
		return "You have no DNA!"
	return FALSE

/datum/quirk/multilingual
	name = "Multilingual"
	desc = "You spent a portion of your life learning to understand an additional language. You may or may not be able to speak it based on your anatomy."
	icon = "book"
	value = 3
	var/datum/language/specific
	gain_text = span_notice("You have learned to understand an additional language.")
	lose_text = span_notice("You have forgotten how to understand a language.")

/datum/quirk/multilingual/add()
	var/mob/living/carbon/human/H = quirk_holder
	if(specific)
		H.grant_language(specific, TRUE, TRUE, LANGUAGE_MULTILINGUAL)
	else
		var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
		var/list/languages_possible = T.languages_possible
		languages_possible = languages_possible - typecacheof(/datum/language/codespeak) - typecacheof(/datum/language/narsie) - typecacheof(/datum/language/ratvar)
		languages_possible = languages_possible - H.language_holder.understood_languages
		languages_possible = languages_possible - H.language_holder.blocked_languages
		if(length(languages_possible))
			var/datum/language/random_language = pick(languages_possible)
			H.grant_language(random_language, TRUE, TRUE, LANGUAGE_MULTILINGUAL)

/datum/quirk/multilingual/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	if(species && specific)
		var/mob/M = new /mob // can't instantiate a language holder without an owner
		var/datum/language_holder/lang = new species.species_language_holder(M)
		if(length(lang.understood_languages) && (specific in lang.understood_languages))
			var/datum/language/L = new specific()
			return "You already know [L.name]!"
		if(length(lang.blocked_languages) && (specific in lang.blocked_languages))
			var/datum/language/L = new specific()
			return "You are incapable of understanding [L.name]!"
	return FALSE

/datum/quirk/multilingual/english
	name = "Multilingual (English)"
	desc = "You spent a portion of your life learning to understand English. You may or may not be able to speak it based on your anatomy."
	specific = /datum/language/english
	gain_text = span_notice("You have learned to understand English.")
	lose_text = span_notice("You have forgotten how to understand English.")

/datum/quirk/multilingual/etherean
	name = "Multilingual (Etherean)"
	desc = "You spent a portion of your life learning to understand Etherean. You may or may not be able to speak it based on your anatomy."
	specific = /datum/language/etherean
	gain_text = span_notice("You have learned to understand Etherean.")
	lose_text = span_notice("You have forgotten how to understand Etherean.")

/datum/quirk/multilingual/mothian
	name = "Multilingual (Mothian)"
	desc = "You spent a portion of your life learning to understand Mothian. You may or may not be able to speak it based on your anatomy."
	specific = /datum/language/mothian
	gain_text = span_notice("You have learned to understand Mothian.")
	lose_text = span_notice("You have forgotten how to understand Mothian.")

/datum/quirk/multilingual/draconic
	name = "Multilingual (Draconic)"
	desc = "You spent a portion of your life learning to understand Draconic. You may or may not be able to speak it based on your anatomy."
	specific = /datum/language/draconic
	gain_text = span_notice("You have learned to understand Draconic.")
	lose_text = span_notice("You have forgotten how to understand Draconic.")

/datum/quirk/multilingual/felinid
	name = "Multilingual (Felinid)"
	desc = "You spent a portion of your life learning to understand Felinid. You may or may not be able to speak it based on your anatomy."
	specific = /datum/language/draconic
	gain_text = span_notice("You have learned to understand Felinid.")
	lose_text = span_notice("You have forgotten how to understand Felinid.")

/datum/quirk/multilingual/sylvan
	name = "Multilingual (Sylvan)"
	desc = "You spent a portion of your life learning to understand Sylvan. You may or may not be able to speak it based on your anatomy."
	specific = /datum/language/sylvan
	gain_text = span_notice("You have learned to understand Sylvan.")
	lose_text = span_notice("You have forgotten how to understand Sylvan.")

/datum/quirk/multilingual/polysmorph
	name = "Multilingual (Polysmorph)"
	desc = "You spent a portion of your life learning to understand Polysmorph. You may or may not be able to speak it based on your anatomy."
	specific = /datum/language/polysmorph
	gain_text = span_notice("You have learned to understand Polysmorph.")
	lose_text = span_notice("You have forgotten how to understand Polysmorph.")

/datum/quirk/multilingual/bonespeak
	name = "Multilingual (Bonespeak)"
	desc = "You spent a portion of your life learning to understand Bonespeak. You may or may not be able to speak it based on your anatomy."
	specific = /datum/language/bonespeak
	gain_text = span_notice("You have learned to understand Bonespeak.")
	lose_text = span_notice("You have forgotten how to understand Bonespeak.")
