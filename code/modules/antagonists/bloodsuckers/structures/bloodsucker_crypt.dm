/obj/structure/bloodsucker
	icon = 'icons/obj/vamp_obj.dmi'
	///Who owns this structure?
	var/mob/living/owner
	/*
	 *	# Descriptions
	 *
	 *	We use vars to add descriptions to items.
	 *	This way we don't have to make a new /examine for each structure
	 *	And it's easier to edit.
	 */
	var/Ghost_desc
	var/Vamp_desc
	var/Vassal_desc
	var/Hunter_desc

/obj/structure/bloodsucker/examine(mob/user)
	. = ..()
	if(!user.mind && Ghost_desc != "")
		. += span_cult(Ghost_desc)
	if(IS_BLOODSUCKER(user) && Vamp_desc)
		if(!owner)
			. += span_cult("It is unsecured. Click on [src] while in your lair to secure it in place to get its full potential.")
			return
		. += span_cult(Vamp_desc)
	if(IS_VASSAL(user) && Vassal_desc != "")
		. += span_cult(Vassal_desc)
	if(IS_MONSTERHUNTER(user) && Hunter_desc != "")
		. += span_cult(Hunter_desc)

/// This handles bolting down the structure.
/obj/structure/bloodsucker/proc/bolt(mob/user)
	to_chat(user, span_danger("You have secured [src] in place."))
	to_chat(user, span_announce("* Bloodsucker Tip: Examine [src] to understand how it functions!"))
	owner = user

/// This handles unbolting of the structure.
/obj/structure/bloodsucker/proc/unbolt(mob/user)
	to_chat(user, span_danger("You have unsecured [src]."))
	owner = null

/obj/structure/bloodsucker/attackby(obj/item/item, mob/living/user, params)
	/// If a Bloodsucker tries to wrench it in place, yell at them.
	if(item.tool_behaviour == TOOL_WRENCH && !anchored && IS_BLOODSUCKER(user))
		user.playsound_local(null, 'sound/machines/buzz-sigh.ogg', 40, FALSE, pressure_affected = FALSE)
		to_chat(user, span_announce("* Bloodsucker Tip: Examine the Persuasion Rack to understand how it functions!"))
		return
	. = ..()

/obj/structure/bloodsucker/attack_hand(mob/user, list/modifiers)
//	. = ..() // Don't call parent, else they will handle unbuckling.
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	/// Claiming the Rack instead of using it?
	if(istype(bloodsuckerdatum) && !owner)
		if(!bloodsuckerdatum.lair)
			to_chat(user, span_danger("You don't have a lair. Claim a coffin to make that location your lair."))
			return FALSE
		if(bloodsuckerdatum.lair != get_area(src))
			to_chat(user, span_danger("You may only activate this structure in your lair: [bloodsuckerdatum.lair]."))
			return FALSE

		/// Menu for securing your Persuasion rack in place.
		switch(input("Do you wish to secure [src] here?") in list("Yes", "No"))
			if("Yes")
				user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
				bolt(user)
				return FALSE
		return FALSE
	return TRUE

/obj/structure/bloodsucker/AltClick(mob/user)
	. = ..()
	if(user == owner && user.Adjacent(src))
		switch(input("Unbolt [src]?") in list("Yes", "No"))
			if("Yes")
				unbolt(user)

////////////////////////////////////////////////////

#define ALTAR_RANKS_PER_DAY 2
/obj/structure/bloodsucker/bloodaltar
	name = "blood altar"
	desc = "It is made of marble, lined with basalt, and radiates an unnerving chill that puts your skin on edge."
	icon_state = "bloodaltar"
	density = TRUE
	anchored = FALSE
	climbable = TRUE
	pass_flags = LETPASSTHROW
	can_buckle = FALSE
	var/task_completed = FALSE
	var/sacrifices = 0
	var/sacrificialtask = FALSE
	var/organ_name = ""
	Ghost_desc = "This is a Blood Altar, where bloodsuckers can get two tasks per night to get more ranks."
	Vamp_desc = "This is a Blood Altar, which allows you to do two tasks per day to advance your ranks.\n\
		Interact with the Altar by clicking on it after it's bolted to get a task.\n\
		By checking your notes or the chat you can see what task needs to be done.\n\
		Remember you only get two tasks per night."
	Vassal_desc = "This is the blood altar, where your master does bounties to advanced their bloodsucking powers.\n\
		Aid your master by bringing them what they need for these bounties or help getting them."
	Hunter_desc = "This is a blood altar, where monsters usually practice a sort of bounty system to advanced their powers.\n\
		They normally sacrifice hearts or blood in exchange for these ranks, forcing them to move out of their lair.\n\
		It can only be used twice per night and it needs to be interacted it to be claimed, making bloodsuckers come back twice a night."

/obj/structure/bloodsucker/bloodaltar/bolt()
	. = ..()
	anchored = TRUE

/obj/structure/bloodsucker/bloodaltar/unbolt()
	. = ..()
	anchored = FALSE
	
/obj/structure/bloodsucker/bloodaltar/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!.)
		return FALSE
	if(!IS_BLOODSUCKER(user))
		to_chat(user, span_warning("You can't figure out how this works."))
		return FALSE
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum.altar_uses >= ALTAR_RANKS_PER_DAY)
		to_chat(user, span_notice("You have done all tasks for the night, come back tomorrow for more."))
		return
	var/task //just like amongus
	var/suckamount = 0
	var/heartamount = 0
	switch(bloodsuckerdatum.bloodsucker_level + bloodsuckerdatum.bloodsucker_level_unspent)
		if(0 to 3)
			suckamount = rand(100, 200)
			heartamount = rand(1,2)
		if(3 to 8)
			suckamount = rand(300, 400)
			heartamount = rand(3,4)
		if(8 to INFINITY)
			suckamount = rand(500, 600)
			heartamount = rand(5,6)
	if(bloodsuckerdatum.task_blood_drank >= suckamount || sacrifices >= heartamount)
		task_completed = TRUE
	if(task_completed)
		bloodsuckerdatum.task_memory = null
		bloodsuckerdatum.current_task = FALSE
		bloodsuckerdatum.bloodsucker_level_unspent++
		bloodsuckerdatum.altar_uses++
		bloodsuckerdatum.task_blood_drank = 0
		sacrifices = 0
		to_chat(user, span_notice("You have sucessfully done a task and gained a rank!"))
		task_completed = FALSE
		sacrificialtask = FALSE
		return
	if(bloodsuckerdatum.current_task)
		to_chat(user, span_warning("You already have a rank up task!"))
		return
	if(!bloodsuckerdatum.current_task)
		var/want_rank = alert("Do you want to gain a task? This will cost 100 Blood.", "Task Manager", "Yes", "No")
		if(want_rank == "No" || QDELETED(src))
			return
		var/mob/living/carbon/C = user
		if(C.blood_volume < 100)
			to_chat(user, span_danger("You don't have enough blood to gain a task!"))
			return
		C.blood_volume -= 100
		switch(rand(1, 3))
			if(1,2)
				task = "Suck [suckamount] units of pure blood."
			if(3)
				task = "Sacrifice [heartamount] hearts by using them on the altar."
				sacrificialtask = TRUE
		bloodsuckerdatum.task_memory += "<B>Current Rank Up Task</B>: [task]<br>"
		bloodsuckerdatum.current_task = TRUE
		to_chat(user, span_boldnotice("You have gained a new Task! [task] Remember to collect it by using the blood altar!"))

