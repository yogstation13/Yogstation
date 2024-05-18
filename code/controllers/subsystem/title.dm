SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE
	init_stage = INITSTAGE_EARLY

	var/file_path
	var/icon/icon
	var/icon/previous_icon
	var/turf/closed/indestructible/splashscreen/splash_turf

/datum/controller/subsystem/title/Initialize()
	if(file_path && icon)
		return SS_INIT_SUCCESS

	if(fexists("data/previous_title.dat"))
		var/previous_path = file2text("data/previous_title.dat")
		if(istext(previous_path))
			previous_icon = new(previous_icon)
	fdel("data/previous_title.dat")

	var/list/normal_provisional_title_screens = flist("[global.config.directory]/title_screens/images/normal/")
	var/list/joke_provisional_title_screens = flist("[global.config.directory]/title_screens/images/joke/")
	var/list/rare_provisional_title_screens = flist("[global.config.directory]/title_screens/images/rare/")
	var/list/title_screens = list()
	var/use_rare_screens = prob(1)		// 1% Chance for Rare Screens in /rare
	var/use_joke_screens = prob(10) 	// 10% Chance for Joke Screens in /joke

	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		use_joke_screens = TRUE

	if(use_rare_screens)
		for(var/S in rare_provisional_title_screens)
			title_screens += S
		if(length(title_screens))
			file_path = "[global.config.directory]/title_screens/images/rare/[pick(title_screens)]"
	
	else if(use_joke_screens)
		for(var/S in joke_provisional_title_screens)
			title_screens += S
		if(length(title_screens))
			file_path = "[global.config.directory]/title_screens/images/joke/[pick(title_screens)]"

	else
		for(var/S in normal_provisional_title_screens)
			title_screens += S
		if(length(title_screens))
			file_path = "[global.config.directory]/title_screens/images/normal/[pick(title_screens)]"

	if(!file_path)
		file_path = "icons/default_title.dmi"

	ASSERT(fexists(file_path))

	icon = new(fcopy_rsc(file_path))

	if(splash_turf)
		splash_turf.icon = icon

	return SS_INIT_SUCCESS

/datum/controller/subsystem/title/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, icon))
				if(splash_turf)
					splash_turf.icon = icon

/datum/controller/subsystem/title/proc/fadeout()
	for(var/thing in GLOB.clients)
		if(!thing)
			continue
		var/atom/movable/screen/splash/S = new(null, thing, FALSE)
		S.Fade(FALSE,FALSE)

/datum/controller/subsystem/title/Shutdown()
	if(file_path)
		var/F = file("data/previous_title.dat")
		WRITE_FILE(F, file_path)

/datum/controller/subsystem/title/Recover()
	icon = SStitle.icon
	splash_turf = SStitle.splash_turf
	file_path = SStitle.file_path
	previous_icon = SStitle.previous_icon
