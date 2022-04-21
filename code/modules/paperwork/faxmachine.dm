GLOBAL_LIST_EMPTY(allfaxes)
GLOBAL_LIST_INIT(admin_departments, list("Central Command"))
GLOBAL_LIST_EMPTY(alldepartments)
GLOBAL_LIST_EMPTY(adminfaxes)

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	insert_anim = "faxsend"
	req_one_access = list(ACCESS_LAWYER, ACCESS_HEADS, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_QM)
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

	if( !((department in GLOB.alldepartments) || (department in GLOB.admin_departments)) )
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
	.["has_copy"] = !copier_empty()
	.["copy_name"] = copy?.name || photocopy?.name || doccopy?.name
	.["cooldown"] = sendcooldown - world.time
	.["depts"] = (GLOB.alldepartments + GLOB.admin_departments)
	.["destination"] = destination

/obj/machinery/photocopier/faxmachine/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	. = TRUE
	switch(action)
		if("send")
			if(!copier_empty())
				if(sendcooldown - world.time > 0)
					to_chat(usr, "<span class='warning'>Transmitter recharging</span>")
					return
				
				sendcooldown = world.time + 1 MINUTES
				if (destination in GLOB.admin_departments)
					INVOKE_ASYNC(src, .proc/send_admin_fax, usr, destination)
				else
					INVOKE_ASYNC(src, .proc/sendfax, destination)
			return
		if("remove")
			if(copy)
				copy.loc = usr.loc
				usr.put_in_hands(copy)
				to_chat(usr, "<span class='notice'>You take \the [copy] out of \the [src].</span>")
				copy = null
				return
			if(photocopy)
				photocopy.loc = usr.loc
				usr.put_in_hands(photocopy)
				to_chat(usr, "<span class='notice'>You take \the [photocopy] out of \the [src].</span>")
				photocopy = null
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
	
	var/success = FALSE
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if( F.department == destination )
			success ||= F.recievefax(copy || photocopy)
	
	if (success)
		visible_message("[src] beeps, \"Message transmitted successfully.\"")
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")

/obj/machinery/photocopier/faxmachine/proc/recievefax(var/obj/item/incoming)
	if(stat & (BROKEN|NOPOWER))
		return FALSE
	
	if(department == "Unknown")
		return FALSE	//You can't send faxes to "Unknown"

	flick("faxreceive", src)
	playsound(loc, "sound/items/polaroid1.ogg", 50, 1)
	
	// give the sprite some time to flick
	sleep(23)
	
	if (istype(incoming, /obj/item/paper))
		copy(incoming)
	else if (istype(incoming, /obj/item/photo))
		photocopy(incoming)
	else if (istype(incoming, /obj/item/paper_bundle))
		bundlecopy(incoming)
	else
		return FALSE

	use_power(active_power_usage)
	return TRUE

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(var/mob/sender, var/destination)
	if(stat & (BROKEN|NOPOWER))
		return

	use_power(200)

	var/obj/item/rcvdcopy
	if (istype(copy, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/rcvdbundle = bundlecopy(copy)
		rcvdbundle.admin_faxed = TRUE
		rcvdcopy = rcvdbundle
	else if (copy)
		rcvdcopy = copy(copy)
	else if (photocopy)
		rcvdcopy = photocopy(photocopy)
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")
		return

	rcvdcopy.moveToNullspace() //hopefully this shouldn't cause trouble
	GLOB.adminfaxes += rcvdcopy

	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(is_centcom_level(F.z))
			F.recievefax(rcvdcopy)
	
	//message badmins that a fax has arrived
	switch(destination)
		if ("Central Command")
			send_adminmessage(sender, "CENTCOM FAX", rcvdcopy, "CentcomFaxReply", "#006100")
	sleep(50)
	visible_message("[src] beeps, \"Message transmitted successfully.\"")
	

/obj/machinery/photocopier/faxmachine/proc/send_adminmessage(var/mob/sender, var/faxname, var/obj/item/sent, var/reply_type, font_colour="#006100")
	var/msg = "<b><font color='[font_colour]'>[faxname]: </font>[key_name(sender, 1)] (<A HREF='?_src_=holder;[HrefToken()];adminplayeropts=\ref[sender]'>PP</A>) (<A HREF='?_src_=vars;[HrefToken()];Vars=\ref[sender]'>VV</A>) (<A HREF='?_src_=holder;[HrefToken()];subtlemessage=\ref[sender]'>SM</A>) (<A HREF='?_src_=holder;[HrefToken()];adminplayerobservefollow=\ref[sender]'>JMP</A>) (<a href='?_src_=holder;[HrefToken()];[reply_type]=\ref[sender];originfax=\ref[src]'>REPLY</a>)</b>: Receiving '[sent.name]' via secure connection ... <a href='?_src_=holder;[HrefToken(TRUE)];AdminFaxView=\ref[sent]'>view message</a>"
	msg = span_admin("<span class=\"message linkify\">[msg]</span>")
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg,
		confidential = TRUE)

/obj/machinery/photocopier/faxmachine/check_ass()
	return FALSE // No ass here

/obj/machinery/photocopier/faxmachine/proc/sendFax(var/obj/machinery/faxmachine/fax as obj in GLOB.allfaxes)
	set name = "Send Fax"
	set category = "Admin"

	if(!check_rights(R_ADMIN)) return
	usr.client.send_admin_fax(src)

/obj/machinery/photocopier/faxmachine/proc/recieve_admin_fax(customname, input)
	if(! (stat & (BROKEN|NOPOWER) ) )
		// animate! it's alive!
		flick("faxreceive", src)

		// give the sprite some time to flick
		spawn(20)
			var/obj/item/paper/P = new /obj/item/paper( loc )
			P.name = "[command_name()]- [customname]"
			P.info = input
			P.update_icon()

			playsound(loc, "sound/items/polaroid1.ogg", 50, 1)

			// Stamps
			var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
			stampoverlay.icon_state = "paper_stamp-cent"
			if(!P.stamped)
				P.stamped = new
			P.stamped += /obj/item/stamp
			P.overlays += stampoverlay
			P.stamps += "<i>This paper has been stamped by the Central Command Quantum Relay.</i>"

		

