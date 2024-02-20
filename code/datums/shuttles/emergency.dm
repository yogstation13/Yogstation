#define EMAG_LOCKED_SHUTTLE_COST (CARGO_CRATE_VALUE * 50)

/datum/map_template/shuttle/emergency
	port_id = "emergency"
	name = "Base Shuttle Template (Emergency)"
	///assoc list of shuttle events to add to this shuttle on spawn (typepath = weight)
	var/list/events
	///pick all events instead of random
	var/use_all_events = FALSE
	///how many do we pick
	var/event_amount = 1
	///do we empty the event list before adding our events
	var/events_override = FALSE

	// Yog code: we haven't completely revamped shuttles yet so to avoid doing a lot more work i'm just adding a placeholder value
	occupancy_limit = "FLEXIBLE"

/datum/map_template/shuttle/emergency/New()
	. = ..()
	if(!occupancy_limit && who_can_purchase)
		CRASH("The [name] needs an occupancy limit!")
	if(HAS_TRAIT(SSstation, STATION_TRAIT_SHUTTLE_SALE) && credit_cost > 0 && prob(15))
		var/discount_amount = round(rand(25, 80), 5)
		name += " ([discount_amount]% Discount!)"
		var/discount_multiplier = 100 - discount_amount
		credit_cost = ((credit_cost * discount_multiplier) / 100)

///on post_load use our variables to change shuttle events
/datum/map_template/shuttle/emergency/post_load(obj/docking_port/mobile/mobile)
	. = ..()
	if(!events)
		return
	// if(events_override)
	// 	mobile.event_list.Cut()
	// if(use_all_events)
	// 	for(var/path in events)
	// 		mobile.event_list.Add(new path(mobile))
	// 		events -= path
	// else
	// 	for(var/i in 1 to event_amount)
	// 		var/path = pick_weight(events)
	// 		events -= path
	// 		mobile.event_list.Add(new path(mobile))

/datum/map_template/shuttle/emergency/backup
	suffix = "backup"
	name = "Backup Shuttle"
	who_can_purchase = null

/datum/map_template/shuttle/emergency/construction
	suffix = "construction"
	name = "Build Your Own Shuttle"
	description = "For the enterprising shuttle engineer! The chassis will dock upon purchase, but launch will have to be authorized as usual via shuttle call. Comes stocked with construction materials. Note: Shuttle can not be purchased after 30 minutes."
	admin_notes = "No brig and no medical facilities. Build YOUR own."
	credit_cost = 5000

/datum/map_template/shuttle/emergency/construction/small
	suffix = "construction_small"
	name = "Build Your Own Shuttle, Jr."
	description = "The full-size BYOS too big for your taste? Aside from the reduced size and cost, this has the all same (lack of) amenities as its full-sized sibling. Note: Shuttle can not be purchased after 30 minutes."
	admin_notes = "No brig and no medical facilities. Build YOUR own."
	credit_cost = 2000

/datum/map_template/shuttle/emergency/construction/prerequisites_met()
	// first 10 minutes only
	return world.time - SSticker.round_start_time < 30 MINUTES

/datum/map_template/shuttle/emergency/construction/post_load()
	. = ..()
	//enable buying engines from cargo
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shuttle_engine]
	P.special_enabled = TRUE


/datum/map_template/shuttle/emergency/transtar
	suffix = "transtar"
	name = "Transtar 800-C"
	description = "A brand-new passenger transit vessel featuring a Centcom exclusion aftermarket kit for securely holding prisoners en-route to Centcom. Features First Class and business, in-flight beverages and snacks, and video screens for entertainment during the voyage!"
	credit_cost = 3000

/datum/map_template/shuttle/emergency/asteroid
	suffix = "asteroid"
	name = "Asteroid Station Emergency Shuttle"
	description = "A respectable mid-sized shuttle that first saw service shuttling Nanotrasen crew to and from their asteroid belt embedded facilities."
	credit_cost = 3000

