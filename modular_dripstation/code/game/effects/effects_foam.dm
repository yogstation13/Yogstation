/obj/structure/foamedmetal/attackby(obj/item/W, mob/user, params)
	///A speed modifier for how fast the wall is build
	var/platingmodifier = 1
	if(HAS_TRAIT(user, TRAIT_QUICK_BUILD))
		platingmodifier = 0.7
		if(next_beep <= world.time)
			next_beep = world.time + 1 SECONDS
			playsound(src, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE)
	add_fingerprint(user)

	if(!istype(W, /obj/item/stack/sheet))
		return ..()

	var/obj/item/stack/sheet/sheet_for_plating = W
	if(istype(sheet_for_plating, /obj/item/stack/sheet/metal))
		if(sheet_for_plating.get_amount() < 2)
			to_chat(user, span_warning("You need two sheets of iron to finish a wall on [src]!"))
			return
		to_chat(user, span_notice("You start adding plating to the foam structure..."))
		if (do_after(user, 40 * platingmodifier, target = src))
			if(!sheet_for_plating.use(2))
				return
			to_chat(user, span_notice("You add the plating."))
			var/turf/T = get_turf(src)
			T.place_on_top(/turf/closed/wall/metal_foam_base)
			transfer_fingerprints_to(T)
			qdel(src)
		return

	add_hiddenprint(user)
