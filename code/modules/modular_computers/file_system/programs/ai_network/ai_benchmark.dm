/datum/computer_file/program/ai/benchmark
	filename = "aibenchmark"
	filedesc = "Network Benchmarking Tool"

	program_icon_state = "power_monitor"
	extended_desc = "This program connects to a historical NT records and compares them with the local network."
	ui_header = "power_norm.gif"

	size = 4
	tgui_id = "NtosAIBenchmark"
	program_icon = "network-wired"
	available_on_ntnet = TRUE

/datum/computer_file/program/ai/benchmark/ui_data(mob/user)
	var/list/data = ..()

	if(!data["has_ai_net"])
		return data

	var/datum/ai_network/net = data["has_ai_net"]

	data["total_cpu"] = net.resources.total_cpu()
	data["total_ram"] = net.resources.total_ram()

	data["ram_records"] = SSpersistence.ai_network_rankings["ram"]
	data["cpu_records"] = SSpersistence.ai_network_rankings["cpu"]

	return data
