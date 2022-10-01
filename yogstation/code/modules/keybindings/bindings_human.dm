/mob/living/carbon/human/key_down(datum/keyinfo/I, client/user)
	if(user.prefs.bindings.isheld_key("Shift"))
		switch(I.action)
			if(ACTION_EQUIP) // Put held thing in belt or take out most recent thing from belt
				if(incapacitated())
					return
				var/obj/item/thing = get_active_held_item()
				var/obj/item/equipped_belt = get_item_by_slot(SLOT_BELT)
				if(!equipped_belt) // We also let you equip a belt like this
					if(!thing)
						to_chat(user, span_notice("You have no belt to take something out of."))
						return
					if(equip_to_slot_if_possible(thing, SLOT_BELT))
						update_inv_hands()
					return
				if(!SEND_SIGNAL(equipped_belt, COMSIG_CONTAINS_STORAGE)) // not a storage item
					if(!thing)
						equipped_belt.attack_hand(src)
					else
						to_chat(user, span_notice("You can't fit anything in."))
					return
				if(thing) // put thing in belt
					if(!SEND_SIGNAL(equipped_belt, COMSIG_TRY_STORAGE_INSERT, thing, user.mob))
						to_chat(user, span_notice("You can't fit anything in."))
					return
				if(!equipped_belt.contents.len) // nothing to take out
					to_chat(user, span_notice("There's nothing in your belt to take out."))
					return
				var/obj/item/stored = equipped_belt.contents[equipped_belt.contents.len]
				if(!stored || stored.on_found(src))
					return
				stored.attack_hand(src) // take out thing from belt
				return

			if(ACTION_RESIST) // Put held thing in backpack or take out most recent thing from backpack
				if(incapacitated())
					return
				var/obj/item/thing = get_active_held_item()
				var/obj/item/equipped_back = get_item_by_slot(SLOT_BACK)
				if(!equipped_back) // We also let you equip a backpack like this
					if(!thing)
						to_chat(user, span_notice("You have no backpack to take something out of."))
						return
					if(equip_to_slot_if_possible(thing, SLOT_BACK))
						update_inv_hands()
					return
				if(!SEND_SIGNAL(equipped_back, COMSIG_CONTAINS_STORAGE)) // not a storage item
					if(!thing)
						equipped_back.attack_hand(src)
					else
						to_chat(user, span_notice("You can't fit anything in."))
					return
				if(thing) // put thing in backpack
					if(!SEND_SIGNAL(equipped_back, COMSIG_TRY_STORAGE_INSERT, thing, user.mob))
						to_chat(user, span_notice("You can't fit anything in."))
					return
				if(!equipped_back.contents.len) // nothing to take out
					to_chat(user, span_notice("There's nothing in your backpack to take out."))
					return
				var/obj/item/stored = equipped_back.contents[equipped_back.contents.len]
				if(!stored || stored.on_found(src))
					return
				stored.attack_hand(src) // take out thing from backpack
				return

			if(ACTION_DROP) // Put held thing in suit storage or take thing out of suit storage
				var/obj/item/thing = get_active_held_item()
				var/obj/item/equipped_suit = get_item_by_slot(SLOT_S_STORE)
				if(!equipped_suit) 
					if(!thing)
						to_chat(user, span_notice("You have no suit storage to take something out of."))
						return
					if(equip_to_slot_if_possible(thing, SLOT_S_STORE))
						update_inv_hands()
					return
				if(!SEND_SIGNAL(equipped_suit, COMSIG_CONTAINS_STORAGE)) // not a storage item
					if(!thing)
						equipped_suit.attack_hand(src)
					else
						to_chat(user, span_notice("You can't fit anything in."))
					return
				if(thing) // put thing in suit storage
					if(!SEND_SIGNAL(equipped_suit, COMSIG_TRY_STORAGE_INSERT, thing, user.mob))
						to_chat(user, span_notice("You can't fit anything in."))
					return
				if(!equipped_suit.contents.len) // nothing to take out
					to_chat(user, span_notice("There's nothing in your suit storage to take out."))
					return
				var/obj/item/stored = equipped_suit.contents[equipped_suit.contents.len]
				if(!stored || stored.on_found(src))
					return
				stored.attack_hand(src) // take out thing from suit storage
				return

	return ..()
