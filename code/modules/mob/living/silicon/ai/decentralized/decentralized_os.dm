GLOBAL_DATUM_INIT(ai_os, /datum/ai_os, new)

/datum/ai_os
	var/name = "Decentralized Resource Management System (DRMS)"

	var/total_cpu = 0

	var/total_ram = 0

	var/previous_cpu = 0
	var/previous_ram = 0

	var/list/cpu_assigned
	var/list/ram_assigned

/datum/ai_os/New()
	update_hardware()
	cpu_assigned = list()
	ram_assigned = list()

/datum/ai_os/proc/remove_ai(mob/living/silicon/ai/AI)
	cpu_assigned.Remove(AI)
	ram_assigned.Remove(AI)


/datum/ai_os/proc/total_cpu_assigned()
	var/total = 0
	for(var/N in cpu_assigned)
		total += cpu_assigned[N]
	return total

/datum/ai_os/proc/total_ram_assigned()
	var/total = 0
	for(var/N in ram_assigned)
		total += ram_assigned[N]
	return total

/datum/ai_os/proc/update_hardware()
	previous_cpu = total_cpu
	previous_ram = total_ram
	total_cpu = 0
	total_ram = 0
	for(var/obj/machinery/ai/expansion_card_holder/C in GLOB.expansion_card_holders)
		if(!C.valid_holder() && !C.roundstart)
			continue
		for(var/CARD in C.installed_cards)
			if(istype(CARD, /obj/item/processing_card))
				var/obj/item/processing_card/PC = CARD
				total_cpu += PC.tier
			if(istype(CARD, /obj/item/memory_card))
				var/obj/item/memory_card/MC = CARD
				total_ram += MC.tier
	
	update_allocations()

/datum/ai_os/proc/update_allocations()
	if(total_cpu >= previous_cpu && total_ram >= previous_ram)
		return
	
	var/list/ram_removal = list()
	var/list/cpu_removal = list()

	var/list/affected_AIs = list()

	var/iterator = 1
	if(total_cpu < previous_cpu)
		while(total_cpu < previous_cpu)
			iterator++
			if(iterator >= 10)
				if(!GLOB.sent_crash_message)
					GLOB.sent_crash_message = TRUE
					log_game("Averted crash in os-cpu loop. Following vars used: total_cpu: [total_cpu], previous_cpu: [previous_cpu], cpu_assigned length: [cpu_assigned.len]")
					var/list/adm = get_admin_counts(R_BAN)
					var/list/allmins = adm["total"]
					if(!allmins.len)
						to_chat(world, "<span class='adminnotice'><b>Server Announces:</b></span>\n \t <h2> Please show this to Bibby: \
						 Averted crash in os-cpu loop. Following vars used: total_cpu: [total_cpu], previous_cpu: [previous_cpu], cpu_assigned length: [cpu_assigned.len]</h2>")
					else
						message_admins("<h3>Averted crash in os-cpu loop. Following vars used: total_cpu: [total_cpu], previous_cpu: [previous_cpu], cpu_assigned length: [cpu_assigned.len]</h3>")
				break
			var/mob/living/silicon/ai/AI = pick(GLOB.ai_list)
			if(cpu_assigned[AI] >= 1)
				cpu_removal[AI]++
				previous_cpu--
			
	iterator = 1
	if(total_ram < previous_ram)
		while(total_ram < previous_ram)
			iterator++
			if(iterator >= 10)
				if(!GLOB.sent_crash_message)
					GLOB.sent_crash_message = TRUE
					log_game("Averted crash in os-ram loop. Following vars used: total_ram: [total_ram], previous_ram: [previous_ram], ram_assigned length: [ram_assigned.len]")
					var/list/adm = get_admin_counts(R_BAN)
					var/list/allmins = adm["total"]
					if(!allmins.len)
						to_chat(world, "<span class='adminnotice'><b>Server Announces:</b></span>\n \t <h2> Please show this to Bibby: \
						 Averted crash in os-ram loop. Following vars used: total_ram: [total_ram], previous_ram: [previous_ram], ram_assigned length: [ram_assigned.len]</h2>")
					else
						message_admins("<h3>Averted crash in os-ram loop. Following vars used: total_ram: [total_ram], previous_ram: [previous_ram], ram_assigned length: [ram_assigned.len]</h3>")
				break
			var/mob/living/silicon/ai/AI = pick(GLOB.ai_list)
			if(ram_assigned[AI] >= 1)
				ram_removal[AI]++
				previous_ram--
	
	for(var/A in ram_removal)
		ram_assigned[A] = ram_assigned[A] - ram_removal[A]
		affected_AIs |= A

	for(var/A in cpu_removal)
		cpu_assigned[A] = cpu_assigned[A] - cpu_removal[A]
		affected_AIs |= A
	
	to_chat(affected_AIs, "<span class='warning'>You have been deducted processing capabilities. Please contact your network administrator if you believe this to be an error.</span>")


/datum/ai_os/proc/add_cpu(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	cpu_assigned[AI] += amount

	update_allocations()

/datum/ai_os/proc/remove_cpu(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	cpu_assigned[AI] -= amount

	update_allocations()

/datum/ai_os/proc/add_ram(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	ram_assigned[AI] += amount

	update_allocations()

/datum/ai_os/proc/remove_ram(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	ram_assigned[AI] -= amount

	update_allocations()


/datum/ai_os/proc/clear_ai_resources(mob/living/silicon/ai/AI)
	if(!AI || !istype(AI))
		return

	remove_ram(AI, ram_assigned[AI])
	remove_cpu(AI, cpu_assigned[AI])

	update_allocations()
