/datum/quirk/stowaway
	name = "Stowaway"
	desc = "You wake up inside a random locker with only a crude fake for an ID card."
	value = -2
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_HIDE_FROM_SCAN
	icon = FA_ICON_SUITCASE

/datum/quirk/stowaway/add_unique()
	var/mob/living/carbon/human/stowaway = quirk_holder
	stowaway.Sleeping(5 SECONDS)
	var/obj/item/card/id/trashed = stowaway.get_item_by_slot(ITEM_SLOT_ID) //No ID
	qdel(trashed)

	var/obj/item/card/id/fake_card/card = new(quirk_holder.drop_location()) //a fake ID with two uses for maint doors
	quirk_holder.equip_to_slot_if_possible(card, ITEM_SLOT_ID)
	card.register_name(quirk_holder.real_name)

	if(prob(20))
		stowaway.adjust_drunk_effect(50) //What did I DO last night?
	var/obj/structure/closet/selected_closet = get_unlocked_closed_locker() //Find your new home
	if(selected_closet)
		stowaway.forceMove(selected_closet) //Move in

/datum/quirk/stowaway/post_add()
	to_chat(quirk_holder, span_boldnotice("You've awoken to find yourself inside [GLOB.station_name] without real identification!"))
	addtimer(CALLBACK(quirk_holder.mind, TYPE_PROC_REF(/datum/mind, remove_from_manifest)), 5 SECONDS)

/obj/item/card/id/fake_card //not a proper ID but still shares a lot of functions
	name = "\"ID Card\""
	desc = "Definitely a legitimate ID card and not a piece of notebook paper with a magnetic strip drawn on it. You'd have to stuff this in a card reader by hand for it to work."
	icon = 'icons/obj/card.dmi'
	icon_state = "counterfeit"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	resistance_flags = FIRE_PROOF | ACID_PROOF
	registered_account = null
	accepts_accounts = FALSE
	registered_name = "Nohbdy"
	access = list(ACCESS_MAINT_TUNNELS)
	var/uses = 2

/obj/item/card/id/fake_card/proc/register_name(new_name)
	registered_name = new_name
	name = "[new_name]'s \"ID Card\""

/obj/item/card/id/fake_card/proc/used()
	uses -= 1
	switch(uses)
		if(0)
			icon_state = "counterfeit_torn2"
		if(1)
			icon_state = "counterfeit_torn"
		else
			icon_state = "counterfeit" //in case you somehow repair it to 3+

/obj/item/card/id/fake_card/AltClick(mob/living/user)
	return //no accounts on fake cards

/obj/item/card/id/fake_card/examine(mob/user)
	. = ..()
	switch(uses)
		if(0)
			. += "It's too shredded to fit in a scanner!"
		if(1)
			. += "It's falling apart!"
		else
			. += "It looks frail!"
