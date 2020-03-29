//Paperwork pre-made edition. What a pain this was. Most of these were taken from the wiki.
//fucking shitcode
//REALLY BAD SHITCODE HOLY FUCK


/obj/item/paper/paperwork/general_request_form
	name = "General Requests Form (Form NT-010)"


/obj/item/paper/paperwork/general_request_form/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>General Request Form NT-010</h3></center><hr><b>Name: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Request: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Reason: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Stamp Below if Approved</b>",/datum/language/common)
	update_icon()


//complaint form
/obj/item/paper/paperwork/complaint_form
	name = "Complaint Form (Form NT-021)"

/obj/item/paper/paperwork/complaint_form/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>Complaint Form NT-020</h3></center><hr><b>Complainant: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><b>Complainees: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Complaint Overview: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Complaint Details: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><hr><b>Complaint Signature: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><b>Witness Signature: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><hr><b>Administrator Notes: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><hr><b>Stamp Below if Accepted:</b>",/datum/language/common)
	update_icon()

//incident report
/obj/item/paper/paperwork/incident_report
	name = "Incident Report (Form NT-400)"

/obj/item/paper/paperwork/incident_report/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><hr><h3>Incident Report Form NT-400</h3></center><br>",/datum/language/common)
	written += new/datum/langtext("<b>Name: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<hr><i>For any section that does not apply, simply fill in that it is not applicable or N/A, do not leave any section blank.</i><br>",/datum/language/common)
	written += new/datum/langtext("<b>Incident Type: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Location: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Action Taken: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Action Still Needed: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Involved Parties: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Witnesses (if different than involved parties): </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<hr><br>",/datum/language/common)
	written += new/datum/langtext("<b>Incident Summary: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<hr><br>",/datum/language/common)
	written += new/datum/langtext("<b>Additional Comments: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Signed: </b>",/datum/language/common)
	update_icon()

//security officer incident form
/obj/item/paper/paperwork/sec_incident_report
	name = "Security Incident Report (Form SEC-030)"

