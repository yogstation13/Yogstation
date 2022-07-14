/client/var/adminhelptimerid = 0	//a timer id for returning the ahelp verb
/client/var/datum/admin_help/current_ticket	//the current ticket the (usually) not-admin client is dealing with

//
//TICKET MANAGER
//

GLOBAL_DATUM_INIT(ahelp_tickets, /datum/admin_help_tickets, new)

/datum/admin_help_tickets
	var/list/tickets_list = list()
	var/ticketAmount = 0

/datum/admin_help_tickets/Destroy()
	QDEL_LIST(tickets_list)
	return ..()

/datum/admin_help_tickets/proc/TicketByID(id)
	for(var/I in tickets_list)
		for(var/J in I)
			var/datum/admin_help/AH = J
			if(AH.id == id)
				return J

/datum/admin_help_tickets/proc/TicketsByCKey(ckey)
	. = list()
	for(var/I in tickets_list)
		for(var/J in I)
			var/datum/admin_help/AH = J
			if(AH.initiator_ckey == ckey)
				. += AH

//opens the ticket listings for one of the 3 states
/datum/admin_help_tickets/proc/BrowseTickets(state)
	var/title
	var/list/dat = list("<html><head><meta charset='UTF-8'><title>[title]</title></head>")
	dat += "<A href='?_src_=holder;[HrefToken()];ahelp_tickets=[state]'>Refresh</A><br><br>"
	for(var/I in tickets_list)
		var/datum/admin_help/AH = I
		dat += "<span class='adminnotice'>[span_adminhelp("Ticket #[AH.id]")]: <A href='?_src_=holder;[HrefToken()];ahelp=[REF(AH)];ahelp_action=ticket'>[AH.initiator_key_name]: [AH.name]</A></span><br>"

	usr << browse(dat.Join(), "window=ahelp_list[state];size=600x480")

//Reassociate still open ticket if one exists
/datum/admin_help_tickets/proc/ClientLogin(client/C)
	C.current_ticket = CKey2ActiveTicket(C.ckey)
	if(C.current_ticket)
		C.current_ticket.initiator = C
		C.current_ticket.AddInteraction("Client reconnected.", ckey = C.ckey)

//Dissasociate ticket
/datum/admin_help_tickets/proc/ClientLogout(client/C)
	if(C.current_ticket)
		C.current_ticket.AddInteraction("Client disconnected.")
		C.current_ticket.initiator = null
		C.current_ticket = null

//Get a ticket given a ckey
/datum/admin_help_tickets/proc/CKey2ActiveTicket(ckey)
	for(var/I in tickets_list)
		var/datum/admin_help/AH = I
		if(AH.initiator_ckey == ckey)
			return AH


//
// TICKET LOG DATUM
//

/datum/ticket_log
	var/datum/admin_help/parent
	var/gametime
	var/user
	var/user_admin = FALSE
	var/text
	var/text_admin
	var/for_admins

/datum/ticket_log/New(var/datum/admin_help/parent, var/user, var/text, var/for_admins = 0)
	src.gametime = gameTimestamp()
	src.parent = parent
	if(istype(user, /client))
		src.user_admin = is_admin(user)

	src.for_admins = for_admins
	src.user = get_fancy_key(user)
	src.text = text
	src.text_admin = generate_admin_info(text)

	var/datum/DBQuery/add_interaction_query = SSdbcore.NewQuery(
		"INSERT INTO `[format_table_name("admin_ticket_interactions")]` (`ticket_id`,`user`,`text`) VALUES (:ticket_id,:user,:text)",
		list("ticket_id" = src.parent.db_id, "user" = src.user, "text" = src.text)
	)
	add_interaction_query.Execute()
	qdel(add_interaction_query)

/datum/ticket_log/proc/isAdminComment()
	return istype(user, /client) && (for_admins && !(compare_ckey(parent.initiator_ckey, user) || compare_ckey(parent.handling_admin, user)) ? 1 : 0)

/datum/ticket_log/proc/toSanitizedString()
	return "[gametime] - [user] - [text]"

/datum/ticket_log/proc/toString()
	return "[gametime] - [isAdminComment() ? "<font color='red'>" : ""]<b>[istype(user, /client) ? key_name_params(user, 0, 0, null, parent) : user]</b>[isAdminComment() ? "</font>" : ""] - [text]"

/datum/ticket_log/proc/toAdminString()
	return "[gametime] - [isAdminComment() ? "<font color='red'>" : ""]<b>[istype(user, /client) ? key_name_params(user, 0, 1, null, parent) : user]</b>[isAdminComment() ? "</font>" : ""] - [text_admin]"

/datum/ticket_log/proc/toLogString()
	return "[isAdminComment() ? "COMMENT - " : ""][istype(user, /client) ? key_name_params(user, 0, 1, null, parent) : user] - [text]"


//
//TICKET DATUM
//

/datum/admin_help
	var/db_id
	var/id
	var/name
	var/state = AHELP_ACTIVE

	var/opened_at
	var/closed_at

	var/client/handling_admin

	var/client/initiator	//semi-misnomer, it's the person who ahelped/was bwoinked
	var/initiator_ckey
	var/initiator_key_name
	var/heard_by_no_admins = FALSE
	var/popups_enabled = FALSE // if TRUE, gives a pop-up to the nonadmin to respond to the ticket, whenever the admin speaks.

	var/list/_interactions	//use AddInteraction() or, preferably, admin_ticket_log()
	var/static/ticket_counter = 0
	var/static/last_bwoinking = 0
	var/static/last_unclaimed_notification = 0

