/**
*
*This file contains any "special" / unique donator items which are ckey locked.
*
*To create a new unique donator item, create a new datum/donator_item
*
*@version 1.0
*@author Kmc2000
*
*/

GLOBAL_DATUM_INIT(donator_gear, /datum/donator_gear_resources, new)

/datum/donator_gear_resources
	var/name = "Unique Donator Items Controller"
	var/list/donor_items = list()
	var/list/item_names = list()
	var/list/donor_plush = list()

/datum/donator_gear_resources/New()
	. = ..()
	for(var/Stype in subtypesof(/datum/donator_gear))
		var/datum/donator_gear/S = new Stype
		if(!S.unlock_path)
			message_admins("WARNING: [S] has no unlock path, clearing it out.")
			qdel(S)
			continue
		donor_items += S
		item_names[S.name] = S

	for(var/Ptype in subtypesof(/obj/item/toy/plush))
		var/obj/item/toy/plush/P = new Ptype
		donor_plush += P
		item_names[P.name] = P

/datum/donator_gear
	/// Name of the gear, as displayed in the preferences menu
	var/name = "Base type donator item"
	/// A valid ckey belonging to a player with donator status.
	var/ckey = null
	/// A valid type path pointing to the item(s) that this unlocks. If handed a list, it'll give them anything in the list.
	var/unlock_path = null
	/// Is this a hat? For categorisation in the UI.
	var/slot = null
	var/plush = FALSE

/*
Helper proc for lazy coders. Autogenerates donator gear datums based off of a list of types that you give it. May not work perfectly every time, but it sure beats typing things out.

Uncomment this and use atomproccall as necessary, then copypaste the output into DM (I recommend regexping the output to scrub any spaces it may insert instead of tabs...)

/atom/proc/generate_donator_gear(list/L)
	for(var/X in L)
		var/atom/movable/Y = new X()
		to_chat(world, "/datum/donator_gear/[lowertext(Y.icon_state)]")
		to_chat(world, "		name = \"[Y.name]\"")
		to_chat(world, "		unlock_path = [X]")
		to_chat(world, "")
		qdel(Y)
*/


///Ckey locked (special) items. These should come last to separate them out from the rest of the items for whoever's priviledged enough to own one. (Feel free to contact me, Kmc, if you want one made by the way)

/datum/donator_gear/orca
	name = "Megumus Dress (orcacora)"
	ckey = "orcacora"
	unlock_path = /obj/item/storage/box/megumu

/datum/donator_gear/fatal_eyes
	name = "Green Cosmic Bedsheet (FatalEyes)"
	ckey = "fataleyes"
	unlock_path = /obj/item/bedsheet/cosmos/fatal_eyes

/obj/item/bedsheet/cosmos/fatal_eyes
	name = "green cosmic bedsheet"
	icon_state = "sheetcosmos_green"
	item_state = "sheetcosmos_green"

/datum/donator_gear/mqiib
	name = "Singularity Necklace (Mqiib)"
	ckey = "Mqiib"
	unlock_path = /obj/item/clothing/accessory/sing_necklace

/datum/donator_gear/cowbot
	name = "Singularity Wakizashi (Cowbot93)"
	ckey = "Cowbot93"
	unlock_path = /obj/item/toy/katana/singulo_wakizashi

/datum/donator_gear/marmio64
	name = "Eldritch Cowl (Marmio64)"
	ckey = "Marmio64"
	unlock_path = /obj/item/clothing/suit/hooded/eldritchcowl

/datum/donator_gear/manatee
	name = "Peacekeeper Beret & Dogtags (Majesticmanateee)"
	ckey = "Majesticmanateee"
	unlock_path = /obj/item/storage/box/manatee

/datum/donator_gear/Hisakaki
	name = "Transdimensional halo (Hisakaki)"
	ckey = "Hisakaki"
	unlock_path = /obj/item/clothing/head/halo
	slot = SLOT_HEAD

/datum/donator_gear/skrem
	name = "Rainbow flower (Skrem7)"
	ckey = "Skrem7"
	unlock_path = /obj/item/clothing/head/rainbow_flower

/datum/donator_gear/alvcyktor
	name = "Shark Hoodie (alvcyktor)"
	ckey = "alvcyktor"
	unlock_path = /obj/item/clothing/accessory/sharkhoodie

