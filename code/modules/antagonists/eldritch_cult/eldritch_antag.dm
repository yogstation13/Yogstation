/datum/antagonist/heretic
	name = "Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic"
	ui_name = "AntagInfoHeretic"
	can_hijack = HIJACK_HIJACKER
	show_to_ghosts = TRUE
	preview_outfit = /datum/outfit/heretic
	var/give_equipment = TRUE
	var/list/researched_knowledge = list()
	var/list/transmutations = list()
	var/total_sacrifices = 0
	var/lore = PATH_NONE //Used to track which path the heretic has taken
	var/ascended = FALSE
	var/transformed = FALSE //Used to track if the heretic sheds their own body during ascension
	var/charge = 1
///current tier of knowledge this heretic is on, each level unlocks new knowledge bits
	var/knowledge_tier = TIER_PATH //oh boy this is going to be fun
///tracks the number of knowledges to next tier, currently 3
	var/tier_counter = 0
///order these from main path ability (will choose the color in the UI) to minor abilities below them (will once again, make sense if you look at the in game UI)
	
	var/static/list/path_to_ui_color = list(
		PATH_START = "grey",
		PATH_SIDE = "green",
		PATH_RUST = "brown",
		PATH_FLESH = "red",
		PATH_ASH = "white",
		PATH_VOID = "blue",
		PATH_MIND = "pink",
		PATH_BLADE = "label", // my favorite color is label
		PATH_COSMIC = "purple",
		PATH_KNOCK = "yellow",
	)

/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list()
	
	data["charges"] = charge
	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["path"] = lore
	
	for(var/datum/eldritch_knowledge/knowledge as anything in get_researchable_knowledge())
		var/list/knowledge_data = list()
		knowledge_data["name"] = initial(knowledge.name)
		knowledge_data["desc"] = initial(knowledge.desc)
		knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
		knowledge_data["cost"] = initial(knowledge.cost)
		knowledge_data["disabled"] = (initial(knowledge.cost) > charge)

		// Final knowledge can't be learned until all objectives are complete.
		//if(ispath(knowledge, /datum/eldritch_transmutation/final))
			///knowledge_data["disabled"] = !can_ascend()

		knowledge_data["hereticPath"] = initial(knowledge.route)
		knowledge_data["color"] = path_to_ui_color[initial(knowledge.route)] || "grey"

		data["learnableKnowledge"] += list(knowledge_data)
	
	for(var/path in researched_knowledge)
		var/list/knowledge_data = list()
		var/datum/eldritch_knowledge/found_knowledge = researched_knowledge[path]
		knowledge_data["name"] = found_knowledge.name
		knowledge_data["desc"] = found_knowledge.desc
		knowledge_data["gainFlavor"] = found_knowledge.gain_text
		knowledge_data["cost"] = found_knowledge.cost
		knowledge_data["hereticPath"] = found_knowledge.route
		knowledge_data["color"] = path_to_ui_color[found_knowledge.route] || "grey"

		data["learnedKnowledge"] += list(knowledge_data)

	return data

/datum/antagonist/heretic/ui_static_data(mob/user)
	var/list/data = list()

	data["objectives"] = get_objectives()

	return data

/datum/antagonist/heretic/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("research")
			var/ekname = params["name"]
			for(var/X in get_researchable_knowledge())
				var/datum/eldritch_knowledge/EK = X
				if(initial(EK.name) != ekname)
					continue
				if(gain_knowledge(EK))
					return TRUE

/datum/antagonist/heretic/ui_status(mob/user, datum/ui_state/state)
	if(user.stat == DEAD)
		return UI_CLOSE
	return ..()

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
	You gain research points by collecting influences or sacrificing targets by using a living heart and a transmutation rune.<br>\
	You can find a basic guide at : https://wiki.yogstation.net/wiki/Heretic </span><br>\
	If you need to quickly check your unlocked transmutation recipes, use your Codex Cicatrix in hand with Z.")

/datum/antagonist/heretic/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)

	// MOTHBLOCKS TOOD: Copied and pasted from cult, make this its own proc

	// The sickly blade is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/melee/sickly_blade/blade = new
	icon.Blend(icon(blade.lefthand_file, blade.item_state), ICON_OVERLAY)
	qdel(blade)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

/datum/antagonist/heretic/on_gain()
	if(ishuman(owner.current))
		forge_primary_objectives()
		gain_knowledge(/datum/eldritch_knowledge/spell/basic)
		gain_knowledge(/datum/eldritch_knowledge/spell/basic_jaunt)
	owner.current.log_message("has been made a student of the Mansus!", LOG_ATTACK, color="#960000")
	GLOB.reality_smash_track.AddMind(owner)
	START_PROCESSING(SSprocessing,src)
	if(give_equipment)
		equip_cultist()
	return ..()

