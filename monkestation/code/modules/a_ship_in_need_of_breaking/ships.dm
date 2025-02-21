/datum/map_template/shipbreaker
	should_place_on_top = TRUE
	returns_created_atoms = TRUE
	keep_cached_map = TRUE

	var/emag_only = 0
	var/template_id
	var/description
	var/datum/parsed_map/lastparsed
	var/tied_faction = DONK_CO_NAME

/datum/map_template/shipbreaker/black_peregrine
	name = "Black Peregrine"
	template_id = "black_peregrine"
	description = "Syndicate's brightest naval minds began beliving that a decisive battle doctrine wouldn't be enough, that's why they've went with an experiment for the wolfpack doctrine through smallcrafts such as the black peregrine"
	mappath = "_maps/~monkestation/shipbreaking/black_peregrine.dmm"

/datum/map_template/shipbreaker/gasstation
	name="Gas Station Shuttle"
	template_id="gasstation"
	description="Getcher gas here, pardner."
	mappath="_maps/~monkestation/shipbreaking/gasstation.dmm"

/datum/map_template/shipbreaker/goonshuttlesmall
	name = "G00N-S Class Light Executive Shuttle"
	template_id = "goonshuttlesmall"
	description = "The G00N-S Class Light Executive shuttle. The G00N-S is for the executive who is conscious of his shareholder's wallets. Luxury on a budget. Featuring comfortable plush seating, a sick bay, and a security suite. Ride with style...on a budget."
	mappath = "_maps/~monkestation/shipbreaking/goonshuttlesmall.dmm"

/*
/datum/map_template/shipbreaker/marauders_vanguard
	name = "Gorlex Marauder Cruiser"
	template_id = "gorlex_cruiser"
	description = "One of the Gorlex Marauders' heavy cruisers, used during early conflicts between the group and Nanotrasen. The design has aged quite a bit, and they now serve as backline vessels for outpost maintenance and field support in emergencies, with much more comfortable quarters than they had during their frontline service. Many of these vessels went missing during a food shortage among the Cybersun logistics fleet, presumably due to starvation of crew."
	mappath = "_maps/~monkestation/shipbreaking/gorlex_cruiser.dmm"
	emag_only = 1
*/

/datum/map_template/shipbreaker/mcsail
	name = "McSteal Solar Sail"
	template_id = "mcsail"
	description = "A emergency vehicle able to be rigged up within 15 minutes. Able to make an (albeit slow), getaway from dangerous locations. Will propel itself untill just 200W!"
	mappath = "_maps/~monkestation/shipbreaking/mcsail.dmm"

/datum/map_template/shipbreaker/mcsloop
	name = "McSteal Sloop"
	template_id = "McSloop"
	description = "Little more then a expanded escape pod. Contains enough to survive and thrive on dangerous enviroments."
	mappath = "_maps/~monkestation/shipbreaking/mcsteal_sloop.dmm"

/*
/datum/map_template/shipbreaker/mess
	name = "The Mess Discount Shuttle"
	template_id = "mess"
	description = "Introducing the newest in discount Shuttles, The Mess! Why build your own space worthy shuttle when you can scrap- err ahem,\
	Recycle eight other shuttles and/or prefab buildings and/or unknowable horrors of the void? \
	And what better way than to traverse the cosmos than in one of these unique shuttles? \
	As each Mess shuttle is made from recycled materials, final product may differ from advertisement materials."
	mappath = "_maps/~monkestation/shipbreaking/mess.dmm
	emag_only = 1
*/

/datum/map_template/shipbreaker/mule
	name = "Mule Freighter"
	template_id = "mule"
	description = "Listen, I've got a plan, get everything aboard the ship, we'll sell that to some greasy jacket wearing monkey."
	mappath = "_maps/~monkestation/shipbreaking/mule.dmm"

