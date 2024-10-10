// ear code here
/obj/item/organ/internal/ears/avian
	name = "avian ears"
	desc = "Senstive, much?"
	// yes, this uses the default icon. Yellow TODO: make an organ sprite for this
	damage_multiplier = 1.5 // felinids take 2x ear damage, ornithids have other things to worry about (pain increase) so they get 1.5x

// end ear code. begin plumage code, because external organs are significantly fucking better to work in than internals when it comes to visuals

/obj/item/organ/external/plumage
	name = "Plumage"
	desc = "Some feathers to ruffle. Seems the person who lost this definitely had theirs."
	preference = "feature_avian_ears"

	icon = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithidfeatures.dmi'

	dna_block = DNA_AVIAN_EARS_BLOCK // putting this as a reminder to future c*ders, this used to be part of ears.
	bodypart_overlay = /datum/bodypart_overlay/mutant/plumage
	use_mob_sprite_as_obj_sprite = TRUE
	slot = ORGAN_SLOT_EXTERNAL_FEATHERS

/datum/bodypart_overlay/mutant/plumage
	feature_key = "ears_avian"
	layers = EXTERNAL_FRONT
	color_source = ORGAN_COLOR_OVERRIDE
	palette = /datum/color_palette/ornithids
	palette_key = "plummage"
	fallback_key = "feather_main"

/datum/bodypart_overlay/mutant/plumage/get_global_feature_list()
	return GLOB.avian_ears_list

/datum/sprite_accessory/plumage
	icon = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithidfeatures.dmi'

/datum/sprite_accessory/plumage/hermes
	name = "Hermes"
	icon_state = "hermes"

/datum/sprite_accessory/plumage/arched
	name = "Arched"
	icon_state = "arched"

/* /datum/sprite_accessory/plumage/kresnik // similar to tails (originally!), this is commented out for the time being.
	name = "Kresnik"
	icon_state = "kresnik" */