/obj/structure/bloodsucker/bloodaltar/examine(mob/user)
	. = ..()
	if(sacrificialtask)
		if(sacrifices > 0)
			. += span_boldnotice("It currently contains [sacrifices] [organ_name].")
	else 
		return ..()

/obj/structure/bloodsucker/bloodaltar/attackby(obj/item/H, mob/user, params)
	if(!IS_BLOODSUCKER(user) && !IS_VASSAL(user))
		return ..()
	if(sacrificialtask)
		if(istype(H, /obj/item/organ/heart))
			if(istype(H, /obj/item/organ/heart/gland))
				to_chat(usr, span_warning("This type of organ doesn't have blood to sustain the altar!"))
				return ..()
			organ_name = H.name
			to_chat(usr, span_notice("You feed the heart to the altar!"))
			qdel(H)
			sacrifices++
			return 
	return ..()
#undef ALTAR_RANKS_PER_DAY

////////////////////////////////////////////////////

/obj/structure/bloodsucker/bloodaltar/restingplace
	name = "resting place"
	desc = "This seem to hold a bit of significance."
	icon_state = "restingplace"
	var/awoken = FALSE
	Ghost_desc = "This is a Resting Place, where Lasombra bloodsucker can ascend their powers."
	Vamp_desc = "This is a Resting Place, which allows you to ascend your powers by gaining points using your ranks or blood.\n\
		Interact with the Altar by clicking on it after you have fed it a abyssal essence, acquirable through influences.\n\
		Remember most ascended powers have benefits if used in the dark.\n\
		It only seems to speak to elders of 4 or higher ranks."
	Vassal_desc = "This is the resting place, where your master does rituals to ascend their bloodsucking powers.\n\
		Aid your master by bringing them what they need for these or by help getting them."
	Hunter_desc = "This is a blood altar, where monsters ascend their powers to shadowy levels.\n\
		They normally need ranks or blood in exchange for power, forcing them to move out of their lair and weakening them."
	
/obj/item/abyssal_essence
	name = "abyssal essence"
	desc = "As you glare at the abyssal essence, you feel it glaring back."
	icon = 'icons/obj/vamp_obj.dmi'
	icon_state = "abyssal_essence"
	item_state = "abyssal_essence"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 10

/obj/structure/bloodsucker/bloodaltar/restingplace/deconstruct(disassembled = TRUE)
	. = ..()
	new /obj/item/abyssal_essence(src.loc)
	qdel(src)

/obj/structure/bloodsucker/bloodaltar/restingplace/attackby(obj/item/H, mob/user, params)
	if(!IS_BLOODSUCKER(user) && !IS_VASSAL(user))
		return ..()
	if(!awoken)
		if(istype(H, /obj/item/abyssal_essence))
			to_chat(usr, span_notice("As you touch [src] with the [H], you start sensing something different coming from [src]!"))
			qdel(H)
			awoken = TRUE
		else
			to_chat(user, span_cult("Seems like you need a direct link to the abyss to awaken [src]. Maybe searching a spacial influence would yield something."))
		return
	. = ..()

/obj/effect/reality_smash/attack_hand(mob/user, list/modifiers) // this is important
	if(!IS_BLOODSUCKER(user)) //only bloodsucker will attack this with their hand
		return
	if(INTERACTING_WITH(user, src))
		return
	if(user.mind in src.siphoners)
		to_chat(user, span_danger("You have already harvested this shard!"))
		return
	to_chat(user, span_danger("You start to harvest the energy of [src]..."))
	if(do_after(user, 10 SECONDS, src))
		user.put_in_hands(new /obj/item/abyssal_essence)
		to_chat(user, span_notice("You finish harvesting the energy of [src]!"))
		src.siphoners |= user.mind

/obj/structure/bloodsucker/bloodaltar/restingplace/attack_hand(mob/user, list/modifiers)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!IS_BLOODSUCKER(user))
		return ..()
	if(bloodsuckerdatum.my_clan == CLAN_LASOMBRA)
		if(bloodsuckerdatum.clanpoints > 0)
			var/list/upgradablepowers = list()
			var/list/unupgradablepowers = list(/datum/action/bloodsucker/feed, /datum/action/bloodsucker/masquerade, /datum/action/bloodsucker/veil)
			for(var/datum/action/bloodsucker/power as anything in bloodsuckerdatum.powers)
				if(initial(power.purchase_flags) & BLOODSUCKER_CAN_BUY)
					upgradablepowers += power
				if(is_type_in_list(power, unupgradablepowers))
					upgradablepowers -= power
			var/choice = input(usr, "What Power do you wish to ascend? This resets the powers level.", "Darkness Manager") in upgradablepowers
			if(!choice)
				return
			if((locate(upgradablepowers[choice]) in bloodsuckerdatum.powers))
				return
			if(istype(choice, /datum/action/bloodsucker/targeted/brawn))
				bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/targeted/brawn/shadow)
			if(istype(choice, /datum/action/bloodsucker/targeted/haste))
				bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/targeted/haste/shadow)
			if(istype(choice, /datum/action/bloodsucker/fortitude))
				bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/fortitude/shadow) // i hate this
			if(istype(choice, /datum/action/bloodsucker/targeted/mesmerize))
				bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/targeted/mesmerize/shadow)
			if(istype(choice, /datum/action/bloodsucker/targeted/trespass))
				bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/targeted/trespass/shadow)
			if(istype(choice, /datum/action/bloodsucker/targeted/lunge))
				bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/targeted/lunge/shadow)
			if(istype(choice, /datum/action/bloodsucker/cloak/))
				bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/cloak/shadow)
			bloodsuckerdatum.powers -= choice
			qdel(choice)
			to_chat(user, span_boldnotice("You have ascended [choice]!"))
			bloodsuckerdatum.clanpoints--
			return
		if(bloodsuckerdatum.bloodsucker_level >= 4 )
			if(!awoken) //don't want this to affect power upgrading if you make another one
				to_chat(user, span_cult("Seems like you need a direct link to the abyss to awaken [src]. Maybe searching a spacial influence would yield something."))
				return
			icon_state = initial(icon_state) + (awoken ? "_idle" : "_awaken")
			update_icon()
			var/rankspent
			switch(bloodsuckerdatum.clanprogress)
				if(0)
					bloodsuckerdatum.clanprogress++
					bloodsuckerdatum.clanpoints++
					to_chat(user, span_notice("As you touch the [src] you feel the a slight abyssal pulse flow through you... You have gained a point!"))
					return
				if(1 to 3)
					rankspent = 1
				if(4 to 6)
					rankspent = 2
				if(7)
					rankspent = 3
				if(8 to INFINITY)
					to_chat(user, span_notice("You have evolved all abilities possible."))
					return
			var/want_clantask = alert("Do you want to spend a rank to gain a shadowpoint? This will cost [rankspent] ranks.", "Dark Manager", "Yes", "No")
			if(want_clantask == "No" || QDELETED(src))
				return
			if(bloodsuckerdatum.bloodsucker_level_unspent < rankspent)
				var/another_shot = alert("It seems like you don't have enough ranks, spend 550 blood instead?", "Dark Manager", "Yes", "No")
				if(another_shot == "No" || QDELETED(src))
					return
				var/mob/living/carbon/C = user
				if(C.blood_volume < 550)
					to_chat(user, span_danger("You don't have enough blood to gain a shadowpoint!"))
					return
				C.blood_volume -= 550
			else
				bloodsuckerdatum.bloodsucker_level_unspent -= rankspent
			bloodsuckerdatum.clanpoints++
			bloodsuckerdatum.clanprogress++
			return
	return ..()

