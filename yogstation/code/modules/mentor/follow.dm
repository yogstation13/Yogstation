/client/proc/mentor_follow(mob/living/M)
	if(!is_mentor())
		return

	if(isnull(M))
		return

	if(!ismob(usr))
		return

	if(check_rights(R_ADMIN, FALSE)) // If they're an admin, then just do an aghost (the FALSE marks that it shouldn't yell about not being admin)
		//Basically a copy of Yogstation\code\modules\admin\topic.dm, line 960, from 24 Feb 2019
		if(!isobserver(usr))
			admin_ghost()
		var/mob/dead/observer/A = mob
		var/mob/living/silicon/ai/I = M
		if(istype(I) && I.eyeobj)
			A.ManualFollow(I.eyeobj)
		else
			A.ManualFollow(M)
		return
		
	usr.reset_perspective(M)
	add_verb(src, /client/proc/mentor_unfollow)
	if(mentor_datum)
		mentor_datum.following = M

	to_chat(GLOB.permissions.admins, span_mentor("[span_prefix("MENTOR:")] <EM>[key_name(usr)]</EM> is now following <EM>[key_name(M)]"), confidential=TRUE)
	to_chat(usr, span_info("Click the \"Stop Following\" button in the Mentor tab to stop following [key_name(M)]."), confidential=TRUE)
	log_mentor("[key_name(usr)] began following [key_name(M)]")

/client/proc/mentor_unfollow()
	set category = "Mentor"
	set name = "Stop Following"
	set desc = "Stop following the followed."

	if(!is_mentor())
		return

	usr.reset_perspective()
	remove_verb(src, /client/proc/mentor_unfollow)
	if(mentor_datum)
		to_chat(GLOB.permissions.admins, span_mentor("[span_prefix("MENTOR:")] <EM>[key_name(usr)]</EM> is no longer following <EM>[key_name(mentor_datum.following)]"), confidential=TRUE)
		log_mentor("[key_name(usr)] stopped following [key_name(mentor_datum.following)]")
		
		mentor_datum.following = null
