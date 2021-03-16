// -------------------------
//  Smartfridges
// -------------------------
/obj/machinery/smartfridge
	name = "smartfridge"
	desc = "Keeps cold things cold and hot things cold."
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	max_integrity = 300
	integrity_failure = 100
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70)
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/smartfridge
	var/max_n_of_items = 1000
	var/allow_ai_retrieve = FALSE
	var/list/initial_contents
	var/full_indicator_state = "smartfridge-indicator" //the icon state for the "oh no, we're full" indicator light
	var/retrieval_state = "smartfridge-retrieve" //the icon state for the dispensing animation
	var/retrieval_time = 19 //the length (in ticks) of the retrieval_state
	var/supports_full_indicator_state = TRUE //whether or not the smartfridge supports a full inventory indicator icon state
	var/supports_retrieval_state = TRUE //whether or not the smartfridge supports a retrieval_state dispensing animation
	var/supports_capacity_indication = TRUE //whether or not the smartfridge supports 5 levels of inventory quantity indication icon states
	var/pitches = FALSE //whether or not it should use "sales pitches" similar to a vendor machine
	var/last_pitch = 0 //When did we last pitch?
	var/pitch_delay = 2000 //How long until we can pitch again?
	var/product_slogans = "" //String of slogans separated by semicolons, optional
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED	//Shock users like an airlock.
	var/dispenser_arm = TRUE //whether or not the dispenser is active (wires can disable this)
	var/power_wire_cut = FALSE
	var/list/slogan_list = list()

/obj/machinery/smartfridge/Initialize()
	. = ..()
	create_reagents(100, NO_REACT)

	wires = new /datum/wires/smartfridge(src)
	if(islist(initial_contents))
		for(var/typekey in initial_contents)
			var/amount = initial_contents[typekey]
			if(isnull(amount))
				amount = 1
			for(var/i in 1 to amount)
				load(new typekey(src))

	//Slogan pitches work almost identically to the vendor code:
	slogan_list = splittext(product_slogans, ";")
	last_pitch = world.time + rand(0, pitch_delay)
	power_change()

/obj/machinery/smartfridge/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/smartfridge/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = initial(max_n_of_items) * B.rating

/obj/machinery/smartfridge/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(!stat)//machine must be operable
			if (contents.len >= max_n_of_items)
				. += "<span class='notice'>The status display reads: <b>Inventory full!</b> Please remove items or upgrade the parts of this storage unit.</span>"
			else
				. += "<span class='notice'>The status display reads: Inventory quantity is currently <b>[contents.len] out of [max_n_of_items]</b> items.</span>"
		else
			if(!(stat & BROKEN))
				. += "<span class='notice'>The status display is off.</span>"

/obj/machinery/smartfridge/power_change()
	..()
	if(!(stat & BROKEN))
		if(powered() && !power_wire_cut)
			stat &= ~NOPOWER
			START_PROCESSING(SSmachines, src)
		else
			stat |= NOPOWER

/obj/machinery/smartfridge/process()
	if(stat & (BROKEN|NOPOWER))
		return PROCESS_KILL

	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--

	//Slogans and pitches.
	if(pitches && prob(5) && last_pitch + pitch_delay <= world.time && (contents.len > 0 || slogan_list.len > 0))
		if(contents.len > 0) //if we have contents to advertise, advertise them
			if(prob(25) && slogan_list.len > 0)
				//Even if we have contents to advertise, 25% of the time it will use a slogan (if available)
				speak_slogan()
			else
				speak_advert()
		else if(slogan_list.len > 0) //no contents to advertise, display a slogan instead
			speak_slogan()
		last_pitch = world.time

/obj/machinery/smartfridge/proc/speak_slogan()
	//speak a generic slogan from our slogan list (if possible)
	if(slogan_list.len > 0)
		speak(pick(slogan_list))

/obj/machinery/smartfridge/proc/speak_advert()
	//advertise our contents (if possible)
	if(contents.len > 0)
		var/selected_item1 = pick(contents)
		var/selected_item2 = pick(contents)
		if(contents.len > 1 && selected_item1 == selected_item2)
			//make an attempt to choose another item for the advertisement.
			selected_item2 = pick(contents)
		speak("This unit contains [contents.len] items, such as [(selected_item1 != selected_item2) ? "\"[selected_item1]\" and \"[selected_item2]\"!" : "\"[selected_item1]\"!"]")

