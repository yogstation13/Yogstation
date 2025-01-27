/datum/symptom/sneeze
	name = "Coldingtons Effect"
	desc = "Makes the infected sneeze every so often, leaving some infected mucus on the floor."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	severity = 2

/datum/symptom/sneeze/activate(mob/living/mob)
	mob.emote("sneeze")
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/host = mob
	if (prob(50) && isturf(mob.loc))
		if(istype(host.wear_mask, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/ciggie = host.get_item_by_slot(ITEM_SLOT_MASK)
			if(prob(20))
				var/turf/startLocation = get_turf(mob)
				var/turf/endLocation
				var/spitForce = pick(0,1,2,3)
				endLocation = get_ranged_target_turf(startLocation, mob.dir, spitForce)
				to_chat(mob, "<span class ='warning'>You sneezed \the [host.wear_mask] out of your mouth!</span>")
				host.dropItemToGround(ciggie)
				ciggie.throw_at(endLocation,spitForce,1)
