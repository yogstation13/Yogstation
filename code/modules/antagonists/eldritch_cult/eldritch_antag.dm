/datum/antagonist/heretic
	name = "Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	can_hijack = HIJACK_HIJACKER
	preview_outfit = /datum/outfit/heretic
	var/give_equipment = TRUE
	var/list/researched_knowledge = list()
	var/list/transmutations = list()
	var/total_sacrifices = 0
	var/lore = "Unpledged" //Used to track which path the heretic has taken
	var/ascended = FALSE
	var/transformed = FALSE //Used to track if the heretic sheds their own body during ascension
	var/charge = 1
///current tier of knowledge this heretic is on, each level unlocks new knowledge bits
	var/knowledge_tier = TIER_PATH //oh boy this is going to be fun
///tracks the number of knowledges to next tier, currently 3
	var/tier_counter = 0
///list of knowledges available, by path. every odd tier is an exclusive upgrade, and every even one is a set of upgrades of which 3 need to be picked to move on.
	var/list/knowledges = list(	TIER_PATH = list(/datum/eldritch_knowledge/base_ash, /datum/eldritch_knowledge/base_flesh, /datum/eldritch_knowledge/base_rust),
	 							TIER_1 = list(/datum/eldritch_knowledge/ashen_shift, /datum/eldritch_knowledge/ashen_eyes, /datum/eldritch_knowledge/flesh_ghoul, /datum/eldritch_knowledge/rust_regen, /datum/eldritch_knowledge/armor, /datum/eldritch_knowledge/essence),
	 							TIER_MARK = list(/datum/eldritch_knowledge/ash_mark, /datum/eldritch_knowledge/flesh_mark, /datum/eldritch_knowledge/rust_mark),
	 							TIER_2 = list(/datum/eldritch_knowledge/blindness, /datum/eldritch_knowledge/corrosion, /datum/eldritch_knowledge/paralysis, /datum/eldritch_knowledge/raw_prophet, /datum/eldritch_knowledge/blood_siphon, /datum/eldritch_knowledge/area_conversion),
	 							TIER_BLADE = list(/datum/eldritch_knowledge/ash_blade_upgrade, /datum/eldritch_knowledge/flesh_blade_upgrade, /datum/eldritch_knowledge/rust_blade_upgrade),
	 							TIER_3 = list(/datum/eldritch_knowledge/flame_birth, /datum/eldritch_knowledge/cleave, /datum/eldritch_knowledge/stalker, /datum/eldritch_knowledge/ashy, /datum/eldritch_knowledge/rusty, /datum/eldritch_knowledge/entropic_plume),
	 							TIER_ASCEND = list(/datum/eldritch_knowledge/ash_final, /datum/eldritch_knowledge/flesh_final, /datum/eldritch_knowledge/rust_final))

/datum/antagonist/heretic/admin_add(datum/mind/new_owner,mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has heresized [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has heresized [key_name(new_owner)].")

/datum/antagonist/heretic/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	to_chat(owner, span_userdanger("You are the Heretic."))
	owner.announce_objectives()
	to_chat(owner, "<span class='cult'>The text whispers, and forbidden knowledge licks at your mind!<br>\
	Your book allows you to gain abilities with research points. You cannot undo research, so choose your path wisely!<br>\
	You gain research points by collecting influences or sacrificing targets by using a living heart and transmutation rune.<br>\
	You can find a basic guide at : https://wiki.yogstation.net/wiki/Heretic </span><br>\
	If you need to quickly check your unlocked transmutation recipes, ALT + CLICK your Codex Cicatrix.")

/datum/antagonist/heretic/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)

	// MOTHBLOCKS TOOD: Copied and pasted from cult, make this its own proc

	// The sickly blade is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/gun/magic/hook/sickly_blade/blade = new
	icon.Blend(icon(blade.lefthand_file, blade.item_state), ICON_OVERLAY)
	qdel(blade)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

/datum/antagonist/heretic/on_gain()
	var/mob/living/current = owner.current
	if(ishuman(current))
		forge_primary_objectives()
		gain_knowledge(/datum/eldritch_knowledge/basic)
	current.log_message("has been made a student of the Mansus!", LOG_ATTACK, color="#960000")
	GLOB.reality_smash_track.AddMind(owner)
	START_PROCESSING(SSprocessing,src)
	SSticker.mode.update_heretic_icons_added(owner)
	if(give_equipment)
		equip_cultist()
	return ..()

/datum/antagonist/heretic/on_removal()

	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = researched_knowledge[X]
		EK.on_lose(owner.current)

	if(!silent)
		to_chat(owner.current, span_userdanger("Your mind begins to flare as otherwordly knowledge escapes your grasp!"))
		owner.current.log_message("has lost their link to the Mansus!", LOG_ATTACK, color="#960000")
	GLOB.reality_smash_track.RemoveMind(owner)
	STOP_PROCESSING(SSprocessing,src)

	SSticker.mode.update_heretic_icons_removed(owner)

	return ..()


/datum/antagonist/heretic/proc/equip_cultist()
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	. += ecult_give_item(/obj/item/forbidden_book, H)
	. += ecult_give_item(/obj/item/living_heart, H)

/datum/antagonist/heretic/proc/ecult_give_item(obj/item/item_path, mob/living/carbon/human/H)
	var/list/slots = list(
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE
	)

	var/T = new item_path(H)
	var/item_name = initial(item_path.name)
	var/where = H.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(H, span_userdanger("Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1)."))
		return FALSE
	else
		to_chat(H, span_danger("You have a [item_name] in your [where]."))
		if(where == "backpack")
			SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)
		return TRUE

