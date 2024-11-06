/datum/bodypart_overlay/mutant/pod_hair/get_overlay(layer, obj/item/bodypart/limb)
	layer = -HAIR_LAYER
	var/mutable_appearance/MA = mutable_appearance(layer = layer)
	for(var/image_layer in list(-BODY_ADJ_LAYER, -BODY_FRONT_LAYER))
		var/mutable_appearance/returned = get_image(image_layer, limb)
		color_image(returned, image_layer, limb)
		MA.overlays += returned
	return MA

/datum/bodypart_overlay/mutant/pod_hair/get_image(image_layer, obj/item/bodypart/limb)
	if(!sprite_datum)
		CRASH("Trying to call get_image() on [type] while it didn't have a sprite_datum. This shouldn't happen, report it as soon as possible.")

	var/list/icon_state_builder = list()
	icon_state_builder += "m" //Male is default because sprite accessories are so ancient they predate the concept of not hardcoding gender
	icon_state_builder += feature_key
	icon_state_builder += get_base_icon_state()
	icon_state_builder += mutant_bodyparts_layertext(image_layer)

	var/icon = sprite_datum.icon
	var/finished_icon_state = icon_state_builder.Join("_")

	if(image_layer == -BODY_ADJ_LAYER && istype(limb, /obj/item/bodypart/head/floran))
		icon = 'monkestation/icons/mob/species/floran/floran_hair.dmi'
		finished_icon_state = get_base_icon_state()

	var/mutable_appearance/appearance = mutable_appearance(icon, finished_icon_state, layer = -HAIR_LAYER)

	if(sprite_datum.center)
		center_image(appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)

	return appearance