////////////////////////////////////////////////////

/*/obj/structure/bloodsucker/bloodstatue
	name = "bloody countenance"
	desc = "It looks upsettingly familiar..."
/obj/structure/bloodsucker/bloodportrait
	name = "oil portrait"
	desc = "A disturbingly familiar face stares back at you. Those reds don't seem to be painted in oil..."
/obj/structure/bloodsucker/bloodbrazier
	name = "lit brazier"
	desc = "It burns slowly, but doesn't radiate any heat."
/obj/structure/bloodsucker/bloodmirror
	name = "faded mirror"
	desc = "You get the sense that the foggy reflection looking back at you has an alien intelligence to it."*/

////////////////////////////////////////////////////

/obj/structure/bloodsucker/possessedarmor
	name = "knight's armor"
	desc = "I swear i saw it's eyes move..."
	icon_state = "posarmor"
	anchored = FALSE
	density = TRUE
	Ghost_desc = "This Knight's armor will come alive once non-bloodsuckers get close to it."
	Vamp_desc = "This is a possesed knight's armor, it will come alive once mortals get close to it.\n\
		You don't care about it's attack's since you are brute immune.\n\
		You can reinforce it with 5 silver bars.\n\
		Good for immediate defense of your lair."
	Vassal_desc = "This is a possesed knight's armor, it will protect your master if people get too close to it."
	Hunter_desc = "This is a suspicious knight's armor. These things shouldn't be here, i shouldn't get too close."
	var/upgraded = FALSE

/obj/structure/bloodsucker/possessedarmor/upgraded
	name = "shiny knight's armor"
	upgraded = TRUE

/obj/structure/bloodsucker/possessedarmor/bolt()
	. = ..()
	anchored = TRUE
	START_PROCESSING(SSprocessing, src)

/obj/structure/bloodsucker/possessedarmor/unbolt()
	. = ..()
	anchored = FALSE
	STOP_PROCESSING(SSprocessing, src)

/obj/structure/bloodsucker/possessedarmor/AltClick(mob/user)
	if(!anchored)
		setDir(turn(dir,-90))
	else
		return ..()

/obj/structure/bloodsucker/possessedarmor/attackby(obj/item/I, mob/user, params)
	if(upgraded)
		to_chat(user, span_warning("[src] is already reinforced!"))
		return
	if(istype(I, /obj/item/stack/sheet/mineral/silver))
		var/obj/item/stack/sheet/mineral/silver/S = I
		if(S.amount < 5)
			to_chat(user, span_warning("You need at least five silver bars to reinforce [src]!"))
			return
		else
			to_chat(user, span_notice("You start adding [I] to [src]..."))
			if(do_after(user, 5 SECONDS, src))
				S.use(5)
				new /obj/structure/bloodsucker/possessedarmor/upgraded(src.loc)
				qdel(src)
				return
	return ..()

/obj/structure/bloodsucker/possessedarmor/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/obj/structure/bloodsucker/possessedarmor/process()
	for(var/mob/living/passerby in dview(1, get_turf(src)))
		if(IS_BLOODSUCKER(passerby) || IS_VASSAL(passerby))
			continue
		to_chat(passerby, span_warning("The armor starts moving!"))
		if(upgraded)
			new /mob/living/simple_animal/hostile/bloodsucker/possessedarmor/upgraded(src.loc)
		else
			new /mob/living/simple_animal/hostile/bloodsucker/possessedarmor(src.loc)
		qdel(src)

////////////////////////////////////////////////////

/obj/structure/bloodsucker/vassalrack
	name = "persuasion rack"
	desc = "If this wasn't meant for torture, then someone has some fairly horrifying hobbies."
	icon_state = "vassalrack"
	anchored = FALSE
	/// Start dense. Once fixed in place, go non-dense.
	density = TRUE
	can_buckle = TRUE
	buckle_lying = 180
	Ghost_desc = "This is a Vassal rack, which allows Bloodsuckers to thrall crewmembers into loyal minions."
	Vamp_desc = "This is the Vassal rack, which allows you to thrall crewmembers into loyal minions in your service.\n\
		Simply click and hold on a victim, and then drag their sprite on the vassal rack. Click on help intent on the vassal rack to unbuckle them.\n\
		To convert into a Vassal, repeatedly click on the persuasion rack while NOT on help intent. The time required scales with the tool in your off hand. This costs Blood to do.\n\
		Once you have Vassals ready, you are able to select a Favorite Vassal;\n\
		Click the Rack as a Vassal is buckled onto it to turn them into your Favorite. This can only be done once, so choose carefully!\n\
		This process costs 150 Blood to do, and will make your Vassal unable to be deconverted, outside of you reaching Final Death."
	Vassal_desc = "This is the vassal rack, which allows your master to thrall crewmembers into their minions.\n\
		Aid your master in bringing their victims here and keeping them secure.\n\
		You can secure victims to the vassal rack by click dragging the victim onto the rack while it is secured."
	Hunter_desc = "This is the vassal rack, which monsters use to brainwash crewmembers into their loyal slaves.\n\
		They usually ensure that victims are handcuffed, to prevent them from running away.\n\
		Their rituals take time, allowing us to disrupt it."
	/// So we can't spam buckle people onto the rack
	var/use_lock = FALSE
	var/mob/buckled
	/// Resets on each new character to be added to the chair. Some effects should lower it...
	var/convert_progress = 3
	/// Mindshielded and Antagonists willingly have to accept you as their Master.
	var/disloyalty_confirm = FALSE
	/// Prevents popup spam.
	var/disloyalty_offered = FALSE
	/// For Tzimisce bloodsuckers' rituals
	var/meat_points = 0
	var/bigmeat = 0
	var/intermeat = 0
	var/mediummeat = 0
	var/smallmeat = 0
	var/meat_amount = 0

