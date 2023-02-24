/////////////////\\\\\\\\\\\\\\
////						\\\\
////  STARTING ABILITIES 	\\\\
////						\\\\
////\\\\\\\\\\\\///////////\\\\

/datum/action/innate/zombie/default/endure
	name = "Endure"
	desc = "Harden your muscles, gaining increased vitality, but restricting arm movement."
	button_icon_state = "endure"
	ability_type = ZOMBIE_TOGGLEABLE
	cost = 5
	constant_cost = 2.5

/datum/action/innate/zombie/default/endure/Activate()
	. = ..()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, ZOMBIE_TRAIT)
	ADD_TRAIT(owner, TRAIT_PACIFISM, ZOMBIE_TRAIT)
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(zombie_owner.zombie_mutations["better_reflexes"])
		ADD_TRAIT(owner, TRAIT_DODGE, ZOMBIE_TRAIT)

/datum/action/innate/zombie/default/endure/Deactivate()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, ZOMBIE_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, ZOMBIE_TRAIT)
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(zombie_owner.zombie_mutations["better_reflexes"])
		REMOVE_TRAIT(owner, TRAIT_DODGE, ZOMBIE_TRAIT)

/datum/action/innate/zombie/parkour
	name = "Parkour"
	desc = "Prepare your legs to instantly dive over any low standing structures."
	button_icon_state = "parkour"
	ability_type = ZOMBIE_TOGGLEABLE
	cooldown = 15 SECONDS
	/// Jumping over 5 obstacles will automatically disable Parkour, 10 with the leg_response upgrade.
	var/obstacles_jumped = 0

/datum/action/innate/zombie/parkour/Activate()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_BUMP, .proc/Parkour)

/datum/action/innate/zombie/parkour/process()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	var/max_obstacles = (zombie_owner.zombie_mutations["leg_response"]) ? 10 : 5
	if(obstacles_jumped == max_obstacles)
		Deactivate()

/datum/action/innate/zombie/parkour/proc/Parkour(mob/user, atom/affected)
	var/list/bumpable_atoms = list(/obj/structure/table, /obj/structure/barricade, /obj/structure/destructible/cult, /obj/structure/altar_of_gods)
	if(is_type_in_list(affected, bumpable_atoms))
		user.emote("flip")
		user.forceMove(get_turf(affected))
		obstacles_jumped++

/datum/action/innate/zombie/parkour/Deactivate()
	. = ..()
	obstacles_jumped = 0
	UnregisterSignal(owner, COMSIG_MOVABLE_BUMP)

/////////////////\\\\\\\\\\\\\\
////						\\\\
////  PURCHASABLE ABILITIES \\\\
////						\\\\
////\\\\\\\\\\\\///////////\\\\

/datum/action/innate/zombie/pickpocket
	name = "Pickpocket"
	desc = "Gain increased neuron and muscle communication, allowing for you to slowly strip pockets and slap away peoples items from their hands."
	button_icon_state = "pickpocket"
	ability_type = ZOMBIE_TOGGLEABLE
	cooldown = 20 SECONDS

/datum/action/innate/zombie/pickpocket/process()
	var/people_pocketed = 0
	if(people_pocketed == 5)
		Deactivate()
	for(var/mob/living/carbon/C in view(1, owner))
		if(C == owner)
			continue
		if(INTERACTING_WITH(owner, C))
			continue
		C.dropItemToGround(C.get_active_held_item())
		people_pocketed++
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(!do_after(owner, 2.5 SECONDS, H))
				continue
			var/obj/item/pocket_item = H.r_store || H.l_store
			H.dropItemToGround(pocket_item)
