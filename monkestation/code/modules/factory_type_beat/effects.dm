/obj/effect/temp_visual/mining_overlay/vent
	icon = 'monkestation/code/modules/factory_type_beat/icons/vent_overlays.dmi'
	icon_state = "unknown"
	duration = 45
	pixel_x = 0
	pixel_y = 0
	easing_style = CIRCULAR_EASING|EASE_IN

/obj/effect/decal/cleanable/rubble
	name = "rubble"
	desc = "A pile of rubble."
	icon = 'monkestation/code/modules/factory_type_beat/icons/debris.dmi'
	icon_state = "rubble"
	mergeable_decal = FALSE
	beauty = -10

/obj/effect/decal/cleanable/rubble/Initialize(mapload)
	. = ..()
	flick("rubble_bounce", src)
	icon_state = "rubble"
	update_appearance(UPDATE_ICON_STATE)
