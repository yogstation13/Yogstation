/datum/map_template/ruin/jungle
	prefix = "_maps/RandomRuins/JungleRuins/"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/jungle/all
	should_place_on_top = FALSE

/datum/map_template/ruin/jungle/dying/crashed_ship
	name = "Crashed Ship"
	id = "jungle-crashed-ship"
	description = "The remains of a long crashed ship, weathered away into scrap."
	suffix = "jungleland_dead_crashedship.dmm"	

/datum/map_template/ruin/jungle/dying/testing_facility
	name = "Testing-facility"
	id = "jungle-testing-facility"
	description = "A testing facility, were bodily experiments were conducted on people, safely remote from scrutiny."
	suffix = "jungleland_dead_testingfacility.dmm"

/datum/map_template/ruin/jungle/all/ivymen_nest
	name = "Ivymen Nest"
	id = "jungle-ivymen-next"
	description = "A dormant nest filled with primal plant creatures, waiting to hatch."
	suffix = "jungleland_jungle_ivymen_nest.dmm"

/datum/map_template/ruin/jungle/proper/old_temple
	name = "Ancient Temple"
	id = "jungle-old-temple"
	description = "A temple bearing signs of the occult. It seems the spirits inside have been corrupted..."
	suffix = "jungleland_jungle_oldtemple.dmm"	

/datum/map_template/ruin/jungle/proper/xenos
	name = "Xeno Nest"
	id = "jungle-xenos"
	description = "Once an expeditionary camp for soldiers, it fell to predatory alien creatures."
	suffix = "jungleland_jungle_xenos.dmm"	

/datum/map_template/ruin/jungle/proper/geode
	name = "Geode"
	id = "jungle-geode"
	description = "Geode"
	suffix = "jungleland_jungle_geode.dmm"	

/datum/map_template/ruin/jungle/proper/felinid
	name = "Felinid Party"
	id = "jungle-felinid"
	description = "Felinid party"
	suffix = "jungleland_jungle_felinid.dmm"	

/datum/map_template/ruin/jungle/proper/garden
	name = "Old Garden"
	id = "jungle-garden"
	description = "A very old garden, still kept in peak condition by a dryad. A quaint place for a traveller to fish and rest."
	suffix = "jungleland_jungle_garden.dmm"		

/datum/map_template/ruin/jungle/proper/seedvault
	name = "Seed Vault"
	id = "jungle-seedvault"
	description = "A seedvault launched from far away. Thousands of exact copies litter planets across the entire universe, so finding one here isn't too much of a surprise."
	suffix = "jungleland_jungle_seed_vault.dmm"	

/datum/map_template/ruin/jungle/proper/sinden
	name = "Den of Sin"
	id = "jungle-sinden"
	description = "A vile den of sin, run by a demon contracted to make as much profit as possible off everyone planetside."
	suffix = "jungleland_jungle_sinden.dmm"	

/datum/map_template/ruin/jungle/swamp/cave
	name = "Cave"
	id = "jungle-cave"
	description = "A mass of rock hiding a small cave system, home to a den of basilisks. If you're willing to brave them, you might get something worthwhile."
	suffix = "jungleland_swamp_cave.dmm"

/datum/map_template/ruin/jungle/swamp/burial_grounds
	name = "Drowned Burial Grounds"
	id = "jungle-burial-grounds"
	description = "Flooded burial grounds, filled with toxic water and the reanimated dead of those buried inside."
	suffix = "jungleland_swamp_drownedburialgrounds.dmm"	

/datum/map_template/ruin/jungle/swamp/farm 
	name = "Abandoned Farm"
	id = "jungle-farm"
	description = "A large field of rotting, tilled soil next to a small home."
	suffix = "jungleland_swamp_farm.dmm"	

/datum/map_template/ruin/jungle/swamp/hut
	name = "Old Hut"
	id = "jungle-hut"
	description = "An old hut that belonged to a witch."
	suffix = "jungleland_swamp_oldhut.dmm"	

/datum/map_template/ruin/jungle/swamp/carp_pond
	name = "Carp Pond"
	id = "jungle-carp-pond"
	description = "A few ponds full of rancid and toxic water, guarded by overgrown carp. \
	 	However, it looks like it could've been pretty, at least in the past..."
	suffix = "jungleland_swamp_carp_pond.dmm"	

/* disables this till marmio fixes it */
/datum/map_template/ruin/jungle/all/syndicate_base //has to be all biomes cause its so big it wont spawn otherwise
	name = "Syndicate Base"
	id = "jungle-syndicate-base"
	description = "A large permanent research and comms station run by the syndicate."
	suffix = "jungleland_swamp_syndicatestation.dmm"	

/datum/map_template/ruin/jungle/all/miningbase //THIS IS THE MINING BASE. DO NOT FUCK WITH THIS UNLESS YOU ARE 100% CERTAIN YOU KNOW WHAT YOU'RE DOING, OR THE MINING BASE WILL DISAPPEAR
	name = "Mining Base"
	id = "miningbase"
	description = "The mining base that Nanotrasen uses for their mining operations."
	suffix = "miningbase.dmm"
	always_place = TRUE
	unpickable = TRUE
	cost = 0

