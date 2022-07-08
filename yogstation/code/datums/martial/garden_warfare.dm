#define VINE_SNATCH_COMBO "DD"

/datum/martial_art/gardern_warfare
	name = "Garden Warfare" //I feel like that I deserve a bullet into my head for this names
	id = MARTIALART_KRAVMAGA
	var/datum/action/vine_snatch/vine_snatch = new/datum/action/vine_snatch()

/datum/martial_art/gardern_warfare/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
    return FALSE

/datum/martial_art/gardern_warfare/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(can_use(A)))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/gardern_warfare/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D && (can_use(A))) 
		add_to_streak("G",D)
		if(check_streak(A,D))
			return TRUE
		return FALSE
	else
		return FALSE

/datum/martial_art/gardern_warfare/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, VINE_SNATCH_COMBO))
		vine_mark(A,D)
		return FALSE

/datum/martial_art/gardern_warfare/proc/vine_mark(mob/living/carbon/human/A, mob/living/carbon/human/D)
    to_chat(A, span_notice("You mark [D] with a vine mark. Using vine snatch now will pull an item from their active hands to you, or knokdown them and pull them to you."))
    to_chat(D, span_danger("[A] marks you!"))
    vine_snatch.target = D
    vine_snatch.last_time_marked = world.time
    streak = ""

/datum/action/vine_snatch
	name = "Vine Snatch - using it while having a target, recently marked with a vine mark in the range of 2 tiles will pull an item in their active hands to you, or pull and knockdown them.."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "neckchop"
    var/mob/living/carbon/human/target = null
    var/last_time_marked = 0

/datum/action/vine_snatch/New()
    . = ..()
    last_time_marked = world.time
