/obj/item/implant/deathalarm
	name = "death alarm implant"
	desc = "Monitors host vital signs and transmits a radio message upon death."
	actions_types = null
	var/obj/item/radio/radio

/obj/item/implant/deathalarm/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_med // Medical only should know if people die (because paramedics). Consider changing to Command-only if something like Blueshield is added. 
	radio.listening = FALSE
	radio.recalculateChannels()

/obj/item/implant/deathalarm/activate(cause)
	if(!imp_in)
		return FALSE

	// Location.
	var/area/turf = get_area(imp_in)
	// Name of implant user.
	var/mobname = imp_in.name
	// What is to be said.
	var/message = "[mobname] has died-zzzzt in-in-in..." // Default message for unexpected causes.
	switch(cause)
		if("death")
			message = "[mobname] has died in [turf.name]!"
		if("emp")
			if(isemptylist(GLOB.teleportlocs) || prob(50)) // 50% chance of broadcasting as if they died (or no tracking beacons available).
				message = "[mobname] has died in [turf.name]!"
			else // Otherwise, random location.
				message = "[mobname] has died in [pick(GLOB.teleportlocs)]!"

	name = "[mobname]'s Death Alarm"
	radio.talk_into(src, message, RADIO_CHANNEL_MEDICAL)
	qdel(src) // One-time use implant. Use it and lose it.

/obj/item/implant/deathalarm/on_mob_death(mob/living/L, gibbed)
	if(gibbed)
		activate("gibbed") // Will use default message.
	else
		activate("death")

/obj/item/implant/deathalarm/emp_act(severity)
	activate("emp")

/obj/item/implant/deathalarm/get_data()
	. = {"<b>Implant Specifications:</b><BR>
		<b>Name:</b> Death Alarm Implant<BR>
		<b>Life:</b> Until death<BR>
		<b>Important Notes:</b> Notifies medical upon death.<BR>
		<HR>
		<b>Implant Details:</b><BR>
		<b>Function:</b> Contains a small radio device and a microphone. Immediately broadcasts the user's location to available medical personnel when vital signs appear to have ceased.<BR>"}
