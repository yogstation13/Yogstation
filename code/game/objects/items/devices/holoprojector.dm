/obj/item/device/holoprojector
	name = "holographic object projector"
	desc = "A device which has the ability to scan objects and create stationary holograms of them."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	item_state = "electronic"
	force = 0
	w_class = 2
	throwforce = 0
	throw_speed = 3
	throw_range = 7

	var/max_holograms = 8 //upgrade capacitor to increase max holograms
	var/list/holograms = list()
	var/mutable_appearance/current_item = null
	var/current_item_dir = null
	var/list/allow_scanning_these = list(/obj/item) //upgrade microlaser to increase scanning abilities

	var/obj/item/stock_parts/micro_laser/laser
	var/obj/item/stock_parts/capacitor/cap

	var/replaced_parts = FALSE
	var/range = 1

/obj/item/device/holoprojector/New()
	..()
	laser = new(src)
	cap = new(src)

/obj/item/device/holoprojector/Destroy()
	. = ..()
	for(var/obj/effect/dummy/hologram/H in holograms)
		qdel(H)

/obj/item/device/holoprojector/attack(mob/living/M, mob/user)
	return

/obj/item/device/holoprojector/afterattack(atom/target, mob/user, proximity)
	if(!target) return
	if(get_dist(user, target) > range) return
	if(!laser || !cap)
		to_chat(user, "<span class='warning'>[src] is missing some parts!</span>")
		return

	if(istype(target, /obj/effect/dummy/hologram))
		qdel(target)
		to_chat(user, "<span class='notice'>You remove the hologram.</span>")
		return

	for(var/T in allow_scanning_these)
		if(istype(target, T))
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 50, 1, -6)
			to_chat(user, "<span class='notice'>Scanned [target].</span>")
			var/obj/temp = new/obj()
			temp.appearance = target.appearance
			temp.layer = initial(target.layer) // scanning things in your inventory
			current_item = temp.appearance
			current_item_dir = target.dir
			return

	if(istype(target,/turf/open))
		if(target in view(range, user))
			create_hologram(user, target)
	else
		to_chat(user, "<span class='warning'>You cannot scan that!</span>")

/obj/item/device/holoprojector/proc/create_hologram(mob/user, turf/open/target)
	if(!current_item)
		to_chat(user, "<span class='warning'>You have not scanned anything to replicate yet!</span>")
		return

	if(holograms.len >= max_holograms)
		qdel(holograms[1])

	to_chat(user, "<span class='notice'>You create a fake [current_item.name].</span>")
	playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 1, -6)
	new /obj/effect/dummy/hologram(target, src)

/obj/item/device/holoprojector/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		if(laser)
			laser.loc = get_turf(src.loc)
			laser = null
			replaced_parts = TRUE
		if(cap)
			cap.loc = get_turf(src.loc)
			cap = null
			replaced_parts = TRUE
		if(replaced_parts)
			replaced_parts = FALSE
			to_chat(user, "<span class='notice'>You pop out the parts from [src].</span>")
			for(var/obj/effect/dummy/hologram/H in holograms)
				qdel(H)
		else
			to_chat(user, "<span class='warning'>[src] does not have any parts installed!</span>")

	else if(istype(I, /obj/item/stock_parts/micro_laser) && !laser)
		laser = I
		I.loc = src
		to_chat(user, "<span class='notice'>You insert [laser.name] into [src].</span>")

		switch(laser.rating)
			if(1)
				allow_scanning_these = list(/obj/item)
			if(2)
				allow_scanning_these = list(/obj)
			if(3)
				allow_scanning_these = list(/obj, /mob)
			if(4)
				allow_scanning_these = list(/obj, /mob)

		range = 1+(laser.rating*2)

	else if(istype(I, /obj/item/stock_parts/capacitor) && !cap)
		cap = I
		I.loc = src
		to_chat(user, "<span class='notice'>You insert [cap.name] into [src].</span>")

		max_holograms = 8*cap.rating

/obj/item/device/holoprojector/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You disable the projector.</span>")
	for(var/obj/effect/dummy/hologram/H in holograms)
		qdel(H)

/obj/effect/dummy/hologram
	name = ""
	desc = ""
	density = 0
	var/obj/item/device/holoprojector/parent_projector = null
	var/datum/effect_system/spark_spread/spark_system

/obj/effect/dummy/hologram/New(loc, obj/item/device/holoprojector/parent)
	if(parent)
		parent_projector = parent
		if(parent_projector.current_item)
			appearance = parent_projector.current_item.appearance
			dir = parent_projector.current_item_dir
			desc += " <span class='italics'>It seems to be shimmering a little...</span>"
		parent_projector.holograms += src
	..()

/obj/effect/dummy/hologram/Destroy()
	var/msg = pick("[src] distorts for a moment, then disappears!","[src] flickers out of existence!","[src] suddenly disappears!","[src] warps wildly before disappearing!")
	visible_message("<span class='danger'>[msg]</span>")
	playsound(get_turf(src), "sparks", 100, 1)
	if(parent_projector)
		parent_projector.holograms -= src
	return ..()

/obj/effect/dummy/hologram/attackby(obj/item/W, mob/user)
	to_chat(user, "<span class='danger'>[W] passes right through [src]!</span>")
	qdel(src)

/obj/effect/dummy/hologram/attack_hand(mob/user)
	to_chat(user, "<span class='danger'>Your hand passes right through [src]!</span>")
	qdel(src)

/obj/effect/dummy/hologram/attack_animal(mob/user)
	to_chat(user, "<span class='danger'>Your appendage passes right through [src]!</span>")
	qdel(src)

/obj/effect/dummy/hologram/attack_slime(mob/user)
	to_chat(user, "<span class='danger'>Your blubber passes right through [src]!</span>")
	qdel(src)

/obj/effect/dummy/hologram/attack_alien(mob/user)
	to_chat(user, "<span class='danger'>Your claws pass right through [src]!</span>")
	qdel(src)

/obj/effect/dummy/hologram/ex_act(S, T)
	qdel(src)

/obj/effect/dummy/hologram/bullet_act()
	..()
	qdel(src)

/obj/effect/dummy/hologram/CtrlClick(mob/user)
	if(get_dist(src, user) > 1)
		return FALSE
	to_chat(user, "<span class='danger'>You pass through [src] as you try to grab it!</span>")
	qdel(src)
	return TRUE

/obj/item/device/holoprojector/debug
	name = "debug holoprojector"
	max_holograms = 24
	allow_scanning_these = list(/obj, /mob)
	range = 9

/obj/item/device/holoprojector/debug/New()
	..()
	laser = new /obj/item/stock_parts/micro_laser/quadultra(src)
	cap = new /obj/item/stock_parts/capacitor/quadratic(src)
