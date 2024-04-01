/area/procedurally_generated/maintenance
	name = "Unfinished Maintenance"
	ambience_index = AMBIENCE_MAINT
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	valid_territory = FALSE
	minimap_color = "#4f4e3a"
	airlock_wires = /datum/wires/airlock/maint
	ambient_buzz = 'sound/ambience/source_corridor2.ogg'
	ambient_buzz_vol = 10
	min_ambience_cooldown = 20 SECONDS
	max_ambience_cooldown = 35 SECONDS

	map_generator = /datum/map_generator/dungeon_generator/maintenance

/area/procedurally_generated/maintenance/department/chapel
	name = "Chapel Maintenance"
	icon_state = "maint_chapel"

/area/procedurally_generated/maintenance/department/chapel/monastery
	name = "Monastery Maintenance"
	icon_state = "maint_monastery"

/area/procedurally_generated/maintenance/department/crew_quarters/bar
	name = "Bar Maintenance"
	icon_state = "maint_bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/procedurally_generated/maintenance/department/crew_quarters/dorms
	name = "Dormitory Maintenance"
	icon_state = "maint_dorms"

/area/procedurally_generated/maintenance/department/eva
	name = "EVA Maintenance"
	icon_state = "maint_eva"

/area/procedurally_generated/maintenance/department/electrical
	name = "Electrical Maintenance"
	icon_state = "maint_electrical"

/area/procedurally_generated/maintenance/department/tcoms
	name = "Telecommunications Maintenance"
	icon_state = "tcomsatmaint"

/area/procedurally_generated/maintenance/department/engine/atmos
	name = "Atmospherics Maintenance"
	icon_state = "maint_atmos"

/area/procedurally_generated/maintenance/department/security
	name = "Security Maintenance"
	icon_state = "maint_sec"

/area/procedurally_generated/maintenance/department/security/brig
	name = "Brig Maintenance"
	icon_state = "maint_brig"

/area/procedurally_generated/maintenance/department/medical
	name = "Medbay Maintenance"
	icon_state = "medbay_maint"

/area/procedurally_generated/maintenance/department/medical/central
	name = "Central Medbay Maintenance"
	icon_state = "medbay_maint_central"

/area/procedurally_generated/maintenance/department/medical/morgue
	name = "Morgue Maintenance"
	icon_state = "morgue_maint"

/area/procedurally_generated/maintenance/department/science
	name = "Science Maintenance"
	icon_state = "maint_sci"

/area/procedurally_generated/maintenance/department/science/central
	name = "Central Science Maintenance"
	icon_state = "maint_sci_central"

/area/procedurally_generated/maintenance/department/cargo
	name = "Cargo Maintenance"
	icon_state = "maint_cargo"

/area/procedurally_generated/maintenance/department/bridge
	name = "Bridge Maintenance"
	icon_state = "maint_bridge"

/area/procedurally_generated/maintenance/department/engine
	name = "Engineering Maintenance"
	icon_state = "maint_engi"

/area/procedurally_generated/maintenance/department/science/xenobiology
	name = "Xenobiology Maintenance"
	icon_state = "xenomaint"
	xenobiology_compatible = TRUE


//Maintenance - Generic

/area/procedurally_generated/maintenance/aft
	name = "Aft (S) Maintenance"
	icon_state = "amaint"

/area/procedurally_generated/maintenance/aft/secondary
	name = "Aft (S) Maintenance"
	icon_state = "amaint_2"

/area/procedurally_generated/maintenance/central
	name = "Central Maintenance"
	icon_state = "maintcentral"

/area/procedurally_generated/maintenance/central/secondary
	name = "Central Maintenance"
	icon_state = "maintcentral"
	clockwork_warp_allowed = FALSE

/area/procedurally_generated/maintenance/fore
	name = "Fore (N) Maintenance"
	icon_state = "fmaint"

/area/procedurally_generated/maintenance/fore/secondary
	name = "Fore (N) Maintenance"
	icon_state = "fmaint_2"

/area/procedurally_generated/maintenance/starboard
	name = "Starboard (E) Maintenance"
	icon_state = "smaint"

/area/procedurally_generated/maintenance/starboard/central
	name = "Central Starboard (E) Maintenance"
	icon_state = "smaint"

/area/procedurally_generated/maintenance/starboard/secondary
	name = "Secondary Starboard (E) Maintenance"
	icon_state = "smaint_2"

/area/procedurally_generated/maintenance/starboard/aft
	name = "Starboard Quarter (SE) Maintenance"
	icon_state = "asmaint"

/area/procedurally_generated/maintenance/starboard/aft/secondary
	name = "Secondary Starboard Quarter (SE) Maintenance"
	icon_state = "asmaint_2"

/area/procedurally_generated/maintenance/starboard/fore
	name = "Starboard Bow (NE) Maintenance"
	icon_state = "fsmaint"

/area/procedurally_generated/maintenance/port
	name = "Port (W) Maintenance"
	icon_state = "pmaint"

/area/procedurally_generated/maintenance/port/central
	name = "Central Port (W) Maintenance"
	icon_state = "maintcentral"

/area/procedurally_generated/maintenance/port/aft
	name = "Port Quarter (SW) Maintenance"
	icon_state = "apmaint"

/area/procedurally_generated/maintenance/port/fore
	name = "Port Bow (NW) Maintenance"
	icon_state = "fpmaint"

/area/procedurally_generated/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/procedurally_generated/maintenance/disposal/incinerator
	name = "Incinerator"
	icon_state = "incinerator"

/area/procedurally_generated/maintenance/the_backrooms
	name = "The Backrooms"
	