/datum/map_template/shuttle/emergency/bar
	suffix = "bar"
	name = "The Emergency Escape Bar"
	description = "Features include sentient bar staff (a Bardrone and a Barmaid), bathroom, a quality lounge for the heads, and a large gathering table."
	admin_notes = "Bardrone and Barmaid are GODMODE, will be automatically sentienced by the fun balloon at 60 seconds before arrival. \
	Has medical facilities."
	credit_cost = 5000

/datum/map_template/shuttle/emergency/cozy
	suffix = "cozy"
	name = "The Cozy Shuttle"
	description = "A shuttle that throws out integrity for style, it's all wooden frame contains three fireplaces - numerous lounge areas without sacrificing medical facilities or prisoner lodging."
	credit_cost = 5000

/datum/map_template/shuttle/emergency/triage
	suffix = "triage"
	name = "Emergency Triage Shuttle"
	description = "Do you have plenty of crew who need to be wheeled or dragged to safety? This shuttle is equipped with ample medical equipment to help your medical staff recover as many people as possible."
	credit_cost = 5000 // Yes this is pretty cheap for all the shuttle offers, but considering it's to be used in an extreme medical emergency, it cannot be too expensive.

/datum/map_template/shuttle/emergency/pod
	suffix = "pod"
	name = "Emergency Pods"
	description = "We did not expect an evacuation this quickly. All we have available is two escape pods."
	admin_notes = "For player punishment."

/datum/map_template/shuttle/emergency/pool
	suffix = "pool"
	name = "Pool Party!"
	description = "A modified version of the Box escape shuttle that comes with a preinstalled pool. Fun for the whole family!"
	admin_notes = "Pool filter can be very easily filled with acid or other harmful chemicals."
	credit_cost = 15000

/datum/map_template/shuttle/emergency/russiafightpit
	suffix = "russiafightpit"
	name = "Mother Russia Bleeds"
	description = "Dis is a high-quality shuttle, da. Many seats, lots of space, all equipment! Even includes entertainment! Such as lots to drink, and a fighting arena for drunk crew to have fun! If arena not fun enough, simply press button of releasing bears. Do not worry, bears trained not to break out of fighting pit, so totally safe so long as nobody stupid or drunk enough to leave door open. Try not to let asimov babycons ruin fun!"
	admin_notes = "Includes a small variety of weapons. And bears. Only captain-access can release the bears. Bears won't smash the windows themselves, but they can escape if someone lets them."
	credit_cost = 5000 // While the shuttle is rusted and poorly maintained, trained bears are costly.
	emag_only = TRUE

/datum/map_template/shuttle/emergency/meteor
	suffix = "meteor"
	name = "Asteroid With Engines Strapped To It"
	description = "A hollowed out asteroid with engines strapped to it, the hollowing procedure makes it very difficult to hijack but is very expensive. Due to its size and difficulty in steering it, this shuttle may damage the docking area."
	admin_notes = "This shuttle will likely crush escape, killing anyone there."
	credit_cost = 15000
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)
	emag_only = TRUE

/datum/map_template/shuttle/emergency/luxury
	suffix = "luxury"
	name = "Luxury Shuttle"
	description = "A luxurious golden shuttle complete with an indoor swimming pool. Each crewmember wishing to board must bring 500 credits, payable in cash and mineral coin."
	extra_desc = "This shuttle costs 500 credits to board."
	admin_notes = "Due to the limited space for non paying crew, this shuttle may cause a riot."
	credit_cost = 125000

/datum/map_template/shuttle/emergency/discoinferno
	suffix = "discoinferno"
	name = "Disco Inferno"
	description = "The glorious results of centuries of plasma research done by Nanotrasen employees. This is the reason why you are here. Get on and dance like you're on fire, burn baby burn!"
	admin_notes = "Flaming hot. The main area has a dance machine as well as plasma floor tiles that will be ignited by players every single time."
	credit_cost = 10000
	emag_only = TRUE

