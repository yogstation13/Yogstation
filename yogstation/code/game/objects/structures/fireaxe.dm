/obj/structure/fireaxecabinet
	req_access = list(ACCESS_ATMOSPHERICS) //adds ATMOSPHERICS access requirement for the lock on the cabinet.
	var/datum/effect_system/spark_spread/spark_system	//the spark system, used for generating... sparks?

/obj/structure/fireaxecabinet/bridge
	req_access = list(ACCESS_CAPTAIN)

/obj/structure/fireaxecabinet/Initialize()//<-- mirrored/overwritten proc
	. = ..()
	fireaxe = new
	update_icon()
	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)
	spark_system.attach(src)

/obj/structure/fireaxecabinet/Destroy()//<-- mirrored/overwritten proc
	if(fireaxe)
		fireaxe.forceMove(get_turf(src))
	if(spareid)
		spareid.forceMove(get_turf(src))
	QDEL_NULL(spark_system)
	return ..()

/obj/structure/fireaxecabinet/proc/check_deconstruct(obj/item/I, mob/user)
	if(istype(I, /obj/item/wrench) && !(flags_1 & NODECONSTRUCT_1) && !fireaxe && (open || broken || obj_integrity >= max_integrity))
		//User is attempting to wrench an open/broken fireaxe cabinet with NO fireaxe in it
		user.visible_message(span_warning("[user] disassembles the [name]."), \
							 "You start to disassemble the [name]...", \
							 span_italics("You hear wrenching."))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 4 SECONDS/I.toolspeed, src))
			to_chat(user, span_notice("You disassemble the [name]."))
			var/obj/item/stack/sheet/metal/M = new (loc, 3)//spawn three metal for deconstruction
			if (prob(50))
				M.add_fingerprint(user)
			var/obj/item/stack/sheet/rglass/G = new (loc, 2)//spawn two reinforced glass for it's window
			if (prob(50))
				G.add_fingerprint(user)
			deconstruct()//deconstruct then spawns an additional 2 metal, so you recover more mats using a wrench to decon than just destroying it.
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			return
	else if(istype(I, /obj/item/wrench) && !(flags_1 & NODECONSTRUCT_1) && !broken && !open)
		//User is attempting to wrench a closed & non-broken fireaxe cab
		to_chat(user, span_warning("You need to open the door first to access the [src]'s bolts!"))
		//Still allow damage to pass through, in case they are trying to destroy the cab's window with the wrench.
		return
	else if(istype(I, /obj/item/wrench) && !(flags_1 & NODECONSTRUCT_1) && (open || broken) && fireaxe)
		//User is attempting to wrench an open and ready fireaxe cabinet, but the axe is still in it's slot.
		to_chat(user, span_warning("You need to remove the fireaxe first to deconstruct the [src]!"))
		return

/obj/structure/fireaxecabinet/proc/reset_lock(mob/user)
	//this happens when you hack the lock as a synthetic/AI, or with a multitool.
	if(obj_flags & EMAGGED)
		to_chat(user, span_notice("You try to reset the [name]'s circuits, but they're completely burnt out."))
		return
	if(!open)
		to_chat(user, "<span class = 'caution'>Resetting circuitry...</span>")
		if(do_after(user, 10 SECONDS, src))
			to_chat(user, span_caution("You [locked ? "disable" : "re-enable"] the locking modules."))
			src.add_fingerprint(user)
			toggle_lock(user)


/obj/structure/fireaxecabinet/AltClick(mob/user)
	//Alt-Click can be used to unlock without swiping your ID (assuming you have access), or open/close an unlocked cabinet
	//This has the side-effect of allowing borgs to open it, once they unlock it. They still can't remove the axe from it though.
	if(!broken)
		if (locked)
			if (allowed(user))
				toggle_lock()
			else
				to_chat(user, span_danger("Access denied."))
		else
			//open the cabinet normally.
			toggle_open()

/obj/structure/fireaxecabinet/toggle_lock(mob/user)//<-- mirrored/overwritten proc
	//this happens when you actuate the lock status.
	if(obj_flags & EMAGGED)
		to_chat(user, span_notice("The [name]'s locking modules are unresponsive."))
		return
	if(!open)
		audible_message("You hear an audible clunk as the [name]'s bolt [locked ? "retracts" : "locks into place"].")
		playsound(loc, "sound/machines/locktoggle.ogg", 30, 1, -3)
		locked = !locked
		update_icon()

/obj/structure/fireaxecabinet/emag_act(mob/user)
	//this allows you to emag the fireaxe cabinet, unlocking it immediately.
	if(obj_flags & EMAGGED)
		return
	if(!open && locked)
		user.visible_message(span_warning("Sparks fly out of the [src]'s locking modules!"), \
							 span_caution("You short out the [name]'s locking modules."), \
							 span_italics("You hear electricity arcing."))
		spark_system.start()

		src.add_fingerprint(user)
		obj_flags |= EMAGGED
		desc += "<BR>[span_warning("Its access panel is smoking slightly.")]"

		playsound(loc, "sound/machines/locktoggle.ogg", 30, 1, -3)
		locked = 0
		audible_message("You hear an audible clunk as the [name]'s bolt retracts.")
		update_icon()
		//Fireaxe Cabinet is now permanently unlocked.
