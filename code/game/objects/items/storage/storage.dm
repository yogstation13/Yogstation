
/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/component_type = /datum/component/storage/concrete

/obj/item/storage/get_dumping_location(obj/item/storage/source,mob/user)
	return src

<<<<<<< HEAD
/obj/item/storage/Initialize()
=======
//Tries to dump content
/obj/item/storage/proc/dump_content_at(atom/dest_object, mob/user)
	var/atom/dump_destination = dest_object.get_dumping_location()
	if(Adjacent(user) && dump_destination && user.Adjacent(dump_destination))
		if(dump_destination.storage_contents_dump_act(src, user))
			playsound(loc, "rustle", 50, 1, -5)
			return 1
	return 0

//Object behaviour on storage dump
/obj/item/storage/storage_contents_dump_act(obj/item/storage/src_object, mob/user)
	var/list/things = src_object.contents.Copy()
	var/datum/progressbar/progress = new(user, things.len, src)
	while (do_after(user, 10, TRUE, src, FALSE, CALLBACK(src, .proc/handle_mass_item_insertion, things, src_object, user, progress)))
		stoplag(1)
	qdel(progress)
	orient2hud(user)
	src_object.orient2hud(user)
	if(user.s_active) //refresh the HUD to show the transfered contents
		user.s_active.close(user)
		user.s_active.show_to(user)
	return 1

/obj/item/storage/proc/handle_mass_item_insertion(list/things, obj/item/storage/src_object, mob/user, datum/progressbar/progress)
	for(var/obj/item/I in things)
		things -= I
		if(I.loc != src_object)
			continue
		if(user.s_active != src_object)
			if(I.on_found(user))
				break
		if(can_be_inserted(I,0,user))
			handle_item_insertion(I, TRUE, user)
		if (TICK_CHECK)
			progress.update(progress.goal - things.len)
			return TRUE

	progress.update(progress.goal - things.len)
	return FALSE

/obj/item/storage/proc/return_inv()
	var/list/L = list()
	L += contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	return L


/obj/item/storage/proc/show_to(mob/user)
	if(!user.client)
		return
	if(user.s_active != src && (user.stat == CONSCIOUS))
		for(var/obj/item/I in src)
			if(I.on_found(user))
				return
	if(user.s_active)
		user.s_active.hide_from(user)
	user.client.screen |= boxes
	user.client.screen |= closer
	user.client.screen |= contents
	user.s_active = src
	is_seeing |= user


/obj/item/storage/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	close_all()
	return ..()

/obj/item/storage/proc/hide_from(mob/user)
	if(!user.client)
		return
	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= contents
	if(user.s_active == src)
		user.s_active = null
	is_seeing -= user


/obj/item/storage/proc/can_see_contents()
	var/list/cansee = list()
	for(var/mob/M in is_seeing)
		if(M.s_active == src && M.client)
			cansee |= M
		else
			is_seeing -= M
	return cansee


/obj/item/storage/proc/close(mob/user)
	hide_from(user)
	user.s_active = null


/obj/item/storage/proc/close_all()
	for(var/mob/M in can_see_contents())
		close(M)
		. = 1 //returns 1 if any mobs actually got a close(M) call


//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/obj/item/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes.screen_loc = "[tx]:,[ty] to [mx],[my]"
	for(var/obj/O in contents)
		if(QDELETED(O))
			continue
		O.screen_loc = "[cx],[cy]"
		O.layer = ABOVE_HUD_LAYER
		O.plane = ABOVE_HUD_PLANE
		cx++
		if(cx > mx)
			cx = tx
			cy--
	closer.screen_loc = "[mx+1],[my]"


//This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/storage/proc/standard_orient_objs(rows, cols, list/obj/item/display_contents)
	var/cx = 4
	var/cy = 2+rows
	boxes.screen_loc = "4:16,2:16 to [4+cols]:16,[2+rows]:16"

	if(display_contents_with_number)
		for(var/datum/numbered_display/ND in display_contents)
			ND.sample_object.mouse_opacity = MOUSE_OPACITY_OPAQUE
			ND.sample_object.screen_loc = "[cx]:16,[cy]:16"
			ND.sample_object.maptext = "<font color='white'>[(ND.number > 1)? "[ND.number]" : ""]</font>"
			ND.sample_object.layer = ABOVE_HUD_LAYER
			ND.sample_object.plane = ABOVE_HUD_PLANE
			cx++
			if(cx > (4+cols))
				cx = 4
				cy--
	else
		for(var/obj/O in contents)
			if(QDELETED(O))
				continue
			O.mouse_opacity = MOUSE_OPACITY_OPAQUE //This is here so storage items that spawn with contents correctly have the "click around item to equip"
			O.screen_loc = "[cx]:16,[cy]:16"
			O.maptext = ""
			O.layer = ABOVE_HUD_LAYER
			O.plane = ABOVE_HUD_PLANE
			cx++
			if(cx > (4+cols))
				cx = 4
				cy--
	closer.screen_loc = "[4+cols+1]:16,2:16"


