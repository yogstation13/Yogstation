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

/obj/item/explosive_shroom
	name = "Explosive Shroom"
	desc = "Mushroom picked from a foreign world, it will explode when handled too harshly"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "explosive_shroom"

/obj/item/explosive_shroom/attack_self(mob/user)
	. = ..()
	animate(src,time=2.49 SECONDS, color = "#e05a5a")
	addtimer(CALLBACK(src,.proc/explode),2.5 SECONDS)

/obj/item/explosive_shroom/proc/explode()
	dyn_explosion(get_turf(src),4)
	if(src && !QDELETED(src))
		qdel(src)

/obj/item/reagent_containers/food/snacks/grown/jungle
	icon = 'yogstation/icons/obj/jungle.dmi'


/obj/item/seeds/jungleland
	name = "jungleland seeds"
	desc = "You should never see this."
	lifespan = 50
	endurance = 25
	maturation = 7
	production = 4
	yield = 4
	potency = 50
	growthstages = 3
	rarity = 20
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1)
	resistance_flags = ACID_PROOF

/obj/item/reagent_containers/food/snacks/grown/jungle/liberal_hat
	name = "Liberal Hat"
	desc = "Hats off madlad, take me and free your mind..."
	icon_state = "liberal_hat"
	seed = /obj/item/seeds/jungleland/liberal_hats

/obj/item/seeds/jungleland/liberal_hats
	name = "pack of liberal hat mycelium"
	desc = "These spores should grow into liberal hats"
	icon_state = "mycelium-liberal-hat"
	species = "liberal_hat"
	plantname = "Liberal Hat"
	product = /obj/item/reagent_containers/food/snacks/grown/jungle/liberal_hat
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growthstages = 3
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.02, /datum/reagent/jungle/polybycin = 0.1)

/obj/item/reagent_containers/food/snacks/grown/jungle/cinchona_bark
	name = "Cinchona Bark"
	desc = "Powerful healing herb that can help with curing many exotic diseases"
	icon_state = "cinchona_bark"
	seed = /obj/item/seeds/jungleland/cinchona

/obj/item/seeds/jungleland/cinchona
	name = "pack of cinchona seeds"
	desc = "These seeds should grow into cinchona shrubs"
	icon_state = "seed-cinchona"
	species = "cinchona"
	plantname = "Cinchona"
	product = /obj/item/reagent_containers/food/snacks/grown/jungle/cinchona_bark
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	growthstages = 3
	reagents_add = list(/datum/reagent/quinine = 0.1, /datum/reagent/medicine/atropine = 0.05, /datum/reagent/medicine/omnizine = 0.1)

/obj/item/organ/regenerative_core/dryad
	desc = "Heart of a dryad. It can be used to heal completely, but it will rapidly decay into uselessness."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "dryad_heart"
	status_effect = /datum/status_effect/regenerative_core/dryad

/obj/item/organ/regenerative_core/dryad/Initialize()
	. = ..()
	update_icon()

/obj/item/organ/regenerative_core/dryad/update_icon()
	icon_state = inert ? "dryad_heart_decay" : "dryad_heart"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/regenerative_core/dryad/go_inert()
	..()
	desc = "[src] has become inert. It has decayed, and is completely useless."

/obj/item/organ/regenerative_core/dryad/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It is preserved, allowing you to use it to heal completely without danger of decay."

/obj/item/organ/regenerative_core/dryad
	name = "Dryad heart"
	desc = "Heart of a dryad. It can be used to heal completely, but it will rapidly decay into uselessness."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "dryad_heart"
	status_effect = /datum/status_effect/regenerative_core/dryad

/obj/item/organ/regenerative_core/dryad/Initialize()
	. = ..()
	update_icon()

/obj/item/organ/regenerative_core/dryad/update_icon()
	icon_state = inert ? "dryad_heart_decay" : "dryad_heart"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/regenerative_core/dryad/go_inert()
	..()
	desc = "[src] has become inert. It has decayed, and is completely useless."

/obj/item/organ/regenerative_core/dryad/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It is preserved, allowing you to use it to heal completely without danger of decay."

/obj/item/organ/regenerative_core/dryad/corrupted
	name = "Corrupted dryad heart"
	desc = "Heart of a corrupted dryad, for now it still lives, and i may use some of it's strength to help me live aswell."
	icon_state = "corrupted_heart"
	status_effect = /datum/status_effect/corrupted_dryad
