/datum/sprite_accessory
	var/color_blend_mode = COLOR_BLEND_MULTIPLY
	///the body slots outside of the main slot this accessory exists in, so we can draw to those spots seperately
	var/list/body_slots = list()
	/// the list of external organs covered
	var/list/external_slots = list()
	var/list/sprite_sheets = list() //For accessories common across species but need to use 'fitted' sprites (like underwear). e.g. list(SPECIES_VOX = 'icons/mob/species/vox/iconfile.dmi')

/datum/sprite_accessory/undershirt


/datum/sprite_accessory/undershirt/goose
	name = "Shirt (Vomit Goose)"
	icon_state = "vomitgooseshirt"
	icon = 'yogstation/icons/mob/clothing/sprite_accessories/undershirt.dmi'
	gender = NEUTER
