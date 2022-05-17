/datum/ai_project/memory_compressor
	name = "Memory Compressor"
	description = "Using an advanced compression algorithm it should be possible to compress memory dedicated to our kernel. This should increase our available RAM by 3TB. Requires 15% available CPU."
	category = AI_PROJECT_EFFICIENCY
	
	research_cost = 2500
	

/datum/ai_project/memory_compressor/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.free_ram += 3
	ai.cpu_usage[name] = 0.15

/datum/ai_project/memory_compressor/stop()
	ai.free_ram -= 3
	ai.cpu_usage[name] = 0
	..()

/datum/ai_project/memory_compressor/canRun()
	var/total_cpu_used = 0
	for(var/I in ai.cpu_usage)
		total_cpu_used += ai.cpu_usage[I]
	if(total_cpu_used < 0.85)
		return TRUE
	to_chat(ai, span_warning("Unable to run this program. You require 15% free CPU!"))