/obj/machinery/smartfridge/proc/speak(message)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no speak
		return
	if(!message)
		return
	say(message)

//Shock functionality is identical to the vending machines.
/obj/machinery/smartfridge/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE

/obj/machinery/smartfridge/_try_interact(mob/user)
	if(seconds_electrified && !(stat & NOPOWER))
		if(shock(user, 100))
			return
	return ..()

/obj/machinery/smartfridge/obj_break(damage_flag)
	if(!(stat & BROKEN))
		stat |= BROKEN
		update_icon()
	..(damage_flag)

/obj/machinery/smartfridge/update_icon()
	var/startstate = initial(icon_state)
	if(stat & BROKEN)
		icon_state = "[startstate]-broken"
	else if(powered() && !power_wire_cut)
		icon_state = startstate
		//Capacity indication:
		if(supports_capacity_indication && contents.len > 0 && max_n_of_items > 0)
			var/current_capacity_percent = (contents.len/max_n_of_items)*100
			if(current_capacity_percent <= 2)
				icon_state = startstate
			else if(current_capacity_percent < 25)
				icon_state = "[startstate]-1"
			else if (current_capacity_percent < 45)
				icon_state = "[startstate]-2"
			else if (current_capacity_percent < 65)
				icon_state = "[startstate]-3"
			else if (current_capacity_percent < 85)
				icon_state = "[startstate]-4"
			else if (current_capacity_percent <= 100)
				icon_state = "[startstate]-5"
	else
		icon_state = "[startstate]-off"

/obj/machinery/smartfridge/proc/animate_dispenser()
	//visually animate the smartfridge dispensing an item
	if (supports_retrieval_state && !(stat & (NOPOWER|BROKEN)))
		//hacky way to flick an animated overlay in the same DMI
		var/current_icon_state = icon_state
		src.underlays += current_icon_state
		flick(retrieval_state, src)
		src.underlays -= current_icon_state

/obj/machinery/smartfridge/proc/indicate_full()
	//turn on the blinking red full to capacity indicator
	if (supports_full_indicator_state && !(stat & (NOPOWER|BROKEN)))
		add_overlay(full_indicator_state)
		src.visible_message("<span class='warning'>\The [src]'s \"Full Inventory\" indicator light blinks on.</span>", "<span class='warning'>Your \"Full Inventory\" indicator light blinks on, you are now at capacity.</span>", "<span class='notice'>You hear a clunk, then a quiet beep.</span>")

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(obj/item/O, mob/user, params)
	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, O))
		cut_overlays()
		if(panel_open)
			add_overlay("[initial(icon_state)]-panel")
		updateUsrDialog()
		return

	if(default_pry_open(O))
		return

	if(!(flags_1 & NODECONSTRUCT_1) && O.tool_behaviour == TOOL_WRENCH)
		if(panel_open || !anchored)
			if(default_unfasten_wrench(user, O))
				power_change()
				return
		else
			to_chat(user, "<span class='warning'>[src] needs to have it's maintenance panel open before you can reach the anchoring bolts!</span>")

	if(default_deconstruction_crowbar(O))
		updateUsrDialog()
		return

	if(!stat)

		//Unable to add an item, it's already full.
		if(contents.len >= max_n_of_items)
			to_chat(user, "<span class='warning'>\The [src] is full!</span>")
			return FALSE

		//Adding a single item
		if(accept_check(O))
			load(O)
			user.visible_message("[user] has added \the [O] to \the [src].", "<span class='notice'>You add \the [O] to \the [src].</span>")
			update_icon()
			updateUsrDialog()
			if(contents.len >= max_n_of_items)
				indicate_full()
			return TRUE

		//Adding items from a bag
		if(istype(O, /obj/item/storage/bag))
			var/obj/item/storage/P = O
			var/loaded = 0
			for(var/obj/G in P.contents)
				if(contents.len >= max_n_of_items)
					break
				if(accept_check(G))
					load(G)
					loaded++
			update_icon()
			updateUsrDialog()

			if(loaded)
				if(contents.len >= max_n_of_items)
					indicate_full()
					user.visible_message("[user] loads \the [src] with \the [O].", \
									 "<span class='notice'>You fill \the [src] with \the [O].</span>")
				else
					user.visible_message("[user] loads \the [src] with \the [O].", \
										 "<span class='notice'>You load \the [src] with \the [O].</span>")
				if(O.contents.len > 0)
					to_chat(user, "<span class='warning'>Some items are refused.</span>")
				return TRUE
			else
				to_chat(user, "<span class='warning'>There is nothing in [O] to put in [src]!</span>")
				return FALSE

		if(user.a_intent != INTENT_HARM)
			to_chat(user, "<span class='warning'>\The [src] smartly refuses [O].</span>")
			updateUsrDialog()
			return FALSE
		else
			return ..()

	else
		return ..()


