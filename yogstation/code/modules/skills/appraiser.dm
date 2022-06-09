/obj/item/appraiser
	name = "Appraiser"
	desc = "A device that looks up the qualifications of the scanned being and assesses the best job for them."
	icon = 'icons/obj/device.dmi'
	icon_state = "appraiser"
	var/use_roundstart = TRUE
	var/show_skill_groups = TRUE

/obj/item/appraiser/attack(mob/living/M, mob/living/carbon/human/user)
	flick("[icon_state]-scan", src)
  
	if(!do_after(user, 10, target = M, required_skill = SKILL_LEADERSHIP, skill_delay_mult_scaling = list(SKILLLEVEL_UNSKILLED = 2, SKILLLEVEL_BASIC = 1.5, SKILLLEVEL_TRAINED = 1, SKILLLEVEL_EXPERIENCED = 0.5, SKILLLEVEL_MASTER = 0)))
		return
    
	playsound(src, 'sound/effects/fastbeep.ogg', 20)

	user.visible_message(span_notice("[user] has analyzed [M]'s skills."))

	scan(M, user)

	add_fingerprint(user)

/obj/item/appraiser/proc/scan(mob/living/M, mob/living/carbon/human/user)
	return
