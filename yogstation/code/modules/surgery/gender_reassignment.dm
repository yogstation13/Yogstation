/datum/surgery/gender_reassignment
	name = "gender reassignment"
	steps = list(/datum/surgery_step/incise, 
				 /datum/surgery_step/clamp_bleeders, 
				 /datum/surgery_step/reshape_genitals, 
				 /datum/surgery_step/close)
	possible_locs = list("groin")


//reshape_genitals
/datum/surgery_step/reshape_genitals
	name = "reshape genitals"
	implements = list(/obj/item/scalpel = 100, /obj/item/melee/transforming/energy/sword = 15, /obj/item/kitchen/knife = 35, /obj/item/shard = 25)	
	time = 64

/datum/surgery/gender_reassignment/can_start(mob/user, mob/living/carbon/target)
	if(target.dna && ((AGENDER in target.dna.species.species_traits) || (MGENDER in target.dna.species.species_traits) || (FGENDER in target.dna.species.species_traits)))
		return FALSE
	return TRUE

/datum/surgery_step/reshape_genitals/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.gender == FEMALE)
		user.visible_message("[user] begins to reshape [target]'s genitals to look more masculine.", "<span class='notice'>You begin to reshape [target]'s genitals to look more masculine...</span>")
	else
		user.visible_message("[user] begins to reshape [target]'s genitals to look more feminine.", "<span class='notice'>You begin to reshape [target]'s genitals to look more feminine...</span>")

/datum/surgery_step/reshape_genitals/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/H = target	//no type check, as that should be handled by the surgery
	H.gender_ambiguous = 0
	if(target.gender == FEMALE)
		user.visible_message("[user] has made a man of [target]!", "<span class='notice'>You made [target] a man.</span>")
		target.gender = MALE
	else
		user.visible_message("[user] has made a woman of [target]!", "<span class='notice'>You made [target] a woman.</span>")
		target.gender = FEMALE
	target.regenerate_icons()
	return 1

/datum/surgery_step/reshape_genitals/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/H = target
	H.gender_ambiguous = 1
	user.visible_message("<span class='warning'>[user] accidentally mutilates [target]'s genitals beyond the point of recognition!</span>", "<span class='warning'>You accidentally mutilate [target]'s genitals beyond the point of recognition!</span>")
	target.gender = pick(MALE, FEMALE)
	target.regenerate_icons()
	return 1