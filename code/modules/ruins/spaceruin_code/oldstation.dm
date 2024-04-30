///////////	Oldstation items

/obj/item/paper/fluff/ruins/oldstation
	name = "Cryo Awakening Alert"
	info = "<B>**WARNING**</B><BR><BR>Catastrophic damage sustained to station. Powernet exhausted to reawaken crew.<BR><BR>Immediate Objectives<br><br>1: Activate emergency power generator<br>2: Lift station lockdown on the bridge<br><br>Please locate the 'Damage Report' on the bridge for a detailed situation report."

/obj/item/paper/fluff/ruins/oldstation/damagereport
	name = "Damage Report"
	info = "<b>*Damage Report*</b><br><br><b>Alpha Station</b> - Destroyed<br><br><b>Beta Station</b> - Catastrophic Damage. Medical, destroyed. Atmospherics, partially destroyed.<br><br><b>Charlie Station</b> - Intact. Nuclear reactor is damaged. Cooling system offline.<br><br><b>Delta Station</b> - Intact. <b>WARNING</b>: Unknown force occupying Delta Station. Intent unknown. Species unknown. Numbers unknown.<br><br>Recommendation - Reestablish station powernet via solar array. Reestablish station atmospherics system to restore air."

/obj/item/paper/fluff/ruins/oldstation/protosuit
	name = "B01-RIG Hardsuit Report"
	info = "<b>*Prototype Hardsuit*</b><br><br>The B01-RIG Hardsuit is a prototype powered exoskeleton. Based off of a recovered pre-void war era united Earth government powered military \
	exosuit, the RIG Hardsuit is a breakthrough in Hardsuit technology, and is the first post-void war era Hardsuit that can be safely used by an operator.<br><br>The B01 however suffers \
	a myriad of constraints. It is slow and bulky to move around, it lacks any significant armor plating against direct attacks and its internal heads up display is unfinished,  \
	resulting in the user being unable to see long distances.<br><br>The B01 is unlikely to see any form of mass production, but will serve as a base for future Hardsuit developments."

/obj/item/paper/fluff/ruins/oldstation/protohealth
	name = "Health Analyser Report"
	info = "<b>*Health Analyser*</b><br><br>The portable K-9 Health Analyser is essentially a handheld variant of a stationary body scanner. Years of research have concluded with this device which is \
	capable of diagnosing even the most critical, obscure or technical injuries any humanoid entity is suffering in an easy to understand format that even a non-trained health professional \
	can understand.<br><br>The health analyser is expected to go into full production as standard issue medical kit."

/obj/item/paper/fluff/ruins/oldstation/protogun
	name = "K14 Energy Gun Report"
	info = "<b>*K14-Multiphase Energy Gun*</b><br><br>The K14 Prototype Energy Gun is the first energy rifle that has been successfully been able to not only hold a larger ammo charge \
	than other gun models, but is capable of swapping between different energy projectile types on command without malfunction.<br><br>The weapon still suffers several drawbacks, such as the fact its non-lethal, \
	'taser' fire mode can only fire one round before exhausting the energy cell. It also remains prohibitively expensive to produce, nonetheless NT Market Research fully believe this weapon \
	will form the backbone of our energy weapon catalogue.<br><br>The K14 is expected to undergo revision to fix the ammo issues, and the K15 is expected to replace the 'taser' setting with a \
	lower-power version of the laser setting (designed to disorient on contact) in an attempt to bypass the ammo issues."

/obj/item/paper/fluff/ruins/oldstation/protosing
	name = "Singularity Generator"
	info = "<b>*Singularity Generator*</b><br><br>Modern power generation typically comes in two forms, a Fusion Generator or a Fission Generator. Fusion provides the best space to power \
	ratio, and is typically seen on military or high security ships and stations, however Fission reactors require the usage of expensive, and rare, materials in its construction.. Fission generators are massive and bulky, and require a large reserve of uranium to power, however they are extremely cheap to operate and oft need little maintenance once \
	operational.<br><br>The Singularity aims to alter this, a functional Singularity is essentially a controlled Black Hole, a Black Hole that generates far more power than Fusion or Fission \
	generators can ever hope to produce - assuming its containment systems remain operational."


/obj/item/paper/fluff/ruins/oldstation/report
	name = "Crew Reawakening Report"
	info = "Artificial Program's report to surviving crewmembers.<br><br>Crew were placed into cryostasis on March 10th, 2445.<br><br>Crew were awoken from cryostasis around June, 2557.<br><br> \
	<b>SIGNIFICANT EVENTS OF NOTE</b><br>1: The primary radiation detectors were taken offline after 112 years due to power failure. Auxiliary radiation detectors showed no residual \
	radiation on station. <br><br>2: A data burst from a nearby unidentified station (callsign NTSS-13) was received and successfully decoded into research data.<br><br>3: Unknown invasion force has occupied Delta station."

/obj/item/paper/fluff/ruins/oldstation/generator_manual
	name = "S.U.P.E.R.P.A.C.M.A.N.-type portable generator manual"
	info = "<i>You can barely make out a faded sentence...</i> <br><br> Wrench down the generator on top of a wire node connected to either a SMES input terminal or the power grid." 

