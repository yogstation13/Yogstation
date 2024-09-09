//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

/datum/quirk/no_taste
	name = "Ageusia"
	desc = "You can't taste anything! Toxic food will still poison you."
	icon = "meh-blank"
	value = 4
	mob_trait = TRAIT_AGEUSIA
	gain_text = span_notice("You can't taste anything!")
	lose_text = span_notice("You can taste again!")
	medical_record_text = "Patient suffers from ageusia and is incapable of tasting food or reagents."

/datum/quirk/no_taste/check_quirk(datum/preferences/prefs)
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	species_type = new species_type()
	var/disallowed_trait = (NOMOUTH in species_type.species_traits) // Cant eat
	qdel(species_type)
	
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
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	species_type = new species_type()
	var/disallowed_trait = (NOMOUTH in species_type.species_traits) // Cant eat
	qdel(species_type)

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
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	species_type = new species_type()
	var/disallowed_trait = (NOMOUTH in species_type.species_traits) // Cant eat
	qdel(species_type)

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
	if(!istype(H)) //sanity check
		return
	H.update_sight()//refresh their eyesight and vision

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
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	species_type = new species_type()
	var/disallowed_trait = (NOMOUTH in species_type.species_traits) // Cant eat
	qdel(species_type)

	if(disallowed_trait) // Cant eat
		return "You don't have the ability to eat!"
	return FALSE

/datum/quirk/efficient_metabolism //about 25% slower hunger/thirst
	name = "Efficient Metabolism"
	desc = "Your metabolism is unusually efficient, allowing you to better process your food and go longer periods without eating or drinking."
	icon = "utensils"
	value = 2
	mob_trait = TRAIT_EAT_LESS
	gain_text = span_notice("You don't feel very hungry.")
	lose_text = span_danger("You feel a bit peckish.")
	medical_record_text = "Patient has unusually efficient stomach metabolism and requires less sustenance to survive."

/datum/quirk/crafty //about 25% faster crafting
	name = "Crafty"
	desc = "You're very good at making stuff, and can craft faster than others."
	icon = "wrench"
	value = 1
	mob_trait = TRAIT_CRAFTY
	gain_text = span_notice("You feel like crafting some stuff.")
	lose_text = span_danger("You lose the itch to craft.")
	medical_record_text = "Patient is unusually speedy when creating crafts."
