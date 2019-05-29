/obj/structure/showcase/cyborg/old/rd
	name = 	"Cyborg Statue"
	desc = "An old, deactivated cyborg. Whilst once actively used to guard against intruders, it now simply intimidates them with its cold, steely gaze."
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot_old"
	density = TRUE

/obj/structure/showcase/cyborg/old/rd/Initialize()
	. = ..()
	name = pick("HAL 9000", "GlaDOS", "SHODAN", "R2-D2", "Data", "Kryten", "Johnny 5", "KAREN", "Gort", "Ultron", "Bishop", "Metal Gear", "YogbotV2.0", "MoMMIv2")
