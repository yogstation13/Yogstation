/datum/map_template/asteroid
	name = "Asteroid"
	///This is just a reminder, set the path will you? cant load what we cant find.
	//mappath =

	///X wise, where are we on the Cartesian Plane?
	var/x
	///Y wise, where are we on the Cartesian Plane?
	var/y
	///Have we found this astroid, but not yet summoned it?
	var/found = FALSE
	///Have we already summoned this boi to the station?
	var/summoned = FALSE
	///Radius, how big this boi? 7 is max, so 15x15 total!
	var/size = 7
	///How likely is this to generate? We'll assume a base weight of 100 if not defined.
	var/asteroid_weight
	///Where folder-wise is this map?
	var/prefix = "_maps/~monkestation/asteroid_maps/"
	///What is the map's name?
	var/suffix

/datum/map_template/asteroid/New()
	mappath = prefix+suffix
	..(path = mappath)

/datum/map_template/asteroid/test
	name = "Smiley Asteroid"
	suffix = "test_rock.dmm"
	size = 7

	asteroid_weight = 1

/datum/map_template/asteroid/test_two
	name = "Frowny Asteroid"
	suffix = "test_rock_boogaloo.dmm"
	size = 7

	asteroid_weight = 1

/datum/map_template/asteroid/standard_large
	name = "Large Asteroid"
	suffix = "rock.dmm"
	size = 7

	asteroid_weight = 75

/datum/map_template/asteroid/standard_smol
	name = "Small Asteroid"
	suffix = "smol_rock.dmm"
	size = 3

	asteroid_weight = 100

/datum/map_template/asteroid/binary
	name = "Binary Asteroids"
	suffix = "binary.dmm"
	size = 6

	asteroid_weight = 25

/datum/map_template/asteroid/artifact_capsule
	name = "Unknown Metal Object"
	suffix = "capsule.dmm"
	size = 1

	asteroid_weight = 10

/datum/map_template/asteroid/standard_medium
	name = "Asteroid"
	suffix = "medium_rock.dmm"
	size = 4

	asteroid_weight = 125

/datum/map_template/asteroid/rock_bar
	name = "Hollowed Asteroid"
	suffix = "rockbar.dmm"
	size = 6

	asteroid_weight = 10

/datum/map_template/asteroid/geode
	name = "Asteroid"
	suffix = "geode.dmm"
	size = 3

	asteroid_weight = 25

/datum/map_template/asteroid/sealed_danger
	name = "Asteroid"
	suffix = "sealed_danger.dmm"
	size = 3

	asteroid_weight = 30

/datum/map_template/asteroid/rich_small
	name = "Asteroid"
	suffix = "strong_rock.dmm"
	size = 3

	asteroid_weight = 40

/datum/map_template/asteroid/poor_small
	name = "Asteroid"
	suffix = "weak_rock.dmm"
	size = 3

	asteroid_weight = 80

/datum/map_template/asteroid/mutual_destruction_rock
	name = "Asteroid"
	suffix = "mad_rock.dmm"
	size = 3

	asteroid_weight = 50

/datum/map_template/asteroid/cargo_empty
	name = "Abandoned Shipping Container"
	suffix = "cargo_empty.dmm"
	size = 3

	asteroid_weight = 10

/datum/map_template/asteroid/cargo_crates
	name = "Abandoned Shipping Container"
	suffix = "cargo_crates.dmm"
	size = 3

	asteroid_weight = 10

/datum/map_template/asteroid/cargo_bad
	name = "Abandoned Shipping Container"
	suffix = "cargo_danger.dmm"
	size = 3

	asteroid_weight = 5

/datum/map_template/asteroid/cargo_artifacts
	name = "Abandoned Shipping Container"
	suffix = "cargo_artifacts.dmm"
	size = 3

	asteroid_weight = 10

/datum/map_template/asteroid/room
	name = "Asteroid"
	suffix = "room.dmm"
	size = 4

	asteroid_weight = 25

/datum/map_template/asteroid/legion_mod
	name = "Medium Asteroid"
	suffix = "medium_doom.dmm"
	size = 5

	asteroid_weight = 20
/datum/map_template/asteroid/itsastone
	name = "Large Oblong Asteroid"
	suffix = "football.dmm"
	size = 7

	asteroid_weight = 10