/datum/numbered_display
	var/obj/item/sample_object
	var/number

/datum/numbered_display/New(obj/item/sample)
	if(!istype(sample))
		qdel(src)
	sample_object = sample
	number = 1


//This proc determines the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/storage/proc/orient2hud(mob/user)
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/I in contents)
			if(QDELETED(I))
				continue
			var/found = 0
			for(var/datum/numbered_display/ND in numbered_contents)
				if(ND.sample_object.type == I.type)
					ND.number++
					found = 1
					break
			if(!found)
				adjusted_contents++
				numbered_contents.Add( new/datum/numbered_display(I) )

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if(adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	standard_orient_objs(row_num, col_count, numbered_contents)


//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/storage/proc/can_be_inserted(obj/item/W, stop_messages = 0, mob/user)
	if(!istype(W) || (W.flags_1 & ABSTRACT_1))
		return //Not an item

	if(loc == W)
		return 0 //Means the item is already in the storage item
	if(contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>[src] is full, make some space!</span>")
		return 0 //Storage item is full

	if(can_hold.len)
		if(!is_type_in_typecache(W, can_hold))
			if(!stop_messages)
				to_chat(usr, "<span class='warning'>[src] cannot hold [W]!</span>")
			return 0

	if(is_type_in_typecache(W, cant_hold)) //Check for specific items which this container can't hold.
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>[src] cannot hold [W]!</span>")
		return 0

	if(W.w_class > max_w_class)
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>[W] is too big for [src]!</span>")
		return 0

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>[W] won't fit in [src], make some space!</span>")
		return 0

	if(W.w_class >= w_class && (istype(W, /obj/item/storage)))
		if(!istype(src, /obj/item/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(!stop_messages)
				to_chat(usr, "<span class='warning'>[src] cannot hold [W] as it's a storage item of the same size!</span>")
			return 0 //To prevent the stacking of same sized storage items.

	if(W.flags_1 & NODROP_1) //SHOULD be handled in unEquip, but better safe than sorry.
		to_chat(usr, "<span class='warning'>\the [W] is stuck to your hand, you can't put it in \the [src]!</span>")
		return 0

	return 1


//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	if(!istype(W))
		return 0
	if(usr)
		if(!usr.transferItemToLoc(W, src))
			return 0
	else
		W.forceMove(src)
	if(silent)
		prevent_warning = 1
	if(W.pulledby)
		W.pulledby.stop_pulling()
	W.on_enter_storage(src)
	if(usr)
		if(usr.client && usr.s_active != src)
			usr.client.screen -= W
		if(usr.observers && usr.observers.len)
			for(var/M in usr.observers)
				var/mob/dead/observe = M
				if(observe.client && observe.s_active != src)
					observe.client.screen -= W

		add_fingerprint(usr)
		if(rustle_jimmies && !prevent_warning)
			playsound(src.loc, "rustle", 50, 1, -5)

		if(!prevent_warning)
			for(var/mob/M in viewers(usr, null))
				if(M == usr)
					to_chat(usr, "<span class='notice'>You put [W] [preposition]to [src].</span>")
				else if(in_range(M, usr)) //If someone is standing close enough, they can tell what it is...
					M.show_message("<span class='notice'>[usr] puts [W] [preposition]to [src].</span>", 1)
				else if(W && W.w_class >= 3) //Otherwise they can only see large or normal items from a distance...
					M.show_message("<span class='notice'>[usr] puts [W] [preposition]to [src].</span>", 1)

		orient2hud(usr)
		for(var/mob/M in can_see_contents())
			show_to(M)
	W.mouse_opacity = MOUSE_OPACITY_OPAQUE //So you can click on the area around the item to equip it, instead of having to pixel hunt
	update_icon()
	return 1


//Call this proc to handle the removal of an item from the storage item. The item will be moved to the new_location target, if that is null it's being deleted
/obj/item/storage/proc/remove_from_storage(obj/item/W, atom/new_location)
	if(!istype(W))
		return 0

	//Cache this as it should be reusable down the bottom, will not apply if anyone adds a sleep to dropped
	//or moving objects, things that should never happen
	var/list/seeing_mobs = can_see_contents()
	for(var/mob/M in seeing_mobs)
		M.client.screen -= W

	if(ismob(loc))
		var/mob/M = loc
		W.dropped(M)
	

	if(new_location)
		W.forceMove(new_location)
		//Reset the items values
		W.layer = initial(W.layer)
		W.plane = initial(W.plane)
		W.mouse_opacity = initial(W.mouse_opacity)
		if(W.maptext)
			W.maptext = ""
		//We don't want to call this if the item is being destroyed
		W.on_exit_storage(src)

	else
		//Being destroyed, just move to nullspace now (so it's not in contents for the icon update)
		W.moveToNullspace()


	for(var/mob/M in seeing_mobs)
		orient2hud(M)
		show_to(M)

	update_icon()
	return 1

/obj/item/storage/deconstruct(disassembled = TRUE)
	var/drop_loc = loc
	if(ismob(loc))
		drop_loc = get_turf(src)
	for(var/obj/item/I in contents)
		remove_from_storage(I, drop_loc)
	qdel(src)

//This proc is called when you want to place an item into the storage item.
/obj/item/storage/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/hand_labeler))
		var/obj/item/hand_labeler/labeler = W
		if(labeler.mode)
			return 0
	. = 1 //no afterattack
	if(iscyborg(user))
		return	//Robots can't interact with storage items.

	if(!can_be_inserted(W, 0 , user))
		return 1

	handle_item_insertion(W, 0 , user)

/obj/item/storage/AllowDrop()
	return TRUE

/obj/item/storage/attack_hand(mob/user)
	if(user.s_active == src && loc == user) //if you're already looking inside the storage item
		user.s_active.close(user)
		close(user)
		return

	if(rustle_jimmies)
		playsound(loc, "rustle", 50, 1, -5)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == src && !H.get_active_held_item())	//Prevents opening if it's in a pocket.
			H.put_in_hands(src)
			H.l_store = null
			return
		if(H.r_store == src && !H.get_active_held_item())
			H.put_in_hands(src)
			H.r_store = null
			return

	orient2hud(user)
	if(loc == user)
		if(user.s_active)
			user.s_active.close(user)
		show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)
	add_fingerprint(user)

