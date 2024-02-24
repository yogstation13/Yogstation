
/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	item_state = "fingerless"
	transfer_prints = TRUE
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	custom_price = 10
	undyeable = TRUE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 0)
	var/tacticalspeed = 0.9
	var/worn

/obj/item/clothing/gloves/fingerless/equipped(mob/user, slot)
	..()
	var/mob/living/carbon/human/boss = user
	if(slot == ITEM_SLOT_GLOVES)
		if(!worn) //Literally just in case there's some weirdness so you can't cheese this
			boss.physiology.do_after_speed *= tacticalspeed //Does channels 10% faster
			worn = TRUE

/obj/item/clothing/gloves/fingerless/dropped(mob/user)
	..()
	var/mob/living/carbon/human/boss = user
	if(worn) //This way your speed isn't slowed if you never actually put on the gloves
		boss.physiology.do_after_speed /= tacticalspeed
		worn = FALSE

/obj/item/clothing/gloves/fingerless/bigboss
	tacticalspeed = 0.66 //Does channels 34% faster
	clothing_traits = list(TRAIT_QUICKER_CARRY, TRAIT_STRONG_GRIP)

/obj/item/clothing/gloves/fingerless/bigboss/Touch(mob/living/target, proximity = TRUE)
	var/mob/living/M = loc
	M.changeNext_move(CLICK_CD_CLICK_ABILITY) //0.6 seconds instead of 0.8, but affects any intent instead of just harm
	. = FALSE

/obj/item/clothing/gloves/fingerless/weaver
	name = "weaver chitin gloves"
	desc = "Grey gloves without fingertips made from the hide of a dead arachnid found on lavaland. Increases the work speed of the wearer."
	icon_state = "weaver_chitin"
	item_state = "weaver_chitin"
	tacticalspeed = 0.8

/obj/item/clothing/gloves/botanic_leather
	name = "botanist's leather gloves"
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin.  They're also quite warm."
	icon_state = "leather"
	item_state = "ggloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 5, RAD = 0, FIRE = 70, ACID = 30)

/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and shock resistant."
	icon_state = "black"
	item_state = "blackgloves"
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 60, RAD = 0, FIRE = 80, ACID = 50, ELECTRIC = 100)

/obj/item/clothing/gloves/bracer
	name = "bone bracers"
	desc = "For when you're expecting to get slapped on the wrist. Offers modest protection to your arms."
	icon_state = "bracers"
	item_state = "bracers"
	transfer_prints = TRUE
	strip_delay = 40
	equip_delay_other = 20
	body_parts_covered = ARMS
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 15, BULLET = 25, LASER = 15, ENERGY = 15, BOMB = 20, BIO = 10, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 0)

/obj/item/clothing/gloves/rapid
	name = "Gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	icon_state = "rapid"
	item_state = "rapid"
	transfer_prints = TRUE
	var/warcry = "AT"

/obj/item/clothing/gloves/rapid/Touch(mob/living/target,proximity = TRUE)
	var/mob/living/M = loc

	if(M.a_intent == INTENT_HARM)
		M.changeNext_move(CLICK_CD_RAPID)
		if(warcry)
			M.say("[warcry]", ignore_spam = TRUE, forced = "north star warcry")
	.= FALSE

