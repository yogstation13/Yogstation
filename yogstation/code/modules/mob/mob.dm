/atom/proc/pointed_at(var/mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_POINTED_AT, user) //why the hell is this here?

/datum/game_mode/proc/update_vampire_icons_added(datum/mind/vampire_mind)
    var/datum/atom_hud/antag/vampire_hud = GLOB.huds[ANTAG_HUD_VAMPIRE]
    shadow_hud.join_hud(vampire_mind.current)
    set_antag_hud(vampire_mind.current, ((is_vampire(vampire_mind.current)) ? "vampire"))

/datum/game_mode/proc/update_vampire_icons_removed(datum/mind/vampire_mind)
    var/datum/atom_hud/antag/vampire_hud = GLOB.huds[ANTAG_HUD_VAMPIRE]
   vampire_hud.leave_hud(vampire_mind.current)
    set_antag_hud(vampire_mind.current, null)
		
/mob
	var/client/oobe_client //when someone aghosts/uses a scrying orb, this holds the client while it's somewhere else // How did this even get here?