/obj/item/paper/paperwork/sec_incident_report/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<center><h3>Security Incident Report (Form SEC-030)</h3>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Offense/Incident Type: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Location: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<br><hr><h3>Personnel Involved in Incident</h3><br>",/datum/language/common)
	written += new/datum/langtext("<b>Reporting Officer: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Assisting Officer(s) </b><br><br>",/datum/language/common)
	written += new/datum/langtext("<table><row><cell><b>Rank</b><cell> <b>Name</b><cell> <b>Position</row></b><br>",/datum/language/common)
	written += new/datum/langtext("<row><cell><b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</b><cell> ",/datum/language/common)
	written += new/datum/langtext("<cell> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<cell> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</row> ",/datum/language/common)
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("</table><br>",/datum/language/common)
	written += new/datum/langtext("<b>Other Personnel</b><br>",/datum/language/common)
	written += new/datum/langtext("<font size=\"1\"><i>(V-Victim, S-Suspect, W-Witness, M-Missing, A-Arrested, RP-Reporting Person, D-Deceased)</i></font><br><br>",/datum/language/common)
	written += new/datum/langtext("<table><row><cell><b>Rank</b><cell> <b>Name</b><cell> <b>Position</b><br>",/datum/language/common)
	written += new/datum/langtext("<row><cell><b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</b><cell> ",/datum/language/common)
	written += new/datum/langtext("<cell> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("</table><br>",/datum/language/common)
	written += new/datum/langtext("<hr><h3>Description of Items/Property </h3><br>",/datum/language/common)
	written += new/datum/langtext("<font size=\"1\"><i>(D-Damaged, E-Evidence, L-Lost, R-Recovered, S-Stolen)</i></font><br><br>",/datum/language/common)
	written += new/datum/langtext("<table><row><cell><b>Rank</b><cell> <b>Name</b><cell> <b>Position</b></row><br>",/datum/language/common)
	written += new/datum/langtext("<row><cell><b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</b><cell>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<cell> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</row><br>",/datum/language/common)
	written += new/datum/langtext("</table><br>",/datum/language/common)
	written += new/datum/langtext("<hr><h3>Narrative </h3>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Reporting Officer's Signature</b><br>:",/datum/language/common)
	update_icon()

//general item request form
//TODO, prettier paperwork forms. Both code wise, and aesthetically. <-- heh, good luck with that, me. -Redd
/obj/item/paper/paperwork/item_form
	name = "Item Request Form (Form NT-089)"

/obj/item/paper/paperwork/item_form/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>Item Request Form NT-089</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Name:</b> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Item Requested:</b> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Reason Requested: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Sign Here:</b> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Reviewed By: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Stamp Below if Approved</b>",/datum/language/common)
	update_icon()


//cyborgization request form
/obj/item/paper/paperwork/cyborg_request_form
	name = "Cyborgization Consent Form (Form NT-203)"

/obj/item/paper/paperwork/cyborg_request_form/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>Cyberization Consent Form NT-203</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("By signing this document, I, <b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</b> hereby consent to the removal of my brain, acknowledging it will be placed in a Man-Machine Interface.<br>",/datum/language/common)
	written += new/datum/langtext("I further affirm I will not hold Robotics liable for any issues arising from this procedure.<br><b>I consent to have the MMI placed in one or more of the following after the procedure:</b><br>",/datum/language/common)
	written += new/datum/langtext("<font size=\"1\">(Choose one or more, mark your choice with an X)</font><br>",/datum/language/common)
	written += new/datum/langtext("\[",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("\] Cyborg<br>",/datum/language/common)
	written += new/datum/langtext("\[",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("\] Exosuit<br>",/datum/language/common)
	written += new/datum/langtext("\[",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("\] AI Core<br>",/datum/language/common)
	written += new/datum/langtext("<b>Signed, </b><u>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</u><hr><b>Roboticist Notes:</b>",/datum/language/common)
	update_icon()

//HOP access request form
/obj/item/paper/paperwork/hopaccessrequestform
	name = "HoP Access Request Form (Form NT-022)"

/obj/item/paper/paperwork/hopaccessrequestform/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>HOP Access Request Form NT-022</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Name: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Accesses Requested: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Reason: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Reviewed By: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Stamp Below if Approved</b>",/datum/language/common)
	update_icon()

//HOP job request form
/obj/item/paper/paperwork/hop_job_change_form
	name = "Job Reassignment Form (Form NT-059)"

/obj/item/paper/paperwork/hop_job_change_form/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>Job Reassignment Form</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Name: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Current Job: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Requested Job: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Reason for Change: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>By submitting this form, I verify that I recognize all job changes are left to the discretion of the Head of Personnel. I acknowledge my job reassignment may not be approved.</b><br>",/datum/language/common)
	written += new/datum/langtext("<b>Signed, </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Reviewed By: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Stamp Below if Approved</b>",/datum/language/common)
	update_icon()

//RD request form
/obj/item/paper/paperwork/rd_form
	name = "R&D Request Form (Form SCI-3)"

/obj/item/paper/paperwork/rd_form/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>R&D Request Form SCI-3</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Name: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Requested Research: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Reason: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Stamp Below if Approved</b>",/datum/language/common)
	update_icon()

//RD upgrade form not included because from personal experience if you don't upgrade stuff you will be lynched
//Mech request form
/obj/item/paper/paperwork/mech_form
	name = "R&D Mech Request Form (Form SCI-9)"

/obj/item/paper/paperwork/mech_form/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>Mech Request Form SCI-9</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Name: </b><span class=\"paper_field\">write</span><br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Job: </b><span class=\"paper_field\">write</span><br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Requested Mech: </b><span class=\"paper_field\">write</span><br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Requested Equipment: </b><span class=\"paper_field\">write</span><br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Reason: </b><span class=\"paper_field\">write</span><br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Signed, </b><span class=\"paper_field\">write</span><br><br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Stamp Below if Approved</b>",/datum/language/common)
	update_icon()

//HMMM YES A JOB CHANGE CERTIFICATION
/obj/item/paper/paperwork/jobchangecert
	name = "Job Change Certificate"

/obj/item/paper/paperwork/jobchangecert/New()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>Job Transfer Certificate</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("<b>To whom it may concern,<br>",/datum/language/common)
	written += new/datum/langtext("&nbsp;&nbsp;&nbsp;&nbsp;Please let this document certify that </b><u>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</u><b> has transferred from the role of </b><u>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</u><b> to </b><u>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</u>.<br>",/datum/language/common)
	written += new/datum/langtext("&nbsp;&nbsp;&nbsp;&nbsp;<b>Signed,<br/>",/datum/language/common)
	written += new/datum/langtext("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b><u>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</u><br><b>Stamp:</b>",/datum/language/common)
	written += new/datum/langtext("",/datum/language/common)
	update_icon()

//clipboards
/obj/item/clipboard/yog/paperwork
	name = "Paperwork"


/obj/item/clipboard/yog/paperwork/rd/Initialize()
	. = ..()
	name = "Paperwork (RD)"
	new /obj/item/paper/paperwork/jobchangecert(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	new /obj/item/paper/paperwork/rd_form(src)
	new /obj/item/paper/paperwork/mech_form(src)
	new /obj/item/paper/paperwork/cyborg_request_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/incident_report(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/hos/Initialize()
	. = ..()
	name = "Paperwork (HoS)"
	new /obj/item/paper/paperwork/jobchangecert(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/incident_report(src)
	for (var/i in 1 to 10)
		new /obj/item/paper/paperwork/sec_incident_report(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/captain/Initialize()
	. = ..()
	name = "Paperwork (Captain)"
	new /obj/item/paper/paperwork/jobchangecert(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/incident_report(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/hop/Initialize()
	. = ..()
	name = "Paperwork (HoP)"
	new /obj/item/paper/paperwork/jobchangecert(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/hop_job_change_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/incident_report(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/warden/Initialize()
	. = ..()
	name = "Paperwork (Warden)"
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/incident_report(src)
	for (var/i in 1 to 10)
		new /obj/item/paper/paperwork/sec_incident_report(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/ce/Initialize()
	. = ..()
	name = "Paperwork (CE)"
	new /obj/item/paper/paperwork/jobchangecert(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/incident_report(src)
	toppaper = contents[contents.len]
	update_icon()


/obj/item/clipboard/yog/paperwork/cmo/Initialize()
	. = ..()
	name = "Paperwork (CMO)"
	new /obj/item/paper/paperwork/jobchangecert(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/incident_report(src)
	toppaper = contents[contents.len]
	update_icon()

/obj/item/clipboard/yog/paperwork/security/Initialize()
	. = ..()
	for (var/i in 1 to 10)
		new /obj/item/paper/paperwork/sec_incident_report(src)
	for (var/i in 1 to 10)
		new /obj/item/paper/paperwork/incident_report(src)
	toppaper = contents[contents.len]
	update_icon()

//admin clipboard
/obj/item/clipboard/yog/paperwork/admin/Initialize()
	. = ..()
	name = "Paperwork (AdminSpawn)"
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/incident_report(src)
	new /obj/item/paper/paperwork/sec_incident_report(src)
	new /obj/item/paper/paperwork/item_form(src)
	new /obj/item/paper/paperwork/cyborg_request_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/hop_job_change_form(src)
	new /obj/item/paper/paperwork/rd_form(src)
	new /obj/item/paper/paperwork/mech_form(src)
	new /obj/item/paper/paperwork/jobchangecert(src)
	toppaper = contents[contents.len]
	update_icon()
//turdis bad