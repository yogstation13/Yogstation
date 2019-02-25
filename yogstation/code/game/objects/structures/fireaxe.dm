/obj/structure/fireaxecabinet
	req_access = list(ACCESS_ATMOSPHERICS)

/obj/structure/fireaxecabinet/proc/check_deconstruct(obj/item/I, mob/user)
	if(istype(I, /obj/item/wrench) && !(flags_1 & NODECONSTRUCT_1) && !fireaxe && (open || broken || obj_integrity >= max_integrity))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 40/I.toolspeed, target = src))
			to_chat(user, "<span class='notice'>You disassemble the [name].</span>")
			var/obj/item/stack/sheet/metal/M = new (loc, 3)//spawn three metal for deconstruction
			if (prob(50))
				M.add_fingerprint(user)
			var/obj/item/stack/sheet/rglass/G = new (loc, 2)//spawn two reinforced glass for it's window
			if (prob(50))
				G.add_fingerprint(user)
			deconstruct()
			return

/obj/structure/fireaxecabinet/proc/reset_lock(mob/user)
	//this happens when you hack the lock with a multitool, synthetic/AI, or an emag.
	if(!open)
		to_chat(user, "<span class = 'caution'>Resetting circuitry...</span>")
		if(do_after(user, 60, target = src))
			to_chat(user, "<span class='caution'>You [locked ? "disable" : "re-enable"] the locking modules.</span>")
			src.add_fingerprint(user)
			toggle_lock(user)

/obj/structure/fireaxecabinet/proc/toggle_lock(mob/user)//<-- mirrored/overwritten proc
	//this happens when you actuate the lock normally (e.g., you have access to the fireaxe cab)
	if(!open)
		audible_message("You hear an audible clunk as the [name]'s bolt [locked ? "retracts" : "locks into place"].")
		playsound(loc, "sound/machines/locktoggle.ogg", 30, 1, -3)
		locked = !locked
		update_icon()