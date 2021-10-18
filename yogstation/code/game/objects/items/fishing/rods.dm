/obj/item/fishingrod
	name = "fishing rod"
	desc = "A fishing rod used for fishing."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	usesound = 'sound/items/crowbar.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
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


/obj/item/fishingrod/attackby(obj/item/B, mob/user, params)
	if(istype(B,/obj/item/reagent_containers/food/snacks/bait))
		if(bait)
			var/oldbait = bait
			if(!user.transferItemToLoc(B,src))
				return
			bait = B
			to_chat(user, "you attach the [bait] to the fishing rod.")
			user.put_in_hands(oldbait)
		else
			if(!user.transferItemToLoc(B,src))
				return
			bait = B
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

/obj/item/fishingrod/pre_attack(atom/target, mob/living/user)
	fishing_turf = target;
	if(fishing_turf)
		if(istype(fishing_turf,/turf/open/water/safe))
			to_chat(user, "Hit water")
			if(attemptcatch)
				//you catch the fish
				new /obj/item/reagent_containers/food/snacks/fishfingers(get_turf(user.loc))
				fishing = FALSE;
				fishing_turf.cut_overlay(mutable_appearance(bobber_image,bobber_icon_state))
				attemptcatch = FALSE
				return
			else
				to_chat(user, "attempting to feesh")
				if(!fishing)
					if(!do_after(user, 2 SECONDS,TRUE,user))
						return
					fishing = TRUE
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



