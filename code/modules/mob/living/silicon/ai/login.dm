/mob/living/silicon/ai/Login()
	..()
	if(stat != DEAD)
		for(var/each in GLOB.ai_status_displays) //change status
			var/obj/machinery/status_display/ai/O = each
			O.mode = 1
			O.emotion = "Neutral"
			O.update()
	set_eyeobj_visible(TRUE)
	if(multicam_on)
		end_multicam()
	view_core()
	if(!login_warned_temp)
		to_chat(src, span_userdanger("WARNING. THE WAY AI IS PLAYED HAS CHANGED. PLEASE REFER TO https://github.com/yogstation13/Yogstation/pull/12388"))
		login_warned_temp = TRUE