/obj/machinery/smartfridge/proc/accept_check(obj/item/O)
	if(istype(O, /obj/item/reagent_containers/food/snacks/grown/) || istype(O, /obj/item/seeds/) || istype(O, /obj/item/grown/))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/proc/load(obj/item/O)
	if(ismob(O.loc))
		var/mob/M = O.loc
		if(!M.transferItemToLoc(O, src))
			to_chat(usr, "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in \the [src]!</span>")
			return FALSE
		else
			return TRUE
	else
		if(SEND_SIGNAL(O.loc, COMSIG_CONTAINS_STORAGE))
			return SEND_SIGNAL(O.loc, COMSIG_TRY_STORAGE_TAKE, O, src)
		else
			O.forceMove(src)
			return TRUE

///Really simple proc, just moves the object "O" into the hands of mob "M" if able, done so I could modify the proc a little for the organ fridge
/obj/machinery/smartfridge/proc/dispense(obj/item/O, var/mob/M)
	if(!M.put_in_hands(O))
		O.forceMove(drop_location())
		adjust_item_drop_location(O)

/obj/machinery/smartfridge/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmartVend", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/smartfridge/ui_data(mob/user)
	. = list()

	var/listofitems = list()
	for (var/I in src)
		var/atom/movable/O = I
		if (!QDELETED(O))
			var/md5name = md5(O.name)				// This needs to happen because of a bug in a TGUI component, https://github.com/ractivejs/ractive/issues/744
			if (listofitems[md5name])				// which is fixed in a version we cannot use due to ie8 incompatibility
				listofitems[md5name]["amount"]++	// The good news is, #30519 made smartfridge UIs non-auto-updating
			else
				listofitems[md5name] = list("name" = O.name, "type" = O.type, "amount" = 1)
	sortList(listofitems)

	.["contents"] = listofitems
	.["name"] = name
	.["isdryer"] = FALSE


/obj/machinery/smartfridge/handle_atom_del(atom/A) // Update the UIs in case something inside gets deleted
	SStgui.update_uis(src)

/obj/machinery/smartfridge/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("Release")
			var/desired = 0

			if(!allow_ai_retrieve && isAI(usr))
				to_chat(usr, "<span class='warning'>[src] does not seem to be configured to respect your authority!</span>")
				return

			if(!dispenser_arm)
				audible_message("<span class='warning'>\The [src] makes a loud clunk and the dispenser arm twitches slightly.</span>", "<span class='warning'>The dispenser arm on the [src] twitches slightly.</span>")
				return

			if (params["amount"])
				desired = text2num(params["amount"])
			else
				desired = input("How many items?", "How many items would you like to take out?", 1) as null|num

			if(desired <= 0)
				return FALSE

			if(QDELETED(src) || QDELETED(usr) || !usr.Adjacent(src)) // Sanity checkin' in case stupid stuff happens while we wait for input()
				return FALSE

			//Retrieving a single item into your hand
			if(desired == 1 && Adjacent(usr) && !issilicon(usr))
				for(var/obj/item/O in src)
					if(O.name == params["name"])
						dispense(O, usr)
						break
				update_icon()
				cut_overlay(full_indicator_state)
				animate_dispenser()
				return TRUE

			//Retrieving many items
			for(var/obj/item/O in src)
				if(desired <= 0)
					break
				if(O.name == params["name"])
					dispense(O, usr)
					desired--

			update_icon()
			cut_overlay(full_indicator_state)
			animate_dispenser()
			return TRUE
	return FALSE


