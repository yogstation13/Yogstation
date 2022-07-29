/area/medical/paramedic
	name = "Paramedic Staging Area"
	icon_state = "emergencystorage"

//Minsky Specific Areas
/area/medical/paramedic/a
	name = "Primary Paramedic Staging Area"
	icon_state = "emergencystorage"

/area/medical/paramedic/b
	name = "Secondary Paramedic Staging Area"
	icon_state = "emergencystorage"
//end Minsky Specific Areas

/area/medical/psych
	name = "Psychiatrists office"
	icon_state = "exam_room"
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>I feel at ease here.\n</span>"
	ambientsounds = list('sound/ambience/aurora_caelus_short.ogg')

/area/clerk
	name = "Clerks office"
	icon_state = "cafeteria"

/area/security/brig/infirmary
	name = "Brig Infirmary"
	icon_state = "brig_infirmary"

/area/security/physician
	name = "Brig Physician's Office"
	icon_state = "physician"

/area/maintenance
	ambientsounds = list('sound/ambience/ambimaint1.ogg',
						 'sound/ambience/ambimaint2.ogg',
						 'sound/ambience/ambimaint3.ogg',
						 'sound/ambience/ambimaint4.ogg',
						 'sound/ambience/ambimaint5.ogg',
						 'sound/voice/lowHiss2.ogg', //Xeno Breathing Hisses, Hahahaha I'm not even sorry.
						 'sound/voice/lowHiss3.ogg',
						 'sound/voice/lowHiss4.ogg',
						 'yogstation/sound/misc/honk_echo_distant.ogg')

/area/bluespace_locker
	name = "Bluespace Locker"
	icon_state = "away"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	noteleport = TRUE

/area/vacant_room/office/office_b
	name = "Vacant Office - B"

/area/tcommsat/lounge
	name = "Telecommunications Satellite Lounge"
	icon_state = "tcomsatlounge"

/area/tcommsat/entrance
	name = "Telecomms Teleporter"
	icon_state = "tcomsatentrance"

/area/tcommsat/chamber
	name = "Abandoned Satellite"
	icon_state = "tcomsatcham"

/area/ai_monitored/turret_protected/tcomsat
	name = "Telecomms Satellite"
	icon_state = "tcomsatlob"

/area/ai_monitored/turret_protected/tcomfoyer
	name = "Telecomms Foyer"
	icon_state = "tcomsatentrance"

/area/ai_monitored/turret_protected/tcomwest
	name = "Telecommunications Satellite West Wing"
	icon_state = "tcomsatwest"

/area/ai_monitored/turret_protected/tcomeast
	name = "Telecommunications Satellite East Wing"
	icon_state = "tcomsateast"

/area/escapepodbay
	name = "Escape Shuttle Hallway Podbay"
	icon_state = "escape"

/area/security/podbay
	name = "Security Podbay"
	icon_state = "security"
