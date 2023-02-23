// Organs.


// Alien organs
/datum/export/organ/alien/get_cost(obj/O, allowed_categories = NONE, apply_limit = TRUE)
	. = ..()
	if(EXPORT_EMAG in allowed_categories) // Syndicate really wants some new bio-weapons.
		. *= 1.25

/datum/export/organ/alien/brain
	cost = 5000
	unit_name = "alien brain"
	export_types = list(/obj/item/organ/brain/alien)

/datum/export/organ/alien/acid
	cost = 3000
	unit_name = "alien acid gland"
	export_types = list(/obj/item/organ/alien/acid)

/datum/export/organ/alien/hivenode
	cost = 5000
	unit_name = "alien hive node"
	export_types = list(/obj/item/organ/alien/hivenode)

/datum/export/organ/alien/neurotoxin
	cost = 5000
	unit_name = "alien neurotoxin gland"
	export_types = list(/obj/item/organ/alien/neurotoxin)

/datum/export/organ/alien/resinspinner
	cost = 2000
	unit_name = "alien resin spinner"

/datum/export/organ/alien/plasmavessel
	cost = 1000
	unit_name = "alien plasma vessel"
	export_types = list(/obj/item/organ/alien/plasmavessel)

/datum/export/organ/alien/plasmavessel/get_cost(obj/item/organ/alien/plasmavessel/P)
	return ..() + (P.max_plasma * 2) + (P.plasma_rate * 20)



/datum/export/organ/alien/embryo
	cost = 5000 // Allows buyer to set up his own alien farm.
	export_limit = 20
	unit_name = "alien embryo"
	export_types = list(/obj/item/organ/body_egg/alien_embryo)

/datum/export/organ/alien/eggsac
	cost = 10000 // Even better than a single embryo.
	export_limit = 10
	unit_name = "alien egg sac"
	export_types = list(/obj/item/organ/alien/eggsac)


// Other alien organs.
/datum/export/organ/alien/abductor
	cost = 2500
	export_limit = 10
	unit_name = "abductor gland"
	export_types = list(/obj/item/organ/heart/gland)

/datum/export/organ/alien/changeling_egg
	cost = 50000 // Holy. Fuck.
	unit_name = "changeling egg"
	export_types = list(/obj/item/organ/body_egg/antag_egg/changeling_egg)


/datum/export/organ/hivelord
	cost = 1500
	unit_name = "regenerative core"
	export_types = list(/obj/item/organ/regenerative_core)

/datum/export/organ/hivelord/get_cost(obj/O, allowed_categories = NONE, apply_limit = TRUE)
	var/obj/item/organ/regenerative_core/C = O
	if(C.inert)
		return ..() / 3
	if(C.preserved)
		return ..() * 2
	return ..()

// Mutant race organs.
/datum/export/organ/mutant/cat_ears
	cost = 100 //as much as plasma when sold in a set, not counting the skin
	unit_name = "cat ears pair"
	export_types = list(/obj/item/organ/ears/cat)

/datum/export/organ/mutant/cat_tail
	cost = 100
	unit_name = "cat tail"
	export_types = list(/obj/item/organ/tail/cat)

/datum/export/organ/mutant/lizard_tail
	cost = 300
	unit_name = "lizard tail"
	export_types = list(/obj/item/organ/tail/lizard)

// Human organs.

// Do not put human brains here, they are not sellable for a purpose.
// If they would be sellable, X-Porter cannon's finishing move (selling victim's organs) will be instakill with no revive. //remind me to add the X-porter cannon in like a month or something itll be funny i swear

/datum/export/organ/human //it is regrettably easy to get human organs with very little moral dubiation so the prices have to be quite small to still allow organ farms
	export_category = EXPORT_CONTRABAND
	include_subtypes = FALSE

/datum/export/organ/human/heart
	cost = 100
	unit_name = "heart"
	export_types = list(/obj/item/organ/heart)

/datum/export/organ/human/lungs
	cost = 50
	unit_name = "pair"
	message = "of lungs"
	export_types = list(/obj/item/organ/lungs)

/datum/export/organ/human/appendix
	cost = 10
	unit_name = "appendix"
	export_types = list(/obj/item/organ/appendix)

/datum/export/organ/human/appendix/get_cost(obj/item/organ/appendix/O)
	if(O.inflamed)
		return 0
	return ..()