/obj/item/paper/fluff/ruins/oldstation/nuclearcore_status
	name = "Nuclear Reactor Status Assessment"
	info = "Automatic Nuclear Core Status Report <br><br> \
	Date: 2nd of June, 2557 <br><br> \
	Nuclear Core: Intact, Fuel Expended <br><br> \
	Coolant Heat Exchangers: Compromised - Repairs Required <br><br> \
	Moderator Tanks: Intact <br><br> \
	Coolant Input: Intact <br><br> \
	Assessment: Repair Cooling Loop, Then Reboot"

/obj/machinery/computer/terminal/oldstation
	name = "old terminal"
	desc = "An extremely old terminal used to monitor the cryogenic stasis systems of the outpost. Automatically provides a copy of certain reports to crew where necessary."
	upperinfo = "NANOTRASEN SYSTEMS CRYOGENICS TERMINAL 3.11"
	content = list(
		"Date of Last Check: 3rd of June, 2557. Status as of Last Check: 5 crew in stasis.",
		"Artificial Program Alerts: ALPHA WING DISCONNECTED. BETA WING REPORTS HULL DAMAGE. CHARLIE WING REPORTS REACTOR DAMAGE. DELTA WING REPORTS UNKNOWN LIFEFORMS.",
		"Security Level: UNKNOWN.",
		"Distress Beacon: DAMAGED or OFFLINE.",
		"Automated Advisory: Seek the Control Terminal on the Bridge for a detailed situation report."
		)

/obj/machinery/computer/terminal/oldstation/central
	name = "central control terminal"
	desc = "An outdated type of terminal originally used by Nanotrasen to control station systems on a much wider-reaching basis than the communications console."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_BLUE
	tguitheme = "nanotrasen"
	upperinfo = "NANOTRASEN CENTRAL CONTROL UNIT TYPE 1 - Status Report"
	content = list(
		"Automatically-Generated Status Report:",
		"Hull integrity of Alpha wing compromised! Hull integrity of Beta wing compromised!",
		"Artificial Program integrity report: Compromised!",
		"Reactor integrity report: Cooling system damaged!",
		"Incidents of Note:",
		"1: Primary Radiation Detector deactivated after 112 years due to power failure. Auxilliary detector reported no radiation.",
		"2: Data burst recieved from unidentified station in the region, callsign NTSS-13. Successfully decoded into research data.",
		"3: An unidentified biotic force has intruded upon Delta wing.",
		"Cryogenic System Report:",
		"Crew entered stasis on: 10/03/2445",
		"Awakening process started on: 03/06/2557",
		"Crew in stasis as of report generation: Five personnel"
		)

/obj/machinery/computer/terminal/oldstation/research
	name = "prototype console"
	desc = "A terminal used to keep logs about the prototypes in storage."
	upperinfo = "ntOS 1.1 / Prototype Logs / manifest.txt"
	content = list(
		"Delta Wing Prototype Storage Manifest",
		"x1 NT-K-14 / NT-E1 Experimental Energy Gun - inform Head of Security before removing",
		"x1 NT-K-9 / NT-H1 Health Analyzer - inform Chief Medical Officer before removing",
		"x1 NT-K-12 B01 RIG Hardsuit - inform Chief Engineer before removing",
		"x1 NT-K-13 'Singularity Generator' - alert all crew when moving due to volatility",
		"You MUST have permission of the Captain and Research Director to move any prototypes!",
		"Please be advised that your non-disclosure agreement means this manifest is not for public distribution under any circumstances. Don't reveal our hard work!"
		)

/obj/machinery/computer/terminal/oldstation/security
	name = "security terminal"
	desc = "A terminal used to monitor station status, review suit sensors, and request alteration to the facility's alert level."
	icon_screen = "security"
	icon_keyboard = "security_key"
	light_color = LIGHT_COLOR_RED
	upperinfo = "SECURITY WARNING - LOCKDOWN INITIATED"
	content = list(
		"WARNING: A secure area, Delta Wing, has been compromised by an unknown force.",
		"An automated full lockdown has been issued of all systems to prevent capture of proprietary information.",
		"To override the lockdown, please utilise the Central Control Terminal."
		)

/obj/machinery/computer/terminal/oldstation/artificialprogram
	name = "artificial program control terminal"
	desc = "A control terminal used to directly interface and give orders to the station's Artificial Program."
	upperinfo = "INTEGRITY REPORT - WARNING"
	content = list(
		"Alert! The Artificial Program has been disconnected.",
		"Last logs are as follows:",
		"ALERT: CORE DAMAGE DETECTED! CORE DAMAGE DETECTED!",
		"ALERT: Unidentified lifeforms have entered core chamber",
		"ALERT: Unidentified lifeforms have entered Delta Station",
		"WARNING: Crew casualty detected (Research Director)",
		"NOTICE: One crewmember (Research Director) has left stasis.",
		"NOTICE: Cryogenic stasis procedures initiated. 6 personnel frozen."
		)

//terminal formatting is really weird and its just copypasted /tg/ code so idk how to fix it lmao
//advice for anyone else who deals with it: either fix it to use whatever paper uses or **DO NOT** TRY TO FORMAT IT!
//PLEASE I FUCKING BEG YOU EITHER FIX IT OR DONT TRY TO OR ITLL BE FUCKING HELL ON EARTH
