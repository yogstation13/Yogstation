/obj/item/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	activated = FALSE
	var/lifespan_postmortem = 10 MINUTES //for how long after user death will the implant work?
	var/allow_teleport = TRUE //will people implanted with this act as teleporter beacons?

/obj/item/implant/tracking/tra32
	name = "TRAC implant"
	desc = "A smaller tracking implant that supplies power for only a few minutes."
	var/lifespan = 5 MINUTES //how long does the implant last?
	allow_teleport = FALSE

/obj/item/implant/tracking/tra32/Initialize()
	. = ..()
	QDEL_IN(src, lifespan)

/obj/item/implant/tracking/tra32/emp_act(severity) //Demands to call the severity and I do not care to oppose it
	. = ..()
	Destroy()

/obj/item/implant/tracking/New()
	..()
	GLOB.tracked_implants += src

/obj/item/implant/tracking/Destroy()
	. = ..()
	GLOB.tracked_implants -= src

/obj/item/implanter/tracking
	imp_type = /obj/item/implant/tracking

/obj/item/implanter/tracking/gps
	imp_type = /obj/item/gps/mining/internal

/obj/item/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Tracking Beacon<BR>
				<b>Life:</b> 10 minutes after death of host.<BR>
				<b>Important Notes:</b> Implant also works as a teleporter beacon.<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>
				<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
				circuitry. As a result neurotoxins can cause massive damage."}
	return dat