/datum/map_template/shuttle/emergency/arena
	suffix = "arena"
	name = "The Arena"
	description = "The crew must pass through an otherworldly arena to board this shuttle. Expect massive casualties. The source of the Bloody Signal must be tracked down and eliminated to unlock this shuttle."
	admin_notes = "RIP AND TEAR."
	credit_cost = 10000
	emag_only = TRUE

/datum/map_template/shuttle/emergency/arena/prerequisites_met()
	return GLOB.bubblegum_dead

/datum/map_template/shuttle/emergency/birdboat
	suffix = "birdboat"
	name = "Birdboat Station Emergency Shuttle"
	description = "Though a little on the small side, this shuttle is feature complete, which is more than can be said for the pattern of station it was commissioned for."
	credit_cost = 1000

/datum/map_template/shuttle/emergency/box
	suffix = "box"
	name = "Box Station Emergency Shuttle"
	credit_cost = 2000
	description = "The gold standard in emergency exfiltration, this tried and true design is equipped with everything the crew needs for a safe flight home."

/datum/map_template/shuttle/emergency/donut
	suffix = "donut"
	name = "Donutstation Emergency Shuttle"
	description = "The perfect spearhead for any crude joke involving the station's shape, this shuttle supports a separate containment cell for prisoners and a compact medical wing."
	admin_notes = "Has airlocks on both sides of the shuttle and will probably intersect near the front on some stations that build past departures."
	credit_cost = 2500

/datum/map_template/shuttle/emergency/clown
	suffix = "clown"
	name = "Snappop(tm)!"
	description = "Hey kids and grownups! \
	Are you bored of DULL and TEDIOUS shuttle journeys after you're evacuating for probably BORING reasons. Well then order the Snappop(tm) today! \
	We've got fun activities for everyone and an all access cockpit! Play dress up with your friends! Collect all the bedsheets before your neighbour does! \
	Check if the AI is watching you with our patent pending \"Peeping Tom AI Multitool Detector\" or PEEEEEETUR for short. Have a fun ride!"
	admin_notes = "Brig contains a single chair surrounded by fake lavaland chasms. Main seating is replaced with beds."
	credit_cost = 8000

/datum/map_template/shuttle/emergency/cramped
	suffix = "cramped"
	name = "Secure Transport Vessel 5 (STV5)"
	description = "Well, looks like CentCom only had this ship in the area, they probably weren't expecting you to need evac for a while. \
	Probably best if you don't rifle around in whatever equipment they were transporting. I hope you're friendly with your coworkers, because there is very little space in this thing.\n\
	\n\
	Contains contraband armory guns, maintenance loot, and abandoned crates!"
	admin_notes = "Due to origin as a solo piloted secure vessel, has an active GPS onboard labeled STV5. Has roughly as much space as Hi Daniel, except with explosive crates."

/datum/map_template/shuttle/emergency/meta
	suffix = "meta"
	name = "Meta Station Emergency Shuttle"
	credit_cost = 4000
	description = "A fairly standard shuttle, though larger and slightly better equipped than the Box Station variant."

/datum/map_template/shuttle/emergency/mini
	suffix = "mini"
	name = "Ministation emergency shuttle"
	credit_cost = 1000
	description = "Despite its namesake, this shuttle is actually only slightly smaller than standard, and still complete with a brig and medbay."

/datum/map_template/shuttle/emergency/scrapheap
	suffix = "scrapheap"
	name = "Standby Evacuation Vessel \"Scrapheap Challenge\""
	credit_cost = -1000
	description = "Due to a lack of functional emergency shuttles, we bought this second hand from a scrapyard and pressed it into service. Please do not lean too heavily on the exterior windows, they are fragile."
	admin_notes = "An abomination with no functional medbay, sections missing, and some very fragile windows. Surprisingly airtight."
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)
	emag_only = TRUE

