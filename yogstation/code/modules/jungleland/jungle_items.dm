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

/obj/item/clothing/neck/yogs/skin_twister
	name = "skin-twister cloak"
	desc = "Cloak made out of skin of the elusive skin-twister, when worn over head it makes you invisible to the smaller fauna of the jungle."
	icon_state = "skin_twister_cloak_0"
	item_state = "skin_twister_cloak_0"

	var/active = FALSE
	var/list/cached_faction_list

/obj/item/clothing/neck/yogs/skin_twister/equipped(mob/user, slot)
	. = ..()
	active = FALSE
	if(slot != SLOT_NECK)
		return
	active = TRUE
	cached_faction_list = user.faction.Copy() // we dont keep the reference to it 
	user.faction += "mining"
	user.faction += "skin_walkers"

/obj/item/clothing/neck/yogs/skin_twister/dropped(mob/user)
	if(active)
		active = FALSE 
		user.faction = cached_faction_list	
	return ..()

/obj/item/stack/sheet/skin_twister
	name = "skin twister hide"
	desc = "Hide of a skin twister"
	singular_name = "skintwister hide piece"
	icon_state = "sheet-skintwister_hide"

/obj/item/stack/sheet/slime
	name = "slime granule"
	desc = "densely compacted granulate of organic slime"
	singular_name = "slime granulate"
	icon_state = "sheet-slime"

/obj/item/stack/sheet/meduracha 
	name = "meduracha tentacles"
	desc = "a stinger of a giant exotic mosquito, quite sharp"
	singular_name = "meduracha tentacle"
	icon_state = "sheet-meduracha"

/obj/item/stinger 
	name = "giant mosquito stinger"
	desc = "a stinger of a giant exotic mosquito, quite sharp"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "stinger"

/obj/item/melee/stinger_sword
	name = "stinger sword"
	desc = "a sword made out of giant mosquito stinger crudely glued to a metal rod"
	force = 15
	armour_penetration = 75
	icon = 'yogstation/icons/obj/jungle.dmi'
	lefthand_file = 'yogstation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/righthand.dmi'
	icon_state = "stinger_sword"
	item_state = "stinger_sword"

/obj/item/melee/stinger_sword/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return 
	var/mob/living/carbon/C = target 
	C.blood_volume -= force

/obj/item/slime_sling 
	name = "slime sling"
	desc = "a sling made out of organic slime... why are you aiming at me?"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "slime_sling_0"

	var/state = 0

/obj/item/slime_sling/attack_self(mob/user)
	. = ..()
	RegisterSignal(user,COMSIG_MOB_CLICKON, .proc/sling)
	for(var/i in 1 to 3)
		if(do_after(user,2.5 SECONDS, user))
			state++
			icon_state = "slime_sling_[state]" 
		else 
			cancel(user)
			return
	RegisterSignal(user,COMSIG_MOVABLE_MOVED, .proc/cancel)

/obj/item/slime_sling/proc/cancel(mob/user)
	UnregisterSignal(user,COMSIG_MOB_CLICKON)
	UnregisterSignal(user,COMSIG_MOVABLE_MOVED)
	state = 0
	icon_state = "slime_sling_0"

/obj/item/slime_sling/proc/sling(mob/user,atom/A, params)
	UnregisterSignal(user,COMSIG_MOB_CLICKON)
	UnregisterSignal(user,COMSIG_MOVABLE_MOVED)	
	if(!state)
		return
	var/turf/T = get_turf(A)

	var/dir = Get_Angle(user.loc,T)
	
	//i actually fucking hate this utility function, for whatever reason Get_Angle returns the angle assuming that [0;-1] is 0 degrees rather than [1;0] like any sane being.
	var/tx = clamp(0,round(T.x + sin(dir) * state * 5),255)
	var/ty = clamp(0,round(T.y + cos(dir) * state * 5),255)
	user.throw_at(locate(tx,ty,T.z),state * 5,state * 5)
	state = 0
	icon_state = "slime_sling_0"

/obj/item/clothing/head/yogs/tar_king_crown
	name = "Crown of the Tar King"
	desc = "And old and withered crown made out of bone of unknown origin, there is a vibrant pinkish crystal embedded in it, it is warm to the touch..."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "tar_king_crown"