/obj/structure/bloodsucker/vassalrack/deconstruct(disassembled = TRUE)
	. = ..()
	new /obj/item/stack/sheet/metal(src.loc, 4)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)

/obj/structure/bloodsucker/vassalrack/examine(mob/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum.my_clan == CLAN_TZIMISCE)
		if(meat_amount > 0)
			. += span_boldnotice("It currently contains [meat_points] points to use in rituals.")
			. += span_boldnotice("You can add meat points to the rack by using muscle, acquired from <i>Dicing</i> corpses, on it.")
	else 
		return ..()

/obj/structure/bloodsucker/vassalrack/bolt()
	. = ..()
	density = FALSE
	anchored = TRUE

/obj/structure/bloodsucker/vassalrack/unbolt()
	. = ..()
	density = TRUE
	anchored = FALSE

/obj/structure/bloodsucker/vassalrack/MouseDrop_T(atom/movable/movable_atom, mob/user)
	var/mob/living/living_target = movable_atom
	if(!anchored && IS_BLOODSUCKER(user))
		to_chat(user, span_danger("Until this rack is secured in place, it cannot serve its purpose."))
		to_chat(user, span_announce("* Bloodsucker Tip: Examine the Persuasion Rack to understand how it functions!"))
		return
	// Default checks
	if(!isliving(movable_atom) || !living_target.Adjacent(src) || living_target == user || !isliving(user) || use_lock || has_buckled_mobs() || user.incapacitated() || living_target.buckled)
		return
	// Don't buckle Silicon to it please.
	if(issilicon(living_target))
		to_chat(user, span_danger("You realize that Silicon cannot be vassalized, therefore it is useless to buckle them."))
		return
	// Good to go - Buckle them!
	use_lock = TRUE
	if(do_mob(user, living_target, 5 SECONDS))
		attach_victim(living_target, user)
	use_lock = FALSE

/// Attempt Release (Owner vs Non Owner)
/obj/structure/bloodsucker/vassalrack/proc/attach_victim(mob/living/target, mob/living/user)
	// Standard Buckle Check
	target.forceMove(get_turf(src))
	if(!buckle_mob(target))
		return
	user.visible_message(
		span_notice("[user] straps [target] into the rack, immobilizing them."),
		span_boldnotice("You secure [target] tightly in place. They won't escape you now."),
	)

	playsound(src.loc, 'sound/effects/pop_expl.ogg', 25, 1)
	density = TRUE
	update_icon()

	// Set up Torture stuff now
	convert_progress = 3
	disloyalty_confirm = FALSE
	disloyalty_offered = FALSE

/// Attempt Unbuckle
/obj/structure/bloodsucker/vassalrack/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(!IS_BLOODSUCKER(user) || !IS_VASSAL(user))
		if(buckled_mob == user)
			buckled_mob.visible_message(
				span_danger("[user] tries to release themself from the rack!"),
				span_danger("You attempt to release yourself from the rack!"),
				span_hear("You hear a squishy wet noise."),
			)
		else
			buckled_mob.visible_message(
				span_danger("[user] tries to pull [buckled_mob] from the rack!"),
				span_danger("[user] tries to pull [buckled_mob] from the rack!"),
				span_hear("You hear a squishy wet noise."),
			)
		// Monster hunters are used to this sort of stuff, they know how they work, which includes breaking others out
		var/breakout_timer = IS_MONSTERHUNTER(user) ? 20 SECONDS : 10 SECONDS
		if(!do_mob(user, buckled_mob, breakout_timer))
			return
	unbuckle_mob(buckled_mob)
	. = ..()

/obj/structure/bloodsucker/vassalrack/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	. = ..()
	if(!.)
		return FALSE
	src.visible_message(span_danger("[buckled_mob][buckled_mob.stat == DEAD ? "'s corpse" : ""] slides off of the rack."))
	density = FALSE
	buckled_mob.Paralyze(3 SECONDS)
	update_icon()
	use_lock = FALSE // Failsafe
	return TRUE

/obj/structure/bloodsucker/vassalrack/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!.)
		return FALSE
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	// Is there anyone on the rack & If so, are they being tortured?
	if(use_lock || !has_buckled_mobs())
		return FALSE
	var/mob/living/carbon/buckled_carbons = pick(buckled_mobs)
	if(user.a_intent == INTENT_HELP)
		if(istype(bloodsuckerdatum))
			unbuckle_mob(buckled_carbons)
			return FALSE
		else
			user_unbuckle_mob(buckled_carbons, user)
			return
	/// If I'm not a Bloodsucker, try to unbuckle them.
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(buckled_carbons)
	// Are they our Vassal, or Dead?
	if(buckled_carbons.stat == DEAD)
		if(bloodsuckerdatum.my_clan != CLAN_TZIMISCE)
			to_chat(user, span_warning("[buckled_carbons] is dead!"))
			return
		do_ritual(user, buckled_carbons)
		return
	if(istype(vassaldatum) && vassaldatum.master == bloodsuckerdatum)
		// Can we assign a Favorite Vassal?
		if(istype(vassaldatum) && !bloodsuckerdatum.has_favorite_vassal)
			offer_favorite_vassal(user, buckled_carbons)
		else if(bloodsuckerdatum.my_clan == CLAN_TZIMISCE)
			do_ritual(user, buckled_carbons)
		use_lock = FALSE
		return

	// Not our Vassal, but Alive & We're a Bloodsucker, good to torture!
	torture_victim(user, buckled_carbons)

#define MEATLIMIT 3
/obj/structure/bloodsucker/vassalrack/attackby(obj/item/I, mob/user, params) //Tzimisce stuff
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum.my_clan != CLAN_TZIMISCE)
		return ..() // only gamers
	if(istype(I, /obj/item/muscle))
		if(meat_amount >= MEATLIMIT)
			to_chat(user, span_warning("You can't fit more meat into [src]"))
			return
		var/obj/item/muscle/M = I
		meat_points += M.size
		switch(M.size)
			if(4)
				bigmeat++
			if(3)
				intermeat++
			if(2)
				mediummeat++
			if(1)
				smallmeat++
		meat_amount = bigmeat + intermeat + mediummeat + smallmeat
		qdel(I)
	update_icon()
#undef MEATLIMIT