/datum/donator_gear/isotope
	name = "Dark Scientist Jumpsuit and Badass Lighter (Nightmare1243)"
	ckey = "Nightmare1243"
	unlock_path = /obj/item/storage/box/isotope

/datum/donator_gear/cuackles
	name = "punk jacket (cuackles)"
	ckey = "cuackles"
	unlock_path = /obj/item/clothing/suit/yogs/cyberpunk

/datum/donator_gear/hisa
	name = "Hunter Stash (hisakaki)"
	ckey = "hisakaki"
	unlock_path = /obj/item/storage/box/hisa

/datum/donator_gear/slicerv
	name = "axolotl plush"
	ckey = "slicerv"
	unlock_path = /obj/item/toy/plush/axolotlplushie

/datum/donator_gear/cark
	name = "Pride Bedsheet"
	ckey = "cark"
	unlock_path = /obj/item/bedsheets/pridebedsheet/cark

	///Generic donator hats, ckey agnostic.
/datum/donator_gear/dukeofsoleil
	name = "Druid hat"
	ckey = "dukeofsoleil"
	unlock_path = /obj/item/clothing/head/Floralwizhat


/datum/donator_gear/boxta
	name = "Gold Trimmed Fedora & Falcon"
	ckey = "boxta"
	unlock_path = /obj/item/storage/box/boxta

///Generic donator hats, ckey agnostic.
/datum/donator_gear/beanie
	name = "Beanie"
	unlock_path = /obj/item/clothing/head/yogs/beanie
	slot = SLOT_HEAD

/datum/donator_gear/bike
	name = "Biker Helmet"
	unlock_path = /obj/item/clothing/head/yogs/bike
	slot = SLOT_HEAD

/datum/donator_gear/clownhardsuithelm
	name = "Clown Hardsuit Helmet"
	unlock_path = /obj/item/clothing/head/yogs/hardsuit_helm_clown
	slot = SLOT_HEAD

/datum/donator_gear/cowboy
	name = "Cowboy hat"
	unlock_path = /obj/item/clothing/head/yogs/cowboy
	slot = SLOT_HEAD

/datum/donator_gear/crusader
	name = "Crusader hat"
	unlock_path = /obj/item/clothing/head/yogs/crusader
	slot = SLOT_HEAD

/datum/donator_gear/cowboy/sherrif
	name = "Sheriff hat"
	unlock_path = /obj/item/clothing/head/yogs/cowboy_sheriff
	slot = SLOT_HEAD

/datum/donator_gear/cowboy/dallas
	name = "Dallas hat"
	unlock_path = /obj/item/clothing/head/yogs/dallas
	slot = SLOT_HEAD

/datum/donator_gear/drinking_hat
	name = "Drinking hat"
	unlock_path = /obj/item/clothing/head/yogs/drinking_hat
	slot = SLOT_HEAD

/datum/donator_gear/microwave
	name = "Microwave hat"
	unlock_path = /obj/item/clothing/head/yogs/microwave
	slot = SLOT_HEAD

//This sprite still sucks 6 years on, but not as badly as the sith cloak. ~Kmc
/datum/donator_gear/sith_hood
	name = "Sith hood"
	unlock_path = /obj/item/clothing/head/yogs/sith_hood
	slot = SLOT_HEAD

/datum/donator_gear/turban
	name = "Turban"
	unlock_path = /obj/item/clothing/head/yogs/turban
	slot = SLOT_HEAD

/datum/donator_gear/petehat
	name = "Cuban Pete's Hat"
	unlock_path = /obj/item/clothing/head/collectable/petehat
	slot = SLOT_HEAD

/datum/donator_gear/slime
	name = "Slime Hat"
	unlock_path = /obj/item/clothing/head/collectable/slime
	slot = SLOT_HEAD

/datum/donator_gear/xeno
	name = "Xeno Hat"
	unlock_path = /obj/item/clothing/head/collectable/xenom
	slot = SLOT_HEAD

/datum/donator_gear/chef
	name = "Chef Hat"
	unlock_path = /obj/item/clothing/head/collectable/chef
	slot = SLOT_HEAD

