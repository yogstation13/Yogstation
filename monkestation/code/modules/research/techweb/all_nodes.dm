/datum/techweb_node/cloning
	id = "cloning"
	display_name = "Cloning"
	description = "We have the technology to make him."
	prereq_ids = list("biotech")
	design_ids = list("clonecontrol", "clonepod", "clonescanner", "dnascanner", "dna_disk", "clonepod_experimental")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/////////////////////////Nanites/////////////////////////
/datum/techweb_node/nanite_base
	id = "nanite_base"
	display_name = "Basic Nanite Programming"
	description = "The basics of nanite construction and programming."
	prereq_ids = list("datatheory")
	design_ids = list(
		"access_nanites",
		"debugging_nanites",
		"monitoring_nanites",
		"nanite_chamber",
		"nanite_chamber_control",
		"nanite_cloud_control",
		"nanite_comm_remote",
		"nanite_disk",
		"nanite_program_hub",
		"nanite_programmer",
		"nanite_remote",
		"nanite_scanner",
		"public_nanite_chamber",
		"relay_nanites",
		"relay_repeater_nanites",
		"repairing_nanites",
		"repeater_nanites",
		"sensor_nanite_volume",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/nanite_smart
	id = "nanite_smart"
	display_name = "Smart Nanite Programming"
	description = "Nanite programs that require nanites to perform complex actions, act independently, roam or seek targets."
	prereq_ids = list("nanite_base","robotics")
	design_ids = list(
		"memleak_nanites",
		"metabolic_nanites",
		"purging_nanites",
		"sensor_voice_nanites",
		"stealth_nanites",
		"voice_nanites",
		"research_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)

/datum/techweb_node/nanite_mesh
	id = "nanite_mesh"
	display_name = "Mesh Nanite Programming"
	description = "Nanite programs that require static structures and membranes."
	prereq_ids = list("nanite_base","engineering")
	design_ids = list(
		"conductive_nanites",
		"cryo_nanites",
		"dermal_button_nanites",
		"emp_nanites",
		"hardening_nanites",
		"refractive_nanites",
		"shock_nanites",
		"temperature_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)

/datum/techweb_node/nanite_bio
	id = "nanite_bio"
	display_name = "Biological Nanite Programming"
	description = "Nanite programs that require complex biological interaction."
	prereq_ids = list("nanite_base","biotech")
	design_ids = list(
		"bloodheal_nanites",
		"coagulating_nanites",
		"flesheating_nanites",
		"poison_nanites",
		"regenerative_nanites",
		"sensor_crit_nanites",
		"sensor_damage_nanites",
		"sensor_blood_nanites",
		"sensor_nutrition_nanites",
		"sensor_death_nanites",
		"sensor_health_nanites",
		"sensor_species_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)

/datum/techweb_node/nanite_neural
	id = "nanite_neural"
	display_name = "Neural Nanite Programming"
	description = "Nanite programs affecting nerves and brain matter."
	prereq_ids = list("nanite_bio")
	design_ids = list(
		"bad_mood_nanites",
		"brainheal_nanites",
		"good_mood_nanites",
		"nervous_nanites",
		"paralyzing_nanites",
		"selfscan_nanites",
		"stun_nanites",
		"word_filter_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)

/datum/techweb_node/nanite_synaptic
	id = "nanite_synaptic"
	display_name = "Synaptic Nanite Programming"
	description = "Nanite programs affecting mind and thoughts."
	prereq_ids = list("nanite_neural","neural_programming")
	design_ids = list(
		"blinding_nanites",
		"hallucination_nanites",
		"mindshield_nanites",
		"mute_nanites",
		"pacifying_nanites",
		"sleep_nanites",
		"speech_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)

/datum/techweb_node/nanite_harmonic
	id = "nanite_harmonic"
	display_name = "Harmonic Nanite Programming"
	description = "Nanite programs that require seamless integration between nanites and biology. Passively increases nanite regeneration rate for all clouds upon researching."
	prereq_ids = list("nanite_bio","nanite_smart","nanite_mesh")
	design_ids = list(
		"aggressive_nanites",
		"brainheal_plus_nanites",
		"defib_nanites",
		"fakedeath_nanites",
		"purging_plus_nanites",
		"regenerative_plus_nanites",
		"oxygen_rush_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000, TECHWEB_POINT_TYPE_NANITES = 3000)

/datum/techweb_node/nanite_combat
	id = "nanite_military"
	display_name = "Military Nanite Programming"
	description = "Nanite programs that perform military-grade functions."
	prereq_ids = list("nanite_harmonic", "syndicate_basic")
	design_ids = list(
		"explosive_nanites",
		"meltdown_nanites",
		"nanite_sting_nanites",
		"pyro_nanites",
		"viral_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500, TECHWEB_POINT_TYPE_NANITES = 2500)

/datum/techweb_node/nanite_hazard
	id = "nanite_hazard"
	display_name = "Hazard Nanite Programs"
	description = "Extremely advanced Nanite programs with the potential of being extremely dangerous."
	prereq_ids = list("nanite_harmonic", "alientech")
	design_ids = list(
		"mindcontrol_nanites",
		"mitosis_nanites",
		"spreading_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000, TECHWEB_POINT_TYPE_NANITES = 4000)

/datum/techweb_node/nanite_replication_protocols
	id = "nanite_replication_protocols"
	display_name = "Nanite Replication Protocols"
	description = "Protocols that overwrite the default nanite replication routine to achieve more efficiency in certain circumstances."
	prereq_ids = list("nanite_smart")
	design_ids = list(
		"factory_nanites",
		"kickstart_nanites",
		"offline_nanites",
		"pyramid_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000, TECHWEB_POINT_TYPE_NANITES = 5000)

/datum/techweb_node/nanite_storage_protocols
	id = "nanite_storage_protocols"
	display_name = "Nanite Storage Protocols"
	description = "Protocols that overwrite the default nanite storage routine to achieve more efficiency or greater capacity."
	prereq_ids = list("nanite_smart")
	design_ids = list(
		"free_range_nanites",
		"hive_nanites",
		"unsafe_storage_nanites",
		"zip_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000, TECHWEB_POINT_TYPE_NANITES = 5000)

/datum/techweb_node/adv_ballistics
	id = "adv_ballistics"
	display_name = "Advanced Ballistics"
	description = "The most sophisticated methods of shooting people."
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"mag_autorifle_ap",
		"mag_autorifle_ic",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/linked_surgery
	id = "linked_surgery"
	display_name = "Surgical Serverlink Brain Implant"
	description = "A bluespace implant which a holder can read surgical programs from their server with."
	prereq_ids = list("exp_surgery", "micro_bluespace")
	design_ids = list("linked_surgery")
	boost_item_paths = list(/obj/item/organ/internal/cyberimp/brain/linked_surgery)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)

/datum/techweb_node/ipc_parts
	id = "ipc_parts"
	display_name = "I.P.C Repair Parts"
	description = "Through purchasing licenses to print IPC Parts, we can rebuild our silicon friends, no, not those silicon friends."
	prereq_ids = list("robotics")
	design_ids = list(
		"ipc_head",
		"ipc_chest",
		"ipc_arm_left",
		"ipc_arm_right",
		"ipc_leg_left",
		"ipc_leg_right",
		"power_cord"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)



/datum/techweb_node/bomb_actualizer
	id = "bomb_actualizer"
	display_name = "Bomb Actualization Technology"
	description = "Using bluespace technology we can increase the actual yield of ordinance to their theoretical maximum on station... to disasterous effect."
	prereq_ids = list("micro_bluespace", "bluespace_storage", "practical_bluespace")
	design_ids = list(
		"bomb_actualizer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 20000)

// Maint mods
/datum/techweb_node/springlock
	id = "mod_springlock"
	display_name = "MOD Springlock Module"
	description = "A obsolete module decreasing the sealing time of modsuits. A discarded note from the orginal designs was found. 'Try not to nudge or press against ANY of the spring locks inside the suit. Do not touch the spring lock at any time. Do not breathe on a spring lock, as mouisture may loosen them, and cause them to break loose.'"
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_springlock",
	)

	boost_item_paths = list(
		/obj/item/mod/module/springlock,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	hidden = TRUE

/datum/techweb_node/rave
	id = "mod_rave"
	display_name = "MOD Rave Visor Module"
	description = "Reverse engineering of the Super Cool Awesome Visor for mass production."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_rave",
	)

	boost_item_paths = list(
		/obj/item/mod/module/visor/rave,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	hidden = TRUE

/datum/techweb_node/tanner
	id = "mod_tanner"
	display_name = "MOD Tanning Module"
	description = "Enjoy all the benifets of vitamin D without a lick of starlight touching you."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_tanner",
	)

	boost_item_paths = list(
		/obj/item/mod/module/tanner,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	hidden = TRUE

/datum/techweb_node/balloon
	id = "mod_balloon"
	display_name = "MOD Balloon Blower Module"
	description = "Crack the mimes ancestor's secret of balloon blowing."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_balloon",
	)

	boost_item_paths = list(
		/obj/item/mod/module/balloon,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	hidden = TRUE

/datum/techweb_node/paper_dispenser
	id = "mod_paper_dispenser"
	display_name = "MOD Paper Dispenser Module"
	description = "Become the master of all paperwork, and annoy everyone with ondemand paper airplanes."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_paper_dispenser",
	)

	boost_item_paths = list(
		/obj/item/mod/module/paper_dispenser,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	hidden = TRUE

/datum/techweb_node/stamp
	id = "mod_stamp"
	display_name = "MOD Stamper Module"
	description = "Forgo the ability to forget your stamp at home. Paper pushers of all kinds, rejoyce."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_stamp",
	)

	boost_item_paths = list(
		/obj/item/mod/module/stamp,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	hidden = TRUE

/datum/techweb_node/atrocinator
	id = "mod_atrocinator"
	display_name = "MOD Atrocinator Module"
	description = "With this forgotten innovation things will only be looking up from here once."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_atrocinator",
	)

	boost_item_paths = list(
		/obj/item/mod/module/atrocinator,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	hidden = TRUE

/datum/techweb_node/improved_robotic_tend_wounds
	id = "improved_robotic_surgery"
	display_name = "Improved Robotic Repair Surgeries"
	description = "As it turns out, you don't actually need to cut out entire support rods if it's just scratched!"
	prereq_ids = list("engineering")
	design_ids = list(
		"surgery_heal_robot_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 900)

/datum/techweb_node/advanced_robotic_tend_wounds
	id = "advanced_robotic_surgery"
	display_name = "Advanced Robotic Surgeries"
	description = "Did you know Hephaestus actually has a free online tutorial for synthetic trauma repairs? It's true!"
	prereq_ids = list("improved_robotic_surgery")
	design_ids = list(
		"surgery_heal_robot_upgrade_femto",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1300) // less expensive than the organic surgery research equivalent since its JUST tend wounds
