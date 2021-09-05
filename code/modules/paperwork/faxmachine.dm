GLOBAL_LIST_EMPTY(allfaxes)
GLOBAL_LIST_INIT(admin_departments, list("Central Command", "Sol Government"))
GLOBAL_LIST_EMPTY(alldepartments)
GLOBAL_LIST_EMPTY(adminfaxes)

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	insert_anim = "faxsend"
	req_one_access = list(ACCESS_LAWYER, ACCESS_HEADS, ACCESS_ARMORY) //Warden needs to be able to Fax solgov too.

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200

	var/authenticated = FALSE
	var/auth_name
	var/sendcooldown = 0 // to avoid spamming fax messages

	var/department = "Unknown" // our department

	var/destination = "Central Command" // the department we're sending to

/obj/machinery/photocopier/faxmachine/Initialize()
	. = ..()
	GLOB.allfaxes += src

	if( !(("[department]" in GLOB.alldepartments) || ("[department]" in GLOB.admin_departments)) )
		GLOB.alldepartments |= department

/obj/machinery/photocopier/faxmachine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FaxMachine", name)
		ui.open()

/obj/machinery/photocopier/faxmachine/ui_state(mob/user)
	return GLOB.default_state
	
/obj/machinery/photocopier/faxmachine/ui_data(mob/user)
	. = list()
	.["authenticated"] = authenticated
	.["auth_name"] = auth_name
	.["has_copy"] = !!copy
	.["copy_name"] = copy?.name
	.["cooldown"] = sendcooldown
	.["depts"] = (GLOB.alldepartments + GLOB.admin_departments)
	.["destination"] = destination

/obj/machinery/photocopier/faxmachine/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	. = TRUE
	switch(action)
		if("send")
			if(copy)
				if (destination in GLOB.admin_departments)
					send_admin_fax(usr, destination)
				else
					sendfax(destination)
				
				// if (sendcooldown)
				// 	spawn(sendcooldown) // cooldown time
				// 		sendcooldown = 0
			return
		if("remove")
			if(copy)
				copy.loc = usr.loc
				usr.put_in_hands(copy)
				to_chat(usr, "<span class='notice'>You take \the [copy] out of \the [src].</span>")
				copy = null
				return
		if("dept")
			var/lastdestination = destination
			destination = input(usr, "Which department?", "Choose a department", "") as null|anything in (GLOB.alldepartments + GLOB.admin_departments)
			if(!destination) destination = lastdestination
			return
		if("set_dept")
			destination = params["dept"]
			return
		if("auth")
			if (IsAdminGhost(usr))
				authenticated = TRUE
				auth_name = usr.client.holder.admin_signature
				return
			var/obj/item/card/id/id_card = usr.get_idcard(hand_first = TRUE)
			if (check_access(id_card))
				authenticated = TRUE
				auth_name = "[id_card.registered_name] - [id_card.assignment]"
			return

		if("logout")
			authenticated = FALSE
			auth_name = null
			return

	return FALSE

/obj/machinery/photocopier/faxmachine/proc/sendfax(var/destination)
	if(stat & (BROKEN|NOPOWER))
		return
	
	use_power(200)
	
	var/success = 0
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if( F.department == destination )
			success = F.recievefax(copy)
	
	if (success)
		visible_message("[src] beeps, \"Message transmitted successfully.\"")
		//sendcooldown = 600
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")

/obj/machinery/photocopier/faxmachine/proc/recievefax(var/obj/item/incoming)
	if(stat & (BROKEN|NOPOWER))
		return 0
	
	if(department == "Unknown")
		return 0	//You can't send faxes to "Unknown"

	flick("faxreceive", src)
	playsound(loc, "sound/items/polaroid1.ogg", 50, 1)
	
	// give the sprite some time to flick
	sleep(20)
	
	if (istype(incoming, /obj/item/paper))
		copy(incoming)
	else if (istype(incoming, /obj/item/photo))
		photocopy(incoming)
	else if (istype(incoming, /obj/item/paper_bundle))
		bundlecopy(incoming)
	else
		return 0

	use_power(active_power_usage)
	return 1

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(var/mob/sender, var/destination)
	if(stat & (BROKEN|NOPOWER))
		return

	use_power(200)

	var/obj/item/rcvdcopy
	if (istype(copy, /obj/item/paper))
		rcvdcopy = copy(copy)
	else if (istype(copy, /obj/item/photo))
		rcvdcopy = photocopy(copy)
	else if (istype(copy, /obj/item/paper_bundle))
		rcvdcopy = bundlecopy(copy)
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")
		return

	rcvdcopy.loc = null //hopefully this shouldn't cause trouble
	GLOB.adminfaxes += rcvdcopy
	
	//message badmins that a fax has arrived
	switch(destination)
		if ("Central Command")
			send_adminmessage(sender, "CENTCOM FAX", rcvdcopy, "CentcomFaxReply", "#006100")
		if ("Sol Government")
			send_adminmessage(sender, "SOL GOVERNMENT FAX", rcvdcopy, "CentcomFaxReply", "#1F66A0")
	sendcooldown = 1800
	// sleep(50)
	visible_message("[src] beeps, \"Message transmitted successfully.\"")
	

/obj/machinery/photocopier/faxmachine/proc/send_adminmessage(var/mob/sender, var/faxname, var/obj/item/sent, var/reply_type, font_colour="#006100")
	var/msg = "<font color='admin'><b><font color='[font_colour]'>[faxname]: </font>[key_name(sender, 1)] (<A HREF='?_src_=holder;[HrefToken()];adminplayeropts=\ref[sender]'>PP</A>) (<A HREF='?_src_=vars;[HrefToken()];Vars=\ref[sender]'>VV</A>) (<A HREF='?_src_=holder;[HrefToken()];subtlemessage=\ref[sender]'>SM</A>) (<A HREF='?_src_=holder;[HrefToken()];adminplayerobservefollow=\ref[sender]'>JMP</A>) (<a href='?_src_=holder;[HrefToken()];[reply_type]=\ref[sender];originfax=\ref[src]'>REPLY</a>)</b>: Receiving '[sent.name]' via secure connection ... <a href='?_src_=holder;[HrefToken()];AdminFaxView=\ref[sent]'>view message</a></font>"

	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg,
		confidential = TRUE)
