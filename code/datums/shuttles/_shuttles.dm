/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/shuttles/"
	var/suffix
	/**
	 * Port ID is the place this template should be docking at, set on '/obj/docking_port/stationary'
	 * Because getShuttle() compares port_id to shuttle_id to find an already existing shuttle,
	 * you should set shuttle_id to be the same as port_id if you want them to be replacable.
	 */
	var/port_id
	/// ID of the shuttle, make sure it matches port_id if necessary.
	var/shuttle_id
	/// Information to display on communication console about the shuttle
	var/description
	/// The recommended occupancy limit for the shuttle (count chairs, beds, and benches then round to 5)
	var/occupancy_limit
	/// Description of the prerequisition that has to be achieved for the shuttle to be purchased
	var/prerequisites
	/// Shuttle warnings and hazards to the admin who spawns the shuttle
	var/admin_notes
	/// How much does this shuttle cost the cargo budget to purchase? Put in terms of CARGO_CRATE_VALUE to properly scale the cost with the current balance of cargo's income.
	var/credit_cost = INFINITY
	/// What job accesses can buy this shuttle? If null, this shuttle cannot be bought.
	var/list/who_can_purchase = list(ACCESS_CAPTAIN)
	/// Whether or not this shuttle is locked to emags only.
	var/emag_only = FALSE
	/// If set, overrides default movement_force on shuttle
	var/list/movement_force

	var/port_x_offset
	var/port_y_offset
	var/extra_desc = ""

/datum/map_template/shuttle/proc/prerequisites_met()
	return TRUE

/datum/map_template/shuttle/New()
	shuttle_id = "[port_id]_[suffix]"
	mappath = "[prefix][shuttle_id].dmm"
	. = ..()

/datum/map_template/shuttle/preload_size(path, cache)
	. = ..(path, TRUE) // Done this way because we still want to know if someone actualy wanted to cache the map
	if(!cached_map)
		return

	var/offset = discover_offset(/obj/docking_port/mobile)

	port_x_offset = offset[1]
	port_y_offset = offset[2]

	if(!cache)
		cached_map = null

/datum/map_template/shuttle/load(turf/T, centered, register=TRUE)
	. = ..()
	if(!.)
		return
	var/list/turfs = block( locate(.[MAP_MINX], .[MAP_MINY], .[MAP_MINZ]),
							locate(.[MAP_MAXX], .[MAP_MAXY], .[MAP_MAXZ]))
	for(var/i in 1 to turfs.len)
		var/turf/place = turfs[i]
		if(isspaceturf(place)) // This assumes all shuttles are loaded in a single spot then moved to their real destination.
			continue

		if (place.count_baseturfs() < 2) // Some snowflake shuttle shit
			continue

		place.insert_baseturf(3, /turf/baseturf_skipover/shuttle)

		for(var/obj/docking_port/mobile/port in place)
			port.calculate_docking_port_information(src)
			// initTemplateBounds explicitly ignores the shuttle's docking port, to ensure that it calculates the bounds of the shuttle correctly
			// so we need to manually initialize it here
			SSatoms.InitializeAtoms(list(port))
			if(register)
				port.register()

//Whatever special stuff you want
/datum/map_template/shuttle/post_load(obj/docking_port/mobile/M)
	if(movement_force)
		M.movement_force = movement_force.Copy()
	M.linkup()

/datum/map_template/shuttle/cargo
	port_id = "cargo"
	name = "Base Shuttle Template (Cargo)"
	who_can_purchase = null

/datum/map_template/shuttle/ferry
	port_id = "ferry"
	name = "Base Shuttle Template (Ferry)"

/datum/map_template/shuttle/whiteship
	port_id = "whiteship"
	who_can_purchase = null

/datum/map_template/shuttle/labour
	port_id = "labour"
	who_can_purchase = null

/datum/map_template/shuttle/mining
	port_id = "mining"
	who_can_purchase = null

/datum/map_template/shuttle/arrival
	port_id = "arrival"
	who_can_purchase = null

