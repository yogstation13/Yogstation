/mob/living/basic/drone
	/// Should this drone be given a diagnostic HUD?
	/// This is only a thing so bardrones don't get the unneeded HUD.
	var/show_diag_hud = TRUE

/mob/living/basic/drone/Initialize(mapload)
	. = ..()
	if(show_diag_hud)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		hud.show_to(src)
		ADD_TRAIT(src, TRAIT_DIAGNOSTIC_HUD, INNATE_TRAIT)