/obj/item/storage/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	collection_mode = (collection_mode+1)%3
	switch (collection_mode)
		if(2)
			to_chat(usr, "[src] now picks up all items of a single type at once.")
		if(1)
			to_chat(usr, "[src] now picks up all items in a tile at once.")
		if(0)
			to_chat(usr, "[src] now picks up one item at a time.")

// Empty all the contents onto the current turf
/obj/item/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (loc != usr)) || usr.stat || usr.restrained() ||!usr.canmove)
		return
	var/turf/T = get_turf(src)
	var/list/things = contents.Copy()
	var/datum/progressbar/progress = new(usr, things.len, T)
	while (do_after(usr, 10, TRUE, T, FALSE, CALLBACK(src, .proc/mass_remove_from_storage, T, things, progress)))
		stoplag(1)
	qdel(progress)

/obj/item/storage/proc/mass_remove_from_storage(atom/target, list/things, datum/progressbar/progress)
	for(var/obj/item/I in things)
		things -= I
		if (I.loc != src)
			continue
		remove_from_storage(I, target)
		if (TICK_CHECK)
			progress.update(progress.goal - things.len)
			return TRUE

	progress.update(progress.goal - things.len)
	return FALSE

// Empty all the contents onto the current turf, without checking the user's status.
/obj/item/storage/proc/do_quick_empty()
	var/turf/T = get_turf(src)
	if(usr)
		hide_from(usr)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T)


/obj/item/storage/Initialize(mapload)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	PopulateContents()

/obj/item/storage/ComponentInitialize()
	AddComponent(component_type)

/obj/item/storage/AllowDrop()
	return TRUE

/obj/item/storage/contents_explosion(severity, target)
	for(var/atom/A in contents)
		A.ex_act(severity, target)
		CHECK_TICK

//Cyberboss says: "USE THIS TO FILL IT, NOT INITIALIZE OR NEW"

/obj/item/storage/proc/PopulateContents()