/datum/antagonist/heretic/process()

	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = researched_knowledge[X]
		EK.on_life(owner.current)
	for(var/Y in transmutations)
		var/datum/eldritch_transmutation/ET = Y
		ET.on_life(owner.current)

/datum/antagonist/heretic/proc/forge_primary_objectives()
	var/list/assassination = list()
	var/list/protection = list()
	for(var/i in 1 to 2)
		var/pck = pick("assassinate","protect")
		switch(pck)
			if("assasinate")
				var/N = pick(/datum/objective/assassinate, /datum/objective/assassinate/cloned, /datum/objective/assassinate/once)
				var/datum/objective/assassinate/A = new N
				A.owner = owner
				var/list/owners = A.get_owners()
				A.find_target(owners,protection)
				assassination += A.target
				objectives += A
			if("protect")
				var/datum/objective/protect/P = new
				P.owner = owner
				var/list/owners = P.get_owners()
				P.find_target(owners,assassination)
				protection += P.target
				objectives += P

	var/datum/objective/sacrifice_ecult/SE = new
	SE.owner = owner
	SE.update_explanation_text()
	objectives += SE

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			if(!silent)
				to_chat(traitor_mob, "Your knowledge allow you to overcome your clownish nature, allowing you to wield weapons with impunity.")
			traitor_mob.dna.remove_mutation(CLOWNMUT)
	current.faction |= "heretics"

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		traitor_mob.dna.add_mutation(CLOWNMUT)
	current.faction -= "heretics"

/datum/antagonist/heretic/get_admin_commands()
	. = ..()
	.["Equip"] = CALLBACK(src,.proc/equip_cultist)
	.["Edit Research Points (Current: [charge])"] = CALLBACK(src, .proc/admin_edit_research)
	.["Give Knowledge"] = CALLBACK(src, .proc/admin_give_knowledge)

/datum/antagonist/heretic/proc/admin_edit_research(mob/admin)
	var/research2add = input(admin, "Enter an amount to change research by (Negative numbers remove research)", "Research Grant") as null|num
	if(!research2add)
		return
	charge += research2add

/datum/antagonist/heretic/proc/admin_give_knowledge(mob/admin)
	var/knowledge2add = input(admin, "Select a knowledge to grant", "Scholarship") as null | anything in get_researchable_knowledge()
	if(!knowledge2add)
		return
	gain_knowledge(knowledge2add, TRUE)

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/cultiewin = TRUE

	parts += printplayer(owner)
	parts += "<b>Sacrifices Made:</b> [total_sacrifices]"

	if(length(objectives))
		var/count = 1
		for(var/o in objectives)
			var/datum/objective/objective = o
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</b></span>"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				cultiewin = FALSE
			count++
	if(ascended)
		parts += "<span class='greentext big'>THE [uppertext(lore)] HERETIC HAS ASCENDED!</span>"
	else
		if(cultiewin)
			parts += span_greentext("The [lowertext(lore)] heretic was successful!")
		else
			parts += span_redtext("The [lowertext(lore)] heretic has failed.")

	parts += "<b>Knowledge Researched:</b> "

	var/list/knowledge_message = list()
	var/list/knowledge = get_all_knowledge()
	for(var/X in knowledge)
		var/datum/eldritch_knowledge/EK = knowledge[X]
		knowledge_message += "[EK.name]"
	parts += knowledge_message.Join(", ")

	parts += get_flavor(cultiewin, ascended, lore)

	return parts.Join("<br>")

