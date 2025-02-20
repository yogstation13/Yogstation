SUBSYSTEM_DEF(blackmarket)
	name		 = "Blackmarket"
	flags		 = SS_BACKGROUND
	init_order	 = INIT_ORDER_DEFAULT

	/// Descriptions for each shipping methods.
	var/shipping_method_descriptions = list(
		SHIPPING_METHOD_LAUNCH="Launches the item at the station from space, cheap but you might not recieve your item at all.",
		SHIPPING_METHOD_TELEPORT="Teleports the item in a random area in the station, you get 60 seconds to get there first though."
	)

	/// List of all existing markets.
	var/list/datum/blackmarket_market/markets		= list()
	/// List of existing ltsrbts.
	var/list/obj/machinery/ltsrbt/telepads			= list()
	/// Currently queued purchases.
	var/list/queued_purchases 						= list()

/datum/controller/subsystem/blackmarket/Initialize(timeofday)
	for(var/market in subtypesof(/datum/blackmarket_market))
		markets[market] += new market

	for(var/item in subtypesof(/datum/blackmarket_item))
		var/datum/blackmarket_item/I = new item()
		if(!I.item)
			continue

		for(var/M in I.markets)
			if(!markets[M])
				stack_trace("SSblackmarket: Item [I] available in market that does not exist.")
				continue
			markets[M].add_item(item)
		qdel(I)
	. = ..()

/datum/controller/subsystem/blackmarket/fire(resumed)
	while(length(queued_purchases))
		var/datum/blackmarket_purchase/purchase = queued_purchases[1]
		queued_purchases.Cut(1,2)

		// Uh oh, uplink is gone. We will just keep the money and you will not get your order.
		if(!purchase.uplink || QDELETED(purchase.uplink))
			queued_purchases -= purchase
			qdel(purchase)
			continue

		switch(purchase.method)
			// Get random area, throw it somewhere there.
			if(SHIPPING_METHOD_TELEPORT)
				var/turf/targetturf = get_safe_random_station_turf()
				// This shouldn't happen.
				if (!targetturf)
					continue

				to_chat(recursive_loc_check(purchase.uplink.loc, /mob), span_notice("<span class='notice'>[purchase.uplink] flashes a message noting that the order is being teleported to [get_area(targetturf)] in 60 seconds."))

				// do_teleport does not want to teleport items from nullspace, so it just forceMoves and does sparks.
				addtimer(CALLBACK(src, /datum/controller/subsystem/blackmarket/proc/fake_teleport, purchase.entry.spawn_item(), targetturf), 60 SECONDS)
				queued_purchases -= purchase
				qdel(purchase)
			// Get the current location of the uplink if it exists, then throws the item from space at the station from a random direction.
			if(SHIPPING_METHOD_LAUNCH)
				var/startSide = pick(GLOB.cardinals)
				var/turf/T = get_turf(purchase.uplink)
				var/pickedloc = spaceDebrisStartLoc(startSide, T.z)

				var/atom/movable/item = purchase.entry.spawn_item(pickedloc)
				item.throw_at(purchase.uplink, 3, 3, spin = FALSE)

				to_chat(recursive_loc_check(purchase.uplink.loc, /mob), span_notice("[purchase.uplink] flashes a message noting the order is being launched at the station from [dir2text(startSide)].</span>"))

				queued_purchases -= purchase
				qdel(purchase)

		if(MC_TICK_CHECK)
			break

/// Used to make a teleportation effect as do_teleport does not like moving items from nullspace.
/datum/controller/subsystem/blackmarket/proc/fake_teleport(atom/movable/item, turf/target)
	item.forceMove(target)
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(5, 1, target)
	sparks.attach(item)
	sparks.start()

/// Used to add /datum/blackmarket_purchase to queued_purchases var. Returns TRUE when queued.
/datum/controller/subsystem/blackmarket/proc/queue_item(datum/blackmarket_purchase/P)
	queued_purchases += P
	return TRUE
