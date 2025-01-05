/datum/antagonist/bloodsucker
	///Used for assigning your name
	var/bloodsucker_name
	///Used for assigning your title
	var/bloodsucker_title
	///Used for assigning your reputation
	var/bloodsucker_reputation

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Credits flavour---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/// Evaluates the conditions of the bloodsucker at the end of each round to pick a flavor message to add
/datum/antagonist/bloodsucker/proc/get_flavor(objectives_complete, optional_objectives_complete)
	var/list/flavor = list()
	var/flavor_message
	var/alive = owner?.current?.stat != DEAD //Technically not necessary because of Final Death objective?
	var/escaped = ((owner.current.onCentCom() || owner.current.onSyndieBase()) && alive)
	flavor += "<div><font color='#6d6dff'>Epilogue: </font>"
	var/message_color = "#ef2f3c"

	flavor_message += "flavour texts are a work in progress, stay tuned."
	// if(objectives_complete)
	// 	if(optional_objectives_complete)
	// 		message_color = "#008000"
	// 		if(broke_masquerade)
	// 			if(escaped)
	// 				flavor_message += pick(list(
	// 					"What matters of the Masquerade to you? Let it crumble into dust as your tyranny whips forward to dine on more stations. 
	// 					News of your butchering exploits will quickly spread, and you know what will encompass the minds of mortals and undead alike. Fear."
	// 				))
	// 			else if(alive)
	// 				flavor_message += pick(list(
	// 					"Blood still pumps in your veins as you lay stranded on the station. No doubt the wake of chaos left in your path will attract danger, but greater power than you've ever felt courses through your body. 
	// 					Let the Camarilla and the witchers come. You will be waiting."
	// 				))
	// 		else
	// 			if(escaped)
	// 				flavor_message += pick(list(
	// 					"You step off the spacecraft with a mark of pride at a superbly completed mission. Upon arriving back at CentCom, an unassuming assistant palms you an invitation stamped with the Camarilla seal. 
	// 					High society awaits: a delicacy you have earned."
	// 				))
	// 			else if(alive)
	// 				flavor_message += pick(list(
	// 					"This station has become your own slice of paradise. Your mission completed, you turn on the others who were stranded, ripe for your purposes. 
	// 					Who knows? If they prove to elevate your power enough, perhaps a new bloodline might be founded here."
	// 				))
	// 	else
	// 		message_color = "#517fff"
	// 		if(broke_masquerade)
	// 			if(escaped)
	// 				flavor_message += pick(list(
	// 					"Your mission accomplished, you step off the spacecraft, feeling the mark of exile on your neck. Your allies gone, your veins thrum with a singular purpose: survival."
	// 				))
	// 			else if(alive)
	// 				flavor_message += pick(list(
	// 					"You survived, but you broke the Masquerade, your blood-stained presence clear and your power limited. No doubt death in the form of claw or stake hails its approach. Perhaps it's time to understand the cattles' fascinations with the suns."
	// 				))
	// 		else
	// 			if(escaped)
	// 				flavor_message += pick(list(
	// 					"A low profile has always suited you best, conspiring enough to satiate the clan and keep your head low. It's not luxorious living, though death is a less kind alternative. On to the next station."
	// 				))
	// 			else if(alive)
	// 				flavor_message += pick(list(
	// 					"You completed your mission and kept your identity free of heresy, though your mark here is not strong enough to lay a claim. Best stow away when the next shuttle comes around."
	// 				))

	if(!message_color || (!alive && !escaped)) //perish or just fuck up and fail your primary objectives
		message_color = "#ef2f3c"
		flavor_message += pick(list(
			"Thus ends the story of [return_full_name(TRUE)]. No doubt future generations will look back on your legacy and reflect on the lessons of the past. If they remember you at all."
		))

	flavor += "<font color=[message_color]>[flavor_message]</font></div>"
	return "<div>[flavor.Join("<br>")]</div>"


/*
 *	# Bloodsucker Names
 *
 *	All Bloodsuckers get a name, and gets a better one when they hit Rank 4.
 */