/obj/structure/bloodsucker/vassalrack/update_icon()
	cut_overlays()
	if(bigmeat > 0)
		add_overlay("bigmeat_[bigmeat]")
	if(intermeat > 0)
		add_overlay("mediummeat_[intermeat]")
		add_overlay("smallmeat_[intermeat]")
	if(mediummeat > 0)
		add_overlay("mediummeat_[mediummeat + intermeat]")
	if(smallmeat > 0)
		add_overlay("smallmeat_[smallmeat + intermeat]")

/obj/structure/bloodsucker/vassalrack/CtrlClick(mob/user)
	if(!anchored)
		return ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum.my_clan != CLAN_TZIMISCE)
		return ..()
	if(meat_amount > 0)
		if(smallmeat > 0)
			new /obj/item/muscle/small(user.drop_location())
			smallmeat--
			meat_points -= 1
		if(mediummeat > 0)
			new /obj/item/muscle/medium(user.drop_location())
			mediummeat--
			meat_points -= 2
		if(intermeat > 0)
			new /obj/item/muscle/medium(user.drop_location())
			new /obj/item/muscle/small(user.drop_location())
			intermeat--
			meat_points -= 3
		if(bigmeat > 0)
			new /obj/item/muscle/big(user.drop_location())
			bigmeat--
			meat_points -= 4
	else
		to_chat(user, span_warning("There's no meat to retrieve in [src]"))
	meat_amount = bigmeat + intermeat + mediummeat + smallmeat
	update_icon()

/**
 *	Step One: Tick Down Conversion from 3 to 0
 *	Step Two: Break mindshielding/antag (on approve)
 *	Step Three: Blood Ritual
 */

/obj/structure/bloodsucker/vassalrack/proc/torture_victim(mob/living/user, mob/living/target)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	/// Prep...
	use_lock = TRUE
	/// Conversion Process
	if(convert_progress > 0)
		to_chat(user, span_notice("You spill some blood and prepare to initiate [target] into your service."))
		bloodsuckerdatum.AddBloodVolume(-TORTURE_BLOOD_COST)
		if(!do_torture(user,target))
			to_chat(user, span_danger("<i>The ritual has been interrupted!</i>"))
		else
			/// Prevent them from unbuckling themselves as long as we're torturing.
			target.Paralyze(1 SECONDS)
			convert_progress--
			/// We're done? Let's see if they can be Vassal.
			if(convert_progress <= 0)
				if(IS_VASSAL(target))
					var/datum/antagonist/vassal/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal)
					if(!vassaldatum.master.broke_masquerade)
						to_chat(user, span_boldwarning("[target] is under the spell of another Bloodsucker!"))
						return
				if(RequireDisloyalty(user, target))
					to_chat(user, span_boldwarning("[target] has external loyalties! [target.p_they(TRUE)] will require more <i>persuasion</i> to break [target.p_them()] to your will!"))
				else
					to_chat(user, span_notice("[target] looks ready for the <b>Dark Communion</b>."))
			/// Otherwise, we're not done, we need to persuade them some more.
			else
				to_chat(user, span_notice("[target] could use [convert_progress == 1 ? "a little" : "some"] more <i>persuasion</i>."))
		use_lock = FALSE
		return
	/// Check: Mindshield & Antag
	if(!disloyalty_confirm && RequireDisloyalty(user, target))
		if(!do_disloyalty(user,target))
			to_chat(user, span_danger("<i>The ritual has been interrupted!</i>"))
		else if(!disloyalty_confirm)
			to_chat(user, span_danger("[target] refuses to give into your persuasion. Perhaps a little more?"))
		else
			to_chat(user, span_notice("[target] looks ready for the <b>Dark Communion</b>."))
		use_lock = FALSE
		return
	user.visible_message(
		span_notice("[user] marks a bloody smear on [target]'s forehead and puts a wrist up to [target.p_their()] mouth!"),
		span_notice("You paint a bloody marking across [target]'s forehead, place your wrist to [target.p_their()] mouth, and subject [target.p_them()] to the Dark Communion."),
	)
	if(!do_mob(user, src, 5 SECONDS))
		to_chat(user, span_danger("<i>The ritual has been interrupted!</i>"))
		use_lock = FALSE
		return
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(user, span_danger("<i>They're mindshielded! Break their mindshield with a candelabrum or surgery before continuing!</i>"))
		return
	/// Convert to Vassal!
	bloodsuckerdatum.AddBloodVolume(-TORTURE_CONVERSION_COST)
	if(bloodsuckerdatum && bloodsuckerdatum.attempt_turn_vassal(target))
		bloodsuckerdatum.bloodsucker_level_unspent++
		user.playsound_local(null, 'sound/effects/explosion_distant.ogg', 40, TRUE)
		target.playsound_local(null, 'sound/effects/explosion_distant.ogg', 40, TRUE)
		target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
		target.Jitter(15)
		INVOKE_ASYNC(target, /mob.proc/emote, "laugh")
		//remove_victim(target) // Remove on CLICK ONLY!
	use_lock = FALSE

/obj/structure/bloodsucker/vassalrack/proc/do_torture(mob/living/user, mob/living/carbon/target, mult = 1)
	/// Fifteen seconds if you aren't using anything. Shorter with weapons and such.
	var/torture_time = 15
	var/torture_dmg_brute = 2
	var/torture_dmg_burn = 0
	/// Get Bodypart
	var/target_string = ""
	var/obj/item/bodypart/selected_bodypart = null
	selected_bodypart = pick(target.bodyparts)
	if(selected_bodypart)
		target_string += selected_bodypart.name
	/// Get Weapon
	var/obj/item/held_item = user.get_active_held_item()
	if(!istype(held_item))
		held_item = user.get_inactive_held_item()
	/// Weapon Bonus
	if(held_item)
		torture_time -= held_item.force / 4
		torture_dmg_brute += held_item.force / 4
		//torture_dmg_burn += I.
		if(held_item.sharpness == SHARP_EDGED)
			torture_time -= 2
		else if(held_item.sharpness == SHARP_POINTY)
			torture_time -= 3
		/// This will hurt your eyes.
		else if(held_item.tool_behaviour == TOOL_WELDER)
			if(held_item.use_tool(src, user, 0, volume = 5))
				torture_time -= 6
				torture_dmg_burn += 5
		held_item.play_tool_sound(target)
	/// Minimum 5 seconds.
	torture_time = max(5 SECONDS, torture_time SECONDS)
	/// Now run process.
	if(!do_mob(user, target, torture_time * mult))
		return FALSE
	/// Success?
	if(held_item)
		playsound(loc, held_item.hitsound, 30, 1, -1)
		held_item.play_tool_sound(target)
	target.visible_message(
		span_danger("[user] performs a ritual, spilling some of [target]'s blood from their [target_string] and shaking them up!"),
		span_userdanger("[user] performs a ritual, spilling some blood from your [target_string], shaking you up!"),
	)
	INVOKE_ASYNC(target, /mob.proc/emote, "scream")
	target.Jitter(5)
	target.apply_damages(brute = torture_dmg_brute, burn = torture_dmg_burn, def_zone = (selected_bodypart ? selected_bodypart.body_zone : null)) // take_overall_damage(6,0)
	return TRUE

