/area/awaymission/vr/scientist_raid
	name = "Small Abandoned Station"
	icon_state = "awaycontent3"

/obj/item/paper/fluff/awaymissions/scientist_raid/report1
	name = "Adaptive Neural Networks - Research Report"
	info = "While these types of networks seem to be well-suited for our needs, the current processing technology doesn't seem able to simulate them quickly enough. More research is needed.."

/obj/item/paper/fluff/awaymissions/scientist_raid/report2
	name = "Captive Organic Neurons - Research Report"
	info = "A new scientific article has piqued my interest. A Cybersun Industries biologist seems to have extracted useable responses from lab-grown neurons. Although the experiment was small-scale it seems promising.."

/obj/item/paper/fluff/awaymissions/scientist_raid/report3
	name = "Personnel Requisition Order"
	info = "I require additional low-level personnel to maintain the station. Primarily janitors and low-level engineers. Due to the distance to the station they should preferably have minimal family and social contacts."

/obj/item/paper/fluff/awaymissions/scientist_raid/report4
	name = "Deep Tissue Neuron Control"
	info = "Further research reveals that using invasive surgical procedures it is possible to influence and digitally mirror the actions of individual neurons. Preliminary results show a 1251.83x performance improvement compared to traditional neural networks."

/obj/item/paper/crumpled/bloody/fluff/awaymissions/scientist_raid/report5
	name = "hastily scribbled note"
	info = "Forgive me for what I have done... Corporate goons are knocking down the door to my room, it seems they've caught on to my... unique ways of researching. I've hidden my last prototype in my safe. To anyone reading this, please carry on my research. The code to the safe is 7295"

/obj/item/ai_cpu/organic
	name = "experimental organic neural processing unit"
	desc = "A half-machine half-human chip built by a mad scientist. Capable of processing immense amounts of data, at the expense of the sacrifice of the sanity of the consciousness contained within.."
	icon_state = "cpuboard_adv"

	speed = 12
	base_power_usage = 4 * AI_CPU_BASE_POWER_USAGE

	minimum_max_power = 1.1
	maximum_max_power = 2.6

	minimum_growth = 1 
	maximum_growth = 4

/obj/item/storage/secure/safe/scientist_raid
	name = "secure safe"

/obj/item/storage/secure/safe/scientist_raid/Initialize(mapload)
	. = ..()
	l_code = "7295"
	l_set = TRUE
	new /obj/item/ai_cpu/organic(src)
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)
	cut_overlays()
	