//call this on its own to create a ticket, don't manually assign current_ticket
//msg is the title of the ticket: usually the ahelp text
//is_bwoink is TRUE if this ticket was started by an admin PM
/datum/admin_help/New(msg, client/C, is_bwoink)
	//clean the input msg
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg || !C || !C.mob)
		qdel(src)
		return

	id = ++ticket_counter
	opened_at = world.time

	name = msg

	initiator = C
	initiator_ckey = initiator.ckey
	initiator_key_name = key_name(initiator, FALSE, TRUE)
	if(initiator.current_ticket)	//This is a bug
		stack_trace("Multiple ahelp current_tickets")
		initiator.current_ticket.AddInteraction("Ticket erroneously left open by code")
		initiator.current_ticket.Close()
	initiator.current_ticket = src

	var/datum/DBQuery/add_ticket_query = SSdbcore.NewQuery(
		"INSERT INTO `[format_table_name("admin_tickets")]` (round_id, ticket_id, ckey) VALUES (:round, :ticket, :ckey);",
		list("round" = GLOB.round_id, "ticket" = id, "ckey" = initiator_ckey)
	)

	if(!add_ticket_query.Execute())
		message_admins("Failed insert ticket into ticket DB. Check the SQL error logs for more details.")
	else
		db_id = add_ticket_query.last_insert_id
	qdel(add_ticket_query)

	TimeoutVerb()

	_interactions = list()

	if(is_bwoink)
		AddInteraction("[usr.client?.ckey] PM'd [initiator_key_name]") 
		message_admins("<font color='blue'>Ticket [TicketHref("#[id]")] created</font>")
	else
		MessageNoRecipient(msg)

		//send it to irc if nobody is on and tell us how many were on
		var/admin_number_present = check_admins_online()
		log_admin_private("Ticket #[id]: [key_name(initiator)]: [name] - heard by [admin_number_present] non-AFK admins who have +BAN.")
		if(admin_number_present <= 0)
			to_chat(C, span_notice("No active admins are online, your adminhelp was sent to the admin irc."), confidential=TRUE)
			heard_by_no_admins = TRUE

	GLOB.ahelp_tickets.tickets_list += src
	GLOB.ahelp_tickets.ticketAmount += 1

/datum/admin_help/proc/check_admins_online()
	var/list/adm = get_admin_counts(R_BAN)
	var/list/activemins = adm["present"]
	. = activemins.len
	if(. > 0)
		return
	send2irc_adminless_only(initiator_ckey, "Ticket #[id]: [name]")
	var/list/stealthmins = adm["stealth"]
	if(stealthmins.len > 0) // If there are stealthmins, do nothing
		return
	// There are no admins online, try deadmins
	var/found_deadmin = FALSE
	if(GLOB.deadmins.len > 0)
		for(var/deadmin_ckey in GLOB.deadmins)
			var/datum/admins/A = GLOB.deadmins[deadmin_ckey]
			if(!A.check_for_rights(R_BAN))
				continue
			var/client/client = GLOB.directory[deadmin_ckey]
			if(!client)
				continue
			if(client.prefs.toggles & SOUND_ADMINHELP)
				SEND_SOUND(client, sound('sound/effects/adminhelp.ogg'))
			to_chat(client, span_danger("Ticket opened with no active admins. Ticket will be sent to discord in 30 seconds if not taken."), confidential=TRUE)
			if(!found_deadmin)
				found_deadmin = TRUE
				addtimer(CALLBACK(src, .proc/send_to_discord), 30 SECONDS)
	if(!found_deadmin)
		send_to_discord()

/datum/admin_help/proc/send_to_discord()
	if(state == AHELP_ACTIVE && !handling_admin)
		webhook_send_ticket_unclaimed(initiator_ckey, name, id)

/datum/admin_help/Destroy()
	GLOB.ahelp_tickets.tickets_list -= src
	return ..()

/datum/admin_help/proc/check_owner() // Handles unclaimed tickets; returns TRUE if no longer unclaimed
	if(!handling_admin && state == AHELP_ACTIVE)
		var/msg = span_admin("<span class=\"prefix\">ADMIN LOG:</span> <span class=\"message linkify\"><font color='blue'>Ticket [TicketHref("#[id]")] Unclaimed!</font></span>")
		for(var/client/X in GLOB.admins)
			if(check_rights_for(X,R_BAN))
				to_chat(X,
					type = MESSAGE_TYPE_ADMINLOG,
					html = msg,
					confidential = TRUE)
			else
				if(world.time > last_unclaimed_notification)
					last_unclaimed_notification = world.time + 1 SECONDS
					msg = "<span class=\"prefix\">ADMIN LOG:</span> <span class=\"message linkify\"><font color='blue'>Unclaimed Tickets!</font></span>"
					to_chat(X,
						type = MESSAGE_TYPE_ADMINLOG,
						html = msg,
						confidential = TRUE)
				
		if(world.time > last_bwoinking)
			last_bwoinking = world.time + 1 SECONDS
			for(var/client/X in GLOB.admins)
				if(check_rights_for(X,R_BAN) && (X.prefs.toggles & SOUND_ADMINHELP)) // Can't use check_rights here since it's dependent on $usr
					SEND_SOUND(X, sound('sound/effects/adminhelp.ogg'))
		return FALSE
	return TRUE

/datum/admin_help/proc/AddInteraction(msg, for_admins = FALSE, ckey = null)
	_interactions += new /datum/ticket_log(src, usr, msg, for_admins)
	webhook_send("ticket", list("ticketid" = id, "message" = strip_html_simple(msg), "roundid" = GLOB.round_id, "user" = ckey ? ckey : usr.client?.ckey))

//Removes the ahelp verb and returns it after 2 minutes
/datum/admin_help/proc/TimeoutVerb()
	remove_verb(initiator, /client/verb/adminhelp)
	initiator.adminhelptimerid = addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 1200, TIMER_STOPPABLE) //2 minute cooldown of admin helps

//private
/datum/admin_help/proc/FullMonty(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = ADMIN_FULLMONTY_NONAME(initiator.mob)
	if(state == AHELP_ACTIVE)
		. += ClosureLinks(ref_src)

//private
/datum/admin_help/proc/ClosureLinks(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reject'>REJT</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=icissue'>IC</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=resolve'>RSLVE</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=wiki'>WIKI</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=bug'>BUG</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=mhelpquestion'>MHELP</a>)"

//private
/datum/admin_help/proc/LinkedReplyName(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reply'>[initiator_key_name]</A>"

//private
/datum/admin_help/proc/TicketHref(msg, ref_src, action = "ticket")
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=[action]'>[msg]</A>"

//message from the initiator without a target, all admins will see this
//won't bug irc
/datum/admin_help/proc/MessageNoRecipient(msg)
	var/ref_src = "[REF(src)]"
	//Message to be sent to all admins
	var/admin_msg = span_adminnotice("[span_adminhelp("Ticket [TicketHref("#[id]", ref_src)]")]<b>: [LinkedReplyName(ref_src)] [FullMonty(ref_src)]:</b> [keywords_lookup(msg)]")

	AddInteraction(msg)

	//send this msg to all admins
	for(var/client/X in GLOB.admins)
		if(X.prefs.toggles & SOUND_ADMINHELP)
			SEND_SOUND(X, sound('sound/effects/adminhelp.ogg'))
		window_flash(X, ignorepref = TRUE)
		to_chat(X, admin_msg, confidential=TRUE)

	//show it to the person adminhelping too
	to_chat(initiator, span_adminnotice("PM to-<b>Admins</b>: [msg]"), confidential=TRUE)
	GLOB.unclaimed_tickets += src

//Reopen a closed ticket
/datum/admin_help/proc/Reopen()
	if(state == AHELP_ACTIVE)
		to_chat(usr, span_warning("This ticket is already open."), confidential=TRUE)
		return

	if(GLOB.ahelp_tickets.CKey2ActiveTicket(initiator_ckey))
		to_chat(usr, span_warning("This user already has an active ticket, cannot reopen this one."), confidential=TRUE)
		return

	switch(state)
		if(AHELP_CLOSED)
			SSblackbox.record_feedback("tally", "ahelp_stats", -1, "closed")
		if(AHELP_RESOLVED)
			SSblackbox.record_feedback("tally", "ahelp_stats", -1, "resolved")

	AddActive()
	state = AHELP_ACTIVE

	AddInteraction("Reopened by [usr.ckey]")
	var/msg = span_adminhelp("Ticket [TicketHref("#[id]")] reopened by [key_name_admin(usr)].")
	message_admins(msg)
	log_admin_private(msg)
	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "reopened")
	TicketPanel()	//can only be done from here, so refresh it

//private
/datum/admin_help/proc/RemoveActive()
	if(state != AHELP_ACTIVE)
		return

	closed_at = world.time
	if(initiator && initiator.current_ticket == src)
		initiator.current_ticket = null

/datum/admin_help/proc/AddActive()
	if(state == AHELP_ACTIVE)
		return

	closed_at = null
	if(initiator && !initiator.current_ticket)
		initiator.current_ticket = src

//Mark open ticket as closed/meme
/datum/admin_help/proc/Close(key_name = key_name_admin(usr), silent = FALSE)
	if(state != AHELP_ACTIVE)
		return

	RemoveActive()
	state = AHELP_CLOSED
	AddInteraction("Closed by [usr.ckey].")
	if(!silent)
		SSblackbox.record_feedback("tally", "ahelp_stats", 1, "closed")
		var/msg = "Ticket [TicketHref("#[id]")] closed by [key_name]."
		message_admins(msg)
		log_admin_private(msg)

	GLOB.ahelp_tickets.ticketAmount -= 1
	if(SSticker.current_state == GAME_STATE_FINISHED && !GLOB.ahelp_tickets.ticketAmount)
		if(check_rights(R_ADMIN, FALSE) && alert(usr,"Restart the round?.","Round restart","Yes","No") == "Yes")
			SSticker.Reboot(delay = 100, force = TRUE)
		else
			message_admins("All tickets have been closed, round can be restarted")

//Mark open ticket as resolved/legitimate, returns ahelp verb
/datum/admin_help/proc/Resolve(key_name = key_name_admin(usr), silent = FALSE)
	var/resolved = FALSE
	if(state == AHELP_RESOLVED)
		if(initiator.current_ticket)
			to_chat(initiator, span_warning("This user already has an open ticket."), confidential=TRUE)
			return

		AddActive()
		state = AHELP_ACTIVE
		GLOB.ahelp_tickets.ticketAmount += 1
	else if(state == AHELP_ACTIVE)
		RemoveActive()
		state = AHELP_RESOLVED
		resolved = TRUE
		GLOB.ahelp_tickets.ticketAmount -= 1
	else // AHELP_CLOSED
		to_chat(usr, span_warning("This ticket has been closed and can't be unresolved."), confidential=TRUE)
		return

	if(resolved)
		AddInteraction("Ticket #[id] marked as resolved by [usr.ckey].")
		to_chat(initiator, span_adminhelp("Your ticket has been marked as resolved by [usr.client.holder?.fakekey ? "an Administrator" : key_name(usr, 0, 0)]."), confidential=TRUE)
		addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 50)
	else // AHELP_ACTIVE
		AddInteraction("Ticket #[id] marked as unresolved by [usr.ckey].")
		to_chat(initiator, span_adminhelp("Your ticket has been marked as unresolved by [usr.client.holder?.fakekey ? "an Administrator" : key_name(usr, 0, 0)]."), confidential=TRUE)
		TimeoutVerb()

	if(!silent)
		if(resolved)
			SSblackbox.record_feedback("tally", "ahelp_stats", 1, "resolved")

		var/msg = "Ticket [TicketHref("#[id]")] [resolved ? "" : "un"]resolved by [key_name]"
		message_admins(msg)
		log_admin_private(msg)

	if(SSticker.current_state == GAME_STATE_FINISHED && !GLOB.ahelp_tickets.ticketAmount)
		if(check_rights(R_ADMIN, FALSE) && alert(usr,"Restart the round?.","Round restart","Yes","No") == "Yes")
			SSticker.Reboot(delay = 100)
		else
			message_admins("All tickets have been closed, round can be restarted")

//Close and return ahelp verb, use if ticket is incoherent
/datum/admin_help/proc/Reject(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	if(initiator)
		initiator.giveadminhelpverb()

		SEND_SOUND(initiator, sound('sound/effects/adminhelp.ogg'))

		to_chat(initiator, "<font color='red' size='4'><b>- AdminHelp Rejected by [usr.client.holder?.fakekey ? "an Administrator" : key_name(usr, 0, 0)]! -</b></font>", confidential=TRUE)
		to_chat(initiator, "<font color='red'><b>Your admin help was rejected.</b> The adminhelp verb has been returned to you so that you may try again.</font>", confidential=TRUE)
		to_chat(initiator, "Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting.", confidential=TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "rejected")
	var/msg = "Ticket [TicketHref("#[id]")] rejected by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Rejected by [usr.ckey].")
	Close(silent = TRUE)

//Resolve ticket with IC Issue message
/datum/admin_help/proc/ICIssue(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	var/msg = "<font color='red' size='4'><b>- AdminHelp marked as an IC issue by [usr.client.holder?.fakekey ? "an Administrator" : key_name(usr, 0, 0)]! -</b></font><br>"
	msg += "<font color='red'>Unfortunately your issue does not warrant admin intervention, usually because none of the involved parties are breaking any OOC rules. You can however still attempt to find an IC solution to your problem.</font>"

	if(initiator)
		to_chat(initiator, msg, confidential=TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "IC")
	msg = "Ticket [TicketHref("#[id]")] marked as IC by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Marked as an IC issue by [usr.ckey]")
	Resolve(silent = TRUE)

//Resolve ticket with Mhelp Question message
/datum/admin_help/proc/MhelpQuestion(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	var/msg = "<font color='red' size='4'><b>- AdminHelp marked as a Mentorhelp Question by [usr.client.holder?.fakekey ? "an Administrator" : key_name(usr, 0, 0)]! -</b></font><br>"
	msg += "<font color='red'><b>You are asking a mentorhelp question!</b></font><br>"
	msg += "<font color='red'>Please use the mentorhelp button to ask questions about game mechanics and other such questions.</font>"
	msg += "<font color='red'>Your call will now be redirected to the mentors as a mentorhelp.</font>"

	if(initiator)
		to_chat(initiator, msg, confidential=TRUE)
		initiator.mhelp(name, TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "MHelp")
	msg = "Ticket [TicketHref("#[id]")] marked as MHelp by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Marked as an MHelp question by [usr.ckey]")
	Resolve(silent = TRUE)

//Resolve ticket with wiki message
/datum/admin_help/proc/WikiIssue(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	var/msg = "<font color='red' size='4'><b>- AdminHelp marked as a Wiki issue by [usr.client.holder?.fakekey ? "an Administrator" : key_name(usr, 0, 0)]! -</b></font><br>"
	msg += "<font color='red'><b>Go look at the wiki!</b></font><br>"
	msg += "<font color='red'>[CONFIG_GET(string/wikiurl)]</font>"
	if(initiator)
		to_chat(initiator, msg, confidential=TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "WIKI")
	msg = "Ticket [TicketHref("#[id]")] marked as WIKI by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Marked as WIKI issue by [usr.ckey]")
	Resolve(silent = TRUE)

//Resolve ticket with bug message
/datum/admin_help/proc/GithubIssue(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	var/msg = "<font color='red' size='4'><b>- AdminHelp marked as a Github issue by [usr.client.holder?.fakekey ? "an Administrator" : key_name(usr, 0, 0)]! -</b></font><br>"
	msg += "<font color='red'><b>You are reporting a Bug or Github Issue.</b></font><br>"
	msg += "<font color='red'>[CONFIG_GET(string/githuburl)]/issues/new?template=bug_report.md</font>"
	msg += "<font color='red'><b>Please fill out the issues form with detailed information about the bug or other issue you have discovered.</b></font><br>"

	if(initiator)
		to_chat(initiator, msg, confidential=TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "BUG")
	msg = "Ticket [TicketHref("#[id]")] marked as BUG by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Marked as BUG issue by [usr.ckey]")
	Resolve(silent = TRUE)

//Show the ticket panel
/datum/admin_help/proc/TicketPanel()
	if(GLOB.experimental_adminpanel)
		ui_interact(usr)
		return

	var/reply_link = "<a href='?_src_=holder;[HrefToken(TRUE)];user=[REF(usr)];ahelp=[REF(src)];ahelp_action=reply'><img border='0' width='16' height='16' class='uiIcon16 icon-comment' /> Reply</a>"
	var/refresh_link = "<a href='?_src_=holder;[HrefToken(TRUE)];user=[REF(usr)];ahelp=[REF(src)];ahelp_action=ticket'><img border='0' width='16' height='16' class='uiIcon16 icon-refresh' /> Refresh</a>"

	var/content = ""
	if(usr.client.holder)
		content += "<p class='control-bar'>[reply_link] [refresh_link]</p>"

	content += "<p class='title-bar'>[name]</p>"
	content += "<p class='info-bar'>Primary Admin: <span id='primary-admin'>[handling_admin != null ? (usr.client.holder ? key_name(handling_admin, TRUE, TRUE) : "[key_name(handling_admin, TRUE, FALSE)]") : "Unassigned"]</span></p>"

	content += "<p class='resolved-bar [state == AHELP_ACTIVE ? "unresolved" : "resolved"]' id='resolved'>[state == AHELP_ACTIVE ? "Is not resolved" : "Is resolved"]</p>"

	if(usr.client.holder && initiator)
		content += {"<div class='user-bar'>
			<p>[key_name(initiator, 1)]</p>"}

		if(initiator && initiator.mob)
			content += {"<p style='margin-top: 5px;'>
					<a href='?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-search' /> ?</a>
					<a href='?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-clipboard' /> PP</a>
					<a href='?_src_=vars;[HrefToken(TRUE)];Vars=[REF(initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-clipboard' /> VV</a>
					<a href='?_src_=holder;[HrefToken(TRUE)];subtlemessage=[REF(initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-mail-closed' /> SM</a>
					<a href='?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-arrowthick-1-e' /> FLW</a>
					<a href='?_src_=holder;[HrefToken(TRUE)];secretsadmin=check_antagonist'><img border='0' width='16' height='16' class='uiIcon16 icon-clipboard' /> CA</a>
					<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=administer' class='admin-button'><img border='0' width='16' height='16' class='uiIcon16 icon-flag' /> <span>Administer</span></a>
					<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=resolve' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>[state == AHELP_ACTIVE ? "" : "Un"]Resolve</span></a>
					<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=reject' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Reject</span></a>
					<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=close' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Close</span></a>
					<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=icissue' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>IC</span></a>
					<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=mhelpquestion' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>MHelp</span></a>
					<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=popup' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>[popups_enabled ? "De" : ""]Activate Popups</span></a>
				</p>"}
		if(initiator && initiator.mob)
			if(initiator.mob.mind && initiator.mob.mind.assigned_role)
				content += "<p class='user-info-bar'>Role: [initiator.mob.mind.assigned_role]</p>"
				if(initiator.mob.mind.special_role)
					content += "<p class='user-info-bar'>Antagonist: [initiator.mob.mind.special_role]</p>"
				else
					content += "<p class='user-info-bar'>Antagonist: No</p>"

			var/turf/T = get_turf(initiator.mob)

			var/location = ""
			if(isturf(T))
				if(isarea(T.loc))
					location = "([initiator.mob.loc == T ? "at " : "in [initiator.mob.loc] at "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
				else
					location = "([initiator.mob.loc == T ? "at " : "in [initiator.mob.loc] at "] [T.x], [T.y], [T.z])"

			if(location)
				content += "<p class='user-info-bar'>Location: [location]</p>"

		content += "</div>"
	else
		if(usr.client.holder)
			content += "<div class='user-bar'>"
			content += {"<p style='margin-top: 5px;'>
					<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=resolve' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>[state == AHELP_ACTIVE ? "" : "Un"]Resolve</span></a>
					<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(src)];ahelp_action=administer' class='admin-button'><img border='0' width='16' height='16' class='uiIcon16 icon-flag' /> <span>Administer</span></a>
				</p>"}
			content += "</div>"

	content += "<div id='messages'>"

	var/i = 0
	for(i = 1; i <= _interactions.len; i++)
		var/datum/ticket_log/item = _interactions[i]
		if(!usr.client.holder)
			if(!item.for_admins)
				content += "<p class='message-bar'>[item.toString()]</p>"
		else
			content += "<p class='message-bar'>[item.toAdminString()]</p>"

	// New ticket logs added to top - If reverting this, do not forget to prepend in the template!
	/*for(i = log.len; i > 0; i--)
		var/datum/ticket_log/item = log[i]
		if((item.for_admins && usr.client.holder) || !item.for_admins)
			content += "<p class='message-bar'>[item.toString()]</p>"*/

	content += "</div>"

	if(usr.client.holder)
		content += "<p class='control-bar'>[reply_link] [refresh_link]</p>"

	content += "<br /></div></body></html>"

	var/html = get_html("Admin Ticket Interface", "", "", content)

	usr << browse(null, "window=ViewTicketLog[id]")
	usr << browse(html, "window=ViewTicketLog[id]")

// Admin claims a ticket
/datum/admin_help/proc/Administer(announce = FALSE)
	if(!usr.client)
		return FALSE
	handling_admin = usr.client

	var/datum/DBQuery/set_admin_query = SSdbcore.NewQuery(
		"UPDATE `[format_table_name("admin_tickets")]` SET `a_ckey` = :ckey WHERE `id` = :id;",
		list("ckey" = usr.ckey, "id" = db_id)
	)
	set_admin_query.Execute();
	qdel(set_admin_query);

	var/msg = "[usr.ckey]/([usr]) has been assigned to [TicketHref("ticket #[id]")] as primary admin."
	message_admins(msg)
	log_admin_private(msg)

	if(announce && initiator)
		to_chat(initiator,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("[key_name(usr, TRUE, FALSE)] has taken your ticket and will respond shortly."),
			confidential = TRUE)

//Admin activates the pop-ups
/datum/admin_help/proc/PopUps(key_name = key_name_admin(usr))
	popups_enabled = !popups_enabled
	var/msg = "Ticket [TicketHref("#[id]")] has had pop-ups [popups_enabled ? "" : "de"]activated by [key_name]"
	message_admins(msg)
	log_admin_private(msg)

//Forwarded action from admin/Topic
/datum/admin_help/proc/Action(action)
	testing("Ahelp action: [action]")
	switch(action)
		if("ticket")
			TicketPanel()
		if("reject")
			Reject()
		if("reply")
			usr.client.cmd_ahelp_reply(initiator)
		if("icissue")
			ICIssue()
		if("mhelpquestion")
			MhelpQuestion()
		if("close")
			Close()
		if("resolve")
			Resolve()
		if("reopen")
			Reopen()
		if("administer")
			Administer(TRUE)
		if("wiki")
			WikiIssue()
		if("bug")
			GithubIssue()
		if("popup")
			PopUps()

//
// CLIENT PROCS
//

/client/proc/giveadminhelpverb()
	//client may of have disconnected by the time this proc gets called
	if(!src)
		return
		
	if(!locate(/client/verb/adminhelp) in src.verbs)
		add_verb(src, /client/verb/adminhelp)


	deltimer(adminhelptimerid)
	adminhelptimerid = 0

/client/proc/view_tickets()
	set name = "Adminlisttickets"
	set category = "Admin"

	if(GLOB.experimental_adminpanel)
		GLOB.ahelp_tickets.ui_interact(usr)
	else
		view_tickets_main(TICKET_FLAG_LIST_ALL)

/client/proc/view_tickets_main(var/flag)
	flag = text2num(flag)
	if(!flag)
		flag = TICKET_FLAG_LIST_ALL

	var/content = ""
	var/list/tickets_list = GLOB.ahelp_tickets.tickets_list

	if(holder)
		content += {"<p class='info-bar'>
			<a href='?_src_=[REF(src)];[HrefToken()];action=refresh_admin_ticket_list;flag=[flag]'>Refresh List</a>
			<a href='?_src_=[REF(src)];[HrefToken(TRUE)];action=refresh_admin_ticket_list;flag=[(flag | TICKET_FLAG_LIST_ALL) & ~TICKET_FLAG_LIST_MINE & ~TICKET_FLAG_LIST_UNCLAIMED]'>All Tickets</a>

			<a href='?_src_=[REF(src)];[HrefToken(TRUE)];action=refresh_admin_ticket_list;flag=
				[flag & TICKET_FLAG_LIST_MINE ? "[(flag & ~TICKET_FLAG_LIST_MINE) & ~TICKET_FLAG_LIST_ALL]" : "[(flag | TICKET_FLAG_LIST_MINE) & ~TICKET_FLAG_LIST_ALL]"]
				'>[flag & TICKET_FLAG_LIST_MINE ? "� " : ""]My Tickets</a>

			<a href='?_src_=[REF(src)];[HrefToken(TRUE)];action=refresh_admin_ticket_list;flag=
				[flag & TICKET_FLAG_LIST_UNCLAIMED ? "[(flag & ~TICKET_FLAG_LIST_UNCLAIMED) & ~TICKET_FLAG_LIST_ALL]" : "[(flag | TICKET_FLAG_LIST_UNCLAIMED) & ~TICKET_FLAG_LIST_ALL]"]
				'>[flag & TICKET_FLAG_LIST_UNCLAIMED ? "� " : ""]Unclaimed</a>

		</p>"}

		content += {"<p class='info-bar'>
			Filtering:<b>
			[(flag & TICKET_FLAG_LIST_ALL) ? " All" : ""]
			[(flag & TICKET_FLAG_LIST_MINE) ? " Mine" : ""]
			[(flag & TICKET_FLAG_LIST_UNCLAIMED) ? " Unclaimed" : ""]
		</b></p>"}


		var/list/resolved = new /list()
		var/list/unresolved = new /list()

		for(var/i = tickets_list.len, i >= 1, i--)
			var/datum/admin_help/T = tickets_list[i]

			var/include = FALSE

			if(!(flag & TICKET_FLAG_LIST_ALL))
				if(flag & TICKET_FLAG_LIST_MINE)
					if(!compare_ckey(src, T.initiator_ckey) && !compare_ckey(src, T.handling_admin))
						include = FALSE
					else
						include = TRUE

				if(!include && flag & TICKET_FLAG_LIST_UNCLAIMED)
					if(T.handling_admin)
						include = FALSE
					else
						include = TRUE
			else
				include = TRUE

			if(!include)
				continue

			if(T.state == AHELP_ACTIVE)
				unresolved.Add(T)
			else
				resolved.Add(T)

		if(!unresolved.len && !resolved.len)
			content += "<p class='info-bar emboldened'>There are no tickets matching your filter(s)</p>"

		if(unresolved.len > 0)
			content += "<p class='info-bar unresolved emboldened large-font'>Unresolved Tickets ([unresolved.len]/[tickets_list.len]):</p>"
			for(var/I in unresolved)
				var/datum/admin_help/T = I
				if(!T.initiator)
					content += {"<p class='ticket-bar'>
						<span class='ticket-number'>#[T.id]</span>
						<b>[T.handling_admin ? "" : "[span_unclaimed("Unclaimed")]!"] [T.name]</b><br />
						<b>Owner:</b> <b>[T.initiator_ckey] (DC)</b>
						[T.TicketHref("<img border='0' width='16' height='16' class='uiIcon16 icon-search' /> View")]
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=resolve' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>[T.state == AHELP_ACTIVE ? "" : "Un"]Resolve</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=reject' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Reject</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=close' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Close</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=icissue' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>IC</span></a>
						</p>"}
				else
					var/ai_found = (T.initiator && isAI(T.initiator_ckey))
					content += {"<p class='ticket-bar'>
						<span class='ticket-number'>#[T.id]</span>
						<b>[T.handling_admin ? "" : span_unclaimed("Unclaimed")] [T.name]</b><br />
						<b>Owner:</b> <b>[key_name(T.initiator, 1)]</b><br />
						[T.handling_admin ? " <b>Admin:</b> [T.handling_admin]<br />" : ""]
						[T.TicketHref("<img border='0' width='16' height='16' class='uiIcon16 icon-search' /> View")]
						"}
					if(T.initiator.mob)
						content += {"
							<a href='?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-search' /> ?</a>
							<a href='?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-clipboard' /> PP</a>
							<a href='?_src_=vars;[HrefToken(TRUE)];Vars=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-clipboard' /> VV</a>
							<a href='?_src_=holder;[HrefToken(TRUE)];subtlemessage=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-mail-closed' /> SM</a>
							<a href='?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-arrowthick-1-e' /> FLW</a>
							<a href='?_src_=holder;[HrefToken(TRUE)];check_antagonist=1'><img border='0' width='16' height='16' class='uiIcon16 icon-clipboard' /> CA</a>
							[ai_found ? " <a href='?_src_=holder;[HrefToken(TRUE)];adminchecklaws=[REF(T.initiator.mob)]'><img width='16' height='16' class='uiIcon16 icon-clipboard' /> CL</a>" : ""]
							"}
					content += {"
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=resolve' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>[T.state == AHELP_ACTIVE ? "" : "Un"]Resolve</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=reject' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Reject</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=close' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Close</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=icissue' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>IC</span></a>
						</p>"}

		if(resolved.len > 0)
			content += "<p class='info-bar resolved emboldened large-font'>Resolved Tickets ([resolved.len]/[tickets_list.len]):</p>"
			for(var/I in resolved)
				var/datum/admin_help/T = I
				if(!T.initiator)
					content += {"<p class='ticket-bar'>
						<span class='ticket-number'>#[T.id]</span>
						<b>[T.name]</b><br />
						<b>Owner:</b> <b>[T.initiator_ckey] (DC)</b>
						[T.TicketHref("<img border='0' width='16' height='16' class='uiIcon16 icon-search' /> View")]
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=resolve' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>[T.state == AHELP_ACTIVE ? "" : "Un"]Resolve</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=reject' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Reject</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=close' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Close</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=icissue' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>IC</span></a>
						</p>"}
				else
					var/ai_found = (T.initiator && isAI(T.initiator_ckey))
					content += {"<p class='ticket-bar'>
						<span class='ticket-number'>#[T.id]</span>
						<b>[T.name]</b><br />
						<b>Owner:</b> <b>[key_name(T.initiator, 1)]</b><br />
						[T.handling_admin ? " <b>Admin:</b> [T.handling_admin]<br />" : ""]
						[T.TicketHref("<img border='0' width='16' height='16' class='uiIcon16 icon-search' /> View")]
						"}
					if(T.initiator.mob)
						content += {"
							<a href='?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-search' /> ?</a>
							<a href='?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-clipboard' /> PP</a>
							<a href='?_src_=vars;[HrefToken(TRUE)];Vars=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-clipboard' /> VV</a>
							<a href='?_src_=holder;[HrefToken(TRUE)];subtlemessage=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-mail-closed' /> SM</a>
							<a href='?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(T.initiator.mob)]'><img border='0' width='16' height='16' class='uiIcon16 icon-arrowthick-1-e' /> FLW</a>
							<a href='?_src_=holder;[HrefToken(TRUE)];check_antagonist=1'><img border='0' width='16' height='16' class='uiIcon16 icon-clipboard' /> CA</a>
							[ai_found ? " <a href='?_src_=holder;[HrefToken(TRUE)];adminchecklaws=[REF(T.initiator.mob)]'><img width='16' height='16' class='uiIcon16 icon-clipboard' /> CL</a>" : ""]
								"}
					content += {"
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=resolve' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>[T.state == AHELP_ACTIVE ? "" : "Un"]Resolve</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=reject' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Reject</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=close' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>Close</span></a>
						<a href='?_src_=holder;[HrefToken(TRUE)];ahelp=[REF(T)];ahelp_action=icissue' class='resolve-button'><img border='0' width='16' height='16' class='uiIcon16 icon-check' /> <span>IC</span></a>
						</p>"}
	else
		content += "<p class='info-bar'><a href='?_src_=holder;[HrefToken(TRUE)];action=refresh_admin_ticket_list;flag=[flag]'>Refresh List</a></p>"

		if(tickets_list.len == 0)
			content += "<p class='info-bar emboldened'>There are no tickets in the system</p>"
		else
			content += "<p class='info-bar emboldened'>Your tickets:</p>"
			for(var/datum/admin_help/T in tickets_list)
				if(compare_ckey(T.initiator, usr))
					content += {"<p class='ticket-bar [T.state == AHELP_ACTIVE ? "unresolved" : "resolved"]'>
						<b>[T.name]</b>
						<a href='?src=[REF(T)];user=[REF(src)];action=view_admin_ticket;ticket=[REF(T)]'><img border='0' width='16' height='16' class='uiIcon16 icon-search' /> View</a>
						</p>"}

	var/html = get_html("Admin Tickets", "", "", content)

	usr << browse(null, "window=ViewTickets")
	usr << browse(html, "window=ViewTickets")

/client/Topic(href, href_list, hsrc)
	..()

	if(href_list["action"] == "refresh_admin_ticket_list")
		var/client/C = usr.client
		var/flag = href_list["flag"]
		if(!flag)
			flag = TICKET_FLAG_LIST_ALL

		C.view_tickets_main(flag)

// Used for methods where input via arg doesn't work
/client/proc/get_adminhelp()
	var/msg = input(src, "Please describe your problem concisely and an admin will help as soon as they're able.", "Adminhelp contents") as text|null
	if(msg)
		adminhelp(msg)

/client/verb/adminhelp(msg as text)
	set category = "Admin"
	set name = "Adminhelp"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential=TRUE)
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, span_danger("Error: Admin-PM: You cannot send adminhelps (Muted)."), confidential=TRUE)
		return
	if(handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	msg = trim(msg)

	if(!msg)
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Adminhelp") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(current_ticket)
		if(alert(usr, "You already have a ticket open. Would you like to create a new ticket and close your old one?",,"Yes","No") != "Yes")
			if(current_ticket)
				current_ticket.MessageNoRecipient(msg)
				current_ticket.TimeoutVerb()
				return
			else
				to_chat(usr, span_warning("Ticket not found, creating new one..."), confidential=TRUE)
		else
			current_ticket.AddInteraction("[key_name_admin(usr)] opened a new ticket.")
			current_ticket.Close()

	new /datum/admin_help(msg, src, FALSE)

//
// LOGGING
//

//Use this proc when an admin takes action that may be related to an open ticket on what
//what can be a client, ckey, or mob
/proc/admin_ticket_log(what, message, for_admins = TRUE)
	var/client/C
	var/mob/Mob = what
	if(istype(Mob))
		C = Mob.client
	else
		C = what
	if(istype(C) && C.current_ticket)
		C.current_ticket.AddInteraction(message, for_admins)
		return C.current_ticket
	if(istext(what))	//ckey
		var/datum/admin_help/AH = GLOB.ahelp_tickets.CKey2ActiveTicket(what)
		if(AH)
			AH.AddInteraction(message, for_admins)
			return AH

//
// HELPER PROCS
//

/proc/get_admin_counts(requiredflags = R_BAN)
	. = list("total" = list(), "noflags" = list(), "afk" = list(), "stealth" = list(), "present" = list())
	for(var/client/X in GLOB.admins)
		.["total"] += X
		if(requiredflags != 0 && !check_rights_for(X, requiredflags))
			.["noflags"] += X
		else if(X.is_afk())
			.["afk"] += X
		else if(X.holder.fakekey)
			.["stealth"] += X
		else
			.["present"] += X

/proc/send2irc_adminless_only(source, msg, requiredflags = R_BAN)
	var/list/adm = get_admin_counts(requiredflags)
	var/list/activemins = adm["present"]
	. = activemins.len
	if(. <= 0)
		var/final = ""
		var/list/afkmins = adm["afk"]
		var/list/stealthmins = adm["stealth"]
		var/list/powerlessmins = adm["noflags"]
		var/list/allmins = adm["total"]
		if(!afkmins.len && !stealthmins.len && !powerlessmins.len)
			final = "[msg] - No admins online"
		else
			final = "[msg] - All admins stealthed\[[english_list(stealthmins)]\], AFK\[[english_list(afkmins)]\], or lacks +BAN\[[english_list(powerlessmins)]\]! Total: [allmins.len] "
		send2irc(source,final)
		send2otherserver(source,final)


/proc/send2irc(msg,msg2)
	msg = replacetext(replacetext(msg, "\proper", ""), "\improper", "")
	msg2 = replacetext(replacetext(msg2, "\proper", ""), "\improper", "")
	world.TgsTargetedChatBroadcast("[msg] | [msg2]", TRUE)

/proc/send2otherserver(source,msg,type = "Ahelp")
	set waitfor = FALSE
	var/comms_key = CONFIG_GET(string/comms_key)
	if(!comms_key)
		return
	var/list/message = list()
	message["message_sender"] = source
	message["message"] = msg
	message["source"] = "([CONFIG_GET(string/cross_comms_name)])"
	message["key"] = comms_key
	message += type

	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	for(var/I in servers)
		world.Export("[servers[I]]?[list2params(message)]")


/proc/ircadminwho()
	var/list/message = list("Admins: ")
	var/list/admin_keys = list()
	for(var/adm in GLOB.admins)
		var/client/C = adm
		admin_keys += "[C][C.holder.fakekey ? "(Stealth)" : ""][C.is_afk() ? "(AFK)" : ""]"

	for(var/admin in admin_keys)
		if(LAZYLEN(message) > 1)
			message += ", [admin]"
		else
			message += "[admin]"

	return jointext(message, "")

/proc/keywords_lookup(msg,irc)

	//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
	var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as", "i")

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	var/founds = ""
	for(var/mob/M in GLOB.mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)
			indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i=1, i<surname_found, i++)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in adminhelp_ignored_words))
				if(word == "ai")
					ai_found = 1
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = 1
							var/is_antag = 0
							if(found.mind && found.mind.special_role)
								is_antag = 1
							founds += "Name: [found.name]([found.real_name]) Ckey: [found.ckey] [is_antag ? "(Antag)" : null] "
							msg += "[original_word]<font size='1' color='[is_antag ? "red" : "black"]'>(<A HREF='?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(found)]'>?</A>|<A HREF='?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(found)]'>F</A>)</font> "
							continue
		msg += "[original_word] "
	if(irc)
		if(founds == "")
			return "Search Failed"
		else
			return founds

	return msg