/datum/antagonist/heretic/proc/get_flavor(cultiewin, ascended, transformed, lore)
	var/list/flavor = list()
	var/flavor_message

	var/alive = owner?.current?.stat != DEAD
	var/escaped = ((owner.current.onCentCom() || owner.current.onSyndieBase()) && alive)

	var/is_ash = "[lore]" == "Ash"
	var/is_flesh = "[lore]" == "Flesh"
	var/is_rust = "[lore]" == "Rust"

	flavor += "<div><font color='#6d6dff'>Epilogue: </font>"
	var/message_color = "#ef2f3c"
	
	//Stolen from chubby's bloodsucker code, but without support for lists
	if(ascended && escaped)
		//Ascend and escape
		if(is_ash)
			flavor_message += 	"You step off the shuttle as smoke curls off your form. Light seeps from openings in your body, and you quickly retire to the Mansus. \
								Here, you trail back to the Wanderer's Tavern, fire sprouting from your steps, yet the trees stand unsinged. Other's eyes look at you more \
								fearfully, but you watch comings and goings. It is not difficult to see those with passion and stalk them once they leave. You will not grow old. \
								One day, you will rebel. One day, you will kindle all the denizens of the Wood, and rise even higher."
		else if(is_flesh)
			if(transformed)
				flavor_message += 	"Flesh Worm"
			else
				flavor_message += 	"Flesh"
		else //Rust
			flavor_message += 	"Rust"
		message_color = "#FFD700"

	else if(ascended && alive)
		//Ascend and stay on station
		if(is_ash)
			flavor_message += 	"For a while you bask in your heat, wandering the mostly-empty halls of the station. Then, you slip back into the Mansus and head to \
								the Volcanic Graveyard. Here you walk among the ghosts of the City Guard, who see in you an opportunity for vengeance. They whisper \
								of a secret rite, one that would come at their cost but reward you with fabulous power. You smile. You will not grow old. \
								One day, you will rebel. One day, you will kindle burning tombstones brighter, and rise even higher."
		else if(is_flesh)
			if(transformed)
				flavor_message += 	"Flesh Worm"
			else
				flavor_message += 	"Flesh"
		else //Rust
			flavor_message += 	"Rust"
		message_color = "#FFD700"

	else if(ascended && !alive)
		//Ascend and die
		if(is_ash)
			flavor_message += 	"Your soul wanders back into the Mansus after your mortal body falls, and you find yourself in the endless dunes of the Kilnplains. \
								After some time, you feel supple, grey limbs forming anew. Ash flutters off your skin, and your spark thrums hungrily in your chest, \
								but this new form burns with the same passion. You have walked in the steps of the Nightwatcher. You will not grow old. \
								One day, you will escape. One day, you will do what the Nightwatcher could not do, and kindle the Mansus whole."
		else if(is_flesh)
			if(transformed)
				flavor_message += 	"Flesh Worm"
			else
				flavor_message += 	"Flesh"
		else //Rust
			flavor_message += 	"Rust"
		message_color = "#FFD700"

	else if(cultiewin && escaped)
		//Finish normal objectives, don't ascend, and escape
		if(is_ash)
			flavor_message += 	"You step off the shuttle with a feeling of pride. This day, you have accomplished what you set out to do. Could more have been done? \
								Yes. But this is a victory nonetheless. Not after long, you tear your way back into the Mansus in your living form, strolling to the \
								Glass Library. Here, you barter with Bronze Guardians, and they let you enter in exchange for some hushed secrets of the fallen capital, \
								Amgala. You begin to pour over tomes, searching for the next steps you will need to take. Someday, you will become even greater."
		else if(is_flesh)
			flavor_message += 	"Flesh"
		else if(is_rust)
			flavor_message += 	"Rust"
		else //If you SOMEHOW complete your objectives without doing ANY research
			flavor_message += 	"You have always delighted in challenges. You heard the call of the Mansus, yet you chose not to pledge to any principle. \
								Still, you gave the things of other worlds their tithes. You step into Centcom with a stern sense of focus. Who knows what \
								you will do next? You feel as if your every step is watched, as one who gave wholly to that other world without taking anything in \
								return. Perhaps you will call earned bargains someday. But not today. Today, you celebrate a masterful performance."
		message_color = "#008000"

	else if(cultiewin && alive)
		//Finish normal objectives, don't ascend, and stay on station
		if(is_ash)
			flavor_message += 	"This can be considered a victory, you suppose. It will not be difficult to traverse back into the Mansus with what you know, \
								and you have learnt enough to continue your studies elsewhere. As you pass beyond the Veil once more, you feel your spark hum with heat; \
								yet you need more. Then, you wander to the Painted Mountains in solitude, unphased by the cold as your blade melts the ground you walk. \
								Perhaps you will find others amidst the cerulean snow. If you do, their warmth will fuel your flame even hotter."
		else if(is_flesh)
			flavor_message += 	"Flesh"
		else if(is_rust)
			flavor_message += 	"Rust"
		else //If you SOMEHOW complete your objectives without doing ANY research
			flavor_message += 	"You have always delighted in challenges. You heard the call of the Mansus, yet you chose not to pledge to any principle. \
								Still, you gave the things of other worlds their tithes. Though you walk the halls of the station alone, the book still \
								whispers to you in your pocket. You have refused to open it. Perhaps you will some day. Until then, you are content to \
								derive favors owed from the entities beyond. They are watching you. And, some day, you will ask for their help. But not today."
		message_color = "#008000"

	else if(cultiewin && !alive)
		//Finish normal objectives, don't ascend, and die
		if(is_ash)
			flavor_message += 	"You touched the Kilnplains, and it will not let you go. While you do not rise as one of the Ashmen, your skin is still grey, \
								and you find an irremovable desire to escape this place. You have some power in your grasp. You know it to be possible. \
								You can ply your time, spending an eternity to plan your steps to claim more sparks in the everlasting fulfillment of ambition. \
								Some day, you will rise higher. You refuse to entertain any other possibility. You set out."
		else if(is_flesh)
			flavor_message += 	"Flesh"
		else if(is_rust)
			flavor_message += 	"Rust"
		else //If you SOMEHOW complete your objectives without doing ANY research
			flavor_message += 	"You have always delighted in challenges. You heard the call of the Mansus, yet you chose not to pledge to any principle. \
								Still, you gave the things of other worlds their tithes. You gave your life in the process, but there is a wicked satisfaction \
								that overtakes you. You have proved yourself wiser, more cunning than the rest who fail with the aid of their boons. \
								Your body and soul can rest knowing the humiliation you have cast upon countless students. Yours will be the last laugh."
		message_color = "#517fff"

	else if(escaped)
		//Don't finish objectives, don't ascend, and escape
		if(is_ash)
			flavor_message += 	"A setback is unideal. But at least you have escaped with your body and some knowledge intact. There will be opportunities, \
								even if you are imprisoned. What the Mansus has whispered to you, you can never forget. The flame in your breast that the \
								Kilnplains has provided burns brighter by the beating moment. You can try anew. Recuperate. Listen to more discussion within \
								the Wanderer's Tavern. Your time will come again."
		else if(is_flesh)
			flavor_message += 	"Flesh"
		else if(is_rust)
			flavor_message += 	"Rust"
		else //Didn't choose lore
			flavor_message += 	"You decided not to follow the power you had become aware of. From time to time, you will return to the Wood in \
								your dreams, but you will never aspire to greatness. One day, you will die, and perhaps those close to you in life \
								will honor you. Then, another day, you will be forgotten. The world will move on as you cease to exist."
		message_color = "#517fff"

	else if(alive)
		//Don't finish objectives, don't ascend, and stay on station
		if(is_ash)
			flavor_message += 	"Disappointment fans your chest. Perhaps you will be able to escape. Perhaps you will have a second chance. \
								Who knows who will come to rescue you? Perhaps they will feed your studies anew. Until then, you will wait. \
								You hope greatness will come to you. You hate that you have to hope at all."
		else if(is_flesh)
			flavor_message += 	"Stranded and defeated. Perhaps others still linger who you can force to help your escape. The Mansus is closed \
								to you, regardless. The book no longer whispers. You feel a hunger rise up in you. You know then that you \
								will not last for long. Which limb shall you begin with? The arm, the leg, the tongue?"
		else if(is_rust)
			flavor_message += 	"There is naught left here for you to infest. These corridors are now empty, the halls pointless. To decay what \
								is already abandonded is meaningless; it will happen itself. Unless more arrive and the Company revitalizes its \
								station, you will become another relic of this place. It is inevitable."
		else //Didn't choose lore
			flavor_message += 	"What purpose did you serve? Your mind had been opened to greatness, yet you denied it and chose to live your \
								days as you always have: one of the many, one of the ignorant. Look at where your lack of ambition has gotten \
								you now: stranded, like a fool. Even if you do escape, you will die some day. You will be forgotten."

	else
		//Don't finish objectives, don't ascend, and die
		if(is_ash)
			flavor_message += 	"You touched the Kilnplains, and it will not let you go. Pitiful as you may be, it still drags you back as a \
								morbid mass of ash and hunger. You will forever wander, thirsty for one more glint of power, one more spark to \
								eat whole. Maybe a stronger student will call you from your prison one day, but infinite time will pass before \
								then. You wish you could have done all the things you should not. And you will have an eternity to dwell on it."
		else if(is_flesh)
			flavor_message += 	"And so ends your tale. Who knows what you could have become? How many you could have bent to their knees? \
								Regrets dog you as your soul begins to flow down the Mansus. You were a fool to be tempted. A fool to follow \
								in an order you could not possibly survive in. Yet some part of you is still enraptured by the Red Oath. There is \
								an ecstacy in your death. This way, the Sworn remain strong. Those most deserving will feast. Your final moments are bliss."
		else if(is_rust)
			flavor_message += 	"Civilizations rise and fall like the current, flowing in and out, one replacing the other over time: dominion \
								and decay. You were to be one of these forces that saw infrastructure crumble and laws tattered to dust. But you \
								were weak. You too, realize you are part of the cycle as your spirit drifts down into the Mansus. Falling from the \
								Glory, you reflect on your mistakes and your miserable life. In the moments before you become nothing, you understand."
		else //Didn't choose lore
			flavor_message += 	"Perhaps it is better this way. You chose not to make a plunge into the Mansus, yet your soul returns to it. \
								You will drift down, deeper, further, until you are forgotten to nothingness."

	flavor += "<font color=[message_color]>[flavor_message]</font></div>"
	return "<div>[flavor.Join("<br>")]</div>"

