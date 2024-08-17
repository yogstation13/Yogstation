/datum/round_event_control/weightless
	name = "Gravity Systems Failure"
	typepath = /datum/round_event/weightless
	weight = 15

/datum/round_event/weightless
	start_when = 5
	end_when = 165
	announce_when = 1

/datum/round_event/weightless/setup()
	start_when = rand(0,10)
	end_when = rand(80,120)

/datum/round_event/weightless/announce()
	priority_announce("Warning: Failsafes for the station's artificial gravity arrays have been triggered. Please be aware that if this problem recurs it may result in formation of gravitational anomalies. Nanotrasen wishes to remind you that the unauthorised formation of anomalies within Nanotrasen facilities is strictly prohibited by health and safety regulation [rand(99,9999)][pick("a","b","c")]:subclause[rand(1,20)][pick("a","b","c")].")

/datum/round_event/weightless/start()
	for(var/obj/machinery/gravity_generator/main/station/A in GLOB.machines)
		if(A)
			A.disable()

/datum/round_event/weightless/end()
	for(var/obj/machinery/gravity_generator/main/station/A in GLOB.machines)
		if(A)
			if(control && A.on)
				control.weight *= 2	
			A.enable()
	if(announce_when >= 0)
		priority_announce("Artificial gravity arrays are now functioning within normal parameters. Please report any irregularities to your respective head of staff.")
