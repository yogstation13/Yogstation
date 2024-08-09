/datum/sprite_accessory
	var/color_blend_mode = COLOR_BLEND_MULTIPLY
	///the body slots outside of the main slot this accessory exists in, so we can draw to those spots seperately
	var/list/body_slots = list()
	/// the list of external organs covered
	var/list/external_slots = list()
	var/list/sprite_sheets = list() //For accessories common across species but need to use 'fitted' sprites (like underwear). e.g. list(SPECIES_VOX = 'icons/mob/species/vox/iconfile.dmi')

/datum/sprite_accessory/undershirt
	sprite_sheets = list(SPECIES_VOX = 'icons/mob/clothing/species/vox/undershirt.dmi')

/datum/sprite_accessory/undershirt/goose
	name = "Shirt (Vomit Goose)"
	icon_state = "vomitgooseshirt"
	icon = 'yogstation/icons/mob/clothing/sprite_accessories/undershirt.dmi'
	gender = NEUTER

/datum/sprite_accessory/underwear
	sprite_sheets = list(SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi')

/datum/sprite_accessory/socks
	sprite_sheets = list(SPECIES_VOX = 'icons/mob/clothing/species/vox/socks.dmi')

// Vox Accessories

/datum/sprite_accessory/vox_quills
	icon = 'icons/mob/species/vox/quills.dmi'
	color_src = HAIR
	color_blend_mode = COLOR_BLEND_ADD

/datum/sprite_accessory/vox_quills/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/vox_quills/crested
	name = "Crested"
	icon_state = "crested"

/datum/sprite_accessory/vox_quills/emperor
	name = "Emperor"
	icon_state = "emperor"

/datum/sprite_accessory/vox_quills/keel
	name = "Keel"
	icon_state = "keel"

/datum/sprite_accessory/vox_quills/keet
	name = "Keet"
	icon_state = "keet"

/datum/sprite_accessory/vox_quills/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/vox_quills/tiel
	name = "Tiel"
	icon_state = "tiel"

/datum/sprite_accessory/vox_quills/kingly
	name = "Kingly"
	icon_state = "kingly"

/datum/sprite_accessory/vox_quills/afro
	name = "Fluffy"
	icon_state = "afro"

/datum/sprite_accessory/vox_quills/yasuhiro
	name = "Long"
	icon_state = "yasuhiro"

/datum/sprite_accessory/vox_quills/razor
	name = "Razorback"
	icon_state = "razor"

/datum/sprite_accessory/vox_quills/razor_clipped
	name = "Clipped Razorback"
	icon_state = "razor_clipped"

/datum/sprite_accessory/vox_quills/long_braid
	name = "Long Braided"
	icon_state = "long_braid"

/datum/sprite_accessory/vox_quills/short_braid
	name = "Short Braided"
	icon_state = "short_braid"

/datum/sprite_accessory/vox_quills/mowhawk
	name = "Mohawk"
	icon_state = "mohawk"

/datum/sprite_accessory/vox_quills/hawk
	name = "Hawk"
	icon_state = "hawk"

/datum/sprite_accessory/vox_quills/horns
	name = "Horns"
	icon_state = "horns"

/datum/sprite_accessory/vox_quills/mange
	name = "Mange"
	icon_state = "mange"

/datum/sprite_accessory/vox_quills/ponytail
	name = "Ponytail"
	icon_state = "ponytail"

/datum/sprite_accessory/vox_quills/rows
	name = "Rows"
	icon_state = "rows"

/datum/sprite_accessory/vox_quills/surf
	name = "Surf"
	icon_state = "surf"

/datum/sprite_accessory/vox_quills/flowing
	name = "Flowing"
	icon_state = "flowing"

/datum/sprite_accessory/vox_quills/nights
	name = "Nights"
	icon_state = "nights"

/datum/sprite_accessory/vox_quills/cropped
	name = "Cropped"
	icon_state = "cropped"

/datum/sprite_accessory/vox_facial_quills
	icon = 'icons/mob/species/vox/facial_quills.dmi'
	color_src = FACEHAIR
	color_blend_mode = COLOR_BLEND_ADD

/datum/sprite_accessory/vox_facial_quills/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/vox_facial_quills/colonel
	name = "Colonel"
	icon_state = "colonel"

/datum/sprite_accessory/vox_facial_quills/fu
	name = "Fu"
	icon_state = "fu"

/datum/sprite_accessory/vox_facial_quills/neck
	name = "Neck"
	icon_state = "neck"

/datum/sprite_accessory/vox_facial_quills/beard
	name = "Beard"
	icon_state = "beard"

/datum/sprite_accessory/vox_facial_quills/ruff
	name = "Ruff"
	icon_state = "ruff"

/datum/sprite_accessory/vox_tails
	icon = 'icons/mob/species/vox/tails.dmi'
	color_src = NONE

/datum/sprite_accessory/vox_tails/lime
	name = "lime"
	icon_state = "lime"

/datum/sprite_accessory/vox_tails/crimson
	name = "crimson"
	icon_state = "crimson"

/datum/sprite_accessory/vox_tails/grey
	name = "grey"
	icon_state = "grey"

/datum/sprite_accessory/vox_tails/nebula
	name = "nebula"
	icon_state = "nebula"

/datum/sprite_accessory/vox_tails/azure
	name = "azure"
	icon_state = "azure"

/datum/sprite_accessory/vox_tails/emerald
	name = "emerald"
	icon_state = "emerald"

/datum/sprite_accessory/vox_tails/brown
	name = "brown"
	icon_state = "brown"

/datum/sprite_accessory/vox_tails/plum
	name = "plum"
	icon_state = "plum"

/datum/sprite_accessory/vox_tails/mossy
	name = "mossy"
	icon_state = "mossy"

/datum/sprite_accessory/tails_animated/vox
	icon = 'icons/mob/species/vox/tails.dmi'
	color_src = NONE

/datum/sprite_accessory/tails_animated/vox/lime
	name = "lime"
	icon_state = "lime"

/datum/sprite_accessory/tails_animated/vox/crimson
	name = "crimson"
	icon_state = "crimson"

/datum/sprite_accessory/tails_animated/vox/grey
	name = "grey"
	icon_state = "grey"

/datum/sprite_accessory/tails_animated/vox/nebula
	name = "nebula"
	icon_state = "nebula"

/datum/sprite_accessory/tails_animated/vox/azure
	name = "azure"
	icon_state = "azure"

/datum/sprite_accessory/tails_animated/vox/emerald
	name = "emerald"
	icon_state = "emerald"

/datum/sprite_accessory/tails_animated/vox/brown
	name = "brown"
	icon_state = "brown"

/datum/sprite_accessory/tails_animated/vox/plum
	name = "plum"
	icon_state = "plum"

/datum/sprite_accessory/tails_animated/vox/mossy
	name = "mossy"
	icon_state = "mossy"

/datum/sprite_accessory/vox_body_markings
	icon = 'icons/mob/species/vox/body_markings.dmi'
	color_blend_mode = COLOR_BLEND_ADD

/datum/sprite_accessory/vox_body_markings/none
	name = "None"

/datum/sprite_accessory/vox_body_markings/heart
	name = "Heart"
	icon_state = "heart"
	body_slots = list(BODY_ZONE_R_ARM)

/datum/sprite_accessory/vox_body_markings/hive
	name = "Hive"
	icon_state = "hive"
	body_slots = list(BODY_ZONE_CHEST)

/datum/sprite_accessory/vox_body_markings/nightling
	name = "Nightling"
	icon_state = "nightling"
	body_slots = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

/datum/sprite_accessory/vox_body_markings/tiger_body
	name = "Tiger-stripe"
	icon_state = "tiger"
	body_slots = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/sprite_accessory/vox_tail_markings
	icon = 'icons/mob/species/vox/tail_markings.dmi'
	color_src = MUTCOLORS_SECONDARY
	color_blend_mode = COLOR_BLEND_ADD

/datum/sprite_accessory/vox_tail_markings/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/vox_tail_markings/bands
	name = "Bands"
	icon_state = "bands"

/datum/sprite_accessory/vox_tail_markings/tip
	name = "Tip"
	icon_state = "tip"

/datum/sprite_accessory/vox_tail_markings/stripe
	name = "Stripe"
	icon_state = "stripe"

/datum/sprite_accessory/vox_tail_markings_animated
	icon = 'icons/mob/species/vox/tail_markings.dmi'
	color_src = MUTCOLORS_SECONDARY
	color_blend_mode = COLOR_BLEND_ADD

/datum/sprite_accessory/vox_tail_markings_animated/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/vox_tail_markings_animated/bands
	name = "Bands"
	icon_state = "bands"

/datum/sprite_accessory/vox_tail_markings_animated/tip
	name = "Tip"
	icon_state = "tip"

/datum/sprite_accessory/vox_tail_markings_animated/stripe
	name = "Stripe"
	icon_state = "stripe"
