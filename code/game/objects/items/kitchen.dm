/* Kitchen tools
 * Contains:
 *		Fork
 *		Kitchen knives
 *		Ritual Knife
 *		Holy Ritual Knife
 *		Bloodletter
 *		Butcher's cleaver
 *		Combat Knife
 *		Rolling Pins
 *		Shank
 *		Makeshift knives
 */

/obj/item/kitchen
	icon = 'yogstation/icons/obj/kitchen.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'

/obj/item/kitchen/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	force = 4
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	materials = list(/datum/material/iron=80)
	flags_1 = CONDUCT_1
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	sharpness = SHARP_POINTY
	var/datum/reagent/forkload //used to eat omelette
	var/loaded_food = "nothing" /// The name of the thing on the fork

/obj/item/kitchen/fork/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] stabs \the [src] into [user.p_their()] chest! It looks like [user.p_theyre()] trying to take a bite out of [user.p_them()]self!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, 1)
	return BRUTELOSS

/obj/item/kitchen/fork/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	var/mob/living/carbon/human/H = M // For use in a later if, placed here so it can be used in the else-if chain

	if(forkload)
		if(M == user)
			M.visible_message(span_notice("[user] eats a delicious forkful of [loaded_food]!"))
			M.reagents.add_reagent(forkload.type, 1)
		else
			M.visible_message(span_notice("[user] is trying to feed [M] a delicious forkful of [loaded_food]!")) //yogs start
			if(!do_mob(user, M))
				return
			log_combat(user, M, "fed [loaded_food]", forkload.type) //yogs end
			M.visible_message(span_notice("[user] feeds [M] a delicious forkful of [loaded_food]!"))
			M.reagents.add_reagent(forkload.type, 1)
		icon_state = "fork"
		forkload = null
		loaded_food = "nothing"
	else if(user.zone_selected == BODY_ZONE_HEAD && M == user && ishuman(M) && H.creamed)
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
			return eyestab(M,user)
		icon_state = "forkloaded_pie"
		user.visible_message("[user] scoops up the pie with [user.p_their()] fork!", \
			span_notice("You scoop up the pie with your fork."))

		var/datum/reagent/R = new /datum/reagent/consumable/banana
		forkload = R
		loaded_food = "pie"

		H.wash_cream()
	else if(user.zone_selected == BODY_ZONE_PRECISE_EYES)
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
			M = user
		return eyestab(M,user)
	else
		return ..()


/obj/item/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	item_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 6
	materials = list(/datum/material/iron=12000)
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharpness = SHARP_EDGED
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	var/bayonet = TRUE	//Can this be attached to a gun?
	custom_price = 30
	wound_bonus = 5
	bare_wound_bonus = 15

/obj/item/kitchen/knife/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 80 - force, 100, force - 10) //bonus chance increases depending on force

/obj/item/kitchen/knife/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!(user.a_intent == INTENT_HARM) && attempt_initiate_surgery(src, M, user))
		return
	else if(user.zone_selected == BODY_ZONE_PRECISE_EYES)
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
			M = user
		return eyestab(M,user)
	else
		return ..()

/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick(span_suicide("[user] is slitting [user.p_their()] wrists with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
						span_suicide("[user] is slitting [user.p_their()] throat with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
						span_suicide("[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.")))
	return BRUTELOSS

/obj/item/kitchen/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/ritual/holy
	name = "ruinous knife" 
	desc = "The runes inscribed on the knife radiate a strange power. It looks like it could have more runes inscribed upon it..."

/obj/item/kitchen/knife/ritual/holy/strong
	name = "great ruinous knife" 
	desc = "A heavy knife inscribed with dozens of runes."
	force = 15

/obj/item/kitchen/knife/ritual/holy/strong/blood
	name = "blood-soaked ruinous knife" 
	desc = "Runes stretch across the surface of the knife, seemingly endless."
	wound_bonus = 20 //a bit better than a butcher cleaver, you've earned it for finding blood cult metal and doing the previous steps

/obj/item/kitchen/knife/ritual/holy/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 70, 110) //the old gods demandeth more flesh output

