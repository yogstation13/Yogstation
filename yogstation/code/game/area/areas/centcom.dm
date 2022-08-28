/area/yogs/infiltrator_base
	name = "Syndicate Infiltrator Base"
	icon = 'icons/turf/areas.dmi'
	icon_state = "red"
	blob_allowed = FALSE
	requires_power = FALSE
	has_gravity = TRUE
	noteleport = TRUE
	flags_1 = NONE
	ambientsounds = HIGHSEC
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/yogs/infiltrator_base/poweralert(state, obj/source)
	return

/area/yogs/infiltrator_base/atmosalert(danger_level, obj/source)
	return

/area/yogs/infiltrator_base/jail
	name = "Syndicate Infiltrator Base Brig"

//headcanon lore: this is some random snowy moon that the syndies use as a base
/area/yogs/infiltrator_base/outside
	name = "Syndicate Base X-77"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/brazil
	name = "Location Unresolved"
	icon_state = "execution_room"
	blob_allowed = FALSE
	has_gravity = TRUE
	noteleport = TRUE
	atmos = FALSE
	flags_1 = NONE
	requires_power = FALSE
	ambientsounds = HOLY
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/brazil/maints
	name = "Location Unresolved"
	icon_state = "execution_room"
	ambientsounds = list('sound/ambience/ambimaint1.ogg',
						 'sound/ambience/ambimaint2.ogg',
						 'sound/ambience/ambimaint3.ogg',
						 'sound/ambience/ambimaint4.ogg',
						 'sound/ambience/ambimaint5.ogg',
						 'sound/voice/lowHiss2.ogg',
						 'sound/voice/lowHiss3.ogg',
						 'sound/voice/lowHiss4.ogg',
						 'yogstation/sound/misc/honk_echo_distant.ogg')
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
