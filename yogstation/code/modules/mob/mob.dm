/atom/prepare_huds()
    hud_list = list()
    for(var/hud in hud_possible)
        var/hint = hud_possible[hud]
        switch(hint)
            if(HUD_LIST_LIST)
                hud_list[hud] = list()
            else
                var/image/I = image('yogstation/icons/mob/hud.dmi', src, "")
                I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
                hud_list[hud] = I

/mob
	var/client/oobe_client //when someone aghosts/uses a scrying orb, this holds the client while it's somewhere else // How did this even get here?