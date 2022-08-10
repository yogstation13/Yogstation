///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)


  9   1   5
	\ | /
  8 - 0 - 4
	/ | \
  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

/obj/structure/ethernet_cable
	name = "ethernet cable"
	desc = "A rigid and shielded cat 16a cable used for transferring vast amounts of data over long distances. Primarily used for large scale computing networks or advanced neural networks."
	icon = 'icons/obj/power_cond/power_local.dmi'
	icon_state = "0-1"
	level = 1 //is underfloor
	layer = WIRE_LAYER //Above hidden pipes, GAS_PIPE_HIDDEN_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	pixel_y = 5
	pixel_x = 5
	var/d1 = 0   // cable direction 1 (see above)
	var/d2 = 1   // cable direction 2 (see above)
	var/datum/ai_network/network
	//Cables no longer keep a copy of the cable to be dropped in nullspace

	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_CABLE,\
		pipe_interference_group = list("cable"),\
		pipe_group = "cable-ethernet"\
	)


// the ethernet cable object
/obj/structure/ethernet_cable/Initialize(mapload, param_color)
	. = ..()

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num( copytext( icon_state, 1, dash ) )
	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = get_turf(src)			// hide if turf is not intact
	if(level==1)
		hide(T.intact)
	GLOB.ethernet_cable_list += src //add it to the global cable list

	update_icon()

/obj/structure/ethernet_cable/Destroy()					// called when a cable is deleted
	if(network)
		cut_cable_from_ainet()				// update the ai networks
	GLOB.ethernet_cable_list -= src				//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/ethernet_cable/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = loc
		var/cableNum = 1
		if (d1*d2 > 0) //this be true if the cable has two directions, aka it contains two cables. If there is only one cable, one out of d1 and d2 will be zero
			cableNum = 2
		var/newCables = new /obj/item/stack/ethernet_coil(T, cableNum)
		TransferComponents(newCables) //this copies the fingerprints over to the new object
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////

//If underfloor, hide the cable
/obj/structure/ethernet_cable/hide(i)

	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/structure/ethernet_cable/update_icon()
	icon_state = "[d1]-[d2]"

/obj/structure/ethernet_cable/proc/handlecable(obj/item/W, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		user.visible_message("[user] cuts the ethernet cable.", span_notice("You cut the ethernet cable."))
		investigate_log("was cut by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
		add_fingerprint(user)
		deconstruct()
		return

	else if(istype(W, /obj/item/stack/ethernet_coil))
		var/obj/item/stack/ethernet_coil/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, span_warning("Not enough cable!"))
			return
		coil.cable_join(src, user)
	/*
	else if(W.tool_behaviour == TOOL_MULTITOOL) //FIX NETWORK STATS
	
		if(ai network && (ai network.avail > 0))		// is it powered?
			to_chat(user, span_danger("Total power: [DisplayPower(ai network.avail)]\nLoad: [DisplayPower(ai network.load)]\nExcess power: [DisplayPower(surplus())]"))
		else
			to_chat(user, span_danger("The cable is not powered."))
		shock(user, 5, 0.2)
	*/
	add_fingerprint(user)

// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the network stats
//
/obj/structure/ethernet_cable/attackby(obj/item/W, mob/user, params)
	handlecable(W, user, params)


/obj/structure/ethernet_cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

//handles merging diagonally matching cables
//for info : direction^3 is flipping horizontally, direction^12 is flipping vertically
/obj/structure/ethernet_cable/proc/mergeDiagonalsNetworks(direction)

	//search for and merge diagonally matching cables from the first direction component (north/south)
	var/turf/T  = get_step(src, direction&3)//go north/south

	for(var/obj/structure/ethernet_cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == (direction^3) || C.d2 == (direction^3)) //we've got a diagonally matching cable
			if(!C.network) //if the matching cable somehow got no ai network, make him one (should not happen for cables)
				var/datum/ai_network/newAN = new()
				newAN.add_cable(C)

			if(network) //if we already have a ai network, then merge the two ai networks
				merge_ainets(network,C.network)
				//network.rebuild_remote()
			else
				C.network.add_cable(src) //else, we simply connect to the matching cable ai network
				C.network.rebuild_remote()

	//the same from the second direction component (east/west)
	T  = get_step(src, direction&12)//go east/west

	for(var/obj/structure/ethernet_cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue
		if(C.d1 == (direction^12) || C.d2 == (direction^12)) //we've got a diagonally matching cable
			if(!C.network) //if the matching cable somehow got no ai network, make him one (should not happen for cables)
				var/datum/ai_network/newAN = new()
				newAN.add_cable(C)

			if(network) //if we already have a ai network, then merge the two ai networks
				merge_ainets(network,C.network)
				//network.rebuild_remote()
			else
				C.network.add_cable(src) //else, we simply connect to the matching cable ai network
				C.network.rebuild_remote()

	

// merge with the ai networks of power objects in the given direction
/obj/structure/ethernet_cable/proc/mergeConnectedNetworks(direction)

	var/fdir = (!direction)? 0 : turn(direction, 180) //flip the direction, to match with the source position on its turf

	if(!(d1 == direction || d2 == direction)) //if the cable is not pointed in this direction, do nothing
		return

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/ethernet_cable/C in TB)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir) //we've got a matching cable in the neighbor turf
			if(!C.network) //if the matching cable somehow got no ai network, make him one (should not happen for cables)
				var/datum/ai_network/newAN = new(C.loc.z)
				newAN.add_cable(C)

			if(network) //if we already have a ai network, then merge the two ai networks
				merge_ainets(network,C.network)
				//network.rebuild_remote()
			else
				C.network.add_cable(src) //else, we simply connect to the matching cable ai network
				C.network.rebuild_remote()