/obj/item/kitchen/knife/bloodletter
	name = "bloodletter"
	desc = "An occult looking dagger that is cold to the touch. Somehow, the flawless orb on the pommel is made entirely of liquid blood."
	icon = 'icons/obj/ice_moon/artifacts.dmi'
	icon_state = "bloodletter"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/bloodletter/attack(mob/living/M, mob/living/carbon/user)
	. =..()
	if(istype(M) && (M.mob_biotypes & MOB_ORGANIC))
		var/datum/status_effect/saw_bleed/bloodletting/B = M.has_status_effect(/datum/status_effect/saw_bleed/bloodletting)
		if(!B)
			M.apply_status_effect(STATUS_EFFECT_BLOODLETTING)
		else
			B.add_bleed(B.bleed_buildup)

/obj/item/kitchen/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	item_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown by-products."
	flags_1 = CONDUCT_1
	force = 15
	throwforce = 10
	materials = list(/datum/material/iron=18000)
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = 60
	bayonet = TRUE
	wound_bonus = 15

/obj/item/kitchen/knife/combat
	name = "combat knife"
	icon_state = "buckknife"
	desc = "A military combat utility survival knife."
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 65, "embedded_fall_chance" = 10, "embedded_ignore_throwspeed_threshold" = TRUE)
	force = 20
	throwforce = 20
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")
	bayonet = TRUE
	wound_bonus = 10

/obj/item/kitchen/knife/combat/survival
	name = "survival knife"
	icon_state = "survivalknife"
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 35, "embedded_fall_chance" = 10)
	desc = "A hunting grade survival knife."
	force = 15
	throwforce = 15
	bayonet = TRUE

/obj/item/kitchen/knife/combat/bone
	name = "bone dagger"
	item_state = "bone_dagger"
	icon_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A sharpened bone. The bare minimum in survival."
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 35, "embedded_fall_chance" = 10)
	force = 15
	throwforce = 15
	materials = list()
	bayonet = TRUE

/obj/item/kitchen/knife/combat/cyborg
	name = "cyborg knife"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."

/obj/item/kitchen/knife/carrotshiv
	name = "carrot shiv"
	icon_state = "carrotshiv"
	item_state = "carrotshiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	force = 8
	throwforce = 12//fuck git
	max_integrity = 100
	weapon_stats = list(SWING_SPEED = 0.8, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 5, DAMAGE_HIGH = 7)
	break_message = "%SRC snaps into unusable carrot-bits"
	materials = list()
	attack_verb = list("shanked", "shivved")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/kitchen/knife/carrotshiv/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] forcefully drives \the [src] into [user.p_their()] eye! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

// Shank - Makeshift weapon that can embed on throw
/obj/item/kitchen/knife/shank
	name = "shank"
	desc = "A crude knife fashioned by securing a glass shard and a rod together with cables, and welding them together."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "shank"
	item_state = "shank"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 6
	throwforce = 8
	throw_speed = 5 //yeets
	armour_penetration = 5
	max_integrity = 100
	weapon_stats = list(SWING_SPEED = 0.8, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 5, DAMAGE_HIGH = 7)
	embedding = list("embedded_pain_multiplier" = 3, "embed_chance" = 20, "embedded_fall_chance" = 10) // Incentive to disengage/stop chasing when stuck
	attack_verb = list("stuck", "shanked", "stabbed", "shivved")
	materials = list(/datum/material/iron=1150, /datum/material/glass=2075)

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	custom_price = 20

/obj/item/kitchen/rollingpin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins flattening [user.p_their()] head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS
	
/obj/item/kitchen/knife/makeshift
	name = "makeshift knife"
	icon_state = "knife_makeshift"
	icon = 'icons/obj/improvised.dmi'
	desc = "A flimsy, poorly made replica of a classic cooking utensil."
	force = 8
	throwforce = 8

/obj/item/kitchen/knife/makeshift/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(prob(5))
		to_chat(user, span_danger("[src] crumbles apart in your hands!"))
		qdel(src)
		return

/* Trays  moved to /obj/item/storage/bag */
