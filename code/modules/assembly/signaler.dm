/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices. Allows for syncing when using a secure signaler on another."
	icon_state = "signaller"
	item_state = "signaler"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	materials = list(/datum/material/iron=400, /datum/material/glass=120)
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE
	attachable = TRUE
	var/code = DEFAULT_SIGNALER_CODE
	var/frequency = FREQ_SIGNALER
	var/delay = 0
	var/datum/radio_frequency/radio_connection
	var/suicider = null
	var/hearing_range = 1

/obj/item/assembly/signaler/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] eats \the [src]! If it is signaled, [user.p_they()] will die!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	user.transferItemToLoc(src, user, TRUE)
	suicider = user
	return MANUAL_SUICIDE_NONLETHAL

/obj/item/assembly/signaler/proc/manual_suicide(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user]'s [src] receives a signal, killing [user.p_them()] instantly!</span>")
	user.adjustOxyLoss(200)//it sends an electrical pulse to their heart, killing them. or something.
	user.death(0)
	user.set_suicide(TRUE)
	user.suicide_log()

/obj/item/assembly/signaler/Initialize()
	. = ..()
	set_frequency(frequency)


/obj/item/assembly/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	. = ..()

/obj/item/assembly/signaler/activate()
	if(!..())//cooldown processing
		return FALSE
	signal()
	return TRUE

/obj/item/assembly/signaler/update_icon()
	if(holder)
		holder.update_icon()
	return

/obj/item/assembly/signaler/ui_status(mob/user)
	if(is_secured(user))
		return ..()
	return UI_CLOSE

/obj/item/assembly/signaler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Signaler", name)
		ui.open()

/obj/item/assembly/signaler/ui_data(mob/user)
	var/list/data = list()
	data["frequency"] = frequency
	data["code"] = code
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	data["color"] = label_color

	return data

/obj/item/assembly/signaler/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("signal")
			INVOKE_ASYNC(src, .proc/signal)
			. = TRUE
		if("freq")
			frequency = unformat_frequency(params["freq"])
			frequency = sanitize_frequency(frequency, TRUE)
			set_frequency(frequency)
			. = TRUE
		if("code")
			code = text2num(params["code"])
			code = round(code)
			. = TRUE
		if("reset")
			if(params["reset"] == "freq")
				frequency = initial(frequency)
			else
				code = initial(code)
			. = TRUE
		if("color")
			var/idx = label_colors.Find(label_color)
			if(idx == label_colors.len || idx == 0)
				idx = 1
			else
				idx++
			label_color = label_colors[idx]
			update_icon()

	update_icon()

/obj/item/assembly/signaler/attackby(obj/item/W, mob/user, params)
	if(issignaler(W))
		var/obj/item/assembly/signaler/signaler2 = W
		if(secured && signaler2.secured)
			code = signaler2.code
			set_frequency(signaler2.frequency)
			// yogs start - signaller colors
			label_color = signaler2.label_color
			update_icon()
			// yogs end
			to_chat(user, "You transfer the frequency and code of \the [signaler2.name] to \the [name]")
	..()

/obj/item/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/datum/signal/signal = new(list("code" = code))
	radio_connection.post_signal(src, signal)

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	if(usr)
		GLOB.lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")

/obj/item/assembly/signaler/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return
	if(suicider)
		manual_suicide(suicider)
	pulse(TRUE)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*", null, hearing_range)
	for(var/CHM in get_hearers_in_view(hearing_range, src))
		if(ismob(CHM))
			var/mob/LM = CHM
			LM.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	return TRUE


/obj/item/assembly/signaler/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
	return

// Embedded signaller used in grenade construction.
// It's necessary because the signaler doens't have an off state.
// Generated during grenade construction.  -Sayu
/obj/item/assembly/signaler/receiver
	var/on = FALSE

/obj/item/assembly/signaler/receiver/proc/toggle_safety()
	on = !on

/obj/item/assembly/signaler/receiver/activate()
	toggle_safety()
	return TRUE

/obj/item/assembly/signaler/receiver/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The radio receiver is [on?"on":"off"].</span>"

/obj/item/assembly/signaler/receiver/receive_signal(datum/signal/signal)
	if(!on)
		return
	return ..(signal)


// Embedded signaller used in anomalies.
/obj/item/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly core"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	resistance_flags = FIRE_PROOF
	var/anomaly_type = /obj/effect/anomaly

/obj/item/assembly/signaler/anomaly/receive_signal(datum/signal/signal)
	if(!signal)
		return FALSE
	if(signal.data["code"] != code)
		return FALSE
	if(suicider)
		manual_suicide(suicider)
	for(var/obj/effect/anomaly/A in get_turf(src))
		A.anomalyNeutralize()
	return TRUE

/obj/item/assembly/signaler/anomaly/manual_suicide(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user]'s [src] is reacting to the radio signal, warping [user.p_their()] body!</span>")
	user.set_suicide(TRUE)
	user.suicide_log()
	user.gib()

/obj/item/assembly/signaler/anomaly/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, "<span class='notice'>Analyzing... [src]'s stabilized field is fluctuating along frequency [format_frequency(frequency)], code [code].</span>")
	..()

/obj/item/assembly/signaler/anomaly/attack_self()
	return

/obj/item/assembly/signaler/cyborg

/obj/item/assembly/signaler/cyborg/attackby(obj/item/W, mob/user, params)
	return
/obj/item/assembly/signaler/cyborg/screwdriver_act(mob/living/user, obj/item/I)
	return