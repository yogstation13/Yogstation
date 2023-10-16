/datum/action/cooldown/spell/pointed/blind/eldritch
	name = "Eldritch Blind"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	invocation = "E'E'S"
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	cast_range = 10

/obj/effect/temp_visual/dir_setting/entropic
	icon = 'icons/effects/160x160.dmi'
	icon_state = "entropic_plume"
	duration = 3 SECONDS

/obj/effect/temp_visual/dir_setting/entropic/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128

/obj/effect/glowing_rune
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "small_rune_1"
	layer = LOW_SIGIL_LAYER

/obj/effect/glowing_rune/Initialize(mapload)
	. = ..()
	pixel_y = rand(-6,6)
	pixel_x = rand(-6,6)
	icon_state = "small_rune_[rand(12)]"
	update_appearance(UPDATE_ICON)