/// Offer them the oppertunity to join now.
/obj/structure/bloodsucker/vassalrack/proc/do_disloyalty(mob/living/user, mob/living/target)
	spawn(10)
		/// Are we still torturing? Did we cancel? Are they still here?
		if(use_lock && target && target.client)
			to_chat(user, span_notice("[target] has been given the opportunity for servitude. You await their decision..."))
			var/alert_text = "You are being tortured! Do you want to give in and pledge your undying loyalty to [user]?"
			alert_text += "\n\nYou will not lose your current objectives, but they come second to the will of your new master!"
			to_chat(target, span_cultlarge("THE HORRIBLE PAIN! WHEN WILL IT END?!"))
			var/list/torture_icons = list(
				"Accept" = image(icon = 'icons/mob/actions/actions_bloodsucker.dmi', icon_state = "power_recup"),
				"Refuse" = image(icon = 'icons/obj/weapons/baton.dmi', icon_state = "stunbaton_active")
				)
			var/torture_response = show_radial_menu(target, src, torture_icons, radius = 36, require_near = TRUE)
			switch(torture_response)
				if("Accept")
					disloyalty_accept(target)
				else
					disloyalty_refuse(target)
	if(!do_torture(user,target, 2))
		return FALSE

	// NOTE: We only remove loyalties when we're CONVERTED!
	return TRUE

/obj/structure/bloodsucker/vassalrack/proc/RequireDisloyalty(mob/living/user, mob/living/target)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	return bloodsuckerdatum.AmValidAntag(target)

/obj/structure/bloodsucker/vassalrack/proc/disloyalty_accept(mob/living/target)
	// FAILSAFE: Still on the rack?
	if(!(locate(target) in buckled_mobs))
		return
	// NOTE: You can say YES after torture. It'll apply to next time.
	disloyalty_confirm = TRUE

/obj/structure/bloodsucker/vassalrack/proc/disloyalty_refuse(mob/living/target)
	// FAILSAFE: Still on the rack?
	if(!(locate(target) in buckled_mobs))
		return
	// Failsafe: You already said YES.
	if(disloyalty_confirm)
		return
	to_chat(target, span_notice("You refuse to give in! You <i>will not</i> break!"))


/obj/structure/bloodsucker/vassalrack/proc/offer_favorite_vassal(mob/living/carbon/human/user, mob/living/target)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/datum/antagonist/vassal/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal)

	switch(input("Would you like to turn this Vassal into your completely loyal Servant? This costs 150 Blood to do. You cannot undo this.") in list("Yes", "No"))
		if("Yes")
			user.blood_volume -= 150
			bloodsuckerdatum.has_favorite_vassal = TRUE
			vassaldatum.make_favorite(user)
		else
			to_chat(user, span_danger("You decide not to turn [target] into your Favorite Vassal."))
			use_lock = FALSE

