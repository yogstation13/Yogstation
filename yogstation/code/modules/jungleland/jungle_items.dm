/obj/item/dummy_toxic_buildup
	name = "test dummy"
	desc = "what"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "damage_orb"

/obj/item/dummy_toxic_buildup/attack_self(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	living_user.apply_status_effect(/datum/status_effect/toxic_buildup)
/obj/item/dummy_malaria
	name = "test dummy"
	desc = "what"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "damage_orb"

/obj/item/dummy_malaria/attack_self(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	var/datum/disease/malaria/infection = new() 
	carbon_user.ForceContractDisease(infection,FALSE,TRUE)

/obj/item/tar_crystal
	name = "Broken Crystal"
	desc = "A broken crystal, it has an ominous dark glow around it."
	icon = 'yogstation/icons/obj/jungle.dmi'

/obj/item/tar_crystal/Initialize()
	. = ..()
	icon_state = "tar_crystal_part[pick(0,1,2)]"

/obj/item/full_tar_crystal
	name = "Ominous Crystal"
	desc = "a crystal that has been repaired from 3 parts, it emantes dark energy."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "tar_crystal"


