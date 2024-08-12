//Subtype of human
/datum/species/human/vulpine
	name = "Vulpine Human"
	id = "vulpine"
	limbs_id = "human"
	attack_verbs = list("slash")
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'

	mutant_bodyparts = list("ears", "tail_human")
	default_features = list("mcolor" = "FFF", "tail_human" = "Fox", "ears" = "Fox", "wings" = "None")
	rare_say_mod = list("yips"= 10)
	liked_food = SEAFOOD | DAIRY | MICE
	disliked_food = GROSS | RAW
	toxic_food = TOXIC | CHOCOLATE
	mutantears = /obj/item/organ/ears/cat/fox
	mutanttail = /obj/item/organ/tail/cat/fox
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
