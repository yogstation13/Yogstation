
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

/obj/item/clothing/gloves/botanic_leather
	name = "botanist's leather gloves"
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin.  They're also quite warm."
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 70, ACID = 30)

/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and shock resistant."
	icon_state = "black"
	item_state = "blackgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 50)

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
	armor = list(MELEE = 15, BULLET = 25, LASER = 15, ENERGY = 15, BOMB = 20, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

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
	var/obj/effect/proc_holder/swipe/swipe_ability
	alternate_worn_layer = ABOVE_BODY_FRONT_LAYER

/obj/item/clothing/gloves/bracer/cuffs/Initialize()
	. = ..()
	swipe_ability = new(swipe_ability)

/obj/item/clothing/gloves/bracer/cuffs/equipped(mob/living/user, slot)
	. = ..()
	if(ishuman(user) && slot == ITEM_SLOT_GLOVES)
		user.AddAbility(swipe_ability)

/obj/item/clothing/gloves/bracer/cuffs/dropped(mob/living/user)
	. = ..()
	user.RemoveAbility(swipe_ability)

obj/effect/proc_holder/swipe
	name = "Swipe"
	desc = "Swipe at a target area, dealing damage to heal yourself. Creatures take 60 damage while people and cyborgs take 20 damage. Living creatures hit with this ability will heal the user for 13 brute/burn/poison while dead ones heal for 20 and get butchered, while killing a creature with a swipe will heal the user for 33. People and cyborgs hit will heal for 5."
	action_background_icon_state = "bg_demon"
	action_icon = 'icons/mob/actions/actions_items.dmi'
	action_icon_state = "cuff"
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	var/cooldown = 10 SECONDS
	COOLDOWN_DECLARE(scan_cooldown)

/obj/effect/proc_holder/swipe/on_lose(mob/living/user)
	remove_ranged_ability()
	
/obj/effect/proc_holder/swipe/Click(location, control, params)
	. = ..()
	if(!isliving(usr))
		return TRUE
	var/mob/living/user = usr
	fire(user)

/obj/effect/proc_holder/swipe/fire(mob/living/carbon/user)
	if(active)
		remove_ranged_ability(span_notice("You relax your arms."))
	else
		add_ranged_ability(user, span_notice("You ready your cuffs. <B>Left-click a creature or nearby location to swipe at it!</B>"), TRUE)

/obj/effect/proc_holder/swipe/InterceptClickOn(mob/living/caller, params, atom/target)
	. = ..()
	var/turf/open/T = get_turf(target)
	var/mob/living/L = target
	if(.)
		return
	if(ranged_ability_user.stat)
		remove_ranged_ability()
		return
	if(!COOLDOWN_FINISHED(src, scan_cooldown))
		to_chat(ranged_ability_user, span_warning("Your cuffs aren't ready to do that yet. Give them some time to recharge!"))
		return
	if(!istype(T))
		return
	if(!(T in range(9, caller)))
		to_chat(caller, warning("The target is too far!"))
		return
	new /obj/effect/temp_visual/bubblegum_hands/rightpaw(T)
	new /obj/effect/temp_visual/bubblegum_hands/rightthumb(T)
	to_chat(L, span_userdanger("Claws reach out from the floor and maul you!"))
	to_chat(ranged_ability_user, "You summon claws at [L]'s location!")
	L.visible_message(span_warning("[caller] rends [L]!"))
	for(L in range(0,T))
		playsound(T, 'sound/magic/demon_attack1.ogg', 80, 5, -1)
		if(isanimal(L))
			L.adjustBruteLoss(60)
			if(L.stat != DEAD)
				caller.adjustBruteLoss(-13)
				caller.adjustFireLoss(-13)
				caller.adjustToxLoss(-13)
			if(L.stat == DEAD)
				L.gib()
				to_chat(caller, span_notice("You're able to consume the body entirely!"))
				caller.adjustBruteLoss(-20)
				caller.adjustFireLoss(-20)
				caller.adjustToxLoss(-20)
		if(iscarbon(L))
			L.adjustBruteLoss(20)
			caller.adjustBruteLoss(-5)
			caller.adjustFireLoss(-5)
			caller.adjustToxLoss(-5)
	COOLDOWN_START(src, scan_cooldown, cooldown)
	addtimer(CALLBACK(src, .proc/cooldown_over, ranged_ability_user), cooldown)
	remove_ranged_ability()
	return TRUE

/obj/effect/proc_holder/swipe/proc/cooldown_over()
	to_chat(usr, (span_notice("You're ready to swipe again!")))

/obj/item/clothing/gloves/gauntlets
	name = "concussive gauntlets"
	desc = "Ancient gauntlets lost to the necropolis, fabled to bestow the wearer the power to shatter stone with but a simple punch."
	icon_state = "concussive_gauntlets"
	item_state = "concussive_gauntlets"
	mob_overlay_icon = 'icons/mob/clothing/hands/hands.dmi'
	icon = 'icons/obj/lavaland/artefacts.dmi'
	toolspeed = 0.01
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
	if(slot == SLOT_GLOVES)
		tool_behaviour = TOOL_MINING
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/rocksmash)
		RegisterSignal(user, COMSIG_MOVABLE_BUMP, .proc/rocksmash)
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