// ----------------------------
//  Drying Rack 'smartfridge'
// ----------------------------
/obj/machinery/smartfridge/drying_rack
	name = "drying rack"
	desc = "A wooden contraption, used to dry plant products, food and leather."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "drying_rack"
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 200
	supports_full_indicator_state = FALSE //whether or not the smartfridge supports a full inventory indicator icon state
	supports_retrieval_state = FALSE //whether or not the smartfridge supports a retrieval_state dispensing animation
	supports_capacity_indication = FALSE //whether or not the smartfridge supports 5 levels of inventory quantity indication icon states
	product_slogans = "Smokin'!;Blaze it.;Roll 'em up!;This machine is made out of 85% organic hemp product.;Warning: Do not insert limbs into machine.;Enjoy your dried \"plant products\".;This machine was last inspected on April 20th, 2550.;Wait, I forgot what I was going to do... Oh yeah, dry things.;Tell the Cook to bring some food over here, I'm starving."
	pitches = FALSE
	var/drying = FALSE

/obj/machinery/smartfridge/drying_rack/Initialize()
	. = ..()
	if(component_parts && component_parts.len)
		component_parts.Cut()
	component_parts = null

/obj/machinery/smartfridge/drying_rack/on_deconstruction()
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)
	..()

/obj/machinery/smartfridge/drying_rack/RefreshParts()
/obj/machinery/smartfridge/drying_rack/exchange_parts()
/obj/machinery/smartfridge/drying_rack/spawn_frame()

/obj/machinery/smartfridge/drying_rack/default_deconstruction_crowbar(obj/item/crowbar/C, ignore_panel = 1)
	..()

//Whoever made this hacky drying_rack smartfridge thing didn't use the standard construction method
//so we have to override the wiring/deconstruction of the default smartfridge here
/obj/machinery/smartfridge/drying_rack/attackby(obj/item/O, mob/user, params)
	if(!(flags_1 & NODECONSTRUCT_1) && O.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, "<span class='warning'>[src] has nothing to unscrew! You think you can probably pry out the shelves, though.</span>")
		return
	else if(!(flags_1 & NODECONSTRUCT_1) && O.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='warning'>[src] has no bolts to wrench! You think you can probably pry out the shelves, though.</span>")
		return
	else
		return ..()

/obj/machinery/smartfridge/drying_rack/ui_data(mob/user)
	. = ..()
	.["isdryer"] = TRUE
	.["verb"] = "Take"
	.["drying"] = drying


/obj/machinery/smartfridge/drying_rack/ui_act(action, params)
	. = ..()
	if(.)
		update_icon() // This is to handle a case where the last item is taken out manually instead of through drying pop-out
		return
	switch(action)
		if("Dry")
			toggle_drying(FALSE)
			return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/powered()
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/smartfridge/drying_rack/power_change()
	. = ..()
	if(!powered())
		toggle_drying(TRUE)

/obj/machinery/smartfridge/drying_rack/load() //For updating the filled overlay
	..()
	update_icon()

/obj/machinery/smartfridge/drying_rack/update_icon()
	..()
	cut_overlays()
	if(drying)
		add_overlay("drying_rack_drying")
	if(contents.len)
		add_overlay("drying_rack_filled")

/obj/machinery/smartfridge/drying_rack/process()
	..()
	if(drying)
		if(rack_dry())//no need to update unless something got dried
			SStgui.update_uis(src)
			update_icon()

/obj/machinery/smartfridge/drying_rack/accept_check(obj/item/O)
	if(istype(O, /obj/item/reagent_containers/food/snacks/))
		var/obj/item/reagent_containers/food/snacks/S = O
		if(S.dried_type)
			return TRUE
	if(istype(O, /obj/item/stack/sheet/wetleather/))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/proc/toggle_drying(forceoff)
	if(drying || forceoff)
		drying = FALSE
		use_power = IDLE_POWER_USE
	else
		drying = TRUE
		use_power = ACTIVE_POWER_USE
	update_icon()

/obj/machinery/smartfridge/drying_rack/proc/rack_dry()
	for(var/obj/item/reagent_containers/food/snacks/S in src)
		if(S.dried_type == S.type)//if the dried type is the same as the object's type, don't bother creating a whole new item...
			S.add_atom_colour("#ad7257", FIXED_COLOUR_PRIORITY)
			S.dry = TRUE
			S.forceMove(drop_location())
		else
			var/dried = S.dried_type
			new dried(drop_location())
			qdel(S)
		return TRUE
	for(var/obj/item/stack/sheet/wetleather/WL in src)
		new /obj/item/stack/sheet/leather(drop_location(), WL.amount)
		qdel(WL)
		return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	atmos_spawn_air("TEMP=1000")

/obj/machinery/smartfridge/drying_rack/CtrlClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	toggle_drying(FALSE)

// ----------------------------
//  Bar drink smartfridge
// ----------------------------
/obj/machinery/smartfridge/drinks
	name = "drink showcase"
	desc = "A refrigerated storage unit for tasty, tasty alcohol."
	max_n_of_items = 100
	product_slogans = "Only the finest beverages for the discerning crewmember.;All our drinks are served ice-cold.;Happy Hour begins every shift at 12:00.;Don't worry, I won't tell the Captain you drink on the shift.;This'll get ya drunk.;Bottoms up!;Delightfully refreshing!;Show me the way to go home, I'm tired and I want to go to bed...;This unit contains the bartender's latest creations."
	pitches = TRUE

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O)
	if(!istype(O, /obj/item/reagent_containers) || (O.item_flags & ABSTRACT) || !O.reagents || !O.reagents.reagent_list.len)
		return FALSE
	if(istype(O, /obj/item/reagent_containers/glass) || istype(O, /obj/item/reagent_containers/food/drinks) || istype(O, /obj/item/reagent_containers/food/condiment))
		return TRUE

