/datum/antagonist/sentient_creature
	name = "\improper Sentient Creature"
	show_in_antagpanel = FALSE
	show_in_roundend = FALSE

/datum/antagonist/sentient_creature/get_preview_icon()
	var/icon/final_icon = icon('icons/mob/pets.dmi', "corgi")

	var/icon/broodmother = icon('icons/mob/lavaland/lavaland_elites.dmi', "broodmother")
	broodmother.Blend(rgb(128, 128, 128, 128), ICON_MULTIPLY)
	final_icon.Blend(broodmother, ICON_UNDERLAY, -world.icon_size / 4, 0)

	var/icon/rat = icon('icons/mob/animal.dmi', "regalrat")
	rat.Blend(rgb(128, 128, 128, 128), ICON_MULTIPLY)
	final_icon.Blend(rat, ICON_UNDERLAY, world.icon_size / 4, 0)

	final_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return final_icon