/datum/donator_gear/paper
	name = "Paper Hat"
	unlock_path = /obj/item/clothing/head/collectable/paper
	slot = SLOT_HEAD

/datum/donator_gear/tophat
	name = "Top Hat"
	unlock_path = /obj/item/clothing/head/collectable/tophat
	slot = SLOT_HEAD

/datum/donator_gear/captainhat
	name = "Captain Hat (Collectable)"
	unlock_path = /obj/item/clothing/head/collectable/captain
	slot = SLOT_HEAD

/datum/donator_gear/police
	name = "Police Hat (Collectable)"
	unlock_path = /obj/item/clothing/head/collectable/police
	slot = SLOT_HEAD

/datum/donator_gear/welding
	name = "Welding Helmet (Collectable)"
	unlock_path = /obj/item/clothing/head/collectable/welding
	slot = SLOT_HEAD

/datum/donator_gear/flatcap
	name = "Flat Cap"
	unlock_path = /obj/item/clothing/head/collectable/flatcap
	slot = SLOT_HEAD

/datum/donator_gear/pirate
	name = "Pirate Hat"
	unlock_path = /obj/item/clothing/head/collectable/pirate
	slot = SLOT_HEAD

/datum/donator_gear/kitty
	name = "Kitty Ears"
	unlock_path = /obj/item/clothing/head/collectable/kitty
	slot = SLOT_HEAD

/datum/donator_gear/rabbitears
	name = "Rabbit Ears"
	unlock_path = /obj/item/clothing/head/collectable/rabbitears
	slot = SLOT_HEAD

/datum/donator_gear/wizard
	name = "Wizard Hat (Collectable)"
	unlock_path = /obj/item/clothing/head/collectable/wizard
	slot = SLOT_HEAD

/datum/donator_gear/hardhat
	name = "Hard Hat (Collectable)"
	unlock_path = /obj/item/clothing/head/collectable/hardhat
	slot = SLOT_HEAD

/datum/donator_gear/HoS
	name = "HoS Hat (Collectable)"
	unlock_path = /obj/item/clothing/head/collectable/HoS
	slot = SLOT_HEAD

/datum/donator_gear/thunderdome
	name = "Thunderdome Hat (Collectable)"
	unlock_path = /obj/item/clothing/head/collectable/thunderdome
	slot = SLOT_HEAD

/datum/donator_gear/swat
	name = "SWAT Hat (Collectable)"
	unlock_path = /obj/item/clothing/head/collectable/swat
	slot = SLOT_HEAD

/datum/donator_gear/ushanka
	name = "Ushanka"
	unlock_path = /obj/item/clothing/head/ushanka
	slot = SLOT_HEAD

/datum/donator_gear/pumpkinhead
	name = "Pumpkin Hat"
	unlock_path = /obj/item/clothing/head/hardhat/pumpkinhead
	slot = SLOT_HEAD

/datum/donator_gear/powdered_wig
	name = "Powdered Wig"
	unlock_path = /obj/item/clothing/head/powdered_wig
	slot = SLOT_HEAD

/datum/donator_gear/that
	name = "Top Hat"
	unlock_path = /obj/item/clothing/head/that
	slot = SLOT_HEAD

/datum/donator_gear/redcoat
	name = "Redcoat Hat"
	unlock_path = /obj/item/clothing/head/redcoat
	slot = SLOT_HEAD

/datum/donator_gear/mailman
	name = "Mailman Hat"
	unlock_path = /obj/item/clothing/head/mailman
	slot = SLOT_HEAD

/datum/donator_gear/plaguedoctorhat
	name = "Plague Doctor Hat"
	unlock_path = /obj/item/clothing/head/plaguedoctorhat
	slot = SLOT_HEAD

/datum/donator_gear/hasturhood
	name = "Hastur Hood"
	unlock_path = /obj/item/clothing/head/hasturhood
	slot = SLOT_HEAD

/datum/donator_gear/nursehat
	name = "Nurse Hat"
	unlock_path = /obj/item/clothing/head/nursehat
	slot = SLOT_HEAD

/datum/donator_gear/cardborg
	name = "Cardboard Helmet"
	unlock_path = /obj/item/clothing/head/cardborg
	slot = SLOT_HEAD

