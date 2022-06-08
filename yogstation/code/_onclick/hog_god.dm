// HoG god controlls

/atom/proc/attack_god(var/mob/camera/hog_god/god, var/modifier = FALSE)
	return

/mob/camera/hog_god/ClickOn(var/atom/A, var/params) 
	var/list/modifiers = params2list(params)
	var/modifier = FALSE
	if(modifiers["middle"])
		modifier = "middle"
	if(modifiers["shift"])
		modifier = "shift"
	if(modifiers["alt"])
		modifier = "alt"
	if(modifiers["ctrl"])
		modifier = "ctrl"
	A.attack_god(src, modifier)
