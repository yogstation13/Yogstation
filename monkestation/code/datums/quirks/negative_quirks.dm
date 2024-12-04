/datum/quirk/jailbird
	name = "Jailbird"
	desc = "You're a ex-criminal! You start the round set to parole for a random crime."
	value = 0
	icon = FA_ICON_CROW

/datum/quirk/jailbird/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source)
	// Don't bother adding to ghost players
	if(istype(new_holder, /mob/living/carbon/human/ghost))
		qdel(src)
		return FALSE
	return ..()

/datum/quirk/jailbird/post_add()
	. = ..()
	var/mob/living/carbon/human/jailbird = quirk_holder
	var/quirk_crime	= pick(world.file2list("monkestation/strings/random_crimes.txt"))
	to_chat(jailbird, "<span class='boldnotice'>You are on parole for the crime of: [quirk_crime]!</span>")
	addtimer(CALLBACK(src, PROC_REF(apply_arrest), quirk_crime), 10 SECONDS)


/datum/quirk/jailbird/proc/apply_arrest(crime_name)
	var/mob/living/carbon/human/jailbird = quirk_holder
	jailbird.mind.memories += "You have the law on your back because of your crime of: [crime_name]!"
	var/crime = "[pick(world.file2list("monkestation/strings/random_police.txt"))] [(rand(9)+1)] [pick("days", "weeks", "months", "years")] ago"
	var/perpname = jailbird.real_name
	var/datum/record/crew/jailbird_record = find_record(perpname)
	// remove quirk if we don't even have a record
	if(QDELETED(jailbird_record))
		qdel(src)
		return
	var/datum/crime/new_crime = new(name = crime_name, details = crime, author = "Nanotrasen Bounty Department")
	jailbird_record.crimes += new_crime
	jailbird_record.wanted_status = WANTED_PAROLE
	jailbird.sec_hud_set_security_status()

/datum/quirk/stowaway
	name = "Stowaway"
	desc = "You wake up inside a random locker with only a crude fake for an ID card."
	value = -2
	icon = FA_ICON_SUITCASE

/datum/quirk/stowaway/add_unique()
	. = ..()
	var/mob/living/carbon/human/stowaway = quirk_holder
	stowaway.Sleeping(5 SECONDS, TRUE, TRUE) //This is both flavorful and gives time for the rest of the code to work.
	var/obj/item/card/id/trashed = stowaway.get_item_by_slot(ITEM_SLOT_ID) //No ID
	qdel(trashed)

	var/obj/item/card/id/fake_card/card = new(get_turf(quirk_holder)) //a fake ID with two uses for maint doors
	quirk_holder.equip_to_slot_if_possible(card, ITEM_SLOT_ID)
	card.register_name(quirk_holder.real_name)

	if(prob(20))
		stowaway.adjust_drunk_effect(50) //What did I DO last night?
	var/obj/structure/closet/selected_closet = get_unlocked_closed_locker() //Find your new home
	if(selected_closet)
		stowaway.forceMove(selected_closet) //Move in

/datum/quirk/stowaway/post_add()
	. = ..()
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

//Used to get a random closed and non-secure locker on the station z-level, created for the Stowaway trait.
/proc/get_unlocked_closed_locker() //I've seen worse proc names
	var/list/picked_lockers = list()
	var/turf/object_location
	for(var/obj/structure/closet/find_closet in world)
		if(!istype(find_closet,/obj/structure/closet/secure_closet))
			object_location = get_turf(find_closet)
			if(object_location) //If it can't read a Z on the next step, it will error out. Needs a separate check.
				if(is_station_level(object_location.z) && !find_closet.opened) //On the station and closed.
					picked_lockers += find_closet
	if(picked_lockers)
		return pick(picked_lockers)
	return FALSE

/datum/quirk/kleptomaniac
	name = "Kleptomaniac"
	desc = "The station's just full of free stuff!  Nobody would notice if you just... took it, right?"
	value = -2
	icon = FA_ICON_BAG_SHOPPING

