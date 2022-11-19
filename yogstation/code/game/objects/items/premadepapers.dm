/**
  *
  *
  * A General Request Form for things without a form
  *
  * That's literally it. 
  * It's a subtype of paper, with written text already on it.
  *
  */
/obj/item/paper/paperwork/
	var/id = 0
	var/printable = TRUE
/obj/item/paper/paperwork/general_request_form
	name = "General Requests Form (Form NT-010)"
	id = 1

/obj/item/paper/paperwork/general_request_form/Initialize()
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


/**
  *
  * 
  * A complaint form for tattling against coworkers
  *
  * A complaint form for tattling against coworkers. Tattling against coworkers form.
  *
  */
/obj/item/paper/paperwork/complaint_form
	name = "Complaint Form (Form NT-021)"
	id = 2

/obj/item/paper/paperwork/complaint_form/Initialize()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>Complaint Form NT-021</h3></center><hr><b>Complainant: </b>",/datum/language/common)
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

/**
  *
  * 
  * A form for reporting incidents.
  *
  * A form exclusively used for reporting incidents.
  *
  */
/obj/item/paper/paperwork/incident_report
	name = "Incident Report (Form NT-400)"
	id = 3

/obj/item/paper/paperwork/incident_report/Initialize()
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

/**
  *
  * 
  * An incident form for security officers
  *
  * That's literally all it is. Security officers may use it to write about a situation.
  *
  */
/obj/item/paper/paperwork/sec_incident_report
	name = "Security Incident Report (Form SEC-030)"
	id = 4

