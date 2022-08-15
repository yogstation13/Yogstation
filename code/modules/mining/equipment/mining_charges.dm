/obj/item/grenade/plastic/miningcharge
	name = "mining charge"
	desc = "Used to make big holes in rocks. Only works on rocks!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining-charge-2"
	det_time = 5 //uses real world seconds cause screw you i guess
	boom_sizes = list(1,3,5)
	alert_admins = FALSE
	var/hacked = FALSE

/obj/item/grenade/plastic/miningcharge/Initialize()
	. = ..()
	plastic_overlay = mutable_appearance(icon, "[icon_state]_active", ON_EDGED_TURF_LAYER)

/obj/item/grenade/plastic/miningcharge/examine(mob/user)
	. = ..()
	if(hacked)
		. += "Its wiring is haphazardly changed."

/obj/item/grenade/plastic/miningcharge/attack_self(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self(user)

/obj/item/grenade/plastic/miningcharge/afterattack(atom/movable/AM, mob/user, flag, notify_ghosts = FALSE)
	if(ismineralturf(AM) || hacked)
		..()
	else
		to_chat(user,span_warning("The charge only works on rocks!"))

/obj/item/grenade/plastic/miningcharge/prime()
	if(hacked) //big boom override
		var/turf/location = get_turf(target)
		explosion(location, boom_sizes[1], boom_sizes[2], boom_sizes[3])
		qdel(src)
		return //don't know if this is needed...
	var/turf/closed/mineral/location = get_turf(target)
	location.attempt_drill(null,TRUE,3) //orange says it doesnt include the actual middle
	for(var/turf/closed/mineral/rock in circlerangeturfs(location,boom_sizes[3]))
		var/distance = get_dist_euclidian(location,rock)
		if(distance <= boom_sizes[1])
			rock.attempt_drill(null,TRUE,3)
		else if (distance <= boom_sizes[2])
			rock.attempt_drill(null,TRUE,2)
		else if (distance <= boom_sizes[3])
			rock.attempt_drill(null,TRUE,1)
	for(var/mob/living/carbon/C in circlerange(location,boom_sizes[3]))
		if(ishuman(C) && C.soundbang_act(1, 0))
			to_chat(C, span_warning("<font size='2'><b>You are knocked down by the power of the mining charge!</font></b>"))
			var/distance = get_dist_euclidian(location,C)
			C.Knockdown((boom_sizes[3] - distance) * 1 SECONDS) //1 second for how close you are to center if you're in range
			C.adjustEarDamage(0, (boom_sizes[3] - distance) * 5) //5 ear damage for every tile you're closer to the center
	qdel(src)

			
/obj/item/grenade/plastic/miningcharge/deconstruct(disassembled = TRUE) //no gibbing a miner with pda bombs
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/plastic/miningcharge/proc/override_safety()
	hacked = TRUE
	boom_sizes[1] = max(boom_sizes[1]/3, 1) //sorry, too powerful otherwise.
	boom_sizes[2] = max(boom_sizes[2]/3, 1)
	boom_sizes[3] = max(boom_sizes[3]/3, 1)
	alert_admins = TRUE //i'm telling teacher you're gibbing clown!

//MINING CHARGE HACKER
/obj/item/t_scanner/adv_mining_scanner/syndicate
	var/charges = 6

/obj/item/t_scanner/adv_mining_scanner/syndicate/examine(mob/user)
	. = ..()
	if(is_syndicate(user)) //helpful to other syndicates
		. += "This scanner has an extra port for overriding mining charge safeties."

/obj/item/t_scanner/adv_mining_scanner/syndicate/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!is_syndicate(user)) 
		. = ..() //just a normal scanner...
		return
	if(istype(target,/obj/item/grenade/plastic/miningcharge))
		var/obj/item/grenade/plastic/miningcharge/charge = target
		if(charge.hacked)
			to_chat(span_notice("[src] is already overridden!"))
			return
		if(charges <= 0)
			to_chat(span_notice("Its overriding function is depleted."))
			return
		charge.override_safety()
		visible_message(span_warning("Sparks fly out of [src]!"), span_notice("You override [src], disabling its safeties."))
		playsound(src, "sparks", 50, 1)
		charges--
		if(charges <= 0)
			to_chat(span_warning("[src]'s internal battery for overriding mining charges has run dry!"))
	
/obj/item/grenade/plastic/miningcharge/lesser
	name = "lesser mining charge"
	desc = "A mining charge. This one seems less powerful than normal. Only works on rocks!"
	icon_state = "mining-charge-1"
	boom_sizes = list(1,2,3)

/obj/item/grenade/plastic/miningcharge/mega
	name = "mega mining charge"
	desc = "A mining charge. This one seems much more powerful than normal!"
	icon_state = "mining-charge-3"
	boom_sizes = list(2,4,7)

