/mob/living/simple_animal/hostile/hog
	name = "Hog"
	desc = "Hog riders????? (Actually not it isn't a hog rider from clash of clans, if you see this - something went wrong)"
	var/datum/team/hog_cult/cult
	var/cultist_desc = "A hog rider from your cult! (Still shouldn't exist)"
	var/heretic_desc = "A hog rider from an enemy cult! (Still shouldn't exist)"

/mob/living/simple_animal/hostile/hog/Login()
	. = ..()
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(src)
	if(!cult)
		if(cultie && cultie.cult)
			cult = cultie.cult
	else if(cultie && !cultie.cult)
		cultie.cult = cult

/mob/living/simple_animal/hostile/hog/examine(mob/user)
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(cultie && cultie.cult == src.cult)
		desc = cultist_desc
	else if (cultie)
		desc = heretic_desc
	else
		desc = initial(desc)
	. = ..()
	desc = initial(desc)