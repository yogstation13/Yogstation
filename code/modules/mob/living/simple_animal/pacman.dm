/mob/living/simple_animal/pacman
	name = "Pacman"
	real_name = "Pacman"
	desc = "Pac-Man is a widespread critical and commercial success. The game is important and influential, and it is commonly listed as one of the greatest video games of all time. The success of the game led to several sequels, merchandise, and two television series, as well as a hit single by Buckner and Garcia. The Pac-Man video game franchise remains one of the highest-grossing and best-selling game series of all time, generating more than $14 billion in revenue (as of 2016) and $43 million in sales combined. The character of Pac-Man is the mascot and flagship icon of Bandai Namco Entertainment and has the highest brand awareness of any video game character in North America."
	gender = NEUTER
	icon = 'icons/mob/mob.dmi'
	icon_state = "pacman"
	icon_living = "pacman"
	maxHealth = 50
	health = 50
	spacewalk = TRUE
	healable = 0
	speak_emote = list("awas")
	emote_hear = list("awas")
	speak_chance = 0
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "awas"
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	stop_automated_movement = 1
	status_flags = 0
	del_on_ = TRUE
	sound = 'sound/effects/pacman_.ogg'
	attack_sound = 'sound/effects/pacman_chomp.ogg'

/mob/living/simple_animal/pacman/Bump(atom/movable/M)
	. = ..()
	if(ismob(M))
		qdel(M) // c o n s u m e
		playsound(loc, 'sound/effects/pacman_chomp.ogg', 100, 1)
		Bumped(M)