/datum/map_template/shipbreaker/old_altar
	name = "Old Ashwalker Altar Ship"
	template_id = "old_altar"
	description = "mapshaker_old_altar"
	mappath = "_maps/~monkestation/shipbreaking/old_altar.dmm"

/datum/map_template/shipbreaker/old_banana
	name = "Old Honk Ship"
	template_id = "old_banana"
	description = "mapshaker_old_banana"
	mappath = "_maps/~monkestation/shipbreaking/old_banana.dmm"

/datum/map_template/shipbreaker/old_bathroom
	name = "Old Bathroom Ship"
	template_id = "old_Bathroom"
	description = "mapshaker_old_bathroom"
	mappath = "_maps/~monkestation/shipbreaking/old_bathroom.dmm"

/datum/map_template/shipbreaker/old_chapel
	name = "Old Chapel Ship"
	template_id = "old_chapel"
	description = "mapshaker_old_chapel"
	mappath = "_maps/~monkestation/shipbreaking/old_chapel.dmm"

/datum/map_template/shipbreaker/old_diner
	name = "Old diner Ship"
	template_id = "old_diner"
	description = "mapshaker_old_diner"
	mappath = "_maps/~monkestation/shipbreaking/old_diner.dmm"

/datum/map_template/shipbreaker/escape_pod_old
	name = "Old Escape Pods"
	template_id = "old_Escape_Pods"
	description = "mapshaker_old_escape_pods"
	mappath = "_maps/~monkestation/shipbreaking/old_escape_pod.dmm"

/datum/map_template/shipbreaker/repair_old
	name = "Old Repair Ship"
	template_id = "old_repair"
	description = "mapshaker_old_repair"
	mappath = "_maps/~monkestation/shipbreaking/old_repair.dmm"

/datum/map_template/shipbreaker/robotics
	name = "Old Robotics Cruiser"
	template_id = "robotics"
	description = "robotics"
	mappath = "_maps/~monkestation/shipbreaking/robotics.dmm"

/datum/map_template/shipbreaker/squid
	name = "Voidsquid Research Shuttle"
	template_id = "squid"
	description = "The Voidsquid Research shuttle is designed as an independent research platform, needing little to no support from a larger station for the duration of its experiments. Comfortably fitting six researchers, they are able to get their research done without external interruptions, as well as gather new samples as applicable. Two robust holding cells for live specimens, as well as redundant air-and power-supply in each of the rear nacelles, makes for a sturdy vessel."
	mappath = "_maps/~monkestation/shipbreaking/squid.dmm"

/datum/map_template/shipbreaker/torus
	name = "Exotic Gas Transport"
	template_id = "torus"
	description = "An exotic gas shipping shuttle, drifting around aimlessly..."
	mappath = "_maps/~monkestation/shipbreaking/torus.dmm"

/datum/map_template/shipbreaker/true_church
	name = "The True Church"
	template_id = "true_church"
	description = "This ship was constructed to spread the *truth* that the radical faction called The Second Advent wish to spread. This ship in specific was emptied of its occupants after a local patrol discovered it harbored multiple bioforms not permitted in Nanotrasen space. After seeing what it contained offering it to ship breakers is the only logical conclusion."
	mappath = "_maps/~monkestation/shipbreaking/true_church.dmm"

/datum/map_template/shipbreaker/wanglius
	name = "Wanglius Class Salvage Tug"
	template_id = "wanglius"
	description = "A product from DONGCORP, the Wanglius Class Salvage Tug is the tip of the spear when it comes to salvage vessels. Featuring a girthy crew quarters section, multiple engines for maximum thrust, engineering bay, sick bay, and a large and spacious cargo bay with a front access for releasing a load of hard working spacers on that pristine wreck. Guaranteed to satisfy."
	mappath = "_maps/~monkestation/shipbreaking/wanglius.dmm"

/*
/datum/map_template/shipbreaker/whale
	name = "Whale"
	template_id = "whale"
	description = "Whale-type description"
	mappath = "_maps/~monkestation/shipbreaking/whale.dmm"
*/
