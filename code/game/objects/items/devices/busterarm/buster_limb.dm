

/obj/item/bodypart/l_arm/robot/buster
	name = "left buster arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "left_buster_arm"
	max_damage = 50
	aux_layer = 12
	var/datum/action/cooldown/buster/megabuster/l/megabuster_action = new/datum/action/cooldown/buster/megabuster/l()
	var/datum/martial_art/buster_style/buster_style = new


/obj/item/bodypart/l_arm/robot/buster/attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(new_owner.mind)
		megabuster_action.Grant(new_owner)
		buster_style.teach(new_owner)
		RegisterSignal(new_owner.mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer_from))
	RegisterSignal(new_owner, COMSIG_MOB_MIND_TRANSFERRED_INTO, PROC_REF(on_mind_transfer_to))


/obj/item/bodypart/l_arm/robot/buster/drop_limb(special)
	var/obj/item/bodypart/r_arm = owner.get_bodypart(BODY_ZONE_R_ARM)
	if(owner.mind)
		megabuster_action.Remove(owner)
		if(!istype(r_arm, /obj/item/bodypart/r_arm/robot/buster))
			buster_style.remove(owner)
		UnregisterSignal(owner.mind, COMSIG_MIND_TRANSFERRED)
	UnregisterSignal(owner, COMSIG_MOB_MIND_TRANSFERRED_INTO)
	return ..()

/obj/item/bodypart/l_arm/robot/buster/proc/on_mind_transfer_to(mob/living/new_mob)
	buster_style.teach(new_mob)
	megabuster_action.Grant(new_mob)
	RegisterSignal(new_mob.mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer_from))

/obj/item/bodypart/l_arm/robot/buster/proc/on_mind_transfer_from(datum/mind/old_mind)
	buster_style.remove(old_mind.current)
	megabuster_action.Remove(old_mind.current)
	UnregisterSignal(old_mind, COMSIG_MIND_TRANSFERRED)


/obj/item/bodypart/l_arm/robot/buster/attack(mob/living/L, proximity)
	if(!ishuman(L))
		return
	if((L.mind.martial_art != L.mind.default_martial_art) && !(istype(L.mind.martial_art, /datum/martial_art/cqc/under_siege))) //prevents people from learning several martial arts or swapping between them
		to_chat(L, span_warning("You are already dedicated to using [L.mind.martial_art.name]!"))
		return
	playsound(L,'sound/effects/phasein.ogg', 20, 1)
	to_chat(L, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your left arm!"))
	replace_limb(L)


/obj/item/bodypart/l_arm/robot/buster/attack_self(mob/user)
	. = ..()
	var/obj/item/bodypart/r_arm/robot/buster/opphand = new(get_turf(src))
	opphand.brute_dam = src.brute_dam
	opphand.burn_dam = src.burn_dam 
	to_chat(user, span_notice("You modify [src] to be installed on the right arm."))
	qdel(src)
	

/obj/item/bodypart/r_arm/robot/buster
	name = "right buster arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "right_buster_arm"
	max_damage = 50
	aux_layer = 12
	var/datum/action/cooldown/buster/megabuster/r/megabuster_action = new/datum/action/cooldown/buster/megabuster/r()
	var/datum/martial_art/buster_style/buster_style = new


/obj/item/bodypart/r_arm/robot/buster/attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(new_owner.mind)
		megabuster_action.Grant(new_owner)
		buster_style.teach(new_owner)
		RegisterSignal(new_owner.mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer_from))
	RegisterSignal(new_owner, COMSIG_MOB_MIND_TRANSFERRED_INTO, PROC_REF(on_mind_transfer_to))


/obj/item/bodypart/r_arm/robot/buster/drop_limb(special)
	var/obj/item/bodypart/l_arm = owner.get_bodypart(BODY_ZONE_L_ARM)
	if(owner.mind)
		megabuster_action.Remove(owner)
		if(!istype(l_arm, /obj/item/bodypart/l_arm/robot/buster))
			buster_style.remove(owner)
		UnregisterSignal(owner.mind, COMSIG_MIND_TRANSFERRED)
	UnregisterSignal(owner, COMSIG_MOB_MIND_TRANSFERRED_INTO)
	return ..()

/obj/item/bodypart/r_arm/robot/buster/proc/on_mind_transfer_to(mob/living/new_mob)
	buster_style.teach(new_mob)
	megabuster_action.Grant(new_mob)
	RegisterSignal(new_mob.mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer_from))

/obj/item/bodypart/r_arm/robot/buster/proc/on_mind_transfer_from(datum/mind/old_mind)
	buster_style.remove(old_mind.current)
	megabuster_action.Remove(old_mind.current)
	UnregisterSignal(old_mind, COMSIG_MIND_TRANSFERRED)


/obj/item/bodypart/r_arm/robot/buster/attack(mob/living/L, proximity)
	if(!ishuman(L))
		return
	if((L.mind.martial_art != L.mind.default_martial_art) && !(istype(L.mind.martial_art, /datum/martial_art/cqc/under_siege))) //prevents people from learning several martial arts or swapping between them
		to_chat(L, span_warning("You are already dedicated to using [L.mind.martial_art.name]!"))
		return
	playsound(L,'sound/effects/phasein.ogg', 20, 1)
	to_chat(L, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your right arm!"))
	replace_limb(L)


/obj/item/bodypart/r_arm/robot/buster/attack_self(mob/user)
	. = ..()
	var/obj/item/bodypart/l_arm/robot/buster/opphand = new(get_turf(src))
	opphand.brute_dam = src.brute_dam
	opphand.burn_dam = src.burn_dam 
	to_chat(user, span_notice("You modify [src] to be installed on the left arm."))
	qdel(src)