//TAR TEMPLES
/datum/map_template/ruin/jungle/all/tar_temple0
	name = "Tar Temple 0"
	id = "tar_temple"
	description = "Old ruin of a civilization long gone, only echoes of the past remain..."
	suffix = "tar_temple0.dmm"
	always_place = TRUE
	cost = 0

/datum/map_template/ruin/jungle/all/tar_king_phylactery
	name = "Tar King's Phylactery"
	id = "jungle-tar-king"
	description = "In this place lies the core of this world's cancer. \
		Resting deep within the obsidian, sealed under an altar untouched by time, it awaits the day it will finally take form."
	suffix = "jungleland_tar_king.dmm"
	always_place = TRUE
	cost = 0

/datum/map_template/ruin/jungle/all/tar_temple2
	name = "Tar temple 2"
	id = "jungle-swamp-tar-temple"
	description = "Old ruin of a civilization long gone, only echoes of the past remain..."
	suffix = "jungleland_swamp_tartemple.dmm"	
	always_place = TRUE
	cost = 0

/datum/map_template/ruin/jungle/all/tar_temple3
	name = "Tar temple 3"
	id = "jungle-proper-tar-temple"
	description = "Old ruin of a civilization long gone, only echoes of the past remain..."
	suffix = "jungleland_jungle_tartemple.dmm"	
	always_place = TRUE
	cost = 0

/datum/map_template/ruin/jungle/all/tar_assistant
	name = "Tar Assistant"
	id = "jungle-proper-tar-assistant"
	description = "Old ruin of a civilization long gone, only echoes of the past remain..."
	suffix = "tar_assistant.dmm"	
	cost = 5


/datum/map_template/ruin/jungle/all/tar_enchant
	name = "Tar Enchant"
	id = "jungle-proper-tar-enchant"
	description = "Old ruin of a civilization long gone, only echoes of the past remain..."
	suffix = "tar_enchant.dmm"	
	cost = 5


//MEGAFAUNA
/datum/map_template/ruin/jungle/swamp/miner
	name = "Blood Drunk Miner"
	id = "swamp_miner"
	description = "Miner's hideout"
	suffix = "jungleland_swamp_miner.dmm"	
	always_place = TRUE

/datum/map_template/ruin/jungle/dying/colossus
	name = "Colossus"
	id = "dying_colossus"
	description = "Colossus"
	suffix = "jungleland_dead_colossus.dmm"
	always_place = TRUE

/datum/map_template/ruin/jungle/dying/bubblegum
	name = "Bubblegum"
	id = "dying_bubblegum"
	description = "Bubblegum"
	suffix = "jungleland_dead_bubblegum.dmm"
	always_place = TRUE

/datum/map_template/ruin/jungle/barren/drake
	name = "Ash Drake"
	id = "barren_drake"
	description = "Ash Drake"
	suffix = "jungleland_barren_drake.dmm"
	always_place = TRUE
	allow_duplicates = TRUE
	cost = 20

//NESTS
/datum/map_template/ruin/jungle/dying/dead_nest
	name = "Dying Forest Nest"
	id = "jungle-dying-nest"
	description = "a nest"
	suffix = "jungleland_dead_nest.dmm"	
	allow_duplicates = TRUE
	always_place = TRUE
	cost = 2

/datum/map_template/ruin/jungle/proper/jungle_nest
	name = "Jungle Nest"
	id = "jungle-proper-nest"
	description = "a nest"
	suffix = "jungleland_jungle_nest.dmm"	
	allow_duplicates = TRUE 
	always_place = TRUE
	cost = 2
	
/datum/map_template/ruin/jungle/swamp/swamp_nest
	name = "Swamp Nest"
	id = "jungle-swamp-nest"
	description = "a nest"
	suffix = "jungleland_swamp_nest.dmm"	
	allow_duplicates = TRUE 
	always_place = TRUE
	cost = 2

/datum/map_template/ruin/jungle/barren/barren_nest
	name = "Barren Nest"
	id = "jungle-barren-nest"
	description = "a nest"
	suffix = "jungleland_barren_nest.dmm"	
	allow_duplicates = TRUE 
	always_place = TRUE

// OBSIDIAN PILLARS 

/datum/map_template/ruin/jungle/dying/obsidian_pillar0
	name = "Obsidian pillar"
	id = "jungle-dying-obsidian-pillar0"
	description = "obsidian pillar"
	suffix = "obsidian_pillar0.dmm"	
	cost = 1

/datum/map_template/ruin/jungle/dying/obsidian_pillar1
	name = "Obsidian pillar"
	id = "jungle-dying-obsidian-pillar1"
	description = "obsidian pillar"
	suffix = "obsidian_pillar1.dmm"	
	cost = 1

/datum/map_template/ruin/jungle/dying/obsidian_pillar2
	name = "Obsidian pillar"
	id = "jungle-dying-obsidian-pillar2"
	description = "obsidian pillar"
	suffix = "obsidian_pillar2.dmm"	
	cost = 1

/datum/map_template/ruin/jungle/dying/obsidian_pillar3
	name = "Obsidian pillar"
	id = "jungle-dying-obsidian-pillar3"
	description = "obsidian pillar"
	suffix = "obsidian_pillar3.dmm"	
	cost = 1