/datum/map_template/shuttle/emergency/narnar
	suffix = "narnar"
	name = "Shuttle 667"
	description = "Looks like this shuttle may have wandered into the darkness between the stars on route to the station. Let's not think too hard about where all the bodies came from."
	admin_notes = "Contains real cult ruins, mob eyeballs, and inactive constructs. Cult mobs will automatically be sentienced by fun balloon. \
	Cloning pods in 'medbay' area are showcases and nonfunctional."

/datum/map_template/shuttle/emergency/pubby
	suffix = "pubby"
	name = "Pubby Station Emergency Shuttle"
	description = "A train but in space! Complete with a first, second class, brig and storage area."
	admin_notes = "Choo choo motherfucker!"
	credit_cost = 1000

/datum/map_template/shuttle/emergency/cere
	suffix = "cere"
	name = "Cere Station Emergency Shuttle"
	description = "The large, beefed-up version of the box-standard shuttle. Includes an expanded brig, fully stocked medbay, enhanced cargo storage with mech chargers, \
	an engine room stocked with various supplies, and a crew capacity of 80+ to top it all off. Live large, live Cere."
	admin_notes = "Seriously big, even larger than the Delta shuttle."
	credit_cost = 10000

/datum/map_template/shuttle/emergency/octa
	suffix = "octa"
	name = "Octa Prototype Emergency Shuttle"
	description = "Nanotrasen's experimental shuttle utilizing a unique shape to manipulate reality for a percieved larger shuttle in a smaller package. \
		While experimental, it offers great views of outside and decently stocked emergency and medical supplies."
	admin_notes = "Doughnut yummy."
	credit_cost = 9500 //experimental = expensive

/datum/map_template/shuttle/emergency/cargo
	suffix = "cargo"
	name = "O.C.K. Emergency Shuttle"
	description = "The Overnight Cargo-transport K-Class is an OSHA compliant shuttle complete with rails and warning lines to protect her crew from the cargo they are transporting. \
		Seats and a brig space have been retrofitted to help on its current mission of saving you from the station. \
		The higher ups complain this shuttle is very \"\ meta\"\ and \"\ increases greytide levels\"\ whatever that means."
	admin_notes = "Has a chance to have (traitor) maint loot, you can always delete it when its at CC"
	credit_cost = 7000

/datum/map_template/shuttle/emergency/foureightsixfourone
	suffix = "48641"
	name = "Crowd-Sourced Emergency Shuttle"
	description = "The Crowd-Sourced Emergency Shuttle is the product of a Centcom initiative to have crews design their own emergency shuttles. \
		Due to its strange construction, this shuttle offers some amenities not available on other shuttles. \
		The most notable additions are: An electrified arena, A fully functional cargo bay, and a club."
	admin_notes = "The emergency shuttled created during Round 48641. "
	credit_cost = 7000

/datum/map_template/shuttle/emergency/mafia
	suffix = "mafia"
	name = "Droni Fedora"
	description = "I'm gonna make you an offer you can't refuse, the drone mafia has offered their 'services' to shuttle the crew. \
		Just be careful, if you don't show class they might heckle you. Canoli not incuded."
	admin_notes = "has 5 mafia drones that are pacified. By drone law they should only stun people if provoked. Has a pair of sentient barstaff also."
	emag_only = TRUE
	credit_cost = 100000//service fee

/datum/map_template/shuttle/emergency/supermatter
	suffix = "supermatter"
	name = "Hyperfractal Gigashuttle"
	description = "\"I dunno, this seems kinda needlessly complicated.\"\n\
	\"This shuttle has very a very high safety record, according to CentCom Officer Cadet Yins.\"\n\
	\"Are you sure?\"\n\
	\"Yes, it has a safety record of N-A-N, which is apparently larger than 100%.\""
	admin_notes = "Supermatter that spawns on shuttle is special anchored 'hugbox' supermatter that cannot take damage and does not take in or emit gas. \
	Outside of admin intervention, it cannot explode. \
	It does, however, still dust anything on contact, emits high levels of radiation, and induce hallucinations in anyone looking at it without protective goggles. \
	Emitters spawn powered on, expect admin notices, they are harmless."
	credit_cost = 100000
	emag_only = TRUE
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)