// ----------------------------
//  Food smartfridge
// ----------------------------
/obj/machinery/smartfridge/food
	desc = "A refrigerated storage unit for food."
	product_slogans = "Clean your refrigerator regularly!;Is your refrigerator running?;Much better than storing your food in space.;Feeling hungry? Have a snack!;Tasty and nutritious!"
	max_n_of_items = 200

/obj/machinery/smartfridge/food/accept_check(obj/item/O)
	if(istype(O, /obj/item/reagent_containers/food/snacks/))
		return TRUE
	return FALSE

// -------------------------------------
// Xenobiology Slime-Extract Smartfridge
// -------------------------------------
/obj/machinery/smartfridge/extract
	name = "smart slime extract storage"
	desc = "A refrigerated storage unit for slime extracts."
	max_n_of_items = 200
	pitches = FALSE
	product_slogans = "Slime on a dime.;Don't let the Syndicate get their hands on these!;Those slimes won't know what hit 'em.;Hi slimes!;Xeno guts, on ice.;For a lavaland creature, they're pretty cute!;Hello slimes!"

/obj/machinery/smartfridge/extract/accept_check(obj/item/O)
	if(istype(O, /obj/item/slime_extract))
		return TRUE
	if(istype(O, /obj/item/slime_scanner))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/extract/preloaded
	initial_contents = list(/obj/item/slime_scanner = 2)

// -------------------------
// Organ Surgery Smartfridge
// -------------------------
/obj/machinery/smartfridge/organ
	name = "smart organ storage"
	desc = "A refrigerated storage unit for organ storage. Upgraded parts will activate its advanced organ healing technology."
	max_n_of_items = 20	//vastly lower to prevent processing too long
	product_slogans = "Right in the spleen.;Body parts, on ice!;Low-temperature organ storage decreases patient transplant rejection rates.;Register as an organ donor today!;You can't play these organs.;THIS UNIT DOES NOT CONTAIN FOOD.;Keeps your heart colder than HoS's.;This unit is equipped with state-of-the-art organ healing technology, just upgrade it's parts to activate this feature.;Upgrade this unit's parts to increase organ healing speed.;Also check out our new product, the Organ Harvester machine! Pairs well with this unit!"
	pitches = FALSE
	var/repair_rate = 0

/obj/machinery/smartfridge/organ/accept_check(obj/item/O)
	if(istype(O, /obj/item/organ))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/organ/load(obj/item/O)
	if(..())	//if the item loads, clear can_decompose
		var/obj/item/organ/organ = O
		organ.organ_flags |= ORGAN_FROZEN

/obj/machinery/smartfridge/organ/dispense(obj/item/O, var/mob/M)
	var/obj/item/organ/organ = O
	organ.organ_flags &= ~ORGAN_FROZEN
	..()

/obj/machinery/smartfridge/organ/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = 20 * B.rating
		repair_rate = max(0, STANDARD_ORGAN_HEALING * (B.rating - 1))

/obj/machinery/smartfridge/organ/Destroy()
	for(var/organ in src)
		var/obj/item/organ/O = organ
		if(O)
			O.organ_flags &= ~ORGAN_FROZEN
	..()