/obj/item/clothing/gloves/rapid/attack_self(mob/user)
	var/input = stripped_input(user,"What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
	input = replacetext(input, "*", "")
	if(input)
		warcry = input

/obj/item/clothing/gloves/rapid/hug
	name = "Gloves of Hugging"
	desc = "Just looking at these fills you with an urge to hug the shit out of people."

/obj/item/clothing/gloves/rapid/hug/Touch(mob/living/target,proximity = TRUE)
	var/mob/living/M = loc

	if(M.a_intent == INTENT_HELP)
		M.changeNext_move(CLICK_CD_RAPID)
	else
		to_chat(M, span_warning("You don't want to hurt anyone, just give them hugs!"))
		M.a_intent = INTENT_HELP
	.= FALSE

/obj/item/clothing/gloves/bracer/cuffs
	name = "rabid cuffs"
	desc = "Wristbands fashioned after one of the hungriest slaughter demons. Wearing these invokes a hunger in the wearer that can only be sated by bloodshed."
	icon_state = "cuff"
	item_state = "cuff"
	var/datum/action/cooldown/swipe/swipe_ability
	alternate_worn_layer = ABOVE_BODY_FRONT_LAYER

/obj/item/clothing/gloves/bracer/cuffs/Initialize(mapload)
	. = ..()
	swipe_ability = new(swipe_ability)

/obj/item/clothing/gloves/bracer/cuffs/equipped(mob/living/user, slot)
	. = ..()
	if(ishuman(user) && (slot & ITEM_SLOT_GLOVES))
		swipe_ability.Grant(user)

/obj/item/clothing/gloves/bracer/cuffs/dropped(mob/living/user)
	. = ..()
	swipe_ability?.Remove(user)

/datum/action/cooldown/swipe //you stupid
	name = "Swipe"
	desc = "Swipe at a target area, dealing damage to heal yourself. \
		Creatures take 60 damage while people and cyborgs take 20 damage. \
		Living creatures hit with this ability will heal the user for 13 brute/burn/poison while dead ones heal for 20 and get butchered, \
		while killing a creature with a swipe will heal the user for 33. \
		People and cyborgs hit will heal for 5."
	background_icon_state = "bg_demon"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "cuff"
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	click_to_activate = TRUE
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS

	cooldown_time = 10 SECONDS

/datum/action/cooldown/swipe/Remove(mob/living/user)
	unset_click_ability(user)
	return ..()

/datum/action/cooldown/swipe/IsAvailable(feedback = FALSE)
	if(!iscarbon(owner))
		return FALSE
	return ..()

/datum/action/cooldown/swipe/Activate(mob/living/target)
	. = ..()
	var/turf/open/target_turf = get_turf(target)
	var/mob/living/carbon/caller = owner
	if(!istype(target_turf))
		return FALSE
	if(!(target_turf in range(9, owner)))
		to_chat(owner, warning("The target is too far!"))
		return FALSE
	new /obj/effect/temp_visual/bubblegum_hands/rightpaw(target_turf)
	new /obj/effect/temp_visual/bubblegum_hands/rightthumb(target_turf)
	to_chat(target, span_userdanger("Claws reach out from the floor and maul you!"))
	to_chat(owner, "You summon claws at [target]'s location!")
	target.visible_message(span_warning("[owner] rends [target]!"))
	for(target in range(0, target_turf))
		playsound(target_turf, 'sound/magic/demon_attack1.ogg', 80, TRUE, -1)
		if(isanimal(target))
			if(target.stat != DEAD)
				target.adjustBruteLoss(60)
				caller.adjustBruteLoss(-13)
				caller.adjustFireLoss(-13)
				caller.adjustToxLoss(-13)
				if(target.stat == DEAD)
					to_chat(caller, span_notice("You kill [target], healing yourself more!"))
			if(target.stat == DEAD)
				target.gib()
				to_chat(caller, span_notice("You're able to consume the body entirely!"))
				caller.adjustBruteLoss(-20)
				caller.adjustFireLoss(-20)
				caller.adjustToxLoss(-20)
		if(iscarbon(target))
			target.adjustBruteLoss(20)
			caller.adjustBruteLoss(-5)
			caller.adjustFireLoss(-5)
			caller.adjustToxLoss(-5)
	addtimer(CALLBACK(src, PROC_REF(cooldown_over), owner), cooldown_time)
	unset_click_ability(owner)
	return TRUE

/datum/action/cooldown/swipe/proc/cooldown_over()
	owner.balloon_alert(owner, "ready to swipe!")

/obj/item/clothing/gloves/gauntlets
	name = "concussive gauntlets"
	desc = "Ancient gauntlets lost to the necropolis, fabled to bestow the wearer the power to shatter stone with but a simple punch."
	icon_state = "concussive_gauntlets"
	item_state = "concussive_gauntlets"
	mob_overlay_icon = 'icons/mob/clothing/hands/hands.dmi'
	icon = 'icons/obj/lavaland/artefacts.dmi'
	toolspeed = 0
	strip_delay = 40
	equip_delay_other = 20
	body_parts_covered = ARMS
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = LAVA_PROOF | FIRE_PROOF //they are from lavaland after all
	armor = list(MELEE = 25, BULLET = 25, LASER = 15, ENERGY = 25, BOMB = 100, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)

/obj/item/clothing/gloves/gauntlets/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		tool_behaviour = TOOL_MINING
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(rocksmash))
		RegisterSignal(user, COMSIG_MOVABLE_BUMP, PROC_REF(rocksmash))
	else
		stopmining(user)

/obj/item/clothing/gloves/gauntlets/dropped(mob/user)
	. = ..()
	stopmining(user)

/obj/item/clothing/gloves/gauntlets/proc/stopmining(mob/user)
	tool_behaviour = initial(tool_behaviour)
	UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	UnregisterSignal(user, COMSIG_MOVABLE_BUMP)

/obj/item/clothing/gloves/gauntlets/proc/rocksmash(mob/user, atom/A, proximity)
	if(!istype(A, /turf/closed/mineral))
		return
	A.attackby(src, user)
	return COMPONENT_NO_ATTACK_OBJ

/obj/item/clothing/gloves/atmos
	name = "firefighter gloves"
	desc = "Heavy duty gloves for firefighters. These are thick, non-flammable and let you carry people faster."
	icon_state = "atmos"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 90, RAD = 0, FIRE = 100, ACID = 90, ELECTRIC = 80)
	clothing_flags = THICKMATERIAL
	clothing_traits = list(TRAIT_QUICKEST_CARRY, TRAIT_RESISTHEATHANDS)

/obj/item/clothing/gloves/atmos/ce
	name = "advanced insulated gloves"
	desc = "These gloves provide excellent thermal and electrical insulation."
	icon_state = "ce_insuls"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 90, RAD = 0, FIRE = 100, ACID = 90, ELECTRIC = 100)
