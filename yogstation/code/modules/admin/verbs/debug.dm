/client/proc/callproc_datum_fast(datum/A as null|area|mob|obj|turf)
	set category = "Debug"
	set name = "Fast ProcCall"
	set waitfor = 0

	if(!check_rights(R_DEBUG))
		return

	var/procstring = input("Proc call, eg: \"vomit(0, 1, 0, 5)\"","Proc:", null) as text|null
	if(!procstring)
		return
	var/regex/procname_regex = regex("^(\[a-zA-z\]+)(?=\\()")
	var/has_procname = procname_regex.Find(procstring)
	if(!has_procname)
		to_chat(usr, "<font color='red'>Error: Fast ProcCall: Could not parse function name in [procstring].</font>")
		return
	var/procname = procname_regex.group[1]
	if(!hascall(A,procname))
		to_chat(usr, "<font color='red'>Error: Fast ProcCall: Type [A.type] has no proc named [procname].</font>")
		return

	var/regex/pain = regex("(\"(\[^"\\\\\]*(?:\\\\.\[^\"\\\\\]*)*)"|\\d+)")
	pain.Find(procstring)
	var/list/arguments = list()

	for(var/i=1 to pain.group.len)
		var
	if(!A || !IsValidSrc(A))
		to_chat(usr, "<span class='warning'>Error: callproc_datum(): owner of proc no longer exists.</span>")
		return
	log_admin("[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
	var/msg = "[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
	message_admins(msg)
	admin_ticket_log(A, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Atom ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
	. = get_callproc_returnval(returnval,procname)
	if(.)
		to_chat(usr, .)