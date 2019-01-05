//Paperwork pre-made edition. What a pain this was. Most of these were taken from the wiki.
/obj/item/paper/paperwork/general_request_form
	name = "General Requests Form (Form NT-010)"
	fields = 3
	info = "<b>Full Name:</b> <span class=\"paper_field\"></span><br><b>Request:</b> <span class=\"paper_field\"></span><br><b>Reason for Request: </b><span class=\"paper_field\"></span><br><br><u>Sign Below:</u>"

//complaint form
/obj/item/paper/paperwork/complaint_form
	name = "Complaint Form (Form NT-021)"
	fields = 6
	info = {"<center>Complaint Form NT-021</center>
	<hr>
	<b>Complainant: </b><span class=\"paper_field\"></span><br>
	<b>Complainees: </b><span class=\"paper_field\"></span><br>
	<br>
	<b>Complaint Overview:</b><br>
	<span class=\"paper_field\"></span><br>
	<br>
	<b>Complaint Details:</b>
	<span class=\"paper_field\"></span><br>
	<br>
	<hr>
	<b>Complaint Signature: </b><span class=\"paper_field\"></span><br>
	<b>Witness Signature: </b><span class=\"paper_field\"></span><br>
	<br>
	<b>Stamp Below If Approved</b>"}


//general item request form
//TODO, prettier paperwork forms. Both code wise, and aesthetically.
/obj/item/paper/paperwork/item_form
	name = "Item Request Form (Form NT-089)"
	fields = 4
	info = "I, <b><span class=\"paper_field\"></span></b>, request <b><span class=\"paper_field\"></span><b> from <b><span class=\"paper_field\"></span></b> for the following reason: <b><span class=\"paper_field\"></span></b><br><b>Signed,<br>"


//cyborgization request form
/obj/item/paper/paperwork/cyborg_request_form
	name = "Cyborgization Consent Form (Form NT-203)"
	fields = 2
	info = "<b>I, <span class=\"paper_field\"></span> hereby consent and authorize Robotics to remove my brain and install it via an MMI into a cybernetic shell.</b><br>Signed, <span class=\"paper_field\"></span><br><b>Roboticist: </b>"

//HOP access request form
/obj/item/paper/paperwork/hopaccessrequestform
	name = "HoP Access Request Form (Form NT-022)"
	fields = 3
	info = "<b>Name: </b><span class=\"paper_field\"></span><br><b>Accesses Requested: </b><span class=\"paper_field\"></span><br><b>Reason:</b> <span class=\"paper_field\"></span><br><b>Captain Authorization: </b>"

//HOP job request form
/obj/item/paper/paperwork/hop_job_change_form
	name = "HoP Job Change Form (Form NT-059)"
	fields = 4
	info = "<b>Name: </b><span class=\"paper_field\"></span><br><b>Current Job: </b><span class=\"paper_field\"></span><br><b>Requested Job:</b> <span class=\"paper_field\"></span><br><b>Request for Change:</b> <span class=\"paper_field\"></span><br><b>Captain Authorization: </b>"

//RD request form
/obj/item/paper/paperwork/rd_form
	name = "R&D Request Form (Form SCI-3)"
	fields = 3
	info = "<b>Name: </b><span class=\"paper_field\"></span><br><b>Job: </b><span class=\"paper_field\"></span><br><b>Requested Research: </b><span class=\"paper_field\"></span><br><b>Reason: </b>"

//RD upgrade form not included because from personal experience if you don't upgrade stuff you will be lynched
//Mech request form
/obj/item/paper/paperwork/mech_form
	name = "R&D Mech Request Form (Form SCI-9)"
	fields = 5
	info = "<b>Name: </b><span class=\"paper_field\"></span><br><b>Job: </b><span class=\"paper_field\"></span><br><b>Requested Mech: </b><span class=\"paper_field\"></span><br><b>Requested Equipment: </b><span class=\"paper_field\"></span><br><b>Reason: </b><span class=\"paper_field\"></span><br>Signed: "


//clipboards
/obj/item/clipboard/yog/paperwork
	name = "Paperwork"


/obj/item/clipboard/yog/paperwork/rd/Initialize()
	. = ..()
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	new /obj/item/paper/paperwork/rd_form(src)
	new /obj/item/paper/paperwork/mech_form(src)
	new /obj/item/paper/paperwork/cyborg_request_form(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/hos/Initialize()
	. = ..()
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/captain/Initialize()
	. = ..()
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/hop/Initialize()
	. = ..()
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/hop_job_change_form(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/warden/Initialize()
	. = ..()
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/ce/Initialize()
	. = ..()
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/cmo/Initialize()
	. = ..()
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	toppaper = contents[contents.len]
	update_icon()