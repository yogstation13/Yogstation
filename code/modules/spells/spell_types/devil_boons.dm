/datum/action/cooldown/spell/summon_wealth
	name = "Summon wealth"
	desc = "The reward for selling your soul."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "moneybag"

	school = SCHOOL_CONJURATION
	invocation_type = INVOCATION_NONE

	cooldown_time = 10 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/summon_wealth/cast(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE
	if(user.dropItemToGround(user.get_active_held_item()))
		var/obj/item = pick(
			new /obj/item/coin/gold(user.drop_location()),
			new /obj/item/coin/diamond(user.drop_location()),
			new /obj/item/coin/silver(user.drop_location()),
			new /obj/item/clothing/accessory/medal/gold(user.drop_location()),
			new /obj/item/stack/sheet/mineral/gold(user.drop_location()),
			new /obj/item/stack/sheet/mineral/silver(user.drop_location()),
			new /obj/item/stack/sheet/mineral/diamond(user.drop_location()),
			new /obj/item/holochip(user.drop_location(), 1000))
		user.put_in_hands(item)

	return TRUE

/datum/action/cooldown/spell/view_range
	name = "Distant vision"
	desc = "The reward for selling your soul."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_jump"

	invocation_type = INVOCATION_NONE

	cooldown_time = 5 SECONDS
	spell_requirements = NONE
	var/ranges = list(7,8,9,10)

/datum/action/cooldown/spell/view_range/cast(mob/living/C)
	. = ..()
	if(!.)
		return FALSE
	C.client?.view_size.setTo(tgui_input_list(C, "Select view range:", "Range", ranges))
	
	return TRUE

/datum/action/cooldown/spell/summon_friend
	name = "Summon Friend"
	desc = "The reward for selling your soul."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "sacredflame"
	
	invocation_type = INVOCATION_NONE

	cooldown_time = 5 SECONDS
	spell_requirements = NONE
	var/mob/living/friend
	var/obj/effect/mob_spawn/human/demonic_friend/friendShell

/datum/action/cooldown/spell/summon_friend/cast(mob/living/C)
	. = ..()
	if(!.)
		return FALSE
	if(!QDELETED(friend))
		to_chat(friend, span_userdanger("Your master has deemed you a poor friend.  Your durance in hell will now resume."))
		friend.dust(TRUE)
		qdel(friendShell)
		return
	if(!QDELETED(friendShell))
		qdel(friendShell)
		return
	var/mob/living/L = C
	friendShell = new /obj/effect/mob_spawn/human/demonic_friend(L.loc, L.mind, src)

	return TRUE

/datum/action/cooldown/spell/conjure_item/spellpacket/robeless
	spell_requirements = NONE
