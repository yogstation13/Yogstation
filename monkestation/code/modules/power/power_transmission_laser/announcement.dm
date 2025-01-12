/obj/machinery/power/transmission_laser/proc/send_ptl_announcement()
	/// The message we send
	var/message
	var/flavor_text
	switch(announcement_treshold)
		if(1 MW)
			message = "PTL account successfully made"
			flavor_text = "From now on, you will receive regular updates on the power exported via the onboard PTL. Good luck [station_name()]!"
			// starts giving the station regular updates on the PTL since our station just got an account
			announcement_timer = addtimer(CALLBACK(src, PROC_REF(send_regular_ptl_announcement)), 30 MINUTES, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_LOOP)

		if(1 GW)
			message = "The onboard PTL has successfully exported 1 Gigawatt worth of power"
			flavor_text = "Using the exported power we managed to save a station whose supermatter engine has delamianted, good work!"

		if(1 TW)
			message = "The onboard PTL has successfully exported 1 Terawatt worth of power"
			flavor_text = "You outputted so much power it caused space station 15's powergrid to overload, good work!"

		if(1 PW)
			message = "The onboard PTL has successfully exported 1 Petawatt worth of power"
			flavor_text = "Your onboard PTL is outperforming all Nanotrasen owned solar PTL platforms in your sector. Central Command congratulates you for your achievement."

		if(1 EW)
			message = "The onboard PTL has successfully exported 1 Exawatt worth of power"
			flavor_text = "Using your exported power, a nearby plasma mining outpost has been established without an engine! Keep up the good work, we depend on you!"

		if(1 ZW)
			message = "The onboard PTL has successfully exported 1 Zetawatt worth of power"
			flavor_text = "Thanks to your exported power, we quickly managed to discharge emergency power to our fleet in distress, securing victory against a nearby syndicate ship. Great work!"

		if(1 YW)
			message = "The onboard PTL has successfully exported 1 Yottawatt worth of power"
			flavor_text = "We did not expect your station to export such a high amount of power, and due to that, [rand(1, 3)] of our batteries over-charged and blew up [rand(1, 5)] stations... keep up the good work?"

		if(1 RW)
			message = "The onboard PTL has successfully exported 1 Ronnawatt worth of power"
			flavor_text = "The sheer amount of power you've sent us has successfully BSA'd an entire planet. We will be charging you 50 million credits for that post-shift, as we know you can afford it."

		if(1 QW)
			message = "The onboard PTL has successfully exported 1 Quettawatt worth of power"
			flavor_text = "\
				We have aquired enormous amounts of power thanks to you, making several new mining outposts. \
				We will hold a special medal granting ceremony to your local Chief Engineer. As an added bonus, all engineers part of your crew will be getting a raise once you arrive to CentCom. \
				But please do stop sending power soon, as we cannot hold much more. Consequences will arise if power output continues to be unmoderated.\
			"

		else // should not be achievable because it would require 1+36e power, but for safety reasons lets leave it here
			message = "The onboard PTL has successfully exported extremelly high amounts of power"
			flavor_text = "We ran out of orders of magnitude that are currently categorized, good work!"

	message = "New milestone reached!\n[message]"

	priority_announce(
		sender_override = "[command_name()] energy unit",
		title = "Power Transmission Laser report",
		text = "[message]\n[flavor_text]",
		color_override = "orange",
	)

	announcement_treshold *= 1000


/obj/machinery/power/transmission_laser/proc/send_regular_ptl_announcement()
	// the total_power variable converted into readable amounts of power, because 100.000.000.000.000 was for some reason hard to read
	var/readable_power

	switch(total_power)
		if(1 MW to (1 GW) - 1)
			readable_power = "[total_power / (1 MW)] Megawatts"

		if(1 GW to (1 TW) - 1)
			readable_power = "[total_power / (1 GW)] Gigawatts"

		if(1 TW to (1 PW) - 1)
			readable_power = "[total_power / (1 TW)] Terawatts"

		if(1 PW to (1 EW) - 1)
			readable_power = "[total_power / (1 PW)] Petawatts"

		if(1 EW to INFINITY)
			readable_power = "[total_power / (1 EW)] Exowatts"

	priority_announce(
		sender_override = "[command_name()] energy unit",
		title = "Regular Power Transmission Laser report",
		text = "Total power exported via the PTL: [readable_power]\n\
				Total earnings: [total_earnings] credits",
		color_override = "orange",
	)
