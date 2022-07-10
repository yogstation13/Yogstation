//If you look at the "geyser_soup" overlay icon_state, you'll see that the first frame has 25 ticks.
//That's because the first 18~ ticks are completely skipped for some ungodly weird fucking byond reason

/obj/structure/reagent_dispensers/geyser
	name = "geyser"
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE
	reagent_id = /datum/reagent/oil
	tank_volume = 500
	filled = FALSE

	var/activated = FALSE //whether we are active and generating chems
	var/potency = 2 //how much reagents we add every process (2 seconds)
	var/start_volume = 50
	var/points = 100

/obj/structure/reagent_dispensers/geyser/proc/start_chemming()
	activated = TRUE
	reagents.add_reagent(reagent_id, start_volume)
	START_PROCESSING(SSfluids, src) 
	var/mutable_appearance/I = mutable_appearance('icons/obj/lavaland/terrain.dmi', "[icon_state]_soup")
	I.color = mix_color_from_reagents(reagents.reagent_list)
	add_overlay(I)

/obj/structure/reagent_dispensers/geyser/process()
	if(activated && reagents.total_volume <= reagents.maximum_volume) //this is also evaluated in add_reagent, but from my understanding proc calls are expensive and should be avoided in continous
		reagents.add_reagent(reagent_id, potency)						   //processes

/obj/structure/reagent_dispensers/geyser/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/t_scanner/adv_mining_scanner))
		if(activated)
			to_chat(user, span_warning("The [src] is already activated!"))
			return
		to_chat(user, span_notice("You start activating the [src]...")) ///Power of mining scanners
		if(do_after(user, 3 SECONDS, src))
			to_chat(user, span_notice("You activate the [src]"))
			var/obj/item/card/id/I = user.get_idcard(TRUE)
			if(I)
				to_chat(user, span_notice("You gain 100 mining points for scanning the [src]."))
				I.mining_points += points
				playsound(src, 'sound/machines/ping.ogg', 15, TRUE)
			start_chemming()
	. = ..()

/obj/structure/reagent_dispensers/geyser/boom()  /// Fuck you, no boom 
	return  

/obj/structure/reagent_dispensers/geyser/random
	var/list/options = list(/datum/reagent/oil = 2, /datum/reagent/clf3 = 1) //fucking add more

/obj/structure/reagent_dispensers/geyser/random/Initialize()
	. = ..()
	reagent_id = pickweight(options)

///Unused shit
/obj/item/plunger
	name = "plunger"
	desc = "It's a plunger for plunging."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "plunger"

	var/plunge_mod = 1 //time*plunge_mod = total time we take to plunge an object
	var/reinforced = FALSE //whether we do heavy duty stuff like geysers

/obj/item/plunger/attack_obj(obj/O, mob/living/user)
	if(!O.plunger_act(src, user, reinforced))
		return ..()

/obj/item/plunger/reinforced
	name = "reinforced plunger"
	desc = " It's an M. 7 Reinforced Plunger© for heavy duty plunging."
	icon_state = "reinforced_plunger"

	reinforced = TRUE
	plunge_mod = 0.8
