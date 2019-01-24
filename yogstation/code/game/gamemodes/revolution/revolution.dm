/datum/game_mode/proc/explain_rev_hud(mob/M)
	if(!M)
		return
	var/images = list(icon('yogstation/icons/mob/hud.dmi', "rev_head"), icon('yogstation/icons/mob/hud.dmi', "rev"), icon('yogstation/icons/mob/hud.dmi', "rev_maybe"), icon('yogstation/icons/mob/hud.dmi', "rev_convertable"), icon('yogstation/icons/mob/hud.dmi', "rev_enemyhead"))
	for(var/V in images)
		var/icon/I = V
		I.Crop(23, 23, 32, 32)
		I.Scale(32, 32)
	to_chat(M, "<span class='notice'>[icon2html(images[1], M)] Head Revolutionary: Protect them.<br>\
				[icon2html(images[2], M)] Revolutionary: Assist them.<br>\
				[icon2html(images[3], M)] Unknown: Take off their mask to expose their identity.<br>\
				[icon2html(images[4], M)] Crewmember: Take them to a head revolutionary to convert them, if possible.<br>\
				[icon2html(images[5], M)] Head of Staff: Kill them to win the revolution!</span>")