/mob/living/carbon/human/do_cpr(mob/living/carbon/C)
	CHECK_DNA_AND_SPECIES(C)

	if(C.stat == DEAD || (C.has_trait(TRAIT_FAKEDEATH)))
		visible_message("<span class='notice'>[src] hugs [C] to make [C.p_them()] feel better!</span>", \
			"<span class='notice'>You hug [C] to make [C.p_them()] feel better!</span>")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		return

	.=..()
