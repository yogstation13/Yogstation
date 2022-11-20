/obj/item/mail/explosive
	var/assigned = FALSE //whether or not the details of the mail have been added
	var/letterbomb = /obj/item/grenade/mailbomb

/obj/item/mail/explosive/attack_self(mob/user)
	if(!assigned)//mixed pinpointer code with mailbox populate code to let people select the recipient of the mail
		var/list/name_counts = list()
		var/list/names = list()

		for(var/mob/living/carbon/human/H in GLOB.carbon_list)
			if(!H.mind)
				continue

			var/crewmember_name = "Unknown"
			if(H.wear_id)
				var/obj/item/card/id/I = H.wear_id.GetID()
				if(I && I.registered_name)
					crewmember_name = I.registered_name

			while(crewmember_name in name_counts)
				name_counts[crewmember_name]++
				crewmember_name = text("[] ([])", crewmember_name, name_counts[crewmember_name])
			names[crewmember_name] = H
			name_counts[crewmember_name] = 1

		if(!names.len)
			user.visible_message(span_notice("[user]'s pinpointer fails to detect a signal."), span_notice("Your pinpointer fails to detect a signal."))
			return

		var/A = input(user, "Person to track", "Pinpoint") in sortList(names)// pick who the mail is for
		if(!A || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !ishuman(A))
			return
			
		var/mob/living/carbon/human/victim = A
		if(!victim.mind)
			return

		var/datum/mind/recipient = victim.mind
		initialize_for_recipient(names[recipient])
		contents = new letterbomb(src) //overwrite the contents of the mail with a bomb
		assigned = TRUE
	else
		. = ..()
	
/obj/item/grenade/mailbomb
	name = "improvised pipebomb"
	desc = "A weak, improvised explosive with a mousetrap attached. For all your mailbombing needs."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "pipebomb"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	active = 0
	display_timer = 0
	det_time = 1 SECONDS //better throw it quickly

/obj/item/grenade/mailbomb/pickup(mob/user)
	. = ..()
	if(ishuman(user))
		to_chat(user, span_userdanger("Oh fuck!"))
		preprime(user, FALSE, FALSE)	
		return TRUE	//good luck~
	else
		visible_message(span_warning("[src] starts beeping!"))
		preprime(loc, FALSE, FALSE)	
		return FALSE

/obj/item/grenade/mailbomb/prime()
	update_mob()
	explosion(src.loc,-1,1,4)	// small explosion
	qdel(src)
