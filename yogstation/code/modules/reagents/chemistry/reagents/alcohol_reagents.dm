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
	if(iscatperson(M))
		M.set_drugginess(50)
		M.adjustOrganLoss(ORGAN_SLOT_EARS, -4*REM)
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


/datum/reagent/consumable/ethanol/neurotoxin_alien
	name = "Alien Neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state. Now 100% more concentrated!"
	color = "#2E2E61" // rgb: 46, 46, 97
	boozepwr = 25
	quality = DRINK_VERYGOOD
	taste_description = "a numbing sensation"
	metabolization_rate = 1 * REAGENTS_METABOLISM
	glass_icon_state = "neurotoxinglass"
	glass_name = "Neurotoxin"
	glass_desc = "A drink that is guaranteed to knock you silly."

/datum/reagent/consumable/ethanol/neurotoxin_alien/proc/pickt()
	return (pick(TRAIT_PARALYSIS_L_ARM,TRAIT_PARALYSIS_R_ARM,TRAIT_PARALYSIS_R_LEG,TRAIT_PARALYSIS_L_LEG))

/datum/reagent/consumable/ethanol/neurotoxin_alien/on_mob_life(mob/living/carbon/M)
	M.dizziness += 2
	if(prob(20))
		M.adjustStaminaLoss(10)
		M.drop_all_held_items()
		to_chat(M, span_warning("You can't feel your hands!"))
	if(prob(20))
		var/t = pickt()
		ADD_TRAIT(M, t, type)
		M.adjustStaminaLoss(10)
	. = 1
	..()

/datum/reagent/consumable/ethanol/neurotoxin_alien/on_mob_end_metabolize(mob/living/carbon/M)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_L_ARM, type)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_R_ARM, type)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_R_LEG, type)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_L_LEG, type)
	M.adjustStaminaLoss(10)
	. = ..()