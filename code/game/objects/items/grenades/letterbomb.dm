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

			var/datum/job/this_job = SSjob.GetJob(H.mind.assigned_role)
			if(!this_job || this_job.faction != "Station")//if they aren't someone that can normally get mail, they can't be a target
				continue

			var/crewmember_name = H.name

			while(crewmember_name in name_counts)
				name_counts[crewmember_name]++
				crewmember_name = text("[] ([])", crewmember_name, name_counts[crewmember_name])
			names[crewmember_name] = H
			name_counts[crewmember_name] = 1

		if(!names.len)
			user.visible_message(span_notice("[user]'s pinpointer fails to detect a signal."), span_notice("Your pinpointer fails to detect a signal."))
			return

		var/A = input(user, "Recipient of mail", "Target Selector") in sortList(names)// pick who the mail is for
		if(!A || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated())
			return

		to_chat(user, "You address the \"letter\" to[names[A] == user ? "... yourself?" : " [names[A]]." ]")
		var/datum/mind/recipient = names[A].mind
		initialize_for_recipient(recipient)
		letterbomb = new /obj/item/grenade/mailbomb(src)
		contents = null
		contents += letterbomb //overwrite the contents of the mail with a bomb
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
	det_time = 1.5 SECONDS //better throw it quickly

/obj/item/grenade/mailbomb/forceMove(atom/destination)//the moment it gets moved from the mail to the player's hands it primes
	. = ..()
	if(ishuman(destination))
		to_chat(destination, span_userdanger("Oh fuck!"))
		preprime(destination, null, FALSE)	
	else
		visible_message(span_warning("[src] starts beeping!"))
		preprime(loc, null, FALSE)	

/obj/item/grenade/mailbomb/preprime(mob/user, delayoverride, msg, volume)
	. = ..()
	icon_state = initial(icon_state)//there's no active icon for pipe bombs, so just force revert it to the default

/obj/item/grenade/mailbomb/prime()
	update_mob()
	explosion(src.loc,0,1,1)	//targeted, but if they can throw it away in time, little overall collateral damage
	qdel(src)
