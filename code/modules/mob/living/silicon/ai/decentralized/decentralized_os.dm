/datum/ai_os
	var/name = "Decentralized Resource Management System (DRMS)"

	var/total_cpu = 0
	var/total_ram = 0

	var/previous_ram = 0



/datum/ai_os/proc/set_cpu(mob/living/silicon/ai/AI, amount)
/*
	if(!AI)
		return
	if(amount > 1 || amount < 0)
		return
	if(!istype(AI))
		return
	cpu_assigned[AI] = amount

	update_allocations()
*/

/datum/ai_os/proc/add_ram(mob/living/silicon/ai/AI, amount)
/*
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	ram_assigned[AI] += amount

	update_allocations()
*/

/datum/ai_os/proc/remove_ram(mob/living/silicon/ai/AI, amount)
/*
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	if(ram_assigned[AI] - amount < 0)
		ram_assigned[AI] = 0
	else
		ram_assigned[AI] -= amount

	update_allocations()
*/

/datum/ai_os/proc/clear_ai_resources(mob/living/silicon/ai/AI)
/*
	if(!AI || !istype(AI))
		return

	remove_ram(AI, ram_assigned[AI])
	cpu_assigned[AI] = 0

	update_allocations()

*/