// merge with the ai networks of power objects in the source turf
/obj/structure/ethernet_cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!network) //if we somehow have no ai network, make one (should not happen for cables)
		var/datum/ai_network/newAN = new(loc.z)
		newAN.add_cable(src)

	//first let's add turf cables to our ai network
	//then we'll connect machines on turf with a node cable is present
	for(var/AM in loc)
		if(istype(AM, /obj/structure/ethernet_cable))
			var/obj/structure/ethernet_cable/C = AM
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) //only connected if they have a common direction
				if(C.network == network)
					continue
				if(C.network)
					merge_ainets(network, C.network)
					//network.rebuild_remote()
				else
					network.add_cable(C) //the cable was ai networkless, let's just add it to our ai network
					network.rebuild_remote()
		
		else if(istype(AM, /obj/machinery/ai)) //other power machines
			var/obj/machinery/ai/M = AM

			if(M.network == network)
				continue

			to_connect += M //we'll connect the machines after all cables are merged 
			

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/ai/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new ai network, remove it from the old nonetheless
	

//////////////////////////////////////////////
// ai networks handling helpers
//////////////////////////////////////////////

//if ai_networkless_only = 1, will only get connections without ai network
/obj/structure/ethernet_cable/proc/get_connections(ai_networkless_only = 0)
	. = list()	// this will be a list of all connected power objects
	var/turf/T

	//get matching cables from the first direction
	if(d1) //if not a node cable
		T = get_step(src, d1)
		if(T)
			. += ai_list(T, src, turn(d1, 180), ai_networkless_only) //get adjacents matching cables

	if(d1&(d1-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d1&3) // go north/south
		if(T)
			. += ai_list(T, src, d1 ^ 3, ai_networkless_only) //get diagonally matching cables
		T = get_step(src,d1&12) // go east/west
		if(T)
			. += ai_list(T, src, d1 ^ 12, ai_networkless_only) //get diagonally matching cables

	. += ai_list(loc, src, d1, ai_networkless_only) //get on turf matching cables

	//do the same on the second direction (which can't be 0)
	T = get_step(src, d2)
	if(T)
		. += ai_list(T, src, turn(d2, 180), ai_networkless_only) //get adjacents matching cables

	if(d2&(d2-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d2&3) // go north/south
		if(T)
			. += ai_list(T, src, d2 ^ 3, ai_networkless_only) //get diagonally matching cables
		T = get_step(src,d2&12) // go east/west
		if(T)
			. += ai_list(T, src, d2 ^ 12, ai_networkless_only) //get diagonally matching cables
	. += ai_list(loc, src, d2, ai_networkless_only) //get on turf matching cables

	return .

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/ethernet_cable/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = ai_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a ai network
	if(powerlist.len>0)
		var/datum/ai_network/AN = new()
		propagate_ai_network(powerlist[1],AN) //propagates the new ai network beginning at the source cable

		if(AN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(AN)

/obj/structure/ethernet_cable/proc/auto_propogate_cut_cable(obj/O, )
	if(O && !QDELETED(O))
		var/datum/ai_network/newAN = new()// creates a new ai network...

		propagate_ai_network(O, newAN)//... and propagates it to the other side of the cable

		

// cut the cable's ai network at this cable and updates the powergrid
/obj/structure/ethernet_cable/proc/cut_cable_from_ainet(remove=TRUE)
	var/turf/T1 = loc
	var/list/P_list
	if(!T1)
		return
	if(d1)
		T1 = get_step(T1, d1)
		P_list = ai_list(T1, src, turn(d1,180),0,cable_only = 1)	// what adjacently joins on to cut cable...

	P_list += ai_list(loc, src, d1, 0, cable_only = 1)//... and on turf

	if(P_list.len == 0)//if nothing in both list, then the cable was a lone cable, just delete it and its ai network
		network.remove_cable(src)

		for(var/obj/machinery/ai/P in T1)//check if it was powering a machine
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network (and delete ai network)
		return

	var/obj/O = P_list[1]
	// remove the cut cable from its turf and ai network, so that it doesn't get count in propagate_network worklist
	if(remove)
		moveToNullspace()

	network.remove_cable(src) //remove the cut cable from its ai network
	

	addtimer(CALLBACK(O, .proc/auto_propogate_cut_cable, O), 0) //so we don't rebuild the network X times when singulo/explosion destroys a line of X cables

	// Disconnect machines connected to nodes
	if(d1 == 0) // if we cut a node (O-X) cable
		for(var/obj/machinery/ai/P in T1)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network


///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////

/obj/item/stack/ethernet_coil
	name = "ethernet cable coil"
	desc = "A coil of shielded ethernet cable."
	custom_price = 25
	gender = NEUTER //That's a cable coil sounds better than that's some cable coils
	icon = 'icons/obj/power.dmi'
	icon_state = "wire"
	item_state = "coil"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/ethernet_coil // This is here to let its children merge between themselves
	
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(/datum/material/iron=10, /datum/material/glass=5, /datum/material/gold=1)
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	singular_name = "ethernet cable piece"
	full_w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/copper = 2) //2 copper per cable in the coil
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/stack/ethernet_coil/cyborg
	is_cyborg = TRUE
	materials = list()
	cost = 1

/obj/item/stack/ethernet_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message(span_suicide("[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	else
		user.visible_message(span_suicide("[user] is trying to upload [user.p_them()]selves to the afterlife with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return(OXYLOSS)

/obj/item/stack/ethernet_coil/Initialize(mapload, new_amount = null, param_color = null)
	. = ..()

	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

///////////////////////////////////
// General procedures
///////////////////////////////////


//you can use wires to heal robotics
/obj/item/stack/ethernet_coil/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting.burn_dam <= 0)
		to_chat(user, span_warning("[affecting] is already in good condition!"))
		return FALSE
	if(affecting && affecting.status == BODYPART_ROBOTIC)
		user.visible_message(span_notice("[user] starts to fix some of the wires in [H]'s [affecting.name]."), span_notice("You start fixing some of the wires in [H == user ? "your" : "[H]'s"] [affecting.name]."))
		heal_robo_limb(src, H, user, 0, 15)
		user.visible_message(span_notice("[user] fixes the wires in [H]'s [affecting.name]."), span_notice("You fix the wires in [H == user ? "your" : "[H]'s"] [affecting.name]."))
		return
	else
		return ..()

/obj/item/stack/ethernet_coil/proc/heal_robo_limb(obj/item/I, mob/living/carbon/human/H,  mob/user, brute_heal, burn_heal)
	if(I.use_tool(H, user, 2 SECONDS, amount=1))
		if(item_heal_robotic(H, user, brute_heal, burn_heal))
			return heal_robo_limb(I, H, user, brute_heal, burn_heal)
		return TRUE

/obj/item/stack/ethernet_coil/update_icon()
	icon_state = "[initial(icon_state)][amount < 3 ? amount : ""]"
	name = "ethernet cable [amount < 3 ? "piece" : "coil"]"

/obj/item/stack/ethernet_coil/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/obj/item/stack/ethernet_coil/new_cable = ..()
	if(istype(new_cable))
		new_cable.update_icon()

//add cables to the stack
/obj/item/stack/ethernet_coil/proc/give(extra)
	if(amount + extra > max_amount)
		amount = max_amount
	else
		amount += extra
	update_icon()



///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/ethernet_coil/proc/get_new_cable(location)
	var/path = /obj/structure/ethernet_cable
	return new path(location)

// called when cable_coil is clicked on a turf
/obj/item/stack/ethernet_coil/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || T.intact || !T.can_have_cabling())
		to_chat(user, span_warning("You can only lay cables on top of exterior catwalks and plating!"))
		return

	if(get_amount() < 1) // Out of cable
		to_chat(user, span_warning("There is no cable left!"))
		return

	if(get_dist(T,user) > 1) // Too far
		to_chat(user, span_warning("You can't lay cable at a place that far away!"))
		return

	var/dirn
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew


	for(var/obj/structure/ethernet_cable/LC in T)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, span_warning("There's already a cable at that position!"))
			return

	var/obj/structure/ethernet_cable/C = get_new_cable(T)

	//set up the new cable
	C.d1 = 0 //it's a O-X node cable
	C.d2 = dirn
	C.add_fingerprint(user)
	C.update_icon()

	//create a new ai network with the cable, if needed it will be merged later
	var/datum/ai_network/AN = new()
	AN.add_cable(C)

	C.mergeConnectedNetworks(C.d2) //merge the ai network with adjacents ai networks
	C.mergeConnectedNetworksOnTurf() //merge the ai network with on turf ai networks

	if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
		C.mergeDiagonalsNetworks(C.d2)

	use(1)

	return C

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/ethernet_coil/proc/cable_join(obj/structure/ethernet_cable/C, mob/user, var/showerror = TRUE, forceddir)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, span_warning("You can't lay cable at a place that far away!"))
		return


	if(U == T && !forceddir) //if clicked on the turf we're standing on and a direction wasn't supplied, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)
	if(forceddir)
		dirn = forceddir

	// one end of the clicked cable is pointing towards us and no direction was supplied
	if((C.d1 == dirn || C.d2 == dirn) && !forceddir)
		if(!U.can_have_cabling())						//checking if it's a plating or catwalk
			if (showerror)
				to_chat(user, span_warning("You can only lay cables on catwalks and plating!"))
			return
		if(U.intact)						//can't place a cable if it's a plating with a tile on it
			to_chat(user, span_warning("You can't lay cable there unless the floor tiles are removed!"))
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/structure/ethernet_cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					if (showerror)
						to_chat(user, span_warning("There's already a cable at that position!"))
					return

			var/obj/structure/ethernet_cable/NC = get_new_cable (U)

			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint(user)
			NC.update_icon()

			//create a new ai network with the cable, if needed it will be merged later
			var/datum/ai_network/newAN = new()
			newAN.add_cable(NC)

			NC.mergeConnectedNetworks(NC.d2) //merge the ai network with adjacents ai networks
			NC.mergeConnectedNetworksOnTurf() //merge the ai network with on turf ai networks

			if(NC.d2 & (NC.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
				NC.mergeDiagonalsNetworks(NC.d2)


			use(1)

			return

	// exisiting cable doesn't point at our position or we have a supplied direction, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/ethernet_cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				if (showerror)
					to_chat(user, span_warning("There's already a cable at that position!"))

				return


		C.update_icon()

		C.d1 = nd1
		C.d2 = nd2

		//updates the stored cable coil

		C.add_fingerprint(user)
		C.update_icon()


		C.mergeConnectedNetworks(C.d1) //merge the ai networks...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)


		use(1)

		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the ai networks.
		return