/obj/item/paper/paperwork/sec_incident_report/Initialize()
	. = ..()
	written = list()
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<center><h3>Security Incident Report (Form SEC-030)</h3>",/datum/language/common)
	written += new/datum/langtext("<hr>",/datum/language/common)
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
	written += new/datum/langtext("<b>Assisting Officer(s)</b><br>",/datum/language/common)
	written += new/datum/langtext("<table><tr><th><b>Rank</b></th><th><b>Name</b></th><th><b>Status</b></th></tr><br>",/datum/language/common)
	written += new/datum/langtext("<tr><td><b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</b></td> ",/datum/language/common)
	written += new/datum/langtext("<td> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</td><td> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</td></tr> ",/datum/language/common)
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("</table><br>",/datum/language/common)
	written += new/datum/langtext("<b>Other Personnel</b><br>",/datum/language/common)
	written += new/datum/langtext("<font size=\"1\"><i>(V-Victim, S-Suspect, W-Witness, M-Missing, A-Arrested, RP-Reporting Person, D-Deceased)</i></font><br>",/datum/language/common)
	written += new/datum/langtext("<table><tr><th><b>Rank</b></th> <th><b>Name</b></th> <th><b>Status</b></th></tr><br>",/datum/language/common)
	written += new/datum/langtext("<tr><td><b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</b></td><td> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</td><td> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</td></tr></table><br>",/datum/language/common)
	written += new/datum/langtext("<hr><h3>Description of Items/Property </h3>",/datum/language/common)
	written += new/datum/langtext("<font size=\"1\"><i>(D-Damaged, E-Evidence, L-Lost, R-Recovered, S-Stolen)</i></font><br>",/datum/language/common)
	written += new/datum/langtext("<table><tr><th><b>Item</b></th> <th><b>Description</b></th> <th><b>Status</b></th></tr><br>",/datum/language/common)
	written += new/datum/langtext("<tr><td><b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</b></td><td>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</td><td> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("</td></tr><br>",/datum/language/common)
	written += new/datum/langtext("</table><br>",/datum/language/common)
	written += new/datum/langtext("<hr><h3>Narrative </h3>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br>",/datum/language/common)
	written += new/datum/langtext("<b>Reporting Officer's Signature</b>:",/datum/language/common)
	update_icon()

/**
  *
  * 
  * A form for requesting an item.
  *
  * A form for requesting an item. Use this to request an item from somewhere. (I should give assistants access to this)
  *
  */
/obj/item/paper/paperwork/item_form
	name = "Item Request Form (Form NT-089)"
	id = 5

/obj/item/paper/paperwork/item_form/Initialize()
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


/**
  *
  * 
  * A form signifying the signer consents to being borged.
  *
  * See short description.
  *
  */
/obj/item/paper/paperwork/cyborg_request_form
	name = "Cyborgization Consent Form (Form NT-203)"
	id = 6

/obj/item/paper/paperwork/cyborg_request_form/Initialize()
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

/**
  *
  * 
  * A form for requesting more access
  *
  * A form for requesting more access. The bane of assistants and annoying chaplains.
  *
  */
/obj/item/paper/paperwork/hopaccessrequestform
	name = "HoP Access Request Form (Form NT-022)"
	id = 7

/obj/item/paper/paperwork/hopaccessrequestform/Initialize()
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

/**
  *
  * 
  * A form for requesting a job change
  *
  * A form for requesting a job change. The bane of assistants.
  *
  */
/obj/item/paper/paperwork/hop_job_change_form
	name = "Job Reassignment Form (Form NT-059)"
	id = 8

/obj/item/paper/paperwork/hop_job_change_form/Initialize()
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

/**
  *
  * 
  * A form for requesting something be researched.
  *
  * Do not use. Everyone will hate you.
  *
  */
/obj/item/paper/paperwork/rd_form
	name = "R&D Request Form (Form SCI-3)"
	id = 9

/obj/item/paper/paperwork/rd_form/Initialize()
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

/**
  *
  * 
  * A form for requesting a mech.
  *
  * A form for requesting a mech. The bane of powergamers.
  *
  */
/obj/item/paper/paperwork/mech_form
	name = "R&D Mech Request Form (Form SCI-9)"
	id = 10

/obj/item/paper/paperwork/mech_form/Initialize()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>Mech Request Form SCI-9</h3></center><hr><b>Name: </b>",/datum/language/common)
	written += "</b><span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Job:</b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Requested Mech: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Requested Equipment: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Reason: </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><b>Signed, </b>",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br><br><br><b>Stamp Below if Approved</b>",/datum/language/common)
	update_icon()

/**
  *
  * 
  * A form for signifying someone got a job change.
  *
  * A form for signifying someone got a job change. Muh RP.
  *
  */
/obj/item/paper/paperwork/jobchangecert
	name = "Job Change Certificate"
	id = 11

/obj/item/paper/paperwork/jobchangecert/Initialize()
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

/**
  *
  * 
  * A form for testing employee literacy.
  *
  * A form for employee literacy testing. The bane of everyone.
  *
  */
/obj/item/paper/paperwork/literacytest
	name = "Literacy Test for NT Employees (Form NT-43)"
	id = 12

/obj/item/paper/paperwork/literacytest/Initialize()
	. = ..()
	//a list of questions for the test
	var/list/questions = list(
		"In the first space below, write the year the Credit was introduced.<br>218",
		"In the first space below, write the year the UN split.<br>220",
		"What was the first race discovered by humanity? Answer below.<br>",
		"Who is the CEO of Nanotrasen? Answer below.<br>",
		"From the following letters, Z V B D M K T P H S Y C, which 2, in order, come last in the alphabet?<br>"
	)
	//select test question 1
	var/question_one = pick(questions)
	//remove from pool
	questions -= question_one
	//select test question 2
	var/question_two = pick(questions)
	//remove from pool
	questions -= question_two
	//select test question 3
	var/question_three = pick(questions)
	//remove from pool
	questions -= question_three
	//select test question 4
	var/question_four = pick(questions)
	//remove from pool
	questions -= question_four
	//select final test question
	var/question_five = pick(questions)
	//remove final pick from pool
	questions -= question_five
	written = list()
	written += new/datum/langtext("<center><h3>NT-43 Literacy Test for Nanotrasen Employees</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Race:</b> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<br>",/datum/language/common)
	written += new/datum/langtext("<b>Name of Test-Taker:</b> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<hr>",/datum/language/common)
	written += new/datum/langtext("<b>Do what you are told in each statement, nothing more and nothing less. Each correct answer is worth 2 points.</b><hr>",/datum/language/common)
	written += new/datum/langtext(question_one,/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<hr>",/datum/language/common)
	written += new/datum/langtext(question_two,/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<hr>",/datum/language/common)
	written += new/datum/langtext(question_three,/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<hr>",/datum/language/common)
	written += new/datum/langtext(question_four,/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<hr>",/datum/language/common)
	written += new/datum/langtext(question_five,/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<hr>" ,/datum/language/common)
	written += new/datum/langtext("Sign your name where there is an option.<br>",/datum/language/common)
	written += new/datum/langtext("<b>I,</b> ",/datum/language/common)
	written += "<span class=\"paper_field\"></span>"
	written += new/datum/langtext("<b>, hereby acknowledge that I have answered this test's questions to the best of my ability, and acknowledge that if I fail this test, a penalty to be determined may be applied to me.</b><hr>",/datum/language/common)
	written += new/datum/langtext("<b>Test Administrator:</b> ",/datum/language/common)
	update_icon()

/**
  *
  * 
  * The answer key to the literacy test.
  *
  * Nobody will know the answers if I don't include this.
  *
  */
/obj/item/paper/paperwork/literacytest/answers
	name = "Literacy Test Answers (NT-44)"
	id = 13
	printable = FALSE

/obj/item/paper/paperwork/literacytest/answers/Initialize()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>NT-44 Literacy Test Answer Key</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("<b>1. In the first space below, write the year the credit was introduced.</b> <u>The credit was introduced in 2181.</u><br>",/datum/language/common)
	written += new/datum/langtext("<b>2. In the first space below, write the year the UN split.</b> <u>The UN split in 2205.</u><br>",/datum/language/common)
	written += new/datum/langtext("<b>3. What was the first race discovered by humanity? Answer below.</b> <u>Plasmamen</u><br>",/datum/language/common)
	written += new/datum/langtext("<b>4. Who is the CEO of Nanotrasen? Answer below.</b> <u>Theo Deimi</u><br>",/datum/language/common)
	written += new/datum/langtext("<b>5. From the following letters, Z V B D M K T P H S Y C, which 2, in order, come last in the alphabet?</b> <u>YZ</u><hr>",/datum/language/common)
	written += new/datum/langtext("<center><b><font color=\"red\">TOP SECRET - Command Eyes Only</font></b></center>",/datum/language/common)
	update_icon()

// How to perform autopsy

/obj/item/paper/autopsy
	name = "Autopsy 101"

/obj/item/paper/autopsy/Initialize()
	. = ..()
	written = list()
	written += new/datum/langtext("Step 1: Apply drapes to the chest and select Autopsy.<br>",/datum/language/common)
	written += new/datum/langtext("Step 2: Incise the chest with a scalpel.<br>",/datum/language/common)
	written += new/datum/langtext("Step 3: While holding a forensic scanner in your off-hand, perform the autopsy using the scalpel again.<br>",/datum/language/common)
	update_icon()

//academy ruin papers

/**
  *
  * 
  * Papers that add flavor to the Wizard Academy
  *
  * These are flavor papers for spicing up the Wizard Academy Ruin
  *
  */
/obj/item/paper/yog/ruins/academy
	name = "Debug Paper"
	desc = "Official Wizard Academy Mail"

//in regards to trey being a lizard

/**
  *
  * 
  * A demonstration paper. See [Wizard Academy Ruins Papers.][/obj/item/paper/yog/ruins/academy]
  *
  * I wrote this paper as a way to try and add some more flavor to the wizard academy. See PR # 9229.
  *
  */
/obj/item/paper/yog/ruins/academy/trey_wizard_lizard
	name = "RE: Trey of the Shattered Voice"

/obj/item/paper/yog/ruins/academy/trey_wizard_lizard/Initialize()
	. = ..()
	written = list()
	written += new/datum/langtext("<center><h3>Wizard Academy Official Mail</h3></center><hr>",/datum/language/common)
	written += new/datum/langtext("<b>From: Archmage Daniel the Great</b><br>",/datum/language/common)
	written += new/datum/langtext("<b>To: Recruiter Billy the Lame</b><hr>",/datum/language/common)
	written += new/datum/langtext("Bill, where the heck did you find this guy? Are you sure he's wizard material..? He st--te-s a-lot. He's a -tink-ng l-zard--<br>",/datum/language/common)
	written += new/datum/langtext("<i><b>The rest of the paper is charred...</i></b>",/datum/language/common)
	update_icon()



//clipboards

/**
  *
  * 
  * The baseline paperwork [clipboard.][/obj/item/clipboard]
  *
  * This is the default object.
  * For the RD variant, [click here.][/obj/item/clipboard/yog/paperwork/rd]
  * For the HoS variant, [click here.][/obj/item/clipboard/yog/paperwork/hos]
  * For the Captain variant, [click here.][/obj/item/clipboard/yog/paperwork/captain]
  * For the HoP variant, [click here.][/obj/item/clipboard/yog/paperwork/hop]
  * For the Warden's variant, [click here.][/obj/item/clipboard/yog/paperwork/warden]
  * For the CE's variant, [click here.][/obj/item/clipboard/yog/paperwork/ce]
  * For the CMO's variant, [click here.][/obj/item/clipboard/yog/paperwork/cmo]
  * For security officer's clipboards, [click here.][/obj/item/clipboard/yog/paperwork/security]
  * For the admin variant, [click here.][/obj/item/clipboard/yog/paperwork/admin]
  * 
  */
/obj/item/clipboard/yog/paperwork
	name = "Paperwork"

/**
  * Initializes the RD's clipboard.
  *
  * Initializes the RD's clipboard and gives them the following:
  * [Job Change Certificate][/obj/item/paper/paperwork/jobchangecert]
  * [General Request Form][/obj/item/paper/paperwork/general_request_form]
  * [Complaint Form][/obj/item/paper/paperwork/complaint_form]
  * [Item Request Form][/obj/item/paper/paperwork/item_form]
  * [Research Request Form][/obj/item/paper/paperwork/rd_form]
  * [Mech Request Form][/obj/item/paper/paperwork/mech_form]
  * [Cyborg Consent Form][/obj/item/paper/paperwork/cyborg_request_form]
  * [HoP Access Request Form][/obj/item/paper/paperwork/hopaccessrequestform]
  * [Incident Report Form][/obj/item/paper/paperwork/incident_report]
  * [Literacy Test for NT Employees][/obj/item/paper/paperwork/literacytest]
  */
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
	new /obj/item/paper/paperwork/literacytest(src)
	toppaper = contents[contents.len]
	update_icon()

/**
  * Initializes the Head of Security's clipboard.
  *
  * Initializes the Head of Security's clipboard and gives them the following:
  * [Job Change Certificate][/obj/item/paper/paperwork/jobchangecert]
  * [General Request Form][/obj/item/paper/paperwork/general_request_form]
  * [Complaint Form][/obj/item/paper/paperwork/complaint_form]
  * [Item Request Form][/obj/item/paper/paperwork/item_form]
  * [HoP Access Request Form][/obj/item/paper/paperwork/hopaccessrequestform]
  * [Incident Report Form][/obj/item/paper/paperwork/incident_report]
  * [10 Security Incident Report Forms][/obj/item/paper/paperwork/sec_incident_report]
  */
/obj/item/clipboard/yog/paperwork/hos/Initialize()
	. = ..()
	name = "Paperwork (HoS)"
	new /obj/item/paper/paperwork/jobchangecert(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/item_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/incident_report(src)
	new /obj/item/paper/paperwork/literacytest(src)
	for (var/i in 1 to 10)
		new /obj/item/paper/paperwork/sec_incident_report(src)
	toppaper = contents[contents.len]
	update_icon()

/**
  * Initializes the Captain's clipboard.
  *
  * Initializes the Captain's clipboard and gives them the following:
  * [Job Change Certificate][/obj/item/paper/paperwork/jobchangecert]
  * [General Request Form][/obj/item/paper/paperwork/general_request_form]
  * [Complaint Form][/obj/item/paper/paperwork/complaint_form]
  * [HoP Access Request Form][/obj/item/paper/paperwork/hopaccessrequestform]
  * [Incident Report Form][/obj/item/paper/paperwork/incident_report]
  * [Literacy Test][/obj/item/paper/paperwork/literacytest]
  * [Literacy Test Answer Key][/obj/item/paper/paperwork/literacytest/answers]
  */
/obj/item/clipboard/yog/paperwork/captain/Initialize()
	. = ..()
	name = "Paperwork (Captain)"
	new /obj/item/paper/paperwork/jobchangecert(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/incident_report(src)
	new /obj/item/paper/paperwork/literacytest(src)
	new /obj/item/paper/paperwork/literacytest/answers(src)
	toppaper = contents[contents.len]
	update_icon()

/**
  * Initializes the Head of Personnels clipboard.
  *
  * Initializes the HoP's clipboard and gives them the following:
  * [Job Change Certificate][/obj/item/paper/paperwork/jobchangecert]
  * [General Request Form][/obj/item/paper/paperwork/general_request_form]
  * [Complaint Form][/obj/item/paper/paperwork/complaint_form]
  * [HoP Access Request Form][/obj/item/paper/paperwork/hopaccessrequestform]
  * [HoP Job Change Request Form][/obj/item/paper/paperwork/hop_job_change_form]
  * [Incident Report Form][/obj/item/paper/paperwork/incident_report]
  * [Literacy Test][/obj/item/paper/paperwork/literacytest]
  * [Literacy Test Answer Key][/obj/item/paper/paperwork/literacytest/answers]
  */
/obj/item/clipboard/yog/paperwork/hop/Initialize()
	. = ..()
	name = "Paperwork (HoP)"
	new /obj/item/paper/paperwork/jobchangecert(src)
	new /obj/item/paper/paperwork/general_request_form(src)
	new /obj/item/paper/paperwork/complaint_form(src)
	new /obj/item/paper/paperwork/hopaccessrequestform(src)
	new /obj/item/paper/paperwork/hop_job_change_form(src)
	new /obj/item/paper/paperwork/incident_report(src)
	new /obj/item/paper/paperwork/literacytest(src)
	new /obj/item/paper/paperwork/literacytest/answers(src)
	toppaper = contents[contents.len]
	update_icon()

/**
  * Initializes the Warden's clipboard.
  *
  * Initializes the Warden's clipboard and gives them the following:
  * [General Request Form][/obj/item/paper/paperwork/general_request_form]
  * [Complaint Form][/obj/item/paper/paperwork/complaint_form]
  * [Item Request Form][/obj/item/paper/paperwork/item_form]
  * [HoP Access Request Form][/obj/item/paper/paperwork/hopaccessrequestform]
  * [Incident Report Form][/obj/item/paper/paperwork/incident_report]
  * [10 Security Incident Report Forms][/obj/item/paper/paperwork/sec_incident_report]
  */
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

/**
  * Initializes the Chief Engineer's clipboard.
  *
  * Initializes the Chief Engineer's clipboard and gives them the following:
  * [Job Change Certificate][/obj/item/paper/paperwork/jobchangecert]
  * [General Request Form][/obj/item/paper/paperwork/general_request_form]
  * [Complaint Form][/obj/item/paper/paperwork/complaint_form]
  * [Item Request Form][/obj/item/paper/paperwork/item_form]
  * [HoP Access Request Form][/obj/item/paper/paperwork/hopaccessrequestform]
  * [Incident Report Form][/obj/item/paper/paperwork/incident_report]
  */
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

/**
  * Initializes the Chief Medical Officer's clipboard.
  *
  * Initializes the Chief Medical Officer's clipboard and gives them the following:
  * [Job Change Certificate][/obj/item/paper/paperwork/jobchangecert]
  * [Complaint Form][/obj/item/paper/paperwork/complaint_form]
  * [General Request Form][/obj/item/paper/paperwork/general_request_form]
  * [Item Request Form][/obj/item/paper/paperwork/item_form]
  * [HoP Access Request Form][/obj/item/paper/paperwork/hopaccessrequestform]
  * [Incident Report Form][/obj/item/paper/paperwork/incident_report]
  */
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

/**
  * Initializes security officer clipboards.
  *
  * Initializes security officer clipboards and gives them the following:
  * [10 Security Incident Report Forms][/obj/item/paper/paperwork/sec_incident_report]
  * [10 Incident Report Forms][/obj/item/paper/paperwork/incident_report]
  */
/obj/item/clipboard/yog/paperwork/security/Initialize()
	. = ..()
	for (var/i in 1 to 10)
		new /obj/item/paper/paperwork/sec_incident_report(src)
	for (var/i in 1 to 10)
		new /obj/item/paper/paperwork/incident_report(src)
	toppaper = contents[contents.len]
	update_icon()

/**
  * Initializes the admin variant clipboard.
  *
  * Initializes the admin variant clipboard and provides the following:
  * [General Request Form][/obj/item/paper/paperwork/general_request_form]
  * [Complaint Form][/obj/item/paper/paperwork/complaint_form]
  * [Incident Report Form][/obj/item/paper/paperwork/incident_report]
  * [Security Incident Report Form][/obj/item/paperwork/sec_incident_report]
  * [Item Request Form][/obj/item/paper/paperwork/item_form]
  * [Cyborg Consent Form][/obj/item/paper/paperwork/cyborg_request_form]
  * [HoP Access Request Form][/obj/item/paper/paperwork/hopaccessrequestform]
  * [HoP Job Change Request Form][/obj/item/paper/paperwork/hop_job_change_form]
  * [Research Request Form][/obj/item/paper/paperwork/rd_form]
  * [Mech Request Form][/obj/item/paper/paperwork/mech_form]
  * [Job Change Certificate][/obj/item/paper/paperwork/jobchangecert]
  * [Literacy Test][/obj/item/paper/paperwork/literacytest]
  * [Literacy Test Answer Key][/obj/item/paper/paperwork/literacytest/answers]
  */
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
	new /obj/item/paper/paperwork/literacytest(src)
	new /obj/item/paper/paperwork/literacytest/answers(src)
	toppaper = contents[contents.len]
	update_icon()
//turdis bad
