// Fishpeople are a rare race of sentient fish that have taken up a specially constructed body that lets them pilot and walk around
// The fish (brain) itself is organic, the body is not

/datum/species/fishperson
	name = "Fishperson"
	id = "fishperson"
	default_color = "FFFFFF"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | SLIME_EXTRACT
	inherent_traits = list(TRAIT_NOHUNGER, TRAIT_MEDICALIGNORE, TRAIT_VIRUSIMMUNE, TRAIT_NOBREATH)
	species_traits = list(MUTCOLORS, NOBLOOD)
	say_mod = "blubs"
	meat = /obj/item/reagent_containers/food/snacks/carpmeat/fish
	toxic_food = NONE // Doesn't eat
	burnmod = 0.65 // Water cooled, sudden burst of heat doesn't do much to change the overall temperature
	coldmod = 2 // Fish do not like cold water
	heatmod = 2 // Fish do not like hot water
	siemens_coeff = 2 // Water is an amazing conductor
	payday_modifier = 0.6 // It's literally a fish
	mutantbrain = /obj/item/organ/brain/fish
	var/thirst = NUTRITION_LEVEL_FULL
	var/thirst_drain = 0.5
	wings_icon = "Robotic"
	species_language_holder = /datum/language_holder/fishperson

/datum/species/fishperson/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return
	handle_thirst(H)

/datum/species/fishperson/proc/handle_thirst(mob/living/carbon/human/H)
	thirst = clamp(thirst - thirst_drain,0,NUTRITION_LEVEL_FULL)
	if(thirst == 0)
		to_chat(H,span_userdanger("You are out of water! Get some now!"))
		H.adjustOxyLoss(15) // you have 4 ticks until you are in crit
		H.emote("gasp")
		H.throw_alert("fish_thirst", /obj/screen/alert/fish_thirsty, 4)
	else if(thirst < NUTRITION_LEVEL_STARVING)
		H.throw_alert("fish_thirst", /obj/screen/alert/fish_thirsty, 3)
	else if(thirst < NUTRITION_LEVEL_HUNGRY)
		H.throw_alert("fish_thirst", /obj/screen/alert/fish_thirsty, 2)
	else if(thirst < NUTRITION_LEVEL_FED)
		H.throw_alert("fish_thirst", /obj/screen/alert/fish_thirsty, 1)
	else
		H.clear_alert("fish_thirst")
