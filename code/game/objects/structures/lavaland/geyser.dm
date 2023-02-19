//If you look at the "geyser_soup" overlay icon_state, you'll see that the first frame has 25 ticks.
//That's because the first 18~ ticks are completely skipped for some ungodly weird fucking byond reason

/obj/structure/geyser
	name = "geyser"
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE

	///set to null to get it greyscaled from "[icon_state]_soup". Not very usable with the whole random thing, but more types can be added if you change the spawn prob
	var/erupting_state = null
	//whether we are active and generating chems
	var/activated = FALSE
	///what chem do we produce?
	var/reagent_id = /datum/reagent/oil
	///how much reagents we add every process (2 seconds)
	var/potency = 2
	///maximum volume
	var/max_volume = 500
	///how much we start with after getting activated
	var/start_volume = 50

	///Have we been discovered with a mining scanner?
	var/discovered = FALSE
	///How many points we grant to whoever discovers us
	var/point_value = 100
	///what's our real name that will show upon discovery? null to do nothing
	var/true_name
	///the message given when you discover this geyser.
	var/discovery_message = null
	///The internal GPS once this is discovered
	var/obj/item/gps/internal

/obj/structure/geyser/Destroy()
	QDEL_NULL(internal)
	. = ..()
	

/obj/structure/geyser/proc/start_chemming()
	activated = TRUE
	create_reagents(max_volume, DRAINABLE)
	reagents.add_reagent(reagent_id, start_volume)
	START_PROCESSING(SSfluids, src) //It's main function is to be plumbed, so use SSfluids
	if(erupting_state)
		icon_state = erupting_state
	else
		var/mutable_appearance/I = mutable_appearance('icons/obj/lavaland/terrain.dmi', "[icon_state]_soup")
		I.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(I)

/obj/structure/geyser/process()
	if(activated && reagents.total_volume <= reagents.maximum_volume) //this is also evaluated in add_reagent, but from my understanding proc calls are expensive and should be avoided in continous
		reagents.add_reagent(reagent_id, potency)						   //processes

/obj/structure/geyser/plunger_act(obj/item/plunger/P, mob/living/user, _reinforced)
	if(!_reinforced)
		to_chat(user, "<span class='warning'>The [P.name] isn't strong enough!</span>")
		return
	if(activated)
		to_chat(user, "<span class'warning'>The [name] is already active!")
		return

	to_chat(user, "<span class='notice'>You start vigorously plunging [src]!")
	if(do_after(user, 5 SECONDS*P.plunge_mod, src) && !activated)
		start_chemming()

/obj/structure/geyser/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/mining_scanner) && !istype(item, /obj/item/t_scanner/adv_mining_scanner))
		return ..() //this runs the plunger code

	if(discovered)
		to_chat(user, span_warning("This geyser has already been discovered!"))
		return

	to_chat(user, span_notice("You discovered the geyser and mark it on the GPS system!"))
	if(discovery_message)
		to_chat(user, discovery_message)

	discovered = TRUE
	if(true_name)
		name = true_name

	internal = new /obj/item/gps/internal/geyser(src) //put it on the gps so miners can mark it and chemists can profit off of it //Yogs - LOL NO!
	internal.gpstag = true_name

	if(isliving(user))
		var/mob/living/living = user

		var/obj/item/card/id/card = living.get_idcard()
		if(card)
			to_chat(user, span_notice("[point_value] mining points have been paid out!"))
			card.mining_points += point_value
			playsound(src, 'sound/machines/ping.ogg', 15, TRUE)

/obj/structure/geyser/ash
	reagent_id = /datum/reagent/ash
	true_name = "ash geyser"

/obj/structure/geyser/stable_plasma
	reagent_id = /datum/reagent/stable_plasma
	true_name = "plasma geyser"

/obj/structure/geyser/oil
	reagent_id = /datum/reagent/oil
	true_name = "oil geyser"

/obj/structure/geyser/protozine
	reagent_id = /datum/reagent/medicine/omnizine/protozine
	true_name = "protozine geyser"

/obj/structure/geyser/holywater
	point_value = 250
	reagent_id = /datum/reagent/water/holywater
	true_name = "holy water geyser"
	start_volume = 5
	max_volume = 50
	potency = 0.5

/obj/structure/geyser/random
	point_value = 500
	true_name = "strange geyser"
	discovery_message = "It's a strange geyser! How does any of this even work?" //it doesnt

/obj/structure/geyser/random/Initialize()
	. = ..()
	reagent_id = get_random_reagent_id()

/obj/item/gps/internal/geyser
	icon_state = null
	gpstag = "Geyser"
	desc = "Chemicals come from deep below."
	invisibility = 100

/obj/item/plunger
	name = "plunger"
	desc = "It's a plunger for plunging."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "plunger"

	var/plunge_mod = 1 //time*plunge_mod = total time we take to plunge an object
	var/reinforced = TRUE //whether we do heavy duty stuff like geysers / TG made all plungers reinforced

/obj/item/plunger/attack_obj(obj/O, mob/living/user)
	if(!O.plunger_act(src, user, reinforced))
		return ..()

//UNUSED, NORMAL PLUNGERS ARE REINFORCED TOO NOW.
/obj/item/plunger/reinforced
	name = "reinforced plunger"
	desc = " It's an M. 7 Reinforced Plunger© for heavy duty plunging."
	icon_state = "reinforced_plunger"

	plunge_mod = 0.8
