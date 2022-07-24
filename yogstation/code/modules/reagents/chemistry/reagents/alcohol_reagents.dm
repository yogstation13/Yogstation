/datum/reagent/consumable/ethanol/catsip
	name = "Catsip"
	description = "A kawaii drink from space-Japan."
	color ="#ff99ac"
	boozepwr = 50
	quality = DRINK_NICE
	taste_description = "degeneracy"
	glass_icon_state = "catsip"
	glass_name = "Catsip"
	glass_desc = "Unfortunately has a tendency to induce the peculiar vocal tics of a wapanese mutant in the imbiber."
	/// Number of times the chemical is allowed to cause forced speech
	var/meowcount = 2

/datum/reagent/consumable/ethanol/catsip/on_mob_life(mob/living/M)
	if(prob(8) && meowcount)
		M.say(pick("Nya.", "N-nya!", "NYA!"), forced = "catsip")
		meowcount--
	return ..()

/datum/reagent/consumable/ethanol/catsip/on_mob_add(mob/living/carbon/human/M)
	if(!M.dna.species.is_wagging_tail())
		M.emote("wag")
	return ..()

/datum/reagent/consumable/ethanol/whiskey/kong
	name = "Kong"
	description = "Makes You Go Ape!&#174;"
	color = "#332100" // rgb: 51, 33, 0
	addiction_threshold = 15
	taste_description = "the grip of a giant ape"
	glass_name = "glass of Kong"
	glass_desc = "Makes You Go Ape!&#174;"

/datum/reagent/consumable/ethanol/whiskey/kong/addiction_act_stage1(mob/living/M)
	if(prob(5))
		to_chat(M, span_notice("You've made so many mistakes."))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "depression_minimal", /datum/mood_event/depression_minimal)
	..()

/datum/reagent/consumable/ethanol/whiskey/kong/addiction_act_stage2(mob/living/M)
	if(prob(5))
		to_chat(M, span_notice("No matter what you do, people will always get hurt."))
	SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "depression_minimal", /datum/mood_event/depression_minimal)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "depression_mild", /datum/mood_event/depression_mild)
	..()

/datum/reagent/consumable/ethanol/whiskey/kong/addiction_act_stage3(mob/living/M)
	if(prob(5))
		to_chat(M, span_notice("You've lost so many people."))
	SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "depression_mild", /datum/mood_event/depression_mild)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "depression_moderate", /datum/mood_event/depression_moderate)
	..()

/datum/reagent/consumable/ethanol/whiskey/kong/addiction_act_stage4(mob/living/M)
	if(prob(5))
		to_chat(M, span_notice("Just lie down and die."))
	SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "depression_moderate", /datum/mood_event/depression_moderate)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "depression_severe", /datum/mood_event/depression_severe)
	..()

/datum/reagent/consumable/ethanol/whiskey/candycorn
	name = "candy corn liquor"
	description = "Like they drank in 2D speakeasies."
	color = "#ccb800" // rgb: 204, 184, 0
	taste_description = "pancake syrup"
	glass_name = "glass of candy corn liquor"
	glass_desc = "Good for your Imagination."
	var/hal_amt = 4

/datum/reagent/consumable/ethanol/whiskey/candycorn/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		M.hallucination += hal_amt //conscious dreamers can be treasurers to their own currency
	..()