/datum/quirk/kleptomaniac/add()
	var/datum/brain_trauma/mild/kleptomania/T = new()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/kleptomaniac/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H.cure_trauma_type(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/unstable_ass
	name = "Unstable Rear"
	desc = "For reasons unknown, your posterior is unstable and will fall off more often."
	value = -1
	icon = FA_ICON_BOMB
	//All effects are handled directly in butts.dm

//IPC PUNISHMENT SYSTEM//
/datum/quirk/frail/add()
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.3
		human_quirk_holder.physiology.burn_mod *= 1.3

/datum/quirk/frail/post_add()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels frail."))

/datum/quirk/light_drinker/add()
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.1
		human_quirk_holder.physiology.burn_mod *= 1.1

/datum/quirk/light_drinker/post_add()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels very slightly weaker."))

/datum/quirk/prosthetic_limb/add()
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.15
		human_quirk_holder.physiology.burn_mod *= 1.15

/datum/quirk/prosthetic_limb/post_add()
	if(isipc(quirk_holder))
		to_chat(quirk_holder, span_boldnotice("Your chassis feels slightly weaker."))

/datum/quirk/quadruple_amputee/add() //monkestation addition
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.3
		human_quirk_holder.physiology.burn_mod *= 1.3

/datum/quirk/quadruple_amputee/post_add()
	if(isipc(quirk_holder)) //monkestation addition
		to_chat(quirk_holder, span_boldnotice("Your chassis feels frail."))

/datum/quirk/item_quirk/allergic/add() //monkestation addition
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	if(isipc(quirk_holder))
		human_quirk_holder.physiology.brute_mod *= 1.3
		human_quirk_holder.physiology.burn_mod *= 1.3

/datum/quirk/item_quirk/allergic/post_add()
	if(isipc(quirk_holder)) //monkestation addition
		to_chat(quirk_holder, span_boldnotice("Your chassis feels frail."))

/datum/quirk/tunnel_vision
	name = "Tunnel Vision"
	desc = "You spent too long scoped in. You cant see behind you!"
	value = -2
	icon = FA_ICON_QUESTION
	gain_text = span_notice("You have trouble focusing on what you left behind.")
	lose_text = span_notice("You feel paranoid, constantly checking your back...")
	medical_record_text = "Patient had trouble noticing people walking up from behind during the examination."

/datum/quirk/tunnel_vision/add_unique(client/client_source)
	var/range_name = client_source?.prefs.read_preference(/datum/preference/choiced/tunnel_vision_fov) || "Minor (90 Degrees)"
	var/fov_range
	switch(range_name)
		if ("Severe (270 Degrees)")
			fov_range = FOV_270_DEGREES
		if ("Moderate (180 Degrees)")
			fov_range = FOV_180_DEGREES
		else
			fov_range = FOV_90_DEGREES
	quirk_holder.add_fov_trait("tunnel vision quirk", fov_range)
/*
/datum/quirk/tunnel_vision/add()
	quirk_holder.add_fov_trait("tunnel vision quirk", fov_range)
*/
/datum/quirk/tunnel_vision/remove()
	quirk_holder.remove_fov_trait("tunnel vision quirk")

/datum/quirk/dnr
	name = "Do Not Revive"
	desc = "You cannot be defibrillated upon death. Make your only shot count."
	value = -8
	mob_trait = TRAIT_DEFIB_BLACKLISTED
	icon = FA_ICON_HEART
	gain_text = span_danger("You have one chance left.")
	lose_text = span_notice("Your connection to this mortal plane strengthens!")
	medical_record_text = "The connection between the patient's soul and body is incredibly weak, and attempts to resuscitate after death will fail. Ensure heightened care."

/datum/quirk/item_quirk/feeble
	name = "Feeble"
	desc = "All it takes is a strong gust of wind to knock you over, doing anything physical takes much longer and good luck using anything with recoil."
	mob_trait = TRAIT_FEEBLE
	value = -14
	icon = FA_ICON_PERSON_CANE
	gain_text = span_danger("You feel really weak.")
	lose_text = span_notice("You feel much less weak.")
	medical_record_text = "Patient is suffering from poor dexterity and general physical strength."
	mail_goodies = list(/obj/item/cane, /obj/item/cane/white, /obj/item/cane/crutch, /obj/item/cane/crutch/wood)

/datum/quirk/item_quirk/feeble/add_unique(client/client_source)
	give_item_to_holder(/obj/item/cane, list(LOCATION_HANDS = ITEM_SLOT_HANDS, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK))

/datum/movespeed_modifier/feeble_quirk_ground
	variable = TRUE
	movetypes = GROUND

/datum/movespeed_modifier/feeble_quirk_not_ground
	multiplicative_slowdown = 1
	blacklisted_movetypes = GROUND

/datum/actionspeed_modifier/feeble_quirk
	multiplicative_slowdown = 2.2

/datum/quirk/item_quirk/feeble/add()
	quirk_holder.add_movespeed_modifier(/datum/movespeed_modifier/feeble_quirk_not_ground)
	quirk_holder.add_actionspeed_modifier(/datum/actionspeed_modifier/feeble_quirk)
	feeble_quirk_update_slowdown(quirk_holder)

/datum/quirk/item_quirk/feeble/remove()
	quirk_holder.remove_movespeed_modifier(/datum/movespeed_modifier/feeble_quirk_ground)
	quirk_holder.remove_movespeed_modifier(/datum/movespeed_modifier/feeble_quirk_not_ground)
	quirk_holder.remove_actionspeed_modifier(/datum/actionspeed_modifier/feeble_quirk)

/proc/feeble_quirk_update_slowdown(mob/living/target)
	var/slowdown = 2.2 // Same slowdown as the walk intent
	var/list/slowdown_mods = list()
	SEND_SIGNAL(target, COMSIG_LIVING_FEEBLE_MOVESPEED_UPDATE, slowdown_mods)
	for(var/num in slowdown_mods)
		slowdown *= num
	target.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/feeble_quirk_ground, multiplicative_slowdown = slowdown)

