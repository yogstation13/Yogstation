/datum/species/lizard/ashwalker/cosmic
	name = "Cosmic Ashwalker"
	var/rebirth
	var/rebirthcount = 0
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE)

/datum/species/lizard/ashwalker/cosmic/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.health < 0)
		if(rebirthcount >= 3)
			return
		if(rebirth)
			return
		if(H.stat == DEAD) // we only heal when they're close to . not actually dead.
			return
		rebirth = TRUE
		rebirthcount++
		to_chat(H, span_notice("Your body is entering cryogenic rebirth. You will soon be restored to your physical form. Once this happens your soul will be dragged back into your body."))
		if(rebirthcount >= 3)
			to_chat(H, span_notice("You notice that your body isn't regenerating as fast as it used to. It seems like the abductor's effects are wearing off. This is your last rebirth cycle.."))
		H.()
		H.ghostize()
		for(var/obj/item/I in H)
			H.unequip_everything(I)
		var/obj/effect/cyrogenicbubble/CB = new(get_turf(H))
		CB.name = H.real_name
		H.forceMove(CB)
		CB.ashwalker = H
