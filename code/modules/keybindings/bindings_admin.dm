<<<<<<< HEAD
// yogs - Replicated for custom keybindings
=======
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
/datum/admins/key_down(_key, client/user)
	switch(_key)
		if("F3")
			user.get_admin_say()
			return
		if("F5")
			user.admin_ghost()
			return
		if("F6")
			player_panel_new()
			return
		if("F7")
			user.togglebuildmodeself()
			return
		if("F8")
			if(user.keys_held["Ctrl"])
				user.stealth()
			else
				user.invisimin()
			return
<<<<<<< HEAD
		if("F10")
			user.get_dead_say()
			return
=======
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	..()
