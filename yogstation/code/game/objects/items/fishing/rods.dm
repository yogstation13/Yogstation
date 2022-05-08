/obj/item/twohanded/fishingrod
	name = "fishing rod"
	desc = "A rod used for fishing. Despite ordinary appearances, fishing has evolved to suit the cosmos with various features, like auto-reeling."
	icon = 'yogstation/icons/obj/fishing/fishing.dmi'
	icon_state = "fishing_rod"
	lefthand_file = 'icons/mob/inhands/equipment/fishing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	usesound = 'sound/items/crowbar.ogg'
	slot_flags = ITEM_SLOT_BACK
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=50)

	var/fishing_power = 10
	var/obj/item/reagent_containers/food/snacks/bait/bait = null //what bait is attached to the rod
	var/fishing = FALSE
	var/bobber_image = 'yogstation/icons/obj/fishing/fishing.dmi'
	var/bobber_icon_state =  "bobber"
	var/static/mutable_appearance/bobber = mutable_appearance('yogstation/icons/obj/fishing/fishing.dmi',"bobber")
	var/datum/component/fishable/fishing_component
	var/mob/fisher
	var/bite = FALSE

	

/obj/item/twohanded/fishingrod/examine(mob/user)
	. = ..()
	. += "Its current fishing power is [fishing_power]."

/obj/item/twohanded/fishingrod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	var/datum/component/fishable/fc = target.GetComponent(/datum/component/fishable)
	if(!fc)
		return ..()
	if(!fishing)
		if(!wielded)
			to_chat(user, span_warning("You need to wield the rod in both hands before you can cast it!"))
			return
		cast(fc,user)
	else
		if(fc != fishing_component)
			to_chat(user, span_warning("You are not fishing here!"))
			return
		reel_in() //intentionally able to reel in with one hand

/obj/item/twohanded/fishingrod/process()
	if(!fishing)
		return PROCESS_KILL
	if(bite)
		to_chat(fisher, span_warning("Whatever was on the line drifts back into the deep..."))
		bite = FALSE
		return

	if(prob(50))
		to_chat(fisher, span_boldnotice("Something bites! Reel it in!"))
		bite = TRUE
		do_fishing_alert(fisher)

/obj/item/twohanded/fishingrod/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/twohanded/fishingrod/proc/cast(datum/component/fishable/fc,mob/user)
	fishing = TRUE
	fishing_component = fc
	var/turf/fishing_turf = fishing_component.parent
	fishing_turf.add_overlay(bobber)
	fisher = user
	RegisterSignal(user,COMSIG_MOVABLE_MOVED, .proc/reel_in_forced,TRUE)
	RegisterSignal(src,COMSIG_MOVABLE_MOVED, .proc/reel_in_forced,TRUE)
	RegisterSignal(src,COMSIG_ITEM_DROPPED, .proc/reel_in_forced,TRUE)
	START_PROCESSING(SSobj,src)
	playsound(fishing_component, 'sound/effects/splash.ogg', 50, FALSE, -5)
	to_chat(fisher, span_italics("You cast out your fishing rod..."))

/obj/item/twohanded/fishingrod/proc/reel_in(var/forced = FALSE)
	if(!forced && bite) // we got something!!!
		playsound(fishing_component, 'sound/effects/water_emerge.ogg', 50, FALSE, -5)
		spawn_reward()
	else
		playsound(fishing_component, 'sound/effects/splash.ogg', 50, FALSE, -5)
		if(forced)
			to_chat(fisher, span_boldnotice("The auto-reel on the fishing rod activates!"))
		else
			to_chat(fisher, span_italics("You reel in your fishing rod."))
		
	fishing = FALSE
	UnregisterSignal(fisher,COMSIG_MOVABLE_MOVED)
	UnregisterSignal(src,COMSIG_MOVABLE_MOVED)
	UnregisterSignal(src,COMSIG_ITEM_DROPPED)
	fisher = null
	STOP_PROCESSING(SSobj,src)
	var/turf/fishing_turf = fishing_component.parent
	fishing_turf.cut_overlay(bobber)
	fishing_component = null
	bite = FALSE //just to be safe

/obj/item/twohanded/fishingrod/proc/reel_in_forced()
	reel_in(forced = TRUE)

/obj/item/twohanded/fishingrod/proc/do_fishing_alert(atom/A)
	playsound(A.loc, 'sound/machines/chime.ogg', 50, FALSE, -5)
	var/image/I = image('icons/obj/closet.dmi', A, "cardboard_special", A.layer+1)
	flick_overlay_view(I, A, 8)
	I.alpha = 0
	animate(I, pixel_z = 32, alpha = 255, time = 2, easing = ELASTIC_EASING)

/obj/item/twohanded/fishingrod/proc/spawn_reward()
	var/obj/picked_reward = fishing_component.getCommonLoot()
	var/obj/reward_item = new picked_reward(fishing_component.parent)
	reward_item.alpha = 0
	reward_item.pixel_y = -12
	animate(reward_item,time = 0.25 SECONDS,pixel_y = 0,alpha = 255,easing = SINE_EASING)
	if(!fisher) //uh oh
		return
	fisher.visible_message(span_notice("[fisher] reels in a [reward_item]!"), span_notice("You reel in a [reward_item]!"))
	if(fisher.Adjacent(fishing_component.parent))
		unwield(fisher,show_message = FALSE)
		if(fisher.put_in_hands(reward_item))
			return
	reward_item.throw_at(get_step(fishing_component,get_dir(fishing_component,fisher)),2,3,fisher) //whip it at them!
		

/obj/item/twohanded/fishingrod/attackby(obj/item/B, mob/user, params)
	if(!istype(B,/obj/item/reagent_containers/food/snacks/bait))
		return

	if(bait)
		user.put_in_hands(bait)

	if(!user.transferItemToLoc(B,src))
		return
	bait = B
	to_chat(user, span_notice("You attach the [bait] to the fishing rod."))
	cut_overlays()
	add_overlay("fishing_rod_[bait.icon_state]")
	recalculate_power()

/obj/item/twohanded/fishingrod/AltClick(mob/living/user)
	if(bait)
		user.put_in_hands(bait)
		to_chat(user, span_notice("You take the [bait] off the fishing rod."))
		bait = null
		recalculate_power()

/obj/item/twohanded/fishingrod/proc/recalculate_power()
	fishing_power = initial(fishing_power)
	if(bait)
		fishing_power += bait.fishing_power
