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

/obj/item/implant/dusting/iaa/removed(mob/living/source, silent, special)
	if(!defused)
		activate("tampering")
	else
		. = ..()

/obj/item/implant/dusting/iaa/activate(cause)
	. = ..()
	var/turf/my_turf = get_turf(src)
	var/obj/item/iaa_reward/drop = new(my_turf)
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
		to_chat(user, span_notice("\The [src] transforms into 3 telecrystals!"))
		var/hand_index = user.get_held_index_of_item(src)
		user.dropItemToGround(src, TRUE, TRUE)
		var/obj/item/stack/telecrystal/three/reward = new
		if(!user.put_in_hand(reward, hand_index))
			reward.forceMove(get_turf(user))
		// Spawn new IAA
		if(istype(SSticker.mode, /datum/game_mode/traitor/internal_affairs))
			var/datum/game_mode/traitor/internal_affairs/iaa_mode = SSticker.mode
			if(iaa_mode.create_new_traitor())
				to_chat(user, span_warning("You feel like someone is watching you... Keep on your guard."))
		qdel(src)
	else
		to_chat(user, span_notice("\The [src] doesn't seem to do anything."))
