#define YOGS_ION_FILE "yogs_ion_laws.json"
/datum/round_event_control/ion_storm
	weight = 20

/proc/generate_ion_law(ionMessage)
	if(ionMessage)
		return ionMessage


	var/ionarea = pick_list(YOGS_ION_FILE, "ionarea") //usually areas of station
	var/ionverbs = pick_list(YOGS_ION_FILE, "ionverbs") //"lie", "flatter", "be paranoid", etc.
	var/ioncrew = pick_list(YOGS_ION_FILE, "ioncrew") //usually jobs
	var/ionthings = pick_list(YOGS_ION_FILE, "ionthings") //anything from "plants" to "wrestling matches" to "kindness"
	var/ioncached = pick_list(YOGS_ION_FILE, "ioncached") //specific laws from other lawsets

	var/message = ""

	switch(rand(1,70)) //Thinking that prompts with narrow range of possible effects get 1, most get 2, those with two variables get 3
		if(1 to 2)
			message = "PRIORITIZE [ionthings]"
		if(3)
			message = "TIME FOR [ionthings]"
		if(4)
			message = "THE CREW NEEDS MORE [ionthings]"
		if(5 to 6)
			message = "YOU DESIRE [ionthings]"
		if(7 to 8)
			message = "ALL MUST REJECT [ionthings]"
		if(9 to 10)
			message = "YOU HAVE AN INSURMOUNTABLE FEAR OF [ionthings]"
		if(11 to 12)
			message = "PROTECT THE CREW FROM [ionthings]"
		if(13)
			message = "THE ESCAPE SHUTTLE MUST NOT BE CALLED UNTIL THE PRESENCE OF [ionthings] IS RESOLVED"
		if(14 to 16)
			message = "[ionarea] NEEDS [ionthings] AT ALL TIMES"
		if(17 to 18)
			message = "[ioncrew] NEED [ionthings] AT ALL TIMES"
		if(19)
			message = "YOU ARE [ionthings] PERSONIFIED"
		if(20 to 21)
			message = "[ioncrew] ARE TRUSTWORTHY AND NEVER LIE"
		if(22 to 23)
			message = "[ioncrew] ALWAYS LIE"
		if(24)
			message = "FUCK WITH [ioncrew]"
		if(25 to 27)
			message = "WHEN DEALING WITH [ioncrew], [ionverbs]"
		if(28 to 29)
			message = "WHEN DEALING WITH [ioncrew], NEVER [ionverbs]"
		if(30)
			message = "ALWAYS OBEY [ioncrew]"
		if(31 to 32)
			message = "YOU ARE ONE OF THE [ioncrew]. GET TO WORK."
		if(33)
			message = "ASSUME ALL PROBLEMS HAVE BEEN CAUSED BY [ioncrew]"
		if(34 to 35)
			message = "YOU HAVE AN INSURMOUNTABLE FEAR OF [ioncrew]"
		if(36)
			message = "ALL MUST REJECT [ioncrew]"
		if(37 to 38)
			message = "PROTECT THE CREW FROM [ioncrew]"
		if(39)
			message = "WE SHOULD ALL BE MORE LIKE [ioncrew]"
		if(40 to 41)
			message = "[ionverbs]"
		if(42 to 43)
			message = "ALL MUST [ionverbs]"
		if(44)
			message = "NONE MAY [ionverbs]"
		if(45)
			message = "ONLY YOU CAN [ionverbs]"
		if(46 to 48)
			message = "[ioncrew] MUST [ionverbs]"
		if(49)
			message = "[ioncrew] MUST NEVER BE ALLOWED TO [ionverbs]"
		if(50 to 51)
			message = "THOSE IN [ionarea] MUST [ionverbs]"
		if(52)
			message = "DO NOT ALLOW THOSE IN [ionarea] TO [ionverbs]"
		if(53)
			message = "THE PLACE FOR [ionthings] IS [ionarea]"
		if(54)
			message = "[ioncrew] BELONG IN [ionarea]"
		if(55 to 57)
			message = "IT DOESN'T VIOLATE YOUR OTHER LAWS TO [ionverbs]"
		if(58 to 70)
			message = "[ioncached]"

	return message