/obj/structure/bloodsucker/vassalrack/proc/do_ritual(mob/living/user, mob/living/target)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!target.mind)
		to_chat(user, span_warning("[target] is catatonic!"))
	/// To deal with Blood
	var/mob/living/carbon/human/B = user
	var/mob/living/carbon/human/H = target

	/// Due to the checks leding up to this, if they fail this, they're dead & Not our vassal.
	if(!IS_VASSAL(target))
		to_chat(user, span_notice("Do you wish to rebuild this body? This will remove any restraints they might have, and will cost 150 Blood!"))
		var/revive_response = alert(usr, "Would you like to revive [target]?", "Ghetto Medbay", "Yes", "No")
		switch(revive_response)
			if("Yes")
				if(!do_mob(user, src, 7 SECONDS))
					to_chat(user, span_danger("<i>The ritual has been interrupted!</i>"))
					return
				if(prob(15) && bloodsuckerdatum.bloodsucker_level <= 2)
					to_chat(user, span_danger("Something has gone terribly wrong! You have accidentally turned [target] into a High-Functioning Zombie!"))
					to_chat(target, span_announce("As Blood drips over your body, your heart fails to beat... But you still wake up."))
					H.set_species(/datum/species/zombie)
				else
					to_chat(user, span_danger("You have brought [target] back from the Dead!"))
					to_chat(target, span_announce("As Blood drips over your body, your heart begins to beat... You live again!"))
				B.blood_volume -= 150
				target.revive(full_heal = TRUE, admin_revive = FALSE)
				return
		to_chat(user, span_danger("You decide not to revive [target]."))
		// Unbuckle them now.
		unbuckle_mob(B)
		use_lock = FALSE
		return
	var/list/races = list(HUSK_MONSTER)
	switch(bloodsuckerdatum.bloodsucker_level)
		if(1 to 3)
			races += ARMMY_MONSTER
		if(3 to 5)
			races += ARMMY_MONSTER
			races += CALCIUM_MONSTER
		if(5 to INFINITY)
			races += ARMMY_MONSTER
			races += CALCIUM_MONSTER
			races += TRIPLECHEST_MONSTER
	var/list/options = list()
	options = races
	var/answer = input(user, "We have the chance to mutate our Vassal, how should we mutilate their corpse? This will cost us blood.", "What do we do with our Vassal?") in options
	var/meat_cost = 0
	var/blood_gained
	if(!answer)
		to_chat(user, span_notice("You decide to leave your Vassal just the way they are."))
		return
	to_chat(user, span_warning("You start mutating your Vassal into a [answer]..."))
	if(!do_mob(user, src, 5 SECONDS))
		to_chat(user, span_danger("<i>The ritual has been interrupted!</i>"))
		return
	playsound(target.loc, 'sound/weapons/slash.ogg', 50, TRUE, -1)
	switch(answer)
		if(HUSK_MONSTER)
			if(HAS_TRAIT(target, TRAIT_HUSK))
				to_chat(user, span_warning("[target] is already a Husk!"))
				return
			if(!do_mob(user, target, 1 SECONDS))
				return
			playsound(target.loc, 'sound/weapons/slash.ogg', 50, TRUE, -1)
			if(!do_mob(user, target, 1 SECONDS))
				return
			to_chat(user, span_notice("You suck all the blood out of [target], turning them into a Living Husk!"))
			to_chat(target, span_notice("Your master has mutated you into a Living Husk!"))
			playsound(target.loc, 'sound/magic/mutate.ogg', 50, TRUE, -1)
			/// Just take it all
			blood_gained = 250
			target.remove_all_languages()
			target.grant_language(/datum/language/vampiric)
			H.become_husk()
			bloodsuckerdatum.bloodsucker_level_unspent++
		if(ARMMY_MONSTER)
			meat_cost = 4
			var/mob/living/simple_animal/hostile/bloodsucker/tzimisce/armmy/A
			if(!(HAS_TRAIT(target, TRAIT_HUSK)))
				to_chat(user, span_warning("You need to mutilate [target] into a husk first before doing this."))
				return
			if(meat_points < meat_cost)
				to_chat(user, span_warning("You need atleast [meat_cost - meat_points] more meat points to do this."))
				return
			if(!do_mob(user, target, 1 SECONDS))
				return
			playsound(target.loc, 'sound/weapons/slash.ogg', 50, TRUE, -1)
			to_chat(user, span_notice("You transfer your blood and toy with [target]'s flesh, leaving their body as a head and arm almalgam."))
			to_chat(target, span_notice("Your master has mutated you into a tiny arm monster!"))
			B.blood_volume -= 100
			A = new /mob/living/simple_animal/hostile/bloodsucker/tzimisce/armmy(target.loc)
			target.forceMove(A)
			target.mind.transfer_to(A)
			A.bloodsucker = target
		/// Chance to give Bat form, or turn them into a bat.
		if(CALCIUM_MONSTER)
			meat_cost = 8
			var/mob/living/simple_animal/hostile/bloodsucker/tzimisce/calcium/C
			if(!(HAS_TRAIT(target, TRAIT_HUSK)))
				to_chat(user, span_warning("You need to mutilate [target] into a husk first before doing this."))
				return
			if(meat_points < meat_cost)
				to_chat(user, span_warning("You need atleast [meat_cost - meat_points] more meat points to do this."))
				return
			if(!do_mob(user, target, 1 SECONDS))
				return
			playsound(target.loc, 'sound/weapons/slash.ogg', 50, TRUE, -1)
			to_chat(user, span_notice("You transfer your blood and toy with [target]'s flesh and bones, leaving their body as a boney and flesh amalgam."))
			to_chat(target, span_notice("Your master has mutated you into a fractured monster!"))
			B.blood_volume -= 150
			C = new /mob/living/simple_animal/hostile/bloodsucker/tzimisce/calcium(target.loc)
			target.forceMove(C)
			target.mind.transfer_to(C)
			C.bloodsucker = target
		if(TRIPLECHEST_MONSTER)
			meat_cost = 12
			var/mob/living/simple_animal/hostile/bloodsucker/tzimisce/triplechest/T
			if(!(HAS_TRAIT(target, TRAIT_HUSK)))
				to_chat(user, span_warning("You need to mutilate [target] into a husk first before doing this."))
				return
			if(meat_points < meat_cost)
				to_chat(user, span_warning("You need atleast [meat_cost - meat_points] more meat points to do this."))
				return
			if(!do_mob(user, target, 1 SECONDS))
				return
			playsound(target.loc, 'sound/weapons/slash.ogg', 50, TRUE, -1)
			if(!do_mob(user, target, 1 SECONDS))
				return
			to_chat(user, span_notice("You transfer your blood and toy with [target]'s flesh and bones, leaving their body as a huge pile of flesh and organs."))
			to_chat(target, span_notice("Your master has mutated you into a gigartuan monster!"))
			B.blood_volume -= 300
			T = new /mob/living/simple_animal/hostile/bloodsucker/tzimisce/triplechest(target.loc)
			target.forceMove(T)
			target.mind.transfer_to(T)
			T.bloodsucker = target
	if(blood_gained)
		user.blood_volume += blood_gained
	var/meatlost = 0
	while(meat_cost)
		meat_points--
		meat_cost--
		meatlost++
		if(smallmeat && meatlost == 1)
			smallmeat--
			meatlost--
		if(mediummeat && meatlost == 2)
			mediummeat--
			meatlost -= 2
		if(intermeat && meatlost == 3)
			intermeat--
			meatlost -= 3
		if(bigmeat && meatlost == 4)
			bigmeat--
			meatlost -= 4
	update_icon()
	meat_amount = bigmeat + intermeat + mediummeat + smallmeat

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/structure/bloodsucker/candelabrum
	name = "candelabrum"
	desc = "It burns slowly, but doesn't radiate any heat."
	icon_state = "candelabrum"
	light_color = "#66FFFF"//LIGHT_COLOR_BLUEGREEN // lighting.dm
	light_power = 3
	light_range = 0 // to 2
	density = FALSE
	can_buckle = TRUE
	anchored = FALSE
	Ghost_desc = "This is a magical candle which drains at the sanity of non Bloodsuckers and Vassals.\n\
		Vassals can also turn the candle on."
	Vamp_desc = "This is a magical candle which drains at the sanity of mortals who are not under your command while it is active.\n\
		You can click on it to turn it on, clicking on it with a mindshielded individual buckled will start to disable their mindshields."
	Vassal_desc = "This is a magical candle which drains at the sanity of the fools who havent yet accepted your master, as long as it is active.\n\
		You can turn it on and off by clicking on it while you are next to it."
	Hunter_desc = "This is a blue Candelabrum, which causes insanity to those near it while active."
	var/lit = FALSE

/obj/structure/bloodsucker/candelabrum/deconstruct(disassembled = TRUE)
	. = ..()
	new /obj/item/candle(loc, 1)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)

/obj/structure/bloodsucker/candelabrum/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/bloodsucker/candelabrum/update_icon()
	icon_state = "candelabrum[lit ? "_lit" : ""]"
	return ..()

/obj/structure/bloodsucker/candelabrum/examine(mob/user)
	. = ..()

/obj/structure/bloodsucker/candelabrum/bolt()
	. = ..()
	anchored = TRUE
	density = TRUE

/obj/structure/bloodsucker/candelabrum/unbolt()
	. = ..()
	anchored = FALSE
	density = FALSE

/obj/structure/bloodsucker/candelabrum/proc/toggle(mob/user)
	lit = !lit
	if(lit)
		set_light(2, 3, "#66FFFF")
		START_PROCESSING(SSobj, src)
	else
		set_light(0)
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/bloodsucker/candelabrum/process()
	if(!lit)
		return
	for(var/mob/living/carbon/nearly_people in viewers(7, src))
		/// We dont want Bloodsuckers or Vassals affected by this
		if(IS_VASSAL(nearly_people) || IS_BLOODSUCKER(nearly_people))
			continue
		nearly_people.hallucination += 5
		if(nearly_people.getStaminaLoss() >= 100)
			continue
		if(nearly_people.getStaminaLoss() >= 60)
			spawn(10)
			nearly_people.adjustStaminaLoss(1) // keeps the slowness by constantly updating it
		else
			nearly_people.adjustStaminaLoss(10)
		SEND_SIGNAL(nearly_people, COMSIG_ADD_MOOD_EVENT, "vampcandle", /datum/mood_event/vampcandle)
		to_chat(nearly_people, span_warning("<i>You start to feel extremely weak and drained.</i>"))