/obj/machinery/smartfridge/organ/process()
	for(var/organ in src)
		var/obj/item/organ/O = organ
		if(O)
			O.damage = max(0, O.damage - (O.maxHealth * repair_rate))
	..()

/obj/machinery/smartfridge/organ/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	if(isorgan(AM))
		var/obj/item/organ/O = AM
		O.organ_flags &= ~ORGAN_FROZEN

// -----------------------------
// Chemistry Medical Smartfridge
// -----------------------------
/obj/machinery/smartfridge/chemistry
	name = "smart chemical storage"
	desc = "A refrigerated storage unit for medicine storage."
	max_n_of_items = 100
	product_slogans = "Medicine for what ails ya.;Get your medicine here!;Disclaimer: These chemicals are not regulated by the Nanotrasen Drug Administration.;Do you have a prescription for that?;This unit can dispense chemicals, medicines, toxins, and quite possibly also narcotics.;Ask your doctor or CMO about Chloral Hydrate(tm) today!;Check out our expanded inventory of pharmaceuticals.;Chemist, did you remember to make Mannitol?"
	pitches = TRUE

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/O)
	if(istype(O, /obj/item/storage/pill_bottle))
		if(O.contents.len)
			for(var/obj/item/I in O)
				if(!accept_check(I))
					return FALSE
			return TRUE
		return FALSE
	if(!istype(O, /obj/item/reagent_containers) || (O.item_flags & ABSTRACT))
		return FALSE
	if(istype(O, /obj/item/reagent_containers/pill)) // empty pill prank ok
		return TRUE
	if(!O.reagents || !O.reagents.reagent_list.len) // other empty containers not accepted
		return FALSE
	if(istype(O, /obj/item/reagent_containers/syringe) || istype(O, /obj/item/reagent_containers/glass/bottle) || istype(O, /obj/item/reagent_containers/glass/beaker) || istype(O, /obj/item/reagent_containers/spray) || istype(O, /obj/item/reagent_containers/medspray))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/chemistry/preloaded
	pitches = FALSE
	initial_contents = list(
		/obj/item/reagent_containers/pill/epinephrine = 12,
		/obj/item/reagent_containers/pill/charcoal = 5,
		/obj/item/reagent_containers/glass/bottle/epinephrine = 1,
		/obj/item/reagent_containers/glass/bottle/charcoal = 1)

// ----------------------------
// Virology Medical Smartfridge
// ----------------------------
/obj/machinery/smartfridge/chemistry/virology
	name = "smart virus storage"
	desc = "A refrigerated storage unit for volatile sample storage."
	max_n_of_items = 100
	product_slogans = "Try not to spill these.;Use of level-3 biohazard equipment or higher is mandatory when operating this machine.;Whoops, I think I dropped one.;Storage solutions for any and all biohazardous material."

/obj/machinery/smartfridge/chemistry/virology/preloaded
	pitches = FALSE
	initial_contents = list(
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/glass/bottle/cold = 1,
		/obj/item/reagent_containers/glass/bottle/flu_virion = 1,
		/obj/item/reagent_containers/glass/bottle/mutagen = 1,
		/obj/item/reagent_containers/glass/bottle/plasma = 1,
		/obj/item/reagent_containers/glass/bottle/synaptizine = 1,
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 1)

// ----------------------------
// Disk """fridge"""
// ----------------------------
/obj/machinery/smartfridge/disks
	name = "disk compartmentalizer"
	desc = "A machine capable of storing a variety of disks. Denoted by most as the DSU (disk storage unit)."
	icon_state = "disktoaster"
	product_slogans = "Toasty!;Burnt to a crisp.;Puts a new meaning to the term \"burning a disk\", eh?;Store your plant data disks here. Or any kind of disk really. I don't discriminate."
	pass_flags = PASSTABLE
	supports_full_indicator_state = FALSE //whether or not the smartfridge supports a full inventory indicator icon state
	retrieval_state = "disktoaster-retrieve" //the icon state for the dispensing animation
	retrieval_time = 5 //the length (in ticks) of the retrieval_state
	supports_retrieval_state = TRUE //whether or not the smartfridge supports a retrieval_state dispensing animation
	supports_capacity_indication = FALSE //whether or not the smartfridge supports 5 levels of inventory quantity indication icon states

/obj/machinery/smartfridge/disks/accept_check(obj/item/O)
	if(istype(O, /obj/item/disk/))
		return TRUE
	else
		return FALSE
