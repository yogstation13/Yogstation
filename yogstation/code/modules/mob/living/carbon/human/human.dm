/mob/living/carbon/human/Initialize()
	. = ..()
	if(gender == MALE)
		if(skin_tone == "asian1" || skin_tone == "asian2")
			penis_size = rand(1, 10)
			return
		if(skin_tone == "latino" || skin_tone == "african1" || skin_tone == "african2")
			if(prob(10))
				penis_size = rand(7, 20)
			else
				penis_size = rand(15, 30)
		else
			penis_size = rand(5, 30)
	if(gender == FEMALE)
		if(skin_tone == "asian1" || skin_tone == "asian2")
			if(prob(1))
				penis_size = 30
			else if(prob(10))
				penis_size = rand(1, 15)
		else
			penis_size = 0