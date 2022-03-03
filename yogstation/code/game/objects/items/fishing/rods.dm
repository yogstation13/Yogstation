/obj/item/fishingrod
	name = "fishing rod"
	desc = "A fishing rod used for fishing."
	icon = 'yogstation/icons/obj/fishing/fishing.dmi'
	icon_state = "fishing_rod"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	usesound = 'sound/items/crowbar.ogg'
	slot_flags = ITEM_SLOT_BACK
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=50)

	var/initial_fishing_power = 10
	var/fishing_power = 10
	var/obj/item/reagent_containers/food/snacks/bait/bait = null //what bait is attached to the rod
	var/allowed_fishing_turfs = list(/turf/open/water)
	var/fishing = FALSE
	var/attemptcatch = FALSE
	var/bobber_image = 'yogstation/icons/obj/fishing/fishing.dmi'
	var/bobber_icon_state =  "bobber"
	var/max_fishing_tries = 8
	var/fishing_timer
	var/turf/fishing_turf //what turf we are fishing in

	var/list/rewards = list(
		/obj/item/reagent_containers/food/snacks/fish/goldfish,
		/obj/item/reagent_containers/food/snacks/fish/goldfish/giant,
		/obj/item/reagent_containers/food/snacks/fish/salmon,
		/obj/item/reagent_containers/food/snacks/fish/bass,
		/obj/item/reagent_containers/food/snacks/fish/tuna,
		/obj/item/reagent_containers/food/snacks/fish/shrimp,
		/obj/item/reagent_containers/food/snacks/fish/squid,
		/obj/item/reagent_containers/food/snacks/fish/puffer
	)


/obj/item/fishingrod/attackby(obj/item/B, mob/user, params)
	if(istype(B,/obj/item/reagent_containers/food/snacks/bait))
		if(bait)
			var/oldbait = bait
			if(!user.transferItemToLoc(B,src))
				return
			bait = B
			to_chat(user, "you attach the [bait] to the fishing rod.")
			cut_overlays()
			add_overlay(bait)
			user.put_in_hands(oldbait)
		else
			if(!user.transferItemToLoc(B,src))
				return
			bait = B
			add_overlay(bait)
		calculate_fishing_power()

/obj/item/fishingrod/proc/calculate_fishing_power()
	fishing_power = initial(fishing_power) + bait.fishing_power

/obj/item/fishingrod/examine(mob/user)
	. = ..()
	. += "It's current fishing power is [fishing_power]."

/obj/item/fishingrod/AltClick(mob/living/user)
	if(bait)
		user.put_in_hands(bait)
		to_chat(user, "you take the [bait] off the fishing rod.")
		bait = null

/obj/item/fishingrod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!fishing_turf)
		fishing_turf = target;
	else if(target == fishing_turf)
		if(istype(fishing_turf,/turf/open/water/safe))
			to_chat(user, "Hit water")
			if(fishing && attemptcatch)
				//you catch the fish
				catch_fish(target,user)
				return
			else
				to_chat(user, "You attempt to cast your rod.")
				if(!fishing)
					fishing = TRUE
					if(!do_after(user, 2 SECONDS,TRUE,user))
						fishing = FALSE
						return
					to_chat(user, "You cast out your fishing rod.")
					//you are attempting to fish
					fishing_turf.add_overlay(mutable_appearance(bobber_image,bobber_icon_state))

					//do fun stuff
					for(var/attempts = 0 to max_fishing_tries)
						if(!do_after(user,2 SECONDS,TRUE,user)) 
							reel_in(user)
							break
						if(!fishing) //see if you're still fishing
							break 
						//see if you catch a fish
						if(prob(fishing_power)) 
							to_chat(user, "You got something!")
							//reward
							attemptcatch = TRUE
							do_fishing_alert(user);
							fishing_timer = addtimer(CALLBACK(src,.proc/reaction_check, user),20)
							return
						else
							to_chat(user, "Nothing bites...")
					reel_in(user)
				else
					reel_in(user)
	else
		to_chat(user, "You are not fishing on this turf!")
		
/obj/item/fishingrod/proc/reaction_check(mob/user)
	if(attemptcatch) 
		attemptcatch = FALSE
		to_chat(user,"It got away..")
		fishing = FALSE;
		fishing_turf.cut_overlay(mutable_appearance(bobber_image,bobber_icon_state))
		to_chat(user, "You reel in your fishing rod")
		fishing = FALSE
		fishing_turf.cut_overlay(mutable_appearance(bobber_image,bobber_icon_state))

/obj/item/fishingrod/proc/do_fishing_alert(atom/A)
	playsound(A.loc, 'sound/machines/chime.ogg', 50, FALSE, -5)
	var/image/I = image('icons/obj/closet.dmi', A, "cardboard_special", A.layer+1)
	flick_overlay_view(I, A, 8)
	I.alpha = 0
	animate(I, pixel_z = 32, alpha = 255, time = 2, easing = ELASTIC_EASING)

/obj/item/fishingrod/proc/reel_in(mob/living/user)
	if(fishing_timer)
		deltimer(fishing_timer)
	to_chat(user, "You reel in your fishing rod.")
	fishing = FALSE
	if(fishing_turf)
		fishing_turf.cut_overlay(mutable_appearance(bobber_image,bobber_icon_state))

/obj/item/fishingrod/proc/catch_fish(atom/target, mob/living/user)
	var/obj/picked_loot = pick(rewards)
	var/obj/spawned_loot = new picked_loot(get_turf(target.loc))
	if(!user.put_in_hands(spawned_loot)) //if they are holding something besides their rod, naughty naughty
		spawned_loot.throw_at(user,2,3) //whip it at them
	fishing = FALSE;
	fishing_turf.cut_overlay(mutable_appearance(bobber_image,bobber_icon_state))
	attemptcatch = FALSE
	if(istype(spawned_loot,/obj/item/reagent_containers/food/snacks/fish))
		to_chat(user,"You pull a [spawned_loot.name] off your line!")
	else
		to_chat(user,"you fish up [spawned_loot.name].")