/datum/map_template/shuttle/infiltrator
	port_id = "infiltrator"

/datum/map_template/shuttle/aux_base
	port_id = "aux_base"

/datum/map_template/shuttle/escape_pod/
	port_id = "escape_pod"
	suffix = "1"
	who_can_purchase = null

/datum/map_template/shuttle/escape_pod/two
	suffix = "2"

/datum/map_template/shuttle/escape_pod/three
	suffix = "3"

/datum/map_template/shuttle/escape_pod/four
	suffix = "4"

/datum/map_template/shuttle/assault_pod
	port_id = "assault_pod"
	who_can_purchase = null

/datum/map_template/shuttle/pirate
	port_id = "pirate"
	who_can_purchase = null

/datum/map_template/shuttle/hunter
	port_id = "hunter"
	who_can_purchase = null

/datum/map_template/shuttle/ruin //For random shuttles in ruins
	port_id = "ruin"
	who_can_purchase = null

/datum/map_template/shuttle/snowdin
	port_id = "snowdin"
	who_can_purchase = null

// Shuttles start here:

/datum/map_template/shuttle/ferry/base
	suffix = "base"
	name = "transport ferry"
	description = "Standard issue Box/Metastation CentCom ferry."

/datum/map_template/shuttle/ferry/meat
	suffix = "meat"
	name = "\"meat\" ferry"
	description = "Ahoy! We got all kinds o' meat aft here. Meat from plant people, people who be dark, not in a racist way, just they're dark black. \
	Oh and lizard meat too,mighty popular that is. Definitely 100% fresh, just ask this guy here. *person on meatspike moans* See? \
	Definitely high quality meat, nothin' wrong with it, nothin' added, definitely no zombifyin' reagents!"
	admin_notes = "Meat currently contains no zombifying reagents, lizard on meatspike must be spawned in."

/datum/map_template/shuttle/ferry/lighthouse
	suffix = "lighthouse"
	name = "The Lighthouse(?)"
	description = "*static*... part of a much larger vessel, possibly military in origin. \
	The weapon markings aren't anything we've seen ...static... by almost never the same person twice, possible use of unknown storage ...static... \
	seeing ERT officers onboard, but no missions are on file for ...static...static...annoying jingle... only at The LIGHTHOUSE! \
	Fulfilling needs you didn't even know you had. We've got EVERYTHING, and something else!"
	admin_notes = "Currently larger than ferry docking port on Box, will not hit anything, but must be force docked. Trader and ERT bodyguards are not included."

/datum/map_template/shuttle/ferry/fancy
	suffix = "fancy"
	name = "fancy transport ferry"
	description = "At some point, someone upgraded the ferry to have fancier flooring... and fewer seats."

/datum/map_template/shuttle/ferry/kilo
	suffix = "kilo"
	name = "kilo transport ferry"
	description = "Standard issue CentCom Ferry for Kilo pattern stations. Includes additional equipment and rechargers."

/datum/map_template/shuttle/whiteship/box
	suffix = "1"
	name = "Hospital Ship"

/datum/map_template/shuttle/whiteship/meta
	suffix = "2"
	name = "Salvage Ship"

/datum/map_template/shuttle/whiteship/pubby
	suffix = "3"
	name = "NT White UFO"

/datum/map_template/shuttle/whiteship/cere
	suffix = "4"
	name = "NT Construction Vessel"

/datum/map_template/shuttle/whiteship/delta
	suffix = "5"
	name = "NT Frigate"

/datum/map_template/shuttle/whiteship/pod
	suffix = "whiteship_pod"
	name = "Salvage Pod"

/datum/map_template/shuttle/cargo/box
	suffix = "box"
	name = "supply shuttle (Box)"

/datum/map_template/shuttle/cargo/birdboat
	suffix = "birdboat"
	name = "supply shuttle (Birdboat)"

/datum/map_template/shuttle/cargo/kilo
	suffix = "kilo"
	name = "supply shuttle (Kilo)"

