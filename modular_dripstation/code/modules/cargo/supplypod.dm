GLOBAL_LIST_INIT(podstyles, list(\
    list(POD_SHAPE_OTHER, "pod",     TRUE, FALSE,          FALSE,    RUBBLE_NORMAL,	"supply pod", 						    "A Nanotrasen supply drop pod."),\
    list(POD_SHAPE_OTHER, "advpod",   TRUE, FALSE,          FALSE,    RUBBLE_NORMAL,	"bluespace supply pod" , 			    "A Nanotrasen Bluespace supply pod. Teleports back to CentCom after delivery."),\
    list(POD_SHAPE_OTHER, "ntpod",   TRUE, FALSE,          FALSE,     RUBBLE_NORMAL,	"\improper CentCom supply pod", 		"A Nanotrasen supply pod, this one has been marked with Central Command's designations. Teleports back to CentCom after delivery."),\
    list(POD_SHAPE_OTHER, "syndipod",    TRUE, FALSE,          FALSE,      RUBBLE_NORMAL,	"blood-red supply pod", 				"An intimidating supply pod, covered in the blood-red markings of the Syndicate. It's probably best to stand back from this."),\
    list(POD_SHAPE_OTHER, "podmil",  TRUE, FALSE,			FALSE,     RUBBLE_NORMAL,	"military drop pod", 	        "An unknown drop pod marked the markings of unknown elite strike team."),\
    list(POD_SHAPE_OTHER, "cultpod", TRUE, FALSE,			FALSE,      RUBBLE_NORMAL,	"bloody supply pod", 				    "A Nanotrasen supply pod covered in scratch-marks, blood, and strange runes."),\
    list(POD_SHAPE_OTHER, "missile",     FALSE, FALSE,			FALSE,   RUBBLE_THIN,	    "cruise missile", 						"A big ass missile that didn't seem to fully detonate. It was likely launched from some far-off deep space missile silo. There appears to be an auxiliary payload hatch on the side, though manually opening it is likely impossible."),\
    list(POD_SHAPE_OTHER, "smissile",    FALSE, FALSE,	        FALSE,   RUBBLE_THIN,	    "\improper Syndicate cruise missile", 	"A big ass, blood-red missile that didn't seem to fully detonate. It was likely launched from some deep space Syndicate missile silo. There appears to be an auxiliary payload hatch on the side, though manually opening it is likely impossible."),\
    list(POD_SHAPE_OTHER, "box",         TRUE, FALSE,            FALSE,   RUBBLE_WIDE,  	"\improper Aussec supply crate", 		"An incredibly sturdy supply crate, designed to withstand orbital re-entry. Has 'Aussec Armory - 2532' engraved on the side."),\
    list(POD_SHAPE_OTHER, "clownpod",TRUE, FALSE,	        FALSE,    RUBBLE_NORMAL,	"\improper HONK pod", 				    "A brightly-colored supply pod. It likely originated from the Clown Federation."),\
    list(POD_SHAPE_OTHER, "orange",      TRUE, FALSE,			FALSE,   RUBBLE_NONE,	    "\improper Orange", 					"An angry orange."),\
    list(POD_SHAPE_OTHER, FALSE,         FALSE,    FALSE,            FALSE,   RUBBLE_NONE,	    "\improper S.T.E.A.L.T.H. pod MKVII", 	"A supply pod that, under normal circumstances, is completely invisible to conventional methods of detection. How are you even seeing this?"),\
    list(POD_SHAPE_OTHER, "gondola",     FALSE, FALSE,			FALSE,   RUBBLE_NONE,	    "gondola", 							    "The silent walker. This one seems to be part of a delivery agency."),\
    list(POD_SHAPE_OTHER, FALSE,         FALSE,    FALSE,            FALSE,   RUBBLE_NONE,	        FALSE,      FALSE,      "rl_click", "give_po")\
))

/obj/structure/closet/supplypod
	icon = 'modular_dripstation/icons/obj/supplypods.dmi'
	icon_state = "pod"

/datum/asset/spritesheet/supplypods/create_spritesheets()
	for (var/style in 1 to length(GLOB.podstyles))
		var/icon_file = 'modular_dripstation/icons/obj/supplypods.dmi'
		if (style == STYLE_SEETHROUGH)
			Insert("pod_asset[style]", icon(icon_file, "seethrough-icon"))
			continue
		var/base = GLOB.podstyles[style][POD_BASE]
		if (!base)
			Insert("pod_asset[style]", icon(icon_file, "invisible-icon"))
			continue
		var/icon/podIcon = icon(icon_file, base)
		var/door = GLOB.podstyles[style][POD_DOOR]
		if (door)
			door = "[base]_door"
			podIcon.Blend(icon(icon_file, door), ICON_OVERLAY)
		var/shape = GLOB.podstyles[style][POD_SHAPE]
		if (shape == POD_SHAPE_NORML)
			var/decal = GLOB.podstyles[style][POD_DECAL]
			if (decal)
				podIcon.Blend(icon(icon_file, decal), ICON_OVERLAY)
			var/glow = GLOB.podstyles[style][POD_GLOW]
			if (glow)
				glow = "pod_glow_[glow]"
				podIcon.Blend(icon(icon_file, glow), ICON_OVERLAY)
		Insert("pod_asset[style]", podIcon)