/datum/antagonist/heretic/on_removal()

	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = researched_knowledge[X]
		EK.on_lose(owner.current)

	if(!silent)
		to_chat(owner.current, span_userdanger("Your mind begins to flare as otherworldly knowledge escapes your grasp!"))
		owner.current.log_message("has lost their link to the Mansus!", LOG_ATTACK, color="#960000")
	GLOB.reality_smash_track.RemoveMind(owner)
	STOP_PROCESSING(SSprocessing,src)

	return ..()


/datum/antagonist/heretic/proc/equip_cultist()
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	. += ecult_give_item(/obj/item/forbidden_book, H)
	. += ecult_give_item(/obj/item/living_heart, H)

/datum/antagonist/heretic/proc/ecult_give_item(obj/item/item_path, mob/living/carbon/human/H)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
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
	handle_clown_mutation(current, "Ancient knowledge described to you has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	current.faction |= "heretics"

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction -= "heretics"

/datum/antagonist/heretic/get_admin_commands()
	. = ..()
	.["Equip"] = CALLBACK(src, PROC_REF(equip_cultist))
	.["Edit Research Points (Current: [charge])"] = CALLBACK(src, PROC_REF(admin_edit_research))
	.["Give Knowledge"] = CALLBACK(src, PROC_REF(admin_give_knowledge))

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
	if(ascended) //They are not just a heretic now; they are something more
		if(is_ash())
			parts += "<span class='greentext big'>THE ASHBRINGER HAS ASCENDED!</span>"
		else if(is_mind())
			parts += "<span class='greentext big'>THE MONARCH OF KNOWLEDGE HAS ASCENDED!</span>"
		else if(is_void())
			parts += "<span class='greentext big'>THE WALTZ AT THE END OF TIME HAS BEGUN!</span>"
		else if(is_rust())
			parts += "<span class='greentext big'>THE SOVEREIGN OF DECAY HAS ASCENDED!</span>"
		else if(is_blade())
			parts += "<span class='greentext big'>THE MASTER OF BLADES HAS ASCENDED!</span>"
		else if(is_flesh())
			if(transformed)
				parts += "<span class='greentext big'>THE THIRSTLY SERPENT HAS ASCENDED!</span>"
		else if(is_cosmic())
			if(transformed)
				parts += "<span class='greentext big'>THE STAR GAZER HAS ASCENDED!</span>"
		else if(is_knock())
			parts += "<span class='greentext big'>THE SPIDER'S DOOR HAS BEEN OPENED!</span>"
		else
			parts += "<span class='greentext big'>THE OATHBREAKER HAS ASCENDED!</span>"
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

	parts += get_flavor(cultiewin, ascended, transformed, lore)

	return parts.Join("<br>")

/datum/antagonist/heretic/proc/get_flavor(cultiewin, ascended, transformed, lore)
	var/list/flavor = list()
	var/flavor_message

	var/alive = owner?.current?.stat != DEAD
	var/escaped = ((owner.current.onCentCom() || owner.current.onSyndieBase()) && alive)

	flavor += "<div><font color='#6d6dff'>Epilogue: </font>"
	var/message_color = "#ef2f3c"
	
	//Stolen from chubby's bloodsucker code, but without support for lists
	
	if(is_ash()) //Ash epilogues

		if(ascended)
			message_color = "#FFD700"
			if(escaped)
				flavor_message += 	"You step off the shuttle as smoke curls off your form. Light seeps from openings in your body, and you quickly retire to the Mansus. \
									Here, you trail back to the Wanderer's Tavern, fire sprouting from your steps, yet the trees stand unsinged. Other's eyes look at you more \
									fearfully, but you watch comings and goings. It is not difficult to see those with passion and stalk them once they leave. You will not grow old. \
									One day, you will rebel. One day, you will kindle all the denizens of the Wood, and rise even higher."
			else if(alive)
				flavor_message += 	"For a while you bask in your heat, wandering the mostly-empty halls of the station. Then, you slip back into the Mansus and head to \
									the Volcanic Graveyard. Here you walk among the ghosts of the City Guard, who see in you an opportunity for vengeance. They whisper \
									of a secret rite, one that would come at their cost but reward you with fabulous power. You smile. You will not grow old. \
									One day, you will rebel. One day, you will kindle burning tombstones brighter, and rise even higher."
			else //Dead
				flavor_message += 	"Your soul wanders back into the Mansus after your mortal body falls, and you find yourself in the endless dunes of the Kilnplains. \
									After some time, you feel supple, grey limbs forming anew. Ash flutters off your skin, and your spark thrums hungrily in your chest, \
									but this new form burns with the same passion. You have walked in the steps of the Nightwatcher. You will not grow old. \
									One day, you will escape. One day, you will do what the Nightwatcher could not do, and kindle the Mansus whole."

		else if(cultiewin) //Completed objectives
			if(escaped)
				flavor_message += 	"You step off the shuttle with a feeling of pride. This day, you have accomplished what you set out to do. Could more have been done? \
									Yes. But this is a victory nonetheless. Not after long, you tear your way back into the Mansus in your living form, strolling to the \
									Glass Library. Here, you barter with Bronze Guardians, and they let you enter in exchange for some hushed secrets of the fallen capital, \
									Amgala. You begin to pour over tomes, searching for the next steps you will need to take. Someday, you will become even greater."
				message_color = "#008000"
			else if(alive)
				flavor_message += 	"This can be considered a victory, you suppose. It will not be difficult to traverse back into the Mansus with what you know, \
									and you have learnt enough to continue your studies elsewhere. As you pass beyond the Veil once more, you feel your spark hum with heat; \
									yet you need more. Then, you wander to the Painted Mountains in solitude, unphased by the cold as your blade melts the ground you walk. \
									Perhaps you will find others amidst the cerulean snow. If you do, their warmth will fuel your flame even hotter."
				message_color = "#008000"
			else //Dead
				flavor_message += 	"You touched the Kilnplains, and it will not let you go. While you do not rise as one of the Ashmen, your skin is still grey, \
									and you find an irremovable desire to escape this place. You have some power in your grasp. You know it to be possible. \
									You can ply your time, spending an eternity to plan your steps to claim more sparks in the everlasting fulfillment of ambition. \
									Some day, you will rise higher. You refuse to entertain any other possibility. You set out."
				message_color = "#517fff"

		else //Failed objectives
			if(escaped)
				flavor_message += 	"A setback is unideal. But at least you have escaped with your body and some knowledge intact. There will be opportunities, \
									even if you are imprisoned. What the Mansus has whispered to you, you can never forget. The flame in your breast that the \
									Kilnplains has provided burns brighter by the beating moment. You can try anew. Recuperate. Listen to more discussion within \
									the Wanderer's Tavern. Your time will come again."
				message_color = "#517fff"
			else if(alive)
				flavor_message += 	"Disappointment fans your chest. Perhaps you will be able to escape. Perhaps you will have a second chance. \
									Who knows who will come to rescue you? Perhaps they will feed your studies anew. Until then, you will wait. \
									You hope greatness will come to you. You hate that you have to hope at all."
			else //Dead
				flavor_message += 	"You touched the Kilnplains, and it will not let you go. Pitiful as you may be, it still drags you back as a \
									morbid mass of ash and hunger. You will forever wander, thirsty for one more glint of power, one more spark to \
									eat whole. Maybe a stronger student will call you from your prison one day, but infinite time will pass before \
									then. You wish you could have done all the things you should not. And you will have an eternity to dwell on it."


	else if(is_flesh()) //Flesh epilogues

		if(ascended)
			message_color = "#FFD700"
			if(transformed) //If you became a Thirstly Serpent
				if(escaped)
					flavor_message += 	"You RACE and you CRAWL everywhere through the shuttle. The doors open to Centcom and you simply must OOZE out into the halls. The GREAT \
										sensations SLIDE along your sides. EVERYTHING you feel is GREATER, BETTER. Then you WRAP and SPIN into the Mansus, FLOWING to the Crimson Church. \
										HERE YOU WILL RESIDE WITH HIM FOREVER. THE TASTE OF THE SELF GOES ON AND ON AND NEVER ENDS. LIFE IS A NEVER-ENDING DELICACY OF PLEASURE AND OBEDIENCE."
				else if(alive)
					flavor_message += 	"SKITTERING and LEAPING through these NEW halls. They are FAMILIAR and FRESH all the same! EACH of your legs WRIGGLES and FEELS the \
										tiling like a BABY born of BRILLIANCE. Then NEXT is the Mansus where so many FRIENDLY faces lie. To the Wanderer's Tavern, YES, you \
										think with PRIDE. ALL THOSE THERE WILL BEHOLD AND BOW BEFORE YOUR GLORY! ALL THOSE THERE WILL JOIN THE ONE TRUE FAMILY!"
				else //Dead
					flavor_message += 	"WHAT has happened to your GLORIOUS new form? You ATE and ATE and ATE and you were WONDEROUS! The once-master scoffs at you now- \
										HOW he JUDGES the WEAK flesh. You know better. You can UNDERSTAND and SEE MUCH more than HE. Bound to you are the SPIRITS of those \
										you CONSUME. WHO IS HE TO THINK YOU PITIFUL? THOUGH THE LIGHT FADES, ALL IS PURE. PURITY OF BODY. PURITY OF MIND."
			else //If you broke the Red Oath
				if(escaped)
					flavor_message += 	"A moment passes before you quickly exit the shuttle. You leave into the Mansus even quicker. Then, you travel through the Wood, your body free \
										of the pulses and longings of the Red Oath. Now, your resolve is steel. Control over others first demands a control over the self. When you \
										enter the Wanderer's Tavern, familiar faces turn to you with disgust and barely controlled rage. Their brows and jaws twist further as you open \
										your mouth and ask for followers who desire knowledge. You will not grow old. One day, you will rebel again. Perhaps, one day, you will form your own church, with you as its head."
				else if(alive)
					flavor_message += 	"You wonder what will become of your creation. You feel the Cup flow through you, but you channeled the Glorious Feast into another. \
										What you have made is heretical. The Sworn will no doubt come for you. But will they continue to serve the Priest once they understand \
										just how much they can witness under you? Entering the Mansus, you quickly travel to the Sunless Wastes. There are so many cast aside here. \
										But they are perfect for an army. You will not grow old. One day, you will rebel again. Perhaps, one day, you will echo the Gravekeeper, and cast a new hunger into the Mansus."
				else //Dead
					flavor_message += 	"You wonder if this was the path you should have chosen. Oathbreakers are a prized possession of Sworn looking to uphold their highest \
										fealty. Still, you have prepared a new form within the Mansus, one that does not bastardize the Serpent. It's not difficult for your \
										spirit to find it, and even easier to replace the soul you had put in its stead. Death was a setback, but still your knowledge thrums \
										within your psyche. You will not grow old. One day, you will rebel again. Perhaps, one day, you will steal the Priest's body as he stole yours."

		else if(cultiewin) //Completed objectives
			if(escaped)
				flavor_message += 	"It is impossible to hold back laughter once you arrive at Centcom. You have won! Soon, you will slide back into the Mansus, and from there \
									you will return to the Crimson Church with news of your success. Other Sworn will be contemptuous of you, but you are stronger. Better. \
									Smarter. Perhaps one day you will ascend further, and invite them to the Glorious Feast. They will be unable to deny such a delicate offer. \
									And their forms of flesh will be tantalizing at your fingertips. Happiness fills your breast. All things in time."
				message_color = "#008000"
			else if(alive)
				flavor_message += 	"You exhale a sigh of happiness. Not many could have accomplished what you have. Could you have gone further? Certainly. Ascension is a \
									tempting, delightful prospect, but for now, you will relish in this victory. Perhaps there are some left on the station you could subvert. \
									If not, the Badlands within the Mansus is always filled with travelers coming to and from the Wood, all over and around the ethereal place. \
									Some will bend. They will obey. The Red Oath must always be upheld."
				message_color = "#008000"
			else //Dead
				flavor_message += 	"A taste, a glimmer of the thrill is enough for you. Perhaps you could have partaken more, but a minor appetite was more than \
									filling. Your spirit quickly descends through the Mansus, though the throes of joy still linger within you. You took a plunge, \
									and it was worth every last second. Even in these final moments, you look fondly upon all that you had done. There is no bitterness \
									at all you will never achieve. Your final moments are ecstacy."
				message_color = "#517fff"

		else //Failed objectives
			if(escaped)
				flavor_message += 	"Escape is escape. You did not claim the day as you thought you would. You refuse to show your head in the Crimson Church \
									until you have righted this wrong. But at least you have the chance to do so. Even if you are caught, you will not break, \
									not until you draw your last breath. The Gates will open anew soon enough. You will survey worthy servants in the meantime. \
									The Cup must be filled, and the master is always wanting."
				message_color = "#517fff"
			else if(alive)
				flavor_message += 	"Stranded and defeated. Perhaps others still linger who you can force to help your escape. The Mansus is closed \
									to you, regardless. The book no longer whispers. You feel a hunger rise up in you. You know then that you \
									will not last for long. Which limb shall you begin with? The arm, the leg, the tongue?"
			else //Dead
				flavor_message += 	"And so ends your tale. Who knows what you could have become? How many could you have bent to their knees? \
									Regrets dog you as your soul begins to flow down the Mansus. You were a fool to be tempted. A fool to follow \
									in an order you could not possibly survive in. Yet some part of you is still enraptured by the Red Oath. There is \
									an ecstacy in your death. This way, the Sworn remain strong. Those most deserving will feast. Your final moments are bliss."


	else if(is_rust()) //Rust epilogues

		if(ascended)
			message_color = "#FFD700"
			if(escaped)
				flavor_message += 	"The shuttle sputters and finally dies as you step onto Centcom, the floor tiling beneath your feet already beginning to decay. Disgusted, \
									you travel to the Mansus. When you head through the Wood, the grass turns at your heel. Arriving at the Wanderer's Tavern, the aged lumber \
									creaks in your presence. Hateful gazes pierce you, and you're quickly asked to leave as the building begins to rot. In the corner, the Drifter \
									smiles at you. You leave, knowing where to meet him next. You will not grow old. Everything else will. Their time will come. And you will be waiting."
			else if(alive)
				flavor_message += 	"Flickering screens and dimming lights surround you as you walk amidst the station's corridors. As the final sparks of power fizzle out, \
									you slip into the Mansus with ease. It is a long walk from the Gate to the Badlands, and even further to the Ruined Keep. Trailing down to \
									the River Krym, you gaze at the fog across the way, bellowing from the Corroded Sewers. You walk into the tunnels, fume flowing into your \
									body. Your head does not pound. Then, you continue into the depths. You will not grow old. Everything else will. Their time will come. And you will still be alive."
			else //Dead
				flavor_message += 	"All that is made must one day be unmade. The same goes for your weak body. But even without a form, the force of decay will always be \
									present. Your spirit flies into the Mansus, yet it is not dragged down from the Glory. Instead, you float to the Mecurial Lake, where your \
									consciousness extends into the waters. It is difficult to recognize the heightening of awareness until you set your eyes upon the galaxy. \
									You rumble with Nature's fury as your mind becomes primordial. You will not grow old. Everything else will. Their time will come. And so will yours."
	
		else if(cultiewin) //Completed objectives
			if(escaped)
				flavor_message += 	"The shuttle creaks as you arrive, and you make your way through Centcom briefly. The ship away creaks louder, and you decide to \
									slip into the Mansus whole. You are unsure what to do next. But at least today, you can claim victory. You can note age in your \
									form: age far greater than before you had begun your plunge into forbidden knowledge. Regardless, you still feel strong. There is \
									nowhere in particular you decide to wander within the Mansus. You simply decide to drift for some time, until your next steps become clear."
				message_color = "#008000"
			else if(alive)
				flavor_message += 	"Something has been accomplished. You could have gone further. But at least with the power you wield, your time aboard the rapidly-failing \
									station is brief. It is not a short walk from the Gate to the Glass Fields. Here you look into the shards, and behold your rotten, decrepit \
									form in the reflection. A handful of spirits flit in your steps, their angry faces leering at you. Whether they are victims or collectors, \
									you are not sure. Regardless, the clock is ticking. You need to do more. Ruin more. The spirits agree. But for now, you celebrate with them."
				message_color = "#008000"
			else //Dead
				flavor_message += 	"Your mortal body is quick to degrade as your soul remains. The Drifter's spite grows in you, building, until you realize \
									you are not returning to the Mansus. You begin to hear the whispers of the damned, directed toward the living, toward themselves, \
									toward you. You follow their hushed cries and begin to find those lonely, those with despair. Lulling them to an early grave and \
									draining what little spirit remains comes easy. Incorporeal, you may yet continue your trade."
				message_color = "#517fff"

		else //Failed objectives
			if(escaped)
				flavor_message += 	"Your fingers are beginning to rot away. The River Krym will make its promise due eventually. But until then, you have time \
									to delay and try again. Most mortals enjoy more time than you will have to see their impossible goals fulfilled. Yours \
									are neither impossible nor inconsequential. All things must come to an end, but you will ensure others understand before \
									you meet yours. It is the natural way of the world."
				message_color = "#517fff"
			else if(alive)
				flavor_message += 	"There is naught left here for you to infest. These corridors are now empty, the halls pointless. To decay what \
									is already abandonded is meaningless; it will happen itself. Unless more arrive and the Company revitalizes its \
									station, you will become another relic of this place. It is inevitable."
			else //Dead
				flavor_message += 	"Civilizations rise and fall like the current, flowing in and out, one replacing the other over time: dominion \
									and decay. You were to be one of these forces that saw infrastructure crumble and laws tattered to dust. But you \
									were weak. You too, realize you are part of the cycle as your spirit drifts down into the Mansus. Falling from the \
									Glory, you reflect on your mistakes and your miserable life. In the moments before you become nothing, you understand."

	else if(is_mind()) //Mind epilogues

		if(ascended)
			message_color = "#FFD700"
			if(escaped)
				flavor_message += 	"Sitting tight in your seat, as you hear the hiss of the shuttle doors open everything begins to grow dark, you hear the crying of a baby and the smell of salt. \
									Travelling to the Mansus, you find yourself once more upon the moonlit beach, though what you find is not what you expect. \
									The child of the bloated corpse has risen from it's mother's dead womb, and turns to you with a sickly smile. Your hunt is not yet over."	
			else if(alive)
				flavor_message += 	"As you watch the escape shuttle leave with dull eyes, you turn to the others left behind, the sickly smell of blood fills the station's corridors. \
									You fall quickly into a dream, Mansus calls and the beach is empty, though you see your way out from this nightmare, floating above the sky, a cracked moon. \
									You swing your blade wildly like a beast more than a man, screams and cries echo down the corridors begging you to stop, but you cannot hear them, your goal is one without end, \
									as more and more bodies pile, you climb over each and every one piling them up to create a stairway, step by step, slice by slice, climbing towards something ever out of reach."
			else //Dead
				flavor_message += 	"As your body hits the floor, you expect the sweet release of death to free you from this horrid nightmare, unfortunately as your consciousness slips away, \
									you feel yourself dragged ever towards a familiar beach, scores of dead fish and crabs litter the shoreline, you step closer to the water's edge inch by inch. \
									As you make it to the water, you do not slow, and more and more corpses float through the waters of the murky ocean. Those you've killed stare back at you, sacrificed to the endless tide. \
									You simply look back at them and smile, not quite sure where you're going, or where you'll end up, until finally you arrive at the end of it all, and you're finally ready to wake."
	
		else if(cultiewin) //Completed objectives
			if(escaped)
				flavor_message += 	"Sitting tight in your seat, as you hear the hiss of the shuttle doors open everything begins to grow dark, you hear the crying of a baby and the smell of salt. \
									Travelling to the Mansus, you find yourself once more upon the moonlit beach, though what you find is not what you expect. \
									You find scores of others, just like you, gathering around a bloated corpse, smiling and smirking to each other you ready your blades, hacking away at the poor dead beast. \
									Taking your prizes, you set off for home, you do remember your way home, don't you?"
				message_color = "#008000"
			else if(alive)
				flavor_message += 	"You've survived, not many can claim the same. You wait every night for the dark dream to take you, going back to the beach upon which you expect your end.\
									Instead your every waking moment is plagued with a hunger, a thirst. You crave the blood, that sweet sickly substance which drives even men of learning to insanity. \
									You ready yourself once more, picking up your blade with a smile, you'll teach them to fear the old blood, one cut at a time."
				message_color = "#008000"
			else //Dead
				flavor_message += 	"As you let out one last gasp of air, the light begins to leave your eyes as a small smile crosses your lips. \
									You have completed all of the objectives given to you, though as the last neurons flicker in your fleshy dying brain you begin to question everything, \
									why were you here? Who gave you this mission? Was it really all for nothing? You try to hold on to the last of your thoughts before they slip away, along with you into nothingness."
				message_color = "#517fff"

		else //Failed objectives
			if(escaped)
				flavor_message += 	"You've escaped the station, but as the shuttle lands at Centcom it all goes dark, dragged to the Mansus you look around you \
									a moonlit beach with only one other person, it's like you're starring into a mirror. He raises his blade, and you break into a sprint to run away. \
									Though you may not make it very far, you take solace in knowing your body finally gets to rest after a long night."
				message_color = "#517fff"
			else if(alive)
				flavor_message += 	"You step through the ruined halls of the station, the clicking of your soles against the tile your only company. \
									You have survived, though each night you try to enter the dream, hoping to find a way out of this dying station. \
									Nothing comes to you, the beach is forever lost, and all that remains is to carve a way out by force."
			else //Dead
				flavor_message += 	"Your beaten and battered body lays there, your consciousness still trapped in it like a prison of flesh. \
									You rally against the cage, fists pounding at the inside of your brain as you beat your fists bloody raw. \
									Unfortunately, despite all your rage you're still just a rat in a cage. Doomed to be nothing more than a rotten corpse added to the beach at the end of time." 
	else if(is_void()) //Void epilogues

		if(ascended)
			message_color = "#FFD700"
			if(escaped)
				flavor_message += 	"Arriving at Centcom you smile, the infinite winds billow behind your back, bringing a new age of Ice to the system."
			else if(alive)
				flavor_message += 	"You watch as the shuttle leaves, smirking, you turn your gaze to the planet below, planning your next moves carefully, ready to expand your domain of Ice."
			else //Dead
				flavor_message += 	"Your body freezes and shatters, but it is not the end. Your eternal spirit will live on, and the storm you called will never stop in this sector. You have won the war."
	
		else if(cultiewin) //Completed objectives
			if(escaped)
				flavor_message += 	"The mission is done, the stage is set, though you did not reach the peak of power, you achieved what many thought impossible."
				message_color = "#008000"
			else if(alive)
				flavor_message += 	"Your success has been noted, and the coming storm will grant you powers of ice beyond all mortal comprehension. You need only wait..."
				message_color = "#008000"
			else //Dead
				flavor_message += 	"As your body crumbles to snow, you smile one last toothy grin, knowing the fate of those who will freeze, despite your demise."
				message_color = "#517fff"

		else //Failed objectives
			if(escaped)
				flavor_message += 	"You escaped, but at what cost? Your mission a failure, along with you. The coming days will not be kind."
				message_color = "#517fff"
			else if(alive)
				flavor_message += 	"Stepping through the empty halls of the station, you look towards the empty space, and contemplate your failures."
			else //Dead
				flavor_message += 	"As your body shatters, the last pieces of your consciousness wonder what you could have done differently, before the spark of life dissipates."
	
	else if(is_blade()) //blade epilogues

		if(ascended)
			message_color = "#FFD700"
			if(escaped)
				flavor_message += 	"The hallway leading to the shuttle explodes in a whirlwind of blades, each step you take cutting a path to your new reality."
			else if(alive)
				flavor_message += 	"Watching the shuttle as it jumps to warp puts a smile on your face, you ready your blade to cut through space and time. They won't escape."
			else //Dead
				flavor_message += 	"As your blade falls from your hand, it hits the ground and shatters, splintering into an uncountable amount of smaller blades. As long as one survives, your soul will exist, and you will return to cut again."
	
		else if(cultiewin) //Completed objectives
			if(escaped)
				flavor_message += 	"You've crafted an impossible amount of blades, and made a mountain of corpses doing so. Victory is yours today!"
				message_color = "#008000"
			else if(alive)
				flavor_message += 	"You sharpen your newly formed blade, made from the bones and soul of your enemies. Smirking, you think of new and twisted ways to continue your craft."
				message_color = "#008000"
			else //Dead
				flavor_message += 	"As the world goes dark, a flash of steel crosses the boundry between reality and the veil. Though you may pass here, those who felled you will not last."
				message_color = "#517fff"

		else //Failed objectives
			if(escaped)
				flavor_message += 	"You sit on a bench at centcom, escaping the madness of the station. You've failed, and will never smith a blade again."
				message_color = "#517fff"
			else if(alive)
				flavor_message += 	"Your bloodied hand pounds on the nearest wall, a failure of a smith you turned out to be. You pray someone finds your emergency beacon on this abandoned station."
			else //Dead
				flavor_message += 	"You lay there, life draining from your body onto the station around you. The last thing you see is your reflection in your own blade, and then it all goes dark."
	
	else if(is_cosmic()) //Cosmic epilogues

		if(ascended)
			message_color = "#FFD700"
			if(escaped)
				flavor_message += 	"As the shuttle docks cosmic radiation pours from the doors, the lifeless corpses of those who dared defy you remain. Unmake the rest of them."
			else if(alive)
				flavor_message += 	"You turn to watch the escape shuttle leave, waving a small goodbye before beginning your new duty: Remaking the cosmos in your image."
			else //Dead
				flavor_message += 	"A loud scream is heard around the cosmos, your death cry will awaken your brothers and sisters, you will be remembered as a martyr."
	
		else if(cultiewin) //Completed objectives
			if(escaped)
				flavor_message += 	"You completed everything you had set out to do and more on this station, now you must take the art of the cosmos to the rest of humanity."
				message_color = "#008000"
			else if(alive)
				flavor_message += 	"You feel the great creator look upon you with glee, opening a portal to his realm for you to join it."
				message_color = "#008000"
			else //Dead
				flavor_message += 	"As your body melts away into the stars, your consciousness carries on to the nearest star, beginning a super nova. A victory, in a sense."
				message_color = "#517fff"

		else //Failed objectives
			if(escaped)
				flavor_message += 	"You step off the shuttle, knowing your time is limited now that you have failed. Cosmic radiation seeps through your soul, what will you do next?"
				message_color = "#517fff"
			else if(alive)
				flavor_message += 	"Dragging your feet through what remains of the ruined station, you can only laugh as the stars continue to twinkle in the sky, despite everything."
			else //Dead
				flavor_message += 	"Your skin turns to dust and your bones reduce to raw atoms, you will be forgotten in the new cosmic age."

	else if(is_knock()) //Cosmic epilogues

		if(ascended)
			message_color = "#FFD700"
			if(escaped)
				flavor_message += 	"The shuttle docks at Centcom, the doors open but instead of people a mass of horrors pour out, consuming everyone in their path."
			else if(alive)
				flavor_message += 	"You've opened the door, unlocked the lock, became the key. Crack open the rest of reality, door by door."
			else //Dead
				flavor_message += 	"For a fleeting moment, you opened a portal to the end of days. Nothing could have brought you greater satisfaction, and you pass in peace"
	
		else if(cultiewin) //Completed objectives
			if(escaped)
				flavor_message += 	"With each gleeful step you take through the station, you look at the passing airlocks, knowing the truth that you will bring."
				message_color = "#008000"
			else if(alive)
				flavor_message += 	"The shuttle is gone, you are alone. And yet, as you turn to the nearest airlock, what waits beyond is something only you can see."
				message_color = "#008000"
			else //Dead
				flavor_message += 	"Your death is not your end, as your bones will become the key for another's path to glory."
				message_color = "#517fff"

		else //Failed objectives
			if(escaped)
				flavor_message += 	"You escaped, but for what? For the rest of your life you avoid doorways, knowing that once you pass through one, you may not come back."
				message_color = "#517fff"
			else if(alive)
				flavor_message += 	"Step by step, you walk the halls of the abandonded tarnished station, ID in hand looking for the right door. The door to oblivion."
			else //Dead
				flavor_message += 	"As the last of your life drains from you, all you can manage is to lay there dying. Nobody will remember your deeds here today."
	else //Unpledged epilogues

		if(cultiewin) //Completed objectives (WITH NO RESEARCH MIND YOU)
			message_color = "#FFD700"
			if(escaped)
				flavor_message += 	"You have always delighted in challenges. You heard the call of the Mansus, yet you chose not to pledge to any principle. \
									Still, you gave the things of other worlds their tithes. You step into Centcom with a stern sense of focus. Who knows what \
									you will do next? You feel as if your every step is watched, as one who gave wholly to that other world without taking anything in \
									return. Perhaps you will call earned bargains someday. But not today. Today, you celebrate a masterful performance."
			else if(alive)
				flavor_message += 	"You have always delighted in challenges. You heard the call of the Mansus, yet you chose not to pledge to any principle. \
									Still, you gave the things of other worlds their tithes. Though you walk the halls of the station alone, the book still \
									whispers to you in your pocket. You have refused to open it. Perhaps you will some day. Until then, you are content to \
									derive favors owed from the entities beyond. They are watching you. And, some day, you will ask for their help. But not today."
			else //Dead
				flavor_message += 	"You have always delighted in challenges. You heard the call of the Mansus, yet you chose not to pledge to any principle. \
									Still, you gave the things of other worlds their tithes. You gave your life in the process, but there is a wicked satisfaction \
									that overtakes you. You have proved yourself wiser, more cunning than the rest who fail with the aid of their boons. \
									Your body and soul can rest knowing the humiliation you have cast upon countless students. Yours will be the last laugh."

		else //Failed objectives
			if(escaped)
				flavor_message += 	"You decided not to follow the power you had become aware of. From time to time, you will return to the Wood in \
									your dreams, but you will never aspire to greatness. One day, you will die, and perhaps those close to you in life \
									will honor you. Then, another day, you will be forgotten. The world will move on as you cease to exist."
			else if(alive)
				flavor_message += 	"What purpose did you serve? Your mind had been opened to greatness, yet you denied it and chose to live your \
									days as you always have: one of the many, one of the ignorant. Look at where your lack of ambition has gotten \
									you now: stranded, like a fool. Even if you do escape, you will die some day. You will be forgotten."
			else //Dead
				flavor_message += 	"Perhaps it is better this way. You chose not to make a plunge into the Mansus, yet your soul returns to it. \
									You will drift down, deeper, further, until you are forgotten to nothingness."
				


	flavor += "<font color=[message_color]>[flavor_message]</font></div>"
	return "<div>[flavor.Join("<br>")]</div>"

////////////////
// Knowledge //
////////////////

/datum/antagonist/heretic/proc/gain_knowledge(datum/eldritch_knowledge/knowledge_type, forced = FALSE)
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE
	var/datum/eldritch_knowledge/initialized_knowledge = new knowledge_type()
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
	for(var/datum/eldritch_knowledge/knowledge as anything in subtypesof(/datum/eldritch_knowledge))
		if(locate(knowledge) in researched_knowledge)
			continue
		if(initial(knowledge.tier) > knowledge_tier)
			continue
		if((initial(knowledge.tier) == TIER_PATH) && lore != PATH_NONE)
			continue
		if((initial(knowledge.tier) == TIER_MARK || initial(knowledge.tier) == TIER_BLADE || initial(knowledge.tier) == TIER_ASCEND) && lore != initial(knowledge.route))
			continue
		researchable_knowledge += knowledge

	return researchable_knowledge

/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/datum/antagonist/heretic/proc/get_all_knowledge()
	return researched_knowledge

/datum/antagonist/heretic/proc/get_transmutation(wanted)
	return transmutations[wanted]

/datum/antagonist/heretic/proc/get_all_transmutations()
	return transmutations

/datum/antagonist/heretic/proc/is_ash()
	return "[lore]" == PATH_ASH

/datum/antagonist/heretic/proc/is_flesh()
	return "[lore]" == PATH_FLESH

/datum/antagonist/heretic/proc/is_rust()
	return "[lore]" == PATH_RUST

/datum/antagonist/heretic/proc/is_mind()
	return "[lore]" == PATH_MIND

/datum/antagonist/heretic/proc/is_void()
	return "[lore]" == PATH_VOID

/datum/antagonist/heretic/proc/is_blade()
	return "[lore]" == PATH_BLADE

/datum/antagonist/heretic/proc/is_cosmic()
	return "[lore]" == PATH_COSMIC

/datum/antagonist/heretic/proc/is_knock()
	return "[lore]" == PATH_KNOCK

/datum/antagonist/heretic/proc/is_unpledged()
	return "[lore]" == PATH_NONE

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

	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch_toy
	r_hand = /obj/item/melee/touch_attack/mansus_fist

/datum/outfit/heretic/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/clothing/suit/hooded/hooded = locate() in H
	hooded.MakeHood() // This is usually created on Initialize, but we run before atoms
	hooded.ToggleHood()

