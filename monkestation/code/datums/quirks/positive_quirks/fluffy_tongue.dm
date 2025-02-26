/datum/quirk/fluffy_tongue
	name = "Fluffy Tongue"
	desc = "After spending too much time watching anime you have developed a horrible speech impediment."
	value = 5
	icon = FA_ICON_CAT

/datum/quirk/fluffy_tongue/add()
	quirk_holder.AddComponentFrom(QUIRK_TRAIT, /datum/component/fluffy_tongue)

/datum/quirk/fluffy_tongue/remove()
	quirk_holder.RemoveComponentSource(QUIRK_TRAIT, /datum/component/fluffy_tongue)