/datum/donator_gear/justice
	name = "Justice Helmet"
	unlock_path = /obj/item/clothing/head/justice
	slot = SLOT_HEAD

/datum/donator_gear/bowler
	name = "Bowler Hat"
	unlock_path = /obj/item/clothing/head/bowler
	slot = SLOT_HEAD

/datum/donator_gear/witchwig
	name = "Witch's Wig"
	unlock_path = /obj/item/clothing/head/witchwig
	slot = SLOT_HEAD

/datum/donator_gear/chicken
	name = "Chicken Hat"
	unlock_path = /obj/item/clothing/head/witchwig
	slot = SLOT_HEAD

/datum/donator_gear/fedora
	name = "Fedora"
	unlock_path = /obj/item/clothing/head/fedora
	slot = SLOT_HEAD

/datum/donator_gear/sombrero
	name = "Sombrero"
	unlock_path = /obj/item/clothing/head/sombrero
	slot = SLOT_HEAD

/datum/donator_gear/sombrero/green
	name = "Sombrero (Green)"
	unlock_path = /obj/item/clothing/head/sombrero/green
	slot = SLOT_HEAD

/datum/donator_gear/conehat
	name = "Cone Hat"
	unlock_path = /obj/item/clothing/head/cone
	slot = SLOT_HEAD

/datum/donator_gear/beret
	name = "Beret"
	unlock_path = /obj/item/clothing/head/collectable/beret
	slot = SLOT_HEAD

/datum/donator_gear/crown
	name = "Crown"
	unlock_path = /obj/item/clothing/head/crown
	slot = SLOT_HEAD

/datum/donator_gear/wizard/red
	name = "Wizard's Hat (Red, Collectable)"
	unlock_path = /obj/item/clothing/head/wizard/fake/red
	slot = SLOT_HEAD

/datum/donator_gear/wizard/yellow
	name = "Wizard's Hat (Yellow, Collectable)"
	unlock_path = /obj/item/clothing/head/wizard/fake/yellow
	slot = SLOT_HEAD

/datum/donator_gear/wizard/black
	name = "Wizard's Hat (Black, Collectable)"
	unlock_path = /obj/item/clothing/head/wizard/fake/black
	slot = SLOT_HEAD

/datum/donator_gear/wizard/marisa
	name = "Marisa Wizard Hat"
	unlock_path = /obj/item/clothing/head/wizard/marisa/fake
	slot = SLOT_HEAD

/datum/donator_gear/skull
	name = "Skull Helmet (Collectable)"
	unlock_path = /obj/item/clothing/head/collectable/skull
	slot = SLOT_HEAD

//End of items

//Generic donator items
/datum/donator_gear/snail
	name = "Snail Backpack"
	unlock_path = /obj/item/storage/backpack/fakesnail

/datum/donator_gear/toyhammer
	name = "banhammer"
	unlock_path = /obj/item/banhammer
/datum/donator_gear/gondolamask
	name = "gondola mask"
	unlock_path = /obj/item/clothing/mask/gondola
/datum/donator_gear/sheetcosmos
	name = "cosmic space bedsheet"
	unlock_path = /obj/item/bedsheet/cosmos
/datum/donator_gear/sheetwiz
	name = "wizard's bedsheet"
	unlock_path = /obj/item/bedsheet/wiz
/datum/donator_gear/sheetcult
	name = "cultist's bedsheet"
	unlock_path = /obj/item/bedsheet/cult
/datum/donator_gear/sheetnt
	name = "nanotrasen bedsheet"
	unlock_path = /obj/item/bedsheet/nanotrasen
/datum/donator_gear/sheetcentcom
	name = "CentCom bedsheet"
	unlock_path = /obj/item/bedsheet/centcom
/datum/donator_gear/sheetsyndie
	name = "syndicate bedsheet"
	unlock_path = /obj/item/bedsheet/syndie

/datum/donator_gear/air_horn
	name = "air horn"
	unlock_path = /obj/item/bikehorn/airhorn
/datum/donator_gear/sad_horn
	name = "sad horn"
	unlock_path = /obj/item/bikehorn/sad
/datum/donator_gear/camera
	name = "camera"
	unlock_path = /obj/item/camera
/datum/donator_gear/cane
	name = "cane"
	unlock_path = /obj/item/cane
