/mob/living/silicon/ai/Login()
	..()
	if(stat != DEAD)
		for(var/each in GLOB.ai_status_displays) //change status
			var/obj/machinery/status_display/ai/O = each
			O.mode = 1
			O.emotion = "Neutral"
			O.update()
		if(lacks_power() && apc_override) //Placing this in Login() in case the AI doesn't have this link for whatever reason.
			to_chat(usr, "<span class='warning'>Main power is unavailable, backup power in use. Diagnostics scan complete.</span> <A HREF='?src=[REF(src)];emergencyAPC=[TRUE]'>Local APC ready for connection.</A>")
	set_eyeobj_visible(TRUE)
	if(multicam_on)
		end_multicam()
	view_core()
	if(!login_warned_temp)
		to_chat(src, span_userdanger("WARNING. THE WAY AI IS PLAYED HAS CHANGED. PLEASE REFER TO https://github.com/yogstation13/Yogstation/pull/12388"))
		login_warned_temp = TRUE
