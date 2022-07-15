/datum/mood_event/drunk
	mood_change = 3
	description = "<span class='nicegreen'>Everything just feels better after a drink or two.</span>\n"

/datum/mood_event/drunk/add_effects(param)
	// Display blush visual
	if(ishuman(owner.parent))
		var/mob/living/carbon/human/H = owner.parent
		ADD_TRAIT(H, TRAIT_BLUSHING, "[type]")
		H.update_body()

/datum/mood_event/drunk/remove_effects()
	// Stop displaying blush visual
	REMOVE_TRAIT(owner.parent, TRAIT_BLUSHING, "[type]")
	if(ishuman(owner.parent))
		var/mob/living/carbon/human/H = owner.parent
		H.update_body()

/datum/mood_event/quality_nice
	description = "<span class='nicegreen'>That drink wasn't bad at all.</span>\n"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/quality_good
	description = "<span class='nicegreen'>That drink was pretty good.</span>\n"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/quality_verygood
	description = "<span class='nicegreen'>That drink was great!</span>\n"
	mood_change = 3
	timeout = 2 MINUTES

/datum/mood_event/quality_fantastic
	description = "<span class='nicegreen'>That drink was amazing!</span>\n"
	mood_change = 4
	timeout = 2 MINUTES

/datum/mood_event/amazingtaste
	description = "<span class='nicegreen'>Amazing taste!</span>\n"
	mood_change = 50
	timeout = 10 MINUTES
