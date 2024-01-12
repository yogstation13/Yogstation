/obj/item/stack/rods/lava
	name = "heat resistant rod"
	desc = "Treated, specialized iron rods. When exposed to the vaccum of space their coating breaks off, but they can hold up against the extreme heat of active lava."
	singular_name = "heat resistant rod"
	icon_state = "rods"
	item_state = "rods"
	color = "#5286b9ff"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron = 1000, /datum/material/plasma = 500, /datum/material/titanium = 2000)
	max_amount = 30
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	merge_type = /obj/item/stack/rods/lava

/obj/item/stack/rods/lava/thirty
	amount = 30

/obj/structure/lattice/lava
	name = "heatproof support lattice"
	desc = "A specialized support beam for building across lava. Watch your step."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	number_of_rods = 1
	color = "#5286b9ff"
	obj_flags = CAN_BE_HIT
	resistance_flags = FIRE_PROOF | LAVA_PROOF

/obj/structure/lattice/lava/over
	layer = CATWALK_LAYER
	plane = GAME_PLANE

/obj/structure/lattice/lava/deconstruction_hints(mob/user)
	return span_notice("The rods look like they could be <b>cut</b>, but the <i>heat treatment will shatter off</i>. There's space for a <i>tile</i>.")

/obj/structure/lattice/lava/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/P = C
		if(P.use(1))
			to_chat(user, span_notice("You construct a floor plating, as lava settles around the rods."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /turf/open/floor/plating(locate(x, y, z))
		else
			to_chat(user, span_warning("You need one floor tile to build atop [src]."))
		return

/turf/open/lava/attackby(obj/item/C, mob/user, params)
	..()
	if(istype(C, /obj/item/stack/rods/lava))
		var/obj/item/stack/rods/lava/R = C
		var/obj/structure/lattice/lava/H = locate(/obj/structure/lattice/lava, src)
		if(H)
			to_chat(user, span_warning("There is already a lattice here!"))
			return
		if(R.use(1))
			to_chat(user, span_notice("You construct a lattice."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/lava(locate(x, y, z))
		else
			to_chat(user, span_warning("You need one rod to build a heatproof lattice."))
		return
	// Light a cigarette in the lava
	if(istype(C, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/ciggie = C
		if(ciggie.lit)
			to_chat(user, span_warning("The [ciggie.name] is already lit!"))
			return TRUE
		var/clumsy_modifier = HAS_TRAIT(user, TRAIT_CLUMSY) ? 2 : 1
		if(prob(25 * clumsy_modifier ))
			ciggie.light(span_warning("[user] expertly dips \the [ciggie.name] into [src], along with the rest of [user.p_their()] arm. What a dumbass."))
			var/obj/item/bodypart/affecting = user.get_active_hand()
			affecting?.receive_damage(burn = 90)
		else
			ciggie.light(span_rose("[user] expertly dips \the [ciggie.name] into [src], lighting it with the scorching heat of the planet. Witnessing such a feat is almost enough to make you cry."))
		return TRUE

/turf/open/lava/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/lattice/lava, /obj/structure/stone_tile))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)