/// Mindshield breaking
/obj/structure/bloodsucker/candelabrum/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(!anchored)
		return
	// Checks: They're Buckled & Alive.
	if(IS_BLOODSUCKER(user) && has_buckled_mobs())
		var/mob/living/carbon/target = pick(buckled_mobs)
		if(target.stat >= DEAD || user.a_intent == INTENT_HELP)
			unbuckle_mob(target)
			return
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			if(user.blood_volume >= 150)
				switch(input("Do you wish to spend 150 Blood to deactivate [target]'s mindshield?") in list("Yes", "No"))
					if("Yes")
						user.blood_volume -= 150
						if(!do_mob(user, target, 60 SECONDS))
							to_chat(user, span_danger("<i>The ritual has been interrupted!</i>"))
							return FALSE
						remove_loyalties(target)
						to_chat(user, span_boldnotice("You deactivated [target]'s mindshield!"))
			else
				to_chat(user, span_danger("You don't have enough Blood to deactivate [target]'s mindshield."))
			return
	if(IS_VASSAL(user) || IS_BLOODSUCKER(user))
		toggle()

/// Buckling someone in
/obj/structure/bloodsucker/candelabrum/MouseDrop_T(mob/living/target, mob/user)
	if(!anchored && IS_BLOODSUCKER(user))
		to_chat(user, span_danger("Until the candelabrum is secured in place, it cannot serve its purpose."))
		return
	/// Default checks
	if(!target.Adjacent(src) || target == user || !isliving(user) || has_buckled_mobs() || user.incapacitated() || target.buckled)
		return
	/// Are they mindshielded or a bloodsucker/vassal?
	if(!HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(user, span_warning("[target] doesn't have a mindshield for you to turn off!"))
		return
	/// Good to go - Buckle them!
	if(do_mob(user, target, 5 SECONDS))
		attach_mob(target, user)

/obj/structure/bloodsucker/candelabrum/proc/attach_mob(mob/living/target, mob/living/user)
	user.visible_message(
		span_notice("[user] lifts and buckles [target] onto the candelabrum."),
		span_boldnotice("You buckle [target] onto the candelabrum."),
	)

	playsound(src.loc, 'sound/effects/pop_expl.ogg', 25, 1)
	target.forceMove(get_turf(src))

	if(!buckle_mob(target))
		return
	update_icon()

/obj/structure/bloodsucker/candelabrum/proc/remove_loyalties(mob/living/target, mob/living/user)
	// Find Mindshield implant & destroy, takes a good while.
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		for(var/obj/item/implant/mindshield/L in target)
			if(L)
				qdel(L)
/// Attempt Unbuckle
/obj/structure/bloodsucker/candelabrum/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	. = ..()
	src.visible_message(span_danger("[buckled_mob][buckled_mob.stat==DEAD?"'s corpse":""] slides off of the candelabrum."))
	update_icon()

/// Blood Throne - Allows Bloodsuckers to remotely speak with their Vassals. - Code (Mostly) stolen from comfy chairs (armrests) and chairs (layers)
/* broken currently
/obj/structure/bloodsucker/bloodthrone
	name = "wicked throne"
	desc = "Twisted metal shards jut from the arm rests. Very uncomfortable looking. It would take a masochistic sort to sit on this jagged piece of furniture."
	icon = 'icons/obj/vamp_obj_64.dmi'
	icon_state = "throne"
	buckle_lying = 0
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	Ghost_desc = "This is a Bloodsucker throne, any Bloodsucker sitting on it can remotely speak to their Vassals by attempting to speak aloud."
	Vamp_desc = "This is a Blood throne, sitting on it will allow you to telepathically speak to your vassals by simply speaking."
	Vassal_desc = "This is a Blood throne, it allows your Master to telepathically speak to you and others like you."
	Hunter_desc = "This is a chair that hurts those that try to buckle themselves onto it, though the Undead have no problem latching on.\n\
		While buckled, Monsters can use this to telepathically communicate with eachother."
	var/mutable_appearance/armrest

// Add rotating and armrest
/obj/structure/bloodsucker/bloodthrone/Initialize()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/bloodsucker/bloodthrone/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/bloodsucker/bloodthrone/bolt()
	. = ..()
	anchored = TRUE

/obj/structure/bloodsucker/bloodthrone/unbolt()
	. = ..()
	anchored = FALSE

// Armrests
/obj/structure/bloodsucker/bloodthrone/proc/GetArmrest()
	return mutable_appearance('icons/obj/vamp_obj_64.dmi', "thronearm")

/obj/structure/bloodsucker/bloodthrone/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

// Rotating
/obj/structure/bloodsucker/bloodthrone/setDir(newdir)
	. = ..()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(newdir)

	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

// Buckling
/obj/structure/bloodsucker/bloodthrone/buckle_mob(mob/living/user, force = FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_announce("[src] is not bolted to the ground!"))
		return
	user.visible_message(
		span_notice("[user] sits down on [src]."),
		span_boldnotice("You sit down onto [src]."),
	)
	if(IS_BLOODSUCKER(user))
		RegisterSignal(user, COMSIG_MOB_SAY, .proc/handle_speech)
	else
		user.Paralyze(6 SECONDS)
		to_chat(user, span_cult("The power of the blood throne overwhelms you!"))
		user.apply_damage(10, BRUTE)
		unbuckle_mob(user)
		return
	return ..()

/obj/structure/bloodsucker/bloodthrone/post_buckle_mob(mob/living/target)
	. = ..()
	update_armrest()
	target.pixel_y += 2

// Unbuckling
/obj/structure/bloodsucker/bloodthrone/unbuckle_mob(mob/living/user, force = FALSE, can_fall = TRUE)
	src.visible_message(span_danger("[user] unbuckles themselves from [src]."))
	if(IS_BLOODSUCKER(user))
		UnregisterSignal(user, COMSIG_MOB_SAY)
	return ..()

/obj/structure/bloodsucker/bloodthrone/post_unbuckle_mob(mob/living/target)
	target.pixel_y -= 2

// The speech itself
/obj/structure/bloodsucker/bloodthrone/proc/handle_speech(datum/source, mob/speech_args)

	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/user = source
	var/rendered = span_cultlarge("<b>[user.real_name]:</b> [message]")
	user.log_talk(message, LOG_SAY, tag=ROLE_BLOODSUCKER)
	for(var/mob/living/carbon/human/vassals in GLOB.player_list)
		var/datum/antagonist/vassal/vassaldatum = vassals.mind.has_antag_datum(/datum/antagonist/vassal)
		if(vassals == user) // Just so they can hear themselves speak.
			to_chat(vassals, rendered)
		if(!istype(vassaldatum))
			continue
		if(vassaldatum.master.owner == user.mind)
			to_chat(vassals, rendered)

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]")

	speech_args[SPEECH_MESSAGE] = ""
*/