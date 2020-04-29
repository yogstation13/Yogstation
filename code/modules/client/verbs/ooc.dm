GLOBAL_VAR_INIT(OOC_COLOR, null)//If this is null, use the CSS for OOC. Otherwise, use a custom colour.
GLOBAL_VAR_INIT(normal_ooc_colour, "#002eb8")
GLOBAL_VAR_INIT(mentor_ooc_colour, YOGS_MENTOR_OOC_COLOUR) // yogs - mentor ooc color

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(!holder)
		if(!GLOB.ooc_allowed)
			to_chat(src, "<span class='danger'>OOC is globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use OOC (muted).</span>")
			return
	if(is_banned_from(ckey, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from OOC.</span>")
		return
	if(QDELETED(src))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = pretty_filter(msg) //yogs
	msg = emoji_parse(msg)

	//yogs start -- smarter ick ock detection
	var/regex/ickock = regex(@"^\s*(#.*|,.*|(:|;)(\w|\s|\d)|(say \x22)|\.\.?(?!\.))","i")
	//captures a lot of accidental in character speech in ooc chat
	if(length(msg) > 4 && ickock.Find(msg))
	//yogs end
		if(alert("Your message \"[raw_msg]\" looks like it was meant for in game communication, say it in OOC?", "Meant for OOC?", "No", "Yes") != "Yes")
			return

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC muted.</span>")
		return

	mob.log_talk(raw_msg, LOG_OOC)
	if(holder && holder.fakekey) //YOGS start - webhook support
		webhook_send_ooc(holder.fakekey, msg)
	else
		webhook_send_ooc(key, msg) //YOGS end - webhook support

	var/keyname = key
	if(prefs.unlock_content)
		if(prefs.toggles & MEMBER_PUBLIC)
			keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : GLOB.normal_ooc_colour]'>[icon2html('icons/member_content.dmi', world, "blag")][keyname]</font>"
	//The linkify span classes and linkify=TRUE below make ooc text get clickable chat href links if you pass in something resembling a url
	//YOG START - Yog OOC

	//PINGS
	var/regex/ping = regex(@"@+(((([\s]{0,1}[^\s@]{0,30})[\s]*[^\s@]{0,30})[\s]*[^\s@]{0,30})[\s]*[^\s@]{0,30})","g")//Now lets check if they pinged anyone
	// Regex101 link to this specific regex, as of 3rd April 2019: https://regex101.com/r/YtmLDs/7
	var/list/pinged = list()
	while(ping.Find(msg))
		for(var/x in ping.group)
			pinged |= ckey(x)
	var/list/clientkeys = list()
	for(var/x in GLOB.clients)// If the "SENDING MESSAGES OUT" for-loop starts iterating over something else, make this GLOB *that* something else.
		var/client/Y = x //God bless typeless for-loops
		clientkeys += Y.ckey
		if(Y.holder && Y.holder.fakekey)
			clientkeys += Y.holder.fakekey
	pinged &= clientkeys
	if(pinged.len)
		if((world.time - last_ping_time) < 30)
			to_chat(src,"<span class='danger'>You are pinging too much! Please wait before pinging again.</span>")
			return
		last_ping_time = world.time

	//MESSAGE CRAFTING -- This part handles actually making the messages that are to be displayed.
	var/bussedcolor = GLOB.OOC_COLOR ? GLOB.OOC_COLOR : "" // So /TG/ decided to fuck up how OOC colours are handled.
	// So we're sticking a weird <font color='[bussedcolor]'></font> into shit to handle their new system.
	// Completely rewrote this OOC-handling code and /TG/ still manages to make it bad. Hate tg.
	var/oocmsg = ""; // The message sent to normal people
	var/oocmsg_toadmins = FALSE; // The message sent to admins.
	if(holder) // If the speaker is an admin or something
		if(check_rights_for(src, R_ADMIN)) // If they're supposed to have their own admin OOC colour
			oocmsg += "<span class='adminooc'>[(CONFIG_GET(flag/allow_admin_ooccolor) && prefs.ooccolor) ? "<font color=[prefs.ooccolor]>" :"" ]<span class='prefix'>[find_admin_rank(src)]" // The header for an Admin's OOC.
		else // Else if they're an AdminObserver
			oocmsg += "<span class='adminobserverooc'><span class='prefix'>[find_admin_rank(src)]" // The header for an AO's OOC.
		//Check yogstation\code\module\client\verbs\ooc for the find_admin_rank definition.

		if(holder.fakekey) // If they're stealhminning
			oocmsg_toadmins = oocmsg + "OOC:</span> <EM>[keyname]/([holder.fakekey]):</EM> <span class='message linkify'>[msg]</span></span></font>"
			// ^ Message sent to people who should know when someone's stealthminning
			oocmsg = "<span class='ooc'><font color='[bussedcolor]'><span class='prefix'>OOC:</span> <EM>[holder.fakekey]:</EM> <span class='message linkify'>[msg]</span></font></span>"
			// ^ Message sent to normal people
		else
			oocmsg += "OOC:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></span></font>" // Footer for an admin or AO's OOC.
			oocmsg_toadmins = oocmsg
	else
		if(is_mentor()) // If the speaker is a mentor
			oocmsg = "<span class='ooc'>\[Mentor]"
			oocmsg += "<font color='[prefs.ooccolor]'>"
		else
			oocmsg = "<span class='ooc'>[(is_donator(src) && !CONFIG_GET(flag/everyone_is_donator)) ? "(Donator)" : ""]"
			oocmsg += "<font color='[bussedcolor]'>"
		oocmsg += "<span class='prefix'>OOC:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></font></span>"
		oocmsg_toadmins = oocmsg

	//SENDING THE MESSAGES OUT
	for(var/c in GLOB.clients)
		var/client/C = c // God bless typeless for-loops
		if( (C.prefs.chat_toggles & CHAT_OOC) && (holder || !(key in C.prefs.ignoring)) )
			var/sentmsg // The message we're sending to this specific person
			if(C.holder) // If they're an admin-ish
				sentmsg = oocmsg_toadmins // Get the admin one
			else
				sentmsg = oocmsg
			if( (ckey(C.key) in pinged) || (C.holder && C.holder.fakekey && (C.holder.fakekey in pinged)) )
				var/sound/pingsound = sound('yogstation/sound/misc/bikehorn_alert.ogg')
				pingsound.volume = 50
				pingsound.pan = 80
				SEND_SOUND(C,pingsound)
				sentmsg = "<span style='background-color: #ccccdd'>" + sentmsg + "</span>"
			to_chat(C,sentmsg)
	//YOGS END

/proc/toggle_ooc(toggle = null)
	if(toggle != null) //if we're specifically en/disabling ooc
		if(toggle != GLOB.ooc_allowed)
			GLOB.ooc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.ooc_allowed = !GLOB.ooc_allowed
	to_chat(world, "<B>The OOC channel has been globally [GLOB.ooc_allowed ? "enabled" : "disabled"].</B>")

/proc/toggle_dooc(toggle = null)
	if(toggle != null)
		if(toggle != GLOB.dooc_allowed)
			GLOB.dooc_allowed = toggle
		else
			return
	else
		GLOB.dooc_allowed = !GLOB.dooc_allowed

/client/proc/set_ooc(newColor as color)
	set name = "Set Player OOC Color"
	set desc = "Modifies player OOC Color"
	set category = "Fun"
	GLOB.OOC_COLOR = sanitize_ooccolor(newColor)

/client/proc/reset_ooc()
	set name = "Reset Player OOC Color"
	set desc = "Returns player OOC Color to default"
	set category = "Fun"
	GLOB.OOC_COLOR = null

/client/verb/colorooc()
	set name = "Set Your OOC Color"
	set category = "Preferences"

	if(!holder || !check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

	var/new_ooccolor = input(src, "Please select your OOC color.", "OOC color", prefs.ooccolor) as color|null
	if(new_ooccolor)
		prefs.ooccolor = sanitize_ooccolor(new_ooccolor)
		prefs.save_preferences()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set OOC Color") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/verb/resetcolorooc()
	set name = "Reset Your OOC Color"
	set desc = "Returns your OOC Color to default"
	set category = "Preferences"

	if(!holder || !check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

		prefs.ooccolor = initial(prefs.ooccolor)
		prefs.save_preferences()

//Checks admin notice
/client/verb/admin_notice()
	set name = "Adminnotice"
	set category = "Admin"
	set desc ="Check the admin notice if it has been set"

	if(GLOB.admin_notice)
		to_chat(src, "<span class='boldnotice'>Admin Notice:</span>\n \t [GLOB.admin_notice]")
	else
		to_chat(src, "<span class='notice'>There are no admin notices at the moment.</span>")

/client/verb/fix_chat()
	set name = "Fix chat"
	set category = "OOC"
	if (!chatOutput || !istype(chatOutput))
		var/action = alert(src, "Invalid Chat Output data found!\nRecreate data?", "Wot?", "Recreate Chat Output data", "Cancel")
		if (action != "Recreate Chat Output data")
			return
		chatOutput = new /datum/chatOutput(src)
		chatOutput.start()
		action = alert(src, "Goon chat reloading, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if (action == "Fixed")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum")
		else
			chatOutput.load()
			action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
			if (action == "Yes")
				log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum and forcing a load()")
			else
				action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
				if (action == "Switch to old chat")
					winset(src, "output", "is-visible=true;is-disabled=false")
					winset(src, "browseroutput", "is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after recreating the chatOutput and forcing a load()")

	else if (chatOutput.loaded)
		var/action = alert(src, "ChatOutput seems to be loaded\nDo you want me to force a reload, wiping the chat log or just refresh the chat window because it broke/went away?", "Hmmm", "Force Reload", "Refresh", "Cancel")
		switch (action)
			if ("Force Reload")
				chatOutput.loaded = FALSE
				chatOutput.start() //this is likely to fail since it asks , but we should try it anyways so we know.
				action = alert(src, "Goon chat reloading, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
				if (action == "Fixed")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a start()")
				else
					chatOutput.load()
					action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
					if (action == "Yes")
						log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					else
						action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
						if (action == "Switch to old chat")
							winset(src, "output", "is-visible=true;is-disabled=false")
							winset(src, "browseroutput", "is-visible=false")
						log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a start() and forcing a load()")

			if ("Refresh")
				chatOutput.showChat()
				action = alert(src, "Goon chat refreshing, wait a bit and tell me if it's fixed", "", "Fixed", "Nope, force a reload")
				if (action == "Fixed")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a show()")
				else
					chatOutput.loaded = FALSE
					chatOutput.load()
					action = alert(src, "How about now? (give it a moment)", "", "Yes", "No")
					if (action == "Yes")
						log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					else
						action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
						if (action == "Switch to old chat")
							winset(src, "output", "is-visible=true;is-disabled=false")
							winset(src, "browseroutput", "is-visible=false")
						log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a show() and forcing a load()")
		return

	else
		chatOutput.start()
		var/action = alert(src, "Manually loading Chat, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if (action == "Fixed")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start()")
		else
			chatOutput.load()
			alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
			if (action == "Yes")
				log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start() and forcing a load()")
			else
				action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
				if (action == "Switch to old chat")
					winset(src, "output", list2params(list("on-show" = "", "is-disabled" = "false", "is-visible" = "true")))
					winset(src, "browseroutput", "is-disabled=true;is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after manually calling start() and forcing a load()")



/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE)
	else
		to_chat(src, "<span class='notice'>The Message of the Day has not been set.</span>")

/client/proc/self_notes()
	set name = "View Admin Remarks"
	set category = "OOC"
	set desc = "View the notes that admins have written about you"

	if(!CONFIG_GET(flag/see_own_notes))
		to_chat(usr, "<span class='notice'>Sorry, that function is not enabled on this server.</span>")
		return

	browse_messages(null, usr.ckey, null, TRUE)

/client/proc/self_playtime()
	set name = "View tracked playtime"
	set category = "OOC"
	set desc = "View the amount of playtime for roles the server has tracked."

	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, "<span class='notice'>Sorry, tracking is currently disabled.</span>")
		return

	var/list/body = list()
	body += "<html><head><meta charset='UTF-8'><title>Playtime for [key]</title></head><BODY><BR>Playtime:"
	body += get_exp_report()
	body += "</BODY></HTML>"
	usr << browse(body.Join(), "window=playerplaytime[ckey];size=550x615")

/client/proc/ignore_key(client)
	var/client/C = client
	if(C.key in prefs.ignoring)
		prefs.ignoring -= C.key
	else
		prefs.ignoring |= C.key
	to_chat(src, "You are [(C.key in prefs.ignoring) ? "now" : "no longer"] ignoring [C.key] on the OOC channel.")
	prefs.save_preferences()

/client/verb/select_ignore()
	set name = "Ignore"
	set category = "OOC"
	set desc ="Ignore a player's messages on the OOC channel"


	var/see_ghost_names = isobserver(mob)
	var/list/choices = list()
	for(var/client/C in GLOB.clients)
		if(isobserver(C.mob) && see_ghost_names)
			choices["[C.mob]([C])"] = C
		else
			choices[C] = C
	choices = sortList(choices)
	var/selection = input("Please, select a player!", "Ignore", null, null) as null|anything in choices
	if(!selection || !(selection in choices))
		return
	selection = choices[selection]
	if(selection == src)
		to_chat(src, "You can't ignore yourself.")
		return
	ignore_key(selection)

/client/proc/show_previous_roundend_report()
	set name = "Your Last Round"
	set category = "OOC"
	set desc = "View the last round end report you've seen"

	SSticker.show_roundend_report(src, TRUE)

/client/verb/fit_viewport()
	set name = "Fit Viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))
	var/map_size = splittext(sizes["mapwindow.size"], "x")
	var/height = text2num(map_size[2])
	var/desired_width = round(height * aspect_ratio)
	if (text2num(map_size[1]) == desired_width)
		// Nothing to do
		return

	var/split_size = splittext(sizes["mainwindow.split.size"], "x")
	var/split_width = text2num(split_size[1])

	// Calculate and apply a best estimate
	// +4 pixels are for the width of the splitter's handle
	var/pct = 100 * (desired_width + 4) / split_width
	winset(src, "mainwindow.split", "splitter=[pct]")

	// Apply an ever-lowering offset until we finish or fail
	var/delta
	for(var/safety in 1 to 10)
		var/after_size = winget(src, "mapwindow", "size")
		map_size = splittext(after_size, "x")
		var/got_width = text2num(map_size[1])

		if (got_width == desired_width)
			// success
			return
		else if (isnull(delta))
			// calculate a probable delta value based on the difference
			delta = 100 * (desired_width - got_width) / split_width
		else if ((delta > 0 && got_width > desired_width) || (delta < 0 && got_width < desired_width))
			// if we overshot, halve the delta and reverse direction
			delta = -delta/2

		pct += delta
		winset(src, "mainwindow.split", "splitter=[pct]")


/client/verb/policy()
	set name = "Show Policy"
	set desc = "Show special server rules related to your current character."
	set category = "OOC"

	//Collect keywords
	var/list/keywords = mob.get_policy_keywords()
	var/header = get_policy(POLICY_VERB_HEADER)
	var/list/policytext = list(header,"<hr>")
	var/anything = FALSE
	for(var/keyword in keywords)
		var/p = get_policy(keyword)
		if(p)
			policytext += p
			policytext += "<hr>"
			anything = TRUE
	if(!anything)
		policytext += "No related rules found."

	usr << browse(policytext.Join(""),"window=policy")
