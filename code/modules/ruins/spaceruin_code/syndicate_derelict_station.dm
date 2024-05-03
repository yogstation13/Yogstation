///////////	syndicate derelict station items

/obj/item/paper/fluff/ruins/syndicate_derelict_station/engineering
	name = "Syndicate engineering notification"
	info = "Welcome to the station, gentlemen. You have been assigned to this station to repair it after an accident that left it without maintenance for a long time.<br><br>Your objective here is simple: <b>Repair the station to its peak state, and man it until we can afford to send a research team.</b><br><br>We have sent you a package of materials in order to help you repair and restock the station. Anything else, you're on your own."

/obj/item/paper/crumpled/bloody/ruins/syndicate_derelict_station/lore1
	name = "unfinished paper scrap"
	desc = "It appears to have been written in a rush. Unfortunately, the blood stain does not give a clear view of its text."
	info = "##### -- there's no way this fucking happened...<br><br>whoever sees this, please, let them kno-- ###-_"

/obj/item/paper/crumpled/bloody/ruins/syndicate_derelict_station/lore2
	name = "bloody paper scrap"
	desc = "Barely readable due to the blood stains covering the whole paper."
	info = "##### -- DO NOT G-###-_ SIDE__###"

/obj/item/paper/crumpled/ruins/syndicate_derelict_station/important_note
	name = "important note"
	info = "Word has spread that pirates are raiding around us, keep this gun with you just in case they come around"

/obj/machinery/computer/terminal/syndicate_derelict
	name = "syndicate communications console"
	desc = "A console used to recieve important communications from Syndicate Command."
	tguitheme = "syndicate"
	light_color = "#FA8282"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	upperinfo = "syndOS - Communications Terminal"
	content = list("PRIORITY: HIGH | ASSIGNMENT TO ENGINEERING PERSONNEL","You have been assigned to refit this deactivated listening station into an orbital research outpost. We have successfully teleported several supply crates into the onboard Vault. Use them to establish a functional base.")

/obj/machinery/computer/terminal/syndicate_derelict/command
	name = "syndicate central command terminal"
	desc = "An outdated terminal originally used by the Syndicate to provide automated central control for their outposts. Doesn't seem to do much now."
	upperinfo = "Syndicate Integrated Command Terminal"
	content = list("STATION INTEGRITY ALERT!","Atmospheric integrity failure detected in: COMMUNICATIONS. ARRIVALS. MEDICAL. CANTEEN. ENGINEERING.","Hull integrity failure detected in: COMMUNICATIONS. ARRIVALS. MEDICAL. CANTEEN. ENGINEERING.","Unauthorised biotic lifeforms detected in proximity.","Unauthorised robotic systems detected in: VAULT","Outpost security level: RED.")

/obj/machinery/computer/terminal/syndicate_derelict/docking
	name = "syndicate docking console"
	desc = "A unique terminal used by the Syndicate to combine the functions of a cargo, IFF, and hailing system into one. Examples of these are quite rare nowadays."
	upperinfo = "Syndicate Docking Terminal"
	content = list("CODE RED: Terminal lockout engaged.","Unable to connect to regional Syndicate logistics hubs.","IFF beacon in STEALTH mode. Unable to alter - insufficient access.","No vessels on Syndicate hailing frequencies detected.")

/obj/machinery/computer/terminal/syndicate_derelict/cargo
	upperinfo = "Syndicate Command Uplink"
	content = list("PRIORITY: HIGH | ASSIGNMENT TO SALVAGE PERSONNEL","You have been assigned to reactivate this cargo relay station for Syndicate use, and to upgrade it to perform additional functions. You should have necessary supplies in the onboard vault.")

/obj/machinery/computer/terminal/syndicate_derelict/cargo/manifest
	name = "syndicate logistics terminal"
	desc = "A terminal used by certain Syndicate outposts to track cargo."
	upperinfo = "Syndicate Freight Terminal - Property of Cybersun Industries (c) 2542"
	content = list("ALERT!","Security breach detected. Manifest check required.")