/// Names
/datum/antagonist/bloodsucker/proc/SelectFirstName()
	if(owner.current.gender == MALE)
		bloodsucker_name = pick(
			"Desmond","Rudolph","Dracula","Vlad","Pyotr","Gregor",
			"Cristian","Christoff","Marcu","Andrei","Constantin",
			"Gheorghe","Grigore","Ilie","Iacob","Luca","Mihail","Pavel",
			"Vasile","Octavian","Sorin","Sveyn","Aurel","Alexe","Iustin",
			"Theodor","Dimitrie","Octav","Damien","Magnus","Caine","Abel", // Romanian/Ancient
			"Lucius","Gaius","Otho","Balbinus","Arcadius","Romanos","Alexios","Vitellius", // Latin
			"Melanthus","Teuthras","Orchamus","Amyntor","Axion", // Greek
			"Thoth","Thutmose","Osorkon,","Nofret","Minmotu","Khafra", // Egyptian
			"Dio",
		)
	else
		bloodsucker_name = pick(
			"Islana","Tyrra","Greganna","Pytra","Hilda",
			"Andra","Crina","Viorela","Viorica","Anemona",
			"Camelia","Narcisa","Sorina","Alessia","Sophia",
			"Gladda","Arcana","Morgan","Lasarra","Ioana","Elena",
			"Alina","Rodica","Teodora","Denisa","Mihaela",
			"Svetla","Stefania","Diyana","Kelssa","Lilith", // Romanian/Ancient
			"Alexia","Athanasia","Callista","Karena","Nephele","Scylla","Ursa", // Latin
			"Alcestis","Damaris","Elisavet","Khthonia","Teodora", // Greek
			"Nefret","Ankhesenpep", // Egyptian
		)

/datum/antagonist/bloodsucker/proc/SelectTitle(am_fledgling = 0, forced = FALSE)
	// Already have Title
	if(!forced && bloodsucker_title != null)
		return
	// Titles [Master]
	if(!am_fledgling)
		if(owner.current.gender == MALE)
			bloodsucker_title = pick ("Count","Baron","Viscount","Prince","Duke","Tzar","Dreadlord","Lord","Master")
		else
			bloodsucker_title = pick ("Countess","Baroness","Viscountess","Princess","Duchess","Tzarina","Dreadlady","Lady","Mistress")
		to_chat(owner, span_announce("You have earned a title! You are now known as <i>[return_full_name(TRUE)]</i>!"))
	// Titles [Fledgling]
	else
		bloodsucker_title = null



/datum/antagonist/bloodsucker/proc/AmFledgling()
	return !bloodsucker_title

/datum/antagonist/bloodsucker/proc/return_full_name(include_rep = FALSE)

	var/fullname
	// Name First
	fullname = (bloodsucker_name ? bloodsucker_name : owner.current.name)
	// Title
	if(bloodsucker_title)
		fullname = bloodsucker_title + " " + fullname
	// Rep
	if(include_rep && bloodsucker_reputation)
		fullname = fullname + " the " + bloodsucker_reputation

	return fullname
	
/datum/antagonist/bloodsucker/proc/SelectReputation(am_fledgling = FALSE, forced = FALSE)
	// Already have Reputation
	if(!forced && bloodsucker_reputation != null)
		return

	if(am_fledgling)
		bloodsucker_reputation = pick(
			"Crude","Callow","Unlearned","Neophyte","Novice","Unseasoned",
			"Fledgling","Young","Neonate","Scrapling","Untested","Unproven",
			"Unknown","Newly Risen","Born","Scavenger","Unknowing","Unspoiled",
			"Disgraced","Defrocked","Shamed","Meek","Timid","Broken","Fresh",
		)
	else if(owner.current.gender == MALE && prob(10))
		bloodsucker_reputation = pick("King of the Damned", "Blood King", "Emperor of Blades", "Sinlord", "God-King")
	else if(owner.current.gender == FEMALE && prob(10))
		bloodsucker_reputation = pick("Queen of the Damned", "Blood Queen", "Empress of Blades", "Sinlady", "God-Queen")
	else
		bloodsucker_reputation = pick(
			"Butcher","Blood Fiend","Crimson","Red","Black","Terror",
			"Nightman","Feared","Ravenous","Fiend","Malevolent","Wicked",
			"Ancient","Plaguebringer","Sinister","Forgotten","Wretched","Baleful",
			"Inqisitor","Harvester","Reviled","Robust","Betrayer","Destructor",
			"Damned","Accursed","Terrible","Vicious","Profane","Vile",
			"Depraved","Foul","Slayer","Manslayer","Sovereign","Slaughterer",
			"Forsaken","Mad","Dragon","Savage","Villainous","Nefarious",
			"Inquisitor","Marauder","Horrible","Immortal","Undying","Overlord",
			"Corrupt","Hellspawn","Tyrant","Sanguineous",
		)

	to_chat(owner, span_announce("You have earned a reputation! You are now known as <i>[return_full_name(TRUE)]</i>!"))
