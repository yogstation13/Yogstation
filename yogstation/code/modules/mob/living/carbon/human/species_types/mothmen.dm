/datum/species/moth
	var/MothLightRange = 15 //In what radius shall moths look for lights to fly at?
	var/MothLightProb = 2 //Don't want them doing it tooooo often..Unless an admin changes it :^) So change this back to 5 after testing

/datum/species/moth/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat != DEAD) //Suffer not a dead moth to move
		MothLightProb = initial(MothLightProb)
		var/retarded = H.getBrainLoss()
		MothLightProb += retarded*0.3 //So there's always a slight chance.
		var/list/LightsIWantToFlyAt = list()
		if(prob(MothLightProb)) //Moth people now have a random urge to fly violently into lights
			for(var/obj/O in orange(H,MothLightRange))
				if(O.light_sources)
					for(var/datum/light_source/S in O.light_sources)
						if(istype(S, /datum/light_source))
							if(S.light_power > 0)
								for(var/i = 1 to round(S.light_power)) //Weight the list according to light power
									LightsIWantToFlyAt += S.source_atom
			var/atom/MothWantsToFlyAtThisOne = pick(LightsIWantToFlyAt)
			H.Jitter(5)
			H.throw_at(get_turf(MothWantsToFlyAtThisOne), 2, 5) //Moth flies at light
			to_chat(H, "<span class='userdanger'>LIGHT! LIGHT! -- All your thoughts are overtaken as your primordial instincts force you to fly at [MothWantsToFlyAtThisOne]!</span>")
			H.visible_message("<span class='notice'>[H] rapidly flitters towards [MothWantsToFlyAtThisOne]!</span>")
			playsound(H.loc,'yogstation/sound/effects/mothflitter.ogg',60,1)
			return