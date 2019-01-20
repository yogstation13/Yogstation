/datum/game_mode/proc/explain_rev_hud(mob/M)
	if(!M)
		return
	var/static/list/images
	if(!images)
		images = list(icon('yogstation/icons/mob/hud.dmi', "rev_head"), icon('yogstation/icons/mob/hud.dmi', "rev"), icon('yogstation/icons/mob/hud.dmi', "rev_maybe"), icon('yogstation/icons/mob/hud.dmi', "rev_convertable"), icon('yogstation/icons/mob/hud.dmi', "rev_enemyhead"))
		for(var/V in images)
			var/icon/I = V
			I.Crop(23, 23, 32, 32)
			I.Scale(32, 32)
	to_chat(M, "<span class='notice'>\icon[images[1]] Head Revolutionary: Protect them.<br>\
								\icon[images[2]] Revolutionary: Assist them.<br>\
								\icon[images[3]] Unknown: Take off their mask to expose their identity.<br>\
								\icon[images[4]] Crewmember: Take them to a head revolutionary to convert them, if possible.<br>\
								\icon[images[5]] Head of Staff: Kill them to win the revolution!\
								</span>")