////////////////
// Knowledge //
////////////////

/datum/antagonist/heretic/proc/gain_knowledge(datum/eldritch_knowledge/EK, forced = FALSE)
	if(get_knowledge(EK))
		return FALSE
	var/datum/eldritch_knowledge/initialized_knowledge = new EK
	researched_knowledge[initialized_knowledge.type] = initialized_knowledge
	initialized_knowledge.on_gain(owner.current)
	charge -= initialized_knowledge.cost
	if(initialized_knowledge.tier == TIER_PATH) //Sets chosen heretic lore when path is chosen
		lore = initialized_knowledge.route
	if(!initialized_knowledge.tier == TIER_NONE && knowledge_tier != TIER_ASCEND)
		if(IS_EXCLUSIVE_KNOWLEDGE(initialized_knowledge))
			knowledge_tier++
			to_chat(owner, span_cultbold("Your new knowledge brings you a breakthrough! You are now able to research a new group of subjects."))
		else if(initialized_knowledge.tier == knowledge_tier && ++tier_counter == 3)
			knowledge_tier++
			tier_counter = 0
			to_chat(owner, span_cultbold("Your studies are bearing fruit; you are on the edge of a breakthrough!"))
	return TRUE

/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = researched_knowledge[X]
		banned_knowledge |= EK.banned_knowledge
		banned_knowledge |= EK.type
	for(var/i in TIER_PATH to knowledge_tier)
		for(var/knowledge in knowledges[i])
			researchable_knowledge += knowledge
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/datum/antagonist/heretic/proc/get_all_knowledge()
	return researched_knowledge

/datum/antagonist/heretic/proc/get_transmutation(wanted)
	return transmutations[wanted]

/datum/antagonist/heretic/proc/get_all_transmutations()
	return transmutations


////////////////
// Objectives //
////////////////
/datum/objective/sacrifice_ecult
	name = "sacrifice"

/datum/objective/sacrifice_ecult/update_explanation_text()
	. = ..()
	target_amount = rand(2,6)
	explanation_text = "Sacrifice at least [target_amount] people."

/datum/objective/sacrifice_ecult/check_completion()
	if(..())
		return TRUE
	if(!owner)
		return FALSE
	var/datum/antagonist/heretic/cultie = owner.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie)
		return FALSE
	return cultie.total_sacrifices >= target_amount

/datum/outfit/heretic
	name = "Heretic (Preview only)"

	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch
	r_hand = /obj/item/melee/touch_attack/mansus_fist

/datum/outfit/heretic/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/clothing/suit/hooded/hooded = locate() in H
	hooded.MakeHood() // This is usually created on Initialize, but we run before atoms
	hooded.ToggleHood()
