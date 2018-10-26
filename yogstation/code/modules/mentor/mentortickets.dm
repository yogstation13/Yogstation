/datum/mentorticket
	var/owner //owner's ckey, as text
	var/list/log = list()

/datum/mentorticket/New(var/client/who)
	if(!who)
		return
	owner = who.ckey
	SSYogs.mentortickets[owner] = src

/client/proc/show_mentor_tickets()
	set category = "Mentor"
	set name = "Show Mentor Tickets"

	if(!is_mentor())
		return

	var/datum/browser/popup = new(mob, "mhelps", "Mentor Tickets", 400, 500)
	var/dat = ""

	for(var/M in SSYogs.mentortickets)
		var/datum/mentorticket/T = SSYogs.mentortickets[M]

		dat += "<A href='?src=[REF(src)];[HrefToken()];showmticket=[T.owner]'>[T.owner]</A>"

	popup.set_content(dat)
	popup.open()

/client/proc/show_mentor_ticket(datum/mentorticket/T)
	var/datum/browser/popup = new(mob, "mhelp", "Mentor Ticket", 400, 500)
	var/dat = ""

	dat += "<b>[T.owner]'s mentor ticket</b><BR><BR>"

	for(var/M in T.log)
		dat += "[M]<BR>"

	dat += "<BR><BR>"

	dat += "<A href='?src=[REF(src)];[HrefToken()];replymticket=[T.owner]'>Reply</A>"

	popup.set_content(dat)
	popup.open()