/datum/donator_gear/rain_bow
	name = "rainbow shoes"
	unlock_path = /obj/item/clothing/shoes/sneakers/rainbow
/datum/donator_gear/rainbow
	name = "rainbow gloves"
	unlock_path = /obj/item/clothing/gloves/color/rainbow
/datum/donator_gear/rainbow_jumpsuit
	name = "rainbow jumpsuit"
	unlock_path = /obj/item/clothing/under/color/rainbow
/datum/donator_gear/sith_cloak
	name = "sith cloak"
	unlock_path = /obj/item/clothing/neck/yogs/sith_cloak
/datum/donator_gear/sith_suit
	name = "sith suit"
	unlock_path = /obj/item/clothing/suit/yogs/armor/sith_suit
/datum/donator_gear/hardsuit_clown
	name = "clown hardsuit"
	unlock_path = /obj/item/clothing/suit/yogs/armor/hardsuit_clown
/datum/donator_gear/orca_dress
	name = "creator's dress"
	unlock_path = /obj/item/clothing/suit/yogs/keiki
/datum/donator_gear/oreo
	name = "Black and white sneakers"
	unlock_path = /obj/item/clothing/shoes/yogs/trainers
/datum/donator_gear/red
	name = "Black and red sneakers"
	unlock_path = /obj/item/clothing/shoes/yogs/trainers/red
/datum/donator_gear/cream
	name = "Quadrouple white sneakers"
	unlock_path = /obj/item/clothing/shoes/yogs/trainers/white
/datum/donator_gear/zebra
	name = "Zebra print sneakers"
	unlock_path = /obj/item/clothing/shoes/yogs/trainers/zebra
/datum/donator_gear/moonrock
	name = "Rare brown sneakers"
	unlock_path = /obj/item/clothing/shoes/yogs/trainers/darkbrown
/datum/donator_gear/blackvox
	name = "Rare vox black sneakers"
	unlock_path = /obj/item/clothing/shoes/yogs/trainers/black
/datum/donator_gear/zebrasweat
	name = "White and black sweatshirt"
	unlock_path = /obj/item/clothing/suit/yogs/zebrasweat
/datum/donator_gear/blackwhitesweat
	name = "Black and white sweatshirt"
	unlock_path = /obj/item/clothing/suit/yogs/blackwhitesweat
/datum/donator_gear/fuzzyslippers
	name = "fuzzy bunny slippers"
	unlock_path = /obj/item/clothing/shoes/yogs/fuzzy_slippers
/datum/donator_gear/xenos
	name = "xenos suit"
	unlock_path = /obj/item/clothing/suit/xenos
/datum/donator_gear/sunflower
	name = "sunflower"
	unlock_path = /obj/item/grown/sunflower
/datum/donator_gear/potato
	name = "hot potato"
	unlock_path = /obj/item/hot_potato/harmless/toy
/datum/donator_gear/accordion
	name = "accordion"
	unlock_path = /obj/item/instrument/accordion
/datum/donator_gear/glockenspiel
	name = "glockenspiel"
	unlock_path = /obj/item/instrument/glockenspiel
/datum/donator_gear/harmonica
	name = "harmonica"
	unlock_path = /obj/item/instrument/harmonica
/datum/donator_gear/recorder
	name = "recorder"
	unlock_path = /obj/item/instrument/recorder
/datum/donator_gear/saxophone
	name = "saxophone"
	unlock_path = /obj/item/instrument/saxophone
/datum/donator_gear/latexballon
	name = "latex glove"
	unlock_path = /obj/item/latexballon
/datum/donator_gear/zippo
	name = "Zippo lighter"
	unlock_path = /obj/item/lighter
/datum/donator_gear/lipstick
	name = "lime lipstick"
	unlock_path = /obj/item/lipstick/random
/datum/donator_gear/rolled_poster
	name = "contraband poster - Lusty Xenomorph"
	unlock_path = /obj/item/poster/random_contraband
/datum/donator_gear/rolled_legit
	name = "motivational poster - Help Others"
	unlock_path = /obj/item/poster/random_official
/datum/donator_gear/razor
	name = "electric razor"
	unlock_path = /obj/item/razor
/datum/donator_gear/waterballoon
	name = "water balloon"
	unlock_path = /obj/item/toy/balloon
/datum/donator_gear/ball
	name = "beach ball"
	unlock_path = /obj/item/toy/beach_ball
/datum/donator_gear/dread_ipad
	name = "steampunk watch"
	unlock_path = /obj/item/toy/clockwork_watch
/datum/donator_gear/assistant
	name = "ventriloquist dummy"
	unlock_path = /obj/item/toy/dummy
/datum/donator_gear/eightball
	name = "magic eightball"
	unlock_path = /obj/item/toy/eightball
/datum/donator_gear/katana
	name = "replica katana"
	unlock_path = /obj/item/toy/katana
/datum/donator_gear/revolver
	name = "cap gun"
	unlock_path = /obj/item/toy/gun
/datum/donator_gear/sword0
	name = "toy sword"
	unlock_path = /obj/item/toy/sword

//plushies - kill me, for fuck sake
/datum/donator_gear/plushvar
	name = "Ratvar"
	unlock_path = /obj/item/toy/plush/plushvar
	plush = TRUE

/datum/donator_gear/narplush
	name = "Nar'Sie"
	unlock_path = /obj/item/toy/plush/narplush/hugbox
	plush = TRUE

/datum/donator_gear/blahajplush
	name = "Shark"
	unlock_path = /obj/item/toy/plush/blahaj
	plush = TRUE

/datum/donator_gear/slicerv
	name = "axolotl (slicerv)"
	ckey = "slicerv"
	unlock_path = /obj/item/toy/plush/axolotlplushie
	plush = TRUE

/datum/donator_gear/azeelium
	name = "Utatul-Azeel (Anvilman6)"
	ckey = "Anvilman6"
	unlock_path = /obj/item/toy/plush/lizard/azeel/snowflake
	plush = TRUE

/datum/donator_gear/carpplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/carpplushie
	name = "Space Carp"

/datum/donator_gear/bubbleplush
	plush = TRUE
	unlock_path = /obj/item/toy/plush/bubbleplush
	name = "Bubblegum"

/datum/donator_gear/lizardplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/lizardplushie
	name = "Lizard"

/datum/donator_gear/snakeplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/snakeplushie
	name = "Snake"

/datum/donator_gear/nukeplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/nukeplushie
	name = "Operative"

/datum/donator_gear/slimeplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/slimeplushie
	name = "Slime"

/datum/donator_gear/awakenedplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/awakenedplushie
	name = "Awakened"

/datum/donator_gear/beeplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/beeplushie
	name = "Bee"

/datum/donator_gear/mothplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/mothplushie
	name = "Moth"

/datum/donator_gear/pkplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/pkplushie
	name = "Peacekeeper"

/datum/donator_gear/foxplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/foxplushie
	name = "Fox"

/datum/donator_gear/lizard
	plush = TRUE
	unlock_path = /obj/item/toy/plush/lizard
	name = "Coder"

/datum/donator_gear/azeel
	plush = TRUE
	unlock_path = /obj/item/toy/plush/lizard/azeel
	name = "Medical Lizard"

/datum/donator_gear/blahaj
	plush = TRUE
	unlock_path = /obj/item/toy/plush/blahaj
	name = "Shark"

/datum/donator_gear/cdragon
	plush = TRUE
	unlock_path = /obj/item/toy/plush/cdragon
	name = "Crystal Dragon"

/datum/donator_gear/goatplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/goatplushie
	name = "Strange Goat"

/datum/donator_gear/teddybear
	plush = TRUE
	unlock_path = /obj/item/toy/plush/teddybear
	name = "Teddy Bear"

/datum/donator_gear/stuffedmonkey
	plush = TRUE
	unlock_path = /obj/item/toy/plush/stuffedmonkey
	name = "Stuffed Monkey"

/datum/donator_gear/inorixplushie
	plush = TRUE
	unlock_path = /obj/item/toy/plush/inorixplushie
	name = "Inorix"

/datum/donator_gear/flowerbunch
	plush = TRUE
	unlock_path = /obj/item/toy/plush/flowerbunch
	name = "Bunch of Flowers"

/datum/donator_gear/realgoat
	plush = TRUE
	unlock_path = /obj/item/toy/plush/realgoat
	name = "Goat"