/proc/feeble_quirk_wound_chest(mob/living/carbon/target, hugger=null, force=FALSE)
	if (!istype(target))
		return
	var/obj/item/bodypart/chest = target.get_bodypart(BODY_ZONE_CHEST)
	if (!force && !prob((locate(/datum/wound/blunt) in chest.wounds) ? 30 : 15))
		return
	if (hugger)
		to_chat(hugger, span_danger("You feel something break inside [target]!"))
	if (locate(/datum/wound/blunt/bone/critical) in chest.wounds)
		playsound(target, 'sound/effects/wounds/crack2.ogg', 70 + (20 * 3), TRUE)
	else if (locate(/datum/wound/blunt/bone/severe) in chest.wounds)
		chest.force_wound_upwards(/datum/wound/blunt/bone/critical)
	else if (locate(/datum/wound/blunt/bone/rib_break) in chest.wounds)
		chest.force_wound_upwards(/datum/wound/blunt/bone/severe)
	else
		chest.force_wound_upwards(/datum/wound/blunt/bone/rib_break)
	chest.receive_damage(brute = 15)

/proc/feeble_quirk_slow_interact(mob/living/carbon/user, action, atom)
	if(!HAS_TRAIT(user, TRAIT_FEEBLE))
		return FALSE
	user.visible_message(span_notice("[user] struggles to [action] [atom]."), \
			span_notice("You struggle to [action] [atom]."))
	return !do_after(user, 2 SECONDS, target = atom)

/proc/feeble_quirk_recoil(mob/living/user, direction, is_gunshot)
	if (user.body_position == LYING_DOWN || user.buckled)
		if (is_gunshot)
			var/item = user.get_active_held_item()
			user.dropItemToGround(item)
			user.visible_message(span_danger("[item] flies out of [user]'s hand!"), \
				span_danger("The recoil makes [item] fly out of your hand!"))
		return FALSE
	user.Knockdown(4 SECONDS)
	user.visible_message(span_danger("[user] looses [user.p_their()] balance!"), \
		span_danger("You loose your balance!"))
	var/shove_dir = turn(direction, 180)
	if (!is_gunshot && prob(0.01))
		user.safe_throw_at(get_edge_target_turf(user, shove_dir), 8, 3, user, spin=FALSE)
	else
		var/turf/target_shove_turf = get_step(user.loc, shove_dir)
		var/turf/target_old_turf = user.loc
		user.Move(target_shove_turf, shove_dir)
		SEND_SIGNAL(target_shove_turf, COMSIG_CARBON_DISARM_COLLIDE, user, user, get_turf(user) == target_old_turf)
