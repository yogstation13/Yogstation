/obj/item/implant/dusting
	name = "duster implant"
	desc = "An alarm which monitors host vital signs, transmitting a radio message and dusting the corpse on death."
	actions_types = list(/datum/action/item_action/dusting_implant)
	var/popup = FALSE // is the DOUWANNABLOWUP window open?
	var/active = FALSE

/obj/item/implant/dusting/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Ultraviolet Corp XX-13 Security Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Vaporizes organic matter<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, electrically activated heat source that turns its host to ash upon activation, or their death. <BR>
				<b>Special Features:</b> Vaporizes<BR>
				"}
	return dat

/obj/item/implant/dusting/activate(cause)
	if(!cause || !imp_in || cause == "emp" || active)
		return FALSE
	if(cause == "action_button" && !popup)
		popup = TRUE
		var/response = alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to disintergrate!", "[name] Confirmation", "Yes", "No")
		popup = FALSE
		if(response == "No")
			return FALSE
	active = TRUE //to avoid it triggering multiple times due to dying
	to_chat(imp_in, "<span class='notice'>Your dusting implant activates!</span>")
	imp_in.visible_message("<span class='warning'>[imp_in] burns up in a flash!</span>")
	var/turf/T = get_turf(imp_in)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(T)], with cause of [cause].")
	for(var/obj/item/I in imp_in.contents)
		if(I == src || I == imp_in)
			continue
		 qdel(I)
	imp_in.dust()

/obj/item/implant/dusting/on_mob_death(mob/living/L, gibbed)
	activate("death")

/obj/item/implant/dusting/emp_act()
	return

/obj/item/implant/dusting/iaa
	var/defused = FALSE // For safe removal, admin-only
	var/reward_type = /obj/item/iaa_reward

/obj/item/implant/dusting/iaa/removed(mob/living/source, silent, special)
	if(!defused)
		activate("tampering")
	else
		. = ..()

/obj/item/implant/dusting/iaa/activate(cause)
	if(active)
		return
	. = ..()
	var/turf/my_turf = get_turf(src)
	var/obj/item/drop = new reward_type(my_turf)
	if(imp_in)
		drop.desc = "A syndicate 'dog tag' with an inscription that reads [imp_in.real_name]. Seems like it would be a bad idea to let someone evil press this."

/obj/item/iaa_reward
	name = "syndicate button"
	desc = "A syndicate 'dog tag' with an unreadable inscription. Seems like it would be a bad idea to let someone evil press this."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	resistance_flags = INDESTRUCTIBLE // no cremation cheese!

/obj/item/iaa_reward/attack_self(mob/user)
	. = ..()
	if(is_syndicate(user))
		// Reward
		var/list/item_list = list( // Contract kit random items
			/obj/item/grenade/plastic/x4,
			/obj/item/restraints/legcuffs/bola/tactical,
			/obj/item/gun/syringe/syndicate,
			/obj/item/pen/red/edagger,
			/obj/item/pen/blue/sleepy,
			/obj/item/flashlight/emp,
			/obj/item/book/granter/crafting_recipe/weapons,
			/obj/item/clothing/shoes/chameleon/noslip/syndicate,
			/obj/item/storage/firstaid/tactical,
			/obj/item/clothing/shoes/airshoes,
			/obj/item/clothing/glasses/thermal/syndi,
			/obj/item/camera_bug,
			/obj/item/implanter/radio/syndicate,
			/obj/item/implanter/uplink,
			/obj/item/clothing/gloves/krav_maga/combatglovesplus,
			// /obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot,
			/obj/item/reagent_containers/syringe/stimulants,
			/obj/item/implanter/freedom,
			/obj/item/storage/belt/chameleon/syndicate,
			// From here is extra items
			/obj/item/storage/belt/military/shadowcloak,
			/obj/item/grenade/syndieminibomb/concussion/frag,
			/obj/item/card/id/syndicate,
			/obj/item/storage/pill_bottle/gummies/omnizine
		)
		// Pick one item from three random
		item_list = shuffle(item_list)
		var/list/icons_available = list()
		var/obj/item/first_choice = item_list[1]
		var/obj/item/second_choice = item_list[2]
		var/obj/item/third_choice = item_list[3]
		icons_available += list(initial(first_choice.name) = image(icon = initial(first_choice.icon), icon_state = initial(first_choice.icon_state)))
		icons_available += list(initial(second_choice.name) = image(icon = initial(second_choice.icon), icon_state = initial(second_choice.icon_state)))
		icons_available += list(initial(third_choice.name) = image(icon = initial(third_choice.icon), icon_state = initial(third_choice.icon_state)))
		var/selection = show_radial_menu(user, src, icons_available, radius = 38, require_near = TRUE)
		if(!selection || selection == initial(first_choice.name))
			selection = first_choice
		else if(selection == initial(second_choice.name))
			selection = second_choice
		else if(selection == initial(third_choice.name))
			selection = third_choice
		var/hand_index = user.get_held_index_of_item(src)
		user.dropItemToGround(src, TRUE, TRUE)
		var/obj/item/reward = new selection
		to_chat(user, span_notice("\The [src] transforms into \a [reward]!"))
		if(!user.put_in_hand(reward, hand_index))
			reward.forceMove(get_turf(user))
		// Spawn new IAA
		if(istype(SSticker.mode, /datum/game_mode/traitor/internal_affairs))
			var/datum/game_mode/traitor/internal_affairs/iaa_mode = SSticker.mode
			var/mob/living/new_tot = iaa_mode.create_new_traitor()
			if(new_tot)
				to_chat(user, span_warning("You feel like someone is watching you... Keep on your guard."))
				message_admins("[ADMIN_LOOKUPFLW(new_tot)] was made into a new IAA by \a [src].")
		qdel(src)
	else
		to_chat(user, span_notice("\The [src] doesn't seem to do anything."))

//fake one for pseudocider
/obj/item/implant/dusting/iaa/fake
	reward_type = /obj/item/iaa_reward_fake
	
/obj/item/iaa_reward_fake
	name = "syndicate button"
	desc = "A syndicate 'dog tag' with an unreadable inscription. Seems like it would be a bad idea to let someone evil press this."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	resistance_flags = INDESTRUCTIBLE // no cremation cheese!

/obj/item/iaa_reward_fake/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 7 SECONDS)