/datum/map_template/shuttle/emergency/imfedupwiththisworld
	suffix = "imfedupwiththisworld"
	name = "Oh, Hi Daniel"
	description = "How was space work today? Oh, pretty good. We got a new space station and the company will make a lot of money. What space station? I cannot tell you; it's space confidential. \
	Aw, come space on. Why not? No, I can't. Anyway, how is your space roleplay life?"
	admin_notes = "Tiny, with a single airlock and wooden walls. What could go wrong?"
	credit_cost = 7500
	emag_only = TRUE
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)

/datum/map_template/shuttle/emergency/goon
	suffix = "goon"
	name = "NES Port"
	description = "The Nanotrasen Emergency Shuttle Port(NES Port for short) is a shuttle used at other less known Nanotrasen facilities and has a more open inside for larger crowds, but fewer onboard shuttle facilities."
	credit_cost = 500

/datum/map_template/shuttle/emergency/kilo
	suffix = "kilo"
	name = "Kilo Station Emergency Shuttle"
	credit_cost = 5000
	description = "A fully functional shuttle including a complete infirmary, storage facilities, and regular amenities."

/datum/map_template/shuttle/emergency/rollerdome
	suffix = "rollerdome"
	name = "Uncle Pete's Rollerdome"
	description = "Created by a freak accident in which a member of the NT Temporal Discovery Division accidentally warped a building from the past into our second Disco Inferno shuttle. \
	It resembles a 1990s era rollerdome all the way down to the carpet texture."
	admin_notes = "ONLY NINETIES KIDS REMEMBER. Uses the fun balloon and drone from the Emergency Bar."
	credit_cost = 2500

/datum/map_template/shuttle/emergency/wabbajack
	suffix = "wabbajack"
	name = "NT Lepton Violet"
	description = "The research team based on this vessel went missing one day, and no amount of investigation could discover what happened to them. \
	The only occupants were a number of dead rodents, who appeared to have clawed each other to death. \
	Needless to say, no engineering team wanted to go near the thing, and it's only being used as an Emergency Escape Shuttle because there is literally nothing else available."
	admin_notes = "If the crew can solve the puzzle, they will wake the wabbajack statue. It will likely not end well. There's a reason it's boarded up. Maybe they should have just left it alone."
	credit_cost = 15000
	emag_only = TRUE

/datum/map_template/shuttle/emergency/omega
	suffix = "omega"
	name = "Omegastation Emergency Shuttle"
	description = "On the smaller size with a modern design, this shuttle is for the crew who like the cosier things, while still being able to stretch their legs."
	credit_cost = 1000

/datum/map_template/shuttle/emergency/delta
	suffix = "delta"
	name = "Delta Station Emergency Shuttle"
	description = "A large shuttle for a large station, this shuttle can comfortably fit all your overpopulation and crowding needs. Complete with all facilities plus additional equipment."
	admin_notes = "Go big or go home."
	credit_cost = 7500

/datum/map_template/shuttle/emergency/raven
	suffix = "raven"
	name = "CentCom Raven Cruiser"
	description = "The CentCom Raven Cruiser is a former high-risk salvage vessel, now repurposed into an emergency escape shuttle. \
	Once first to the scene to pick through warzones for valuable remains, it now serves as an excellent escape option for stations under heavy fire from outside forces. \
	This escape shuttle boasts shields and numerous anti-personnel turrets guarding its perimeter to fend off meteors and enemy boarding attempts."
	admin_notes = "Comes with turrets that will target anything without the neutral faction (nuke ops, xenos etc, but not pets)."
	credit_cost = 30000