/datum/map_template/shuttle/cargo/gax
	suffix = "gax"
	name = "supply shuttle (Gax)"

/datum/map_template/shuttle/arrival/box
	suffix = "box"
	name = "arrival shuttle (Box)"

/datum/map_template/shuttle/cargo/box
	suffix = "box"
	name = "cargo ferry (Box)"

/datum/map_template/shuttle/mining/box
	suffix = "box"
	name = "mining shuttle (Box)"

/datum/map_template/shuttle/mining/kilo
	suffix = "kilo"
	name = "mining shuttle (Kilo)"

/datum/map_template/shuttle/labour/box
	suffix = "box"
	name = "labour shuttle (Box)"

/datum/map_template/shuttle/labour/kilo
	suffix = "kilo"
	name = "labour shuttle (Kilo)"

/datum/map_template/shuttle/labour/gax
	suffix = "gax"
	name = "labour shuttle (Gax)"

/datum/map_template/shuttle/infiltrator/basic
	suffix = "basic"
	name = "basic syndicate infiltrator"

/datum/map_template/shuttle/cargo/delta
	suffix = "delta"
	name = "cargo ferry (Delta)"

/datum/map_template/shuttle/mining/delta
	suffix = "delta"
	name = "mining shuttle (Delta)"

/datum/map_template/shuttle/labour/delta
	suffix = "delta"
	name = "labour shuttle (Delta)"

/datum/map_template/shuttle/arrival/delta
	suffix = "delta"
	name = "arrival shuttle (Delta)"

/datum/map_template/shuttle/arrival/omega
	suffix = "omega"
	name = "arrival shuttle (Omega)"

/datum/map_template/shuttle/arrival/kilo
	suffix = "kilo"
	name = "arrival shuttle (Kilo)"

/datum/map_template/shuttle/aux_base
	port_id = "aux_base"
	who_can_purchase = null

/datum/map_template/shuttle/aux_base/default
	suffix = "default"
	name = "auxilliary base (Default)"

/datum/map_template/shuttle/aux_base/small
	suffix = "small"
	name = "auxilliary base (Small)"

/datum/map_template/shuttle/escape_pod/default
	suffix = "default"
	name = "escape pod (Default)"

/datum/map_template/shuttle/escape_pod/large
	suffix = "large"
	name = "escape pod (Large)"

/datum/map_template/shuttle/assault_pod/default
	suffix = "default"
	name = "assault pod (Default)"

/datum/map_template/shuttle/pirate/default
	suffix = "default"
	name = "pirate ship (Default)"

/datum/map_template/shuttle/hunter/space_cop
	suffix = "space_cop"
	name = "Police Spacevan"

/datum/map_template/shuttle/hunter/russian
	suffix = "russian"
	name = "Russian Cargo Ship"

/datum/map_template/shuttle/ruin/caravan_victim
	suffix = "caravan_victim"
	name = "Small Freighter"

/datum/map_template/shuttle/ruin/pirate_cutter
	suffix = "pirate_cutter"
	name = "Pirate Cutter"

/datum/map_template/shuttle/ruin/syndicate_dropship
	suffix = "syndicate_dropship"
	name = "Syndicate Dropship"

/datum/map_template/shuttle/ruin/syndicate_fighter_shiv
	suffix = "syndicate_fighter_shiv"
	name = "Syndicate Fighter"

/datum/map_template/shuttle/snowdin/mining
	suffix = "mining"
	name = "Snowdin Mining Elevator"

/datum/map_template/shuttle/snowdin/excavation
	suffix = "excavation"
	name = "Snowdin Excavation Elevator"

/datum/map_template/shuttle/arrival/gax
	suffix = "gax"
	name = "arrival shuttle (Gax)"

/datum/map_template/shuttle/ai/gax
	port_id = "ai"
	suffix = "gax"
	name = "ai ship shuttle (Gax)"

/datum/map_template/shuttle/arrival/donut
	suffix = "donut"
	name = "arrival shuttle (Donut)"
