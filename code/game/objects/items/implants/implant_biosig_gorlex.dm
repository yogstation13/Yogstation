/obj/item/implant/biosig_gorlex
	name = "gorlex marauder biosignaller implant"
	desc = "Monitors host vital signs and transmits an encrypted radio message upon death."
	actions_types = null
	verb_say = "broadcasts"
	var/obj/item/radio/radio

/obj/item/implant/biosig_gorlex/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new/obj/item/encryptionkey/syndicate // Should broadcast exclusively on the syndicate channel.
	radio.listening = FALSE
	radio.recalculateChannels()

/obj/item/implant/biosig_gorlex/activate(cause)
	if(!imp_in)
		return FALSE

	// A message from command for the surviving team members.
	var/gorlex_msg = pick(
		"UPHOLD THE MISSION.",
		"CONTINUE YOUR MISSION.",
		"FAILURE IS NOT AN OPTION.",
		"SUCCEED OR DIE TRYING.",
		"LEARN FROM THAT MISTAKE.",
		"COME BACK SUCCESSFUL OR COME BACK IN PIECES.",
		"DO NOT LOSE SIGHT OF THE OBJECTIVE.",
		"DEFEAT DOES NOT GUARANTEE YOUR FAMILY'S SAFETY.",
		"SEE TO IT THAT THE DEED IS DONE.",
		"NO TIME TO MOURN. KEEP AT IT.",
		"LET NO SACRIFICE BE IN VAIN.",
		"THEY WILL NOT HOLD BACK. SHOW THEM NO MERCY.",
		"DO NOT HESITATE. RIP AND TEAR UNTIL IT IS DONE.",
		"THERE IS NO ROOM FOR ERROR. FINISH THE JOB.",
		"THAT'S ONE LESS SHARE OF THE PAY.",
		"GO HARD OR GO HOME DEAD.",
		"GET DAT FUKKEN DISK.")

	// Location.
	var/area/turf = get_area(imp_in)
	// Name of implant user.
	var/mobname = imp_in.name
	// What is to be said.
	var/message = "OPERATIVE NOTICE: AGENT [uppertext(mobname)] EXPLO//N&#@$¤#§>..." // Default message for unexpected causes.
	if(cause == "death")
		message = "OPERATIVE NOTICE: AGENT [uppertext(mobname)] EXPLOSIVE IMPLANT TRIGGERED IN [uppertext(turf.name)]. [gorlex_msg]"


	name = "[mobname]'s Biosignaller"
	radio.talk_into(src, message, RADIO_CHANNEL_SYNDICATE)
	qdel(src) // Single purpose, single use.

/obj/item/implant/biosig_gorlex/on_mob_death(mob/living/L, gibbed)
	if(gibbed)
		activate("gibbed") // Will use default message.
	else
		activate("death")

/obj/item/implant/biosig_gorlex/get_data()
	. = {"<b>Implant Specifications:</b><BR>
		<b>Name:</b>Gorlex Marauder Biosignaller Implant<BR>
		<b>Life:</b>Until death<BR>
		<b>Important Notes:</b>Broadcasts a message to other operatives over an encrypted channel.<BR>
		<HR>
		<b>Implant Details:</b><BR>
    <b>Function:</b>Contains a miniature radio connected to a bioscanner encased in a black, EMP-resistant shell. Broadcasts the death and last known position of the user over an encrypted radio channel.<BR>"}

/obj/item/implanter/biosig_gorlex // Testing/admin purposes; shouldn't be obtainable.
	imp_type = /obj/item/implant/biosig_gorlex
