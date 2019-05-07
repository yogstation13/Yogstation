/datum/species/insectoid
	// A race of psionic aliens, sold as labour by their more powerful masters.
	name = "Insectoids"
	id = "insectoid"
	say_mod = "hums" //super alien right
	default_color = "FFFFDD"
	species_traits = list(NOGUNS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	changesource_flags = MIRROR_BADMIN //donor only :smirk:
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = ''
	exotic_bloodtype = "X"
	liked_food = MEAT | RAW //highly predatory
	deathsound = ''