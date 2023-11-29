/obj/item/living_heart
	name = "living heart"
	desc = "Link to the worlds beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "living_heart"
	w_class = WEIGHT_CLASS_SMALL
	///Target
	var/mob/living/carbon/human/target

/obj/item/living_heart/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += span_notice("This heart is currently set to target <b>[target.real_name]</b>.")

/obj/item/living_heart/attack_self(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	if(!target)
		to_chat(user,span_warning("No target could be found. Put the living heart on the rune and use the rune to receive a target."))
		return
	var/turf/userturf = get_turf(user)
	var/turf/targetturf = get_turf(target)
	var/dist = get_dist(userturf,targetturf)
	var/dir = get_dir(userturf,targetturf)
	var/crowd = 0
	var/crowd_text = ""
	for(var/mob/living/L in view(7, target))
		if(L == user)
			continue
		if(L == target)
			continue
		if(!L.client)
			continue
		crowd++
	switch(crowd)
		if(0)
			crowd_text = "</span> <span class='boldnotice'>They are alone!"
		if(1 to 2)
			crowd_text = " They are not alone..."
		if(3 to INFINITY)
			crowd_text = "</span> <span class='boldwarning'>They are surrounded by people."

	if(userturf.z != targetturf.z)
		to_chat(user,span_warning("[target.real_name] is ... vertical to you?"))
	else
		switch(dist)
			if(0 to 15)
				to_chat(user,span_warning("[target.real_name] is near you. They are to the [dir2text(dir)] of you![crowd_text]"))
			if(16 to 31)
				to_chat(user,span_warning("[target.real_name] is somewhere in your vicinty. They are to the [dir2text(dir)] of you![crowd_text]"))
			if(32 to 127)
				to_chat(user,span_warning("[target.real_name] is far away from you. They are to the [dir2text(dir)] of you![crowd_text]"))
			else
				to_chat(user,span_warning("[target.real_name] is beyond our reach."))

	if(target.stat == DEAD)
		to_chat(user,span_warning("[target.real_name] is dead. Bring them to a transmutation rune!"))

/datum/action/innate/heretic_shatter
	name = "Shattering Offer"
	desc = "Smash your blade to release the entropic energies within it, teleporting you out of danger."
	background_icon_state = "bg_heretic"
	button_icon_state = "shatter"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	check_flags = AB_CHECK_HANDS_BLOCKED| AB_CHECK_IMMOBILE
	var/mob/living/carbon/human/holder
	var/obj/item/melee/sickly_blade/sword

/datum/action/innate/heretic_shatter/Grant(mob/user, obj/object)
	sword = object
	holder = user
	//i know what im doing
	return ..()

/datum/action/innate/heretic_shatter/IsAvailable(feedback = FALSE)
	if(IS_HERETIC(holder) || IS_HERETIC_MONSTER(holder))
		return TRUE
	else
		return FALSE

/datum/action/innate/heretic_shatter/Activate()
	to_chat(holder, span_warning("You raise \the [sword] in careful preparation to smash it..."))
	if(!do_after(holder, 2 SECONDS, sword))
		return
	var/turf/safe_turf = find_safe_turf(zlevels = sword.z, extended_safety_checks = TRUE)
	holder.visible_message("<span class ='boldwarning'>Light bends around [holder] as they smash [sword], and in a moment they are gone.</span>", span_notice("You feel yourself begin to descend as [sword] breaks, before the darkness suddenly receeds and you find yourself somewhere else."))
	playsound(holder, "shatter", 70, pressure_affected = FALSE)
	playsound(holder, "forcewall", 70, pressure_affected = FALSE)
	flash_color(holder, flash_color = "#000000", flash_time = 10)
	do_teleport(holder,safe_turf,forceMove = TRUE)
	qdel(sword)

/obj/item/melee/sickly_blade
	name = "sickly blade"
	desc = "A sickly, green crescent blade, decorated with an ornamental eye. You feel like you're being watched..."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldritch_blade"
	item_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_NORMAL
	force = 20
	armour_penetration = 25
	throwforce = 10
	wound_bonus = -5
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	var/datum/action/innate/heretic_shatter/linked_action

/obj/item/melee/sickly_blade/Initialize(mapload)
	. = ..()
	linked_action = new(src)

/obj/item/melee/sickly_blade/pickup(mob/user)
	. = ..()
	linked_action.Grant(user, src)

/obj/item/melee/sickly_blade/dropped(mob/user, silent)
	. = ..()
	linked_action.Remove(user, src)

/obj/item/melee/sickly_blade/attack(mob/living/M, mob/living/user)
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user,span_danger("You feel a pulse of some alien intellect lash out at your mind!"))
		var/mob/living/carbon/human/human_user = user
		human_user.AdjustParalyzed(5 SECONDS)
		return FALSE
	return ..()

/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie || !proximity_flag || target == user)
		return
	var/list/knowledge = cultie.get_all_knowledge()
	for(var/X in knowledge)
		var/datum/eldritch_knowledge/eldritch_knowledge_datum = knowledge[X]
		eldritch_knowledge_datum.on_eldritch_blade(target,user,proximity_flag,click_parameters)

/obj/item/melee/sickly_blade/rust
	name = "rusted blade"
	desc = "This crescent blade is decrepit, wasting to dust. Yet still it bites, catching flesh with jagged, rotten teeth. A strange liquid oozes from its points."
	icon_state = "rust_blade"
	item_state = "rust_blade"

/obj/item/melee/sickly_blade/ash
	name = "ashen blade"
	desc = "A hunk of molten metal warped to cinders and slag. Unmade and remade countless times over, it aspires to be more than it is as it shears soot-filled wounds."
	icon_state = "ash_blade"
	item_state = "ash_blade"

/obj/item/melee/sickly_blade/flesh
	name = "flesh blade"
	desc = "A blade of strange material born from a fleshwarped creature. Keenly aware, it seeks to spread the excruciating pain it has endured from dread origins."
	icon_state = "flesh_blade"
	item_state = "flesh_blade"

/obj/item/melee/sickly_blade/mind
	name = "mind blade"
	desc = "A monsterously sharp blade made from pure knowledge and paper. Endlessly it searches to quench it's thirst, often eviserating the user in the process."
	icon_state = "mind_blade"
	item_state = "mind_blade"

/obj/item/melee/sickly_blade/void
	name = "void blade"
	desc = "A monsterously sharp blade made from pure ice. Sharp and acute it's unbreaking edges can rip and tear through bone and sinew with ease."
	icon_state = "void_blade"
	item_state = "void_blade"

/obj/item/melee/sickly_blade/dark
	name = "sundered blade"
	desc = "A silver blade made to cut any and all who get in it's path."
	icon_state = "dark_blade"
	item_state = "dark_blade"

/obj/item/melee/sickly_blade/bone
	name = "bone blade"
	desc = "A broken bloody bone, it'll get the job done."
	icon_state = "bone_blade"
	item_state = "bone_blade"
	force = 5
	armour_penetration = 10
	throwforce = 5
	block_chance = 10

/obj/item/melee/sickly_blade/cosmic
	name = "cosmic blade"
	desc = "A piece of the cosmos, shaped like a weapon for you to wield."
	icon_state = "cosmic_blade"
	item_state = "cosmic_blade"

/obj/item/melee/sickly_blade/dark/attack(mob/living/M, mob/living/user, secondattack = FALSE)
	. = ..()
	var/obj/item/mantis/blade/secondsword = user.get_inactive_held_item()
	if(istype(secondsword, /obj/item/melee/sickly_blade/bone) && !secondattack)
		sleep(0.2 SECONDS)
		secondsword.attack(M, user, TRUE)
		user.changeNext_move(CLICK_CD_MELEE)
	return

/obj/item/melee/sickly_blade/knock
	name = "key blade"
	desc = "A blade in the shape of a key, what door will you unlock with it?"
	icon_state = "knock_blade"
	item_state = "knock_blade"

/obj/item/clothing/neck/eldritch_amulet
	name = "warm eldritch medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulse of a thousand others."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF
	///What trait do we want to add upon equipiing
	var/trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/living/user, slot)
	..()
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user, span_cultlarge("\"The amulet burns at the touch, searing the skin off your hand!\""))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(8 SECONDS)
		user.adjustFireLoss(15)

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	..()
	if(user.mind && (IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		attach_clothing_traits(trait)
		user.update_sight()
	else if(trait in clothing_traits)
		detach_clothing_traits(trait)
		user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	..()
	detach_clothing_traits(trait)
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "piercing eldritch medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into improbable shapes."
	trait = TRAIT_XRAY_VISION

/obj/item/clothing/neck/eldritch_amulet/piercing/equipped(mob/living/user, slot)
	..()
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user, span_cultlarge("\"The amulet burns at the touch, searing the skin off your hand!\""))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(8 SECONDS)
		user.adjustFireLoss(15)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	desc = "A torn, dust-caked hood. You feel it watching you."
	icon_state = "eldritch"
	item_state = "eldritch"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flash_protect = 2
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	item_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 25, BIO = 20, RAD = 0, FIRE = 20, ACID = 20) //Consider yourself reduced, bitch
	resistance_flags = FIRE_PROOF // ash heretic go brrr

/obj/item/clothing/suit/hooded/cultrobes/eldritch/equipped(mob/living/user, slot)
	..()
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user, span_cultlarge("\"You feel the weight of your sins pulling you down!\""))
		user.dropItemToGround(src, TRUE)
		user.adjust_confusion(30)
		user.Paralyze(8 SECONDS)
		user.adjustBruteLoss(15)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/upgraded
	name = "garnished ominous armor"
	desc = "An evolved robe, surging with eldritch power. Strange eyes line the inside."
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 25, BIO = 20, RAD = 0, FIRE = 20, ACID = 20) //now it has a reason to be strong
	slowdown = 0.20

/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Anathema to the close-minded. Ambrosia to those blessed by the Mansus."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldrich_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)

/obj/item/clothing/glasses/hud/toggle/eldritch_eye
	name = "An ancient eye of a forgotten god"
	desc = "Allows the user to swap between three hud types, science, medical, and diagnostic"
	icon_state = "godeye"
	item_state = "godeye"
	// Blue, light blue
	color_cutoffs = list(15, 30, 40)
	hud_type = DATA_HUD_SECURITY_BASIC

/obj/item/clothing/glasses/hud/toggle/eldritch_eye/equipped(mob/living/user, slot)
	..()
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user, span_cultlarge("\"The eye stares back into your soul, branding you for your sin!\""))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(8 SECONDS)
		user.blind_eyes(10 SECONDS)

/obj/item/clothing/glasses/hud/toggle/eldritch_eye/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(ishuman(user) && slot == ITEM_SLOT_EYES)
		ADD_TRAIT(src, TRAIT_NODROP, EYE_OF_GOD_TRAIT)

/obj/item/clothing/glasses/hud/toggle/eldritch_eye/attack_self(mob/user)
	..()
	switch (hud_type)
		if (DATA_HUD_MEDICAL_BASIC)
			icon_state = "godeye"
		if (DATA_HUD_SECURITY_BASIC)
			icon_state = "godeye"
		if (DATA_HUD_DIAGNOSTIC_BASIC)
			icon_state = "godeye"
		else
			icon_state = "godeye"
	user.update_inv_glasses()

/obj/item/clothing/suit/cultrobes/void
	name = "ominous cloak"
	desc = "A ragged, dusty cloak. Strange eyes line the inside."
	icon_state = "void_cloak"
	item_state = "void_cloak"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 20, ACID = 20) //interesting? Maybe?
	resistance_flags = FIRE_PROOF

	/// The mob currently wearing this
	var/mob/current_user
	/// How much the user is cloaked as a percentage, which effects the wearer's transparency and dodge chance (dont edit this)
	var/cloak = 0
	/// What cloak is capped to
	var/max_cloak = 75
	/// How much the cloak charges per process
	var/cloak_charge_rate = 20
	/// How much the cloak decreases when moving
	var/cloak_move_loss = 5
	/// How much the cloak decreases on a successful dodge
	var/cloak_dodge_loss = 40

/obj/item/clothing/suit/cultrobes/void/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(on_unequip))

/obj/item/clothing/suit/cultrobes/void/equipped(mob/user, slot)
	. = ..()
	update_signals()

/obj/item/clothing/suit/cultrobes/void/dropped(mob/user)
	. = ..()
	update_signals()

/obj/item/clothing/suit/cultrobes/void/proc/on_unequip(force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	current_user = null
	update_signals()

/obj/item/clothing/suit/cultrobes/void/Destroy()
	set_cloak(0)
	. = ..()

/obj/item/clothing/suit/cultrobes/void/proc/update_signals(user)
	if((!user || (current_user == user)) && current_user == loc && istype(current_user) && current_user.get_item_by_slot(ITEM_SLOT_OCLOTHING) == src)
		return TRUE

	set_cloak(0)
	UnregisterSignal(current_user, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_BULLET_ACT))
	if(user)
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_BULLET_ACT))

	var/mob/new_user = loc
	if(istype(new_user) && new_user.get_item_by_slot(ITEM_SLOT_OCLOTHING) == src)
		current_user = new_user
		RegisterSignal(current_user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
		RegisterSignal(current_user, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_projectile_hit))
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/cultrobes/void/proc/set_cloak(ammount)
	cloak = clamp(ammount, 0, max_cloak)
	var/mob/user = loc
	if(istype(user))
		animate(user, alpha = round(clamp(255 * (1 - (cloak * 0.01)), 0, 255)), time = 0.5 SECONDS)

/obj/item/clothing/suit/cultrobes/void/process(delta_time)
	if(!update_signals())
		return
	var/mob/user = loc
	if(!istype(user) || !user.get_item_by_slot(ITEM_SLOT_OCLOTHING) == src)

		return
	set_cloak(cloak + (cloak_charge_rate * delta_time))

/obj/item/clothing/suit/cultrobes/void/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!isprojectile(hitby) && dodge(owner, hitby, attack_text))
		return TRUE
	return ..()

/obj/item/clothing/suit/cultrobes/void/proc/on_move(mob/user, Dir, Forced = FALSE)
	if(update_signals(user))
		set_cloak(cloak - cloak_move_loss)

/obj/item/clothing/suit/cultrobes/void/proc/on_projectile_hit(mob/living/carbon/human/user, obj/projectile/P, def_zone)
	SIGNAL_HANDLER
	if(dodge(user, P, "[P]"))
		return BULLET_ACT_FORCE_PIERCE

/obj/item/clothing/suit/cultrobes/void/proc/dodge(mob/living/carbon/human/user, atom/movable/hitby, attack_text)
	if(!update_signals(user) || current_user.incapacitated() || !prob(cloak))
		return FALSE

	set_cloak(cloak - cloak_dodge_loss)
	current_user.balloon_alert_to_viewers("Dodged!", "Dodged!", COMBAT_MESSAGE_RANGE)
	current_user.visible_message(span_danger("[current_user] dodges [attack_text]!"), span_userdanger("You dodge [attack_text]"), null, COMBAT_MESSAGE_RANGE)
	return TRUE


/obj/item/clothing/suit/cultrobes/void/equipped(mob/living/user, slot)
	..()
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user, span_cultlarge("\"You feel your bones begin to freeze to their very core!\""))
		user.dropItemToGround(src, TRUE)
		user.adjust_confusion(30)
		user.Paralyze(8 SECONDS)
		user.adjustFireLoss(10)

/obj/item/clothing/mask/madness_mask
	name = "Abyssal Mask"
	desc = "A mask created from the suffering of existence. Looking down it's eyes, you notice something gazing back at you."
	icon_state = "mad_mask"
	item_state = "mad_mask"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	resistance_flags = FLAMMABLE
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	///Who is wearing this
	var/mob/living/carbon/human/local_user

/obj/item/clothing/mask/madness_mask/Destroy()
	local_user = null
	return ..()

/obj/item/clothing/mask/madness_mask/examine(mob/user)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		. += span_notice("Actively drains the sanity and stamina of nearby non-heretics when worn.")
	else
		. += span_danger("The eyes fill you with dread... You best avoid it.")

/obj/item/clothing/mask/madness_mask/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_MASK))
		return
	if(!ishuman(user) || !user.mind)
		return

	local_user = user
	START_PROCESSING(SSobj, src)

	if(IS_HERETIC_OR_MONSTER(user))
		return

/obj/item/clothing/mask/madness_mask/dropped(mob/M)
	local_user = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/mask/madness_mask/process(seconds_per_tick)
	if(!local_user)
		return PROCESS_KILL

	for(var/mob/living/carbon/human/human_in_range in view(local_user))
		if(IS_HERETIC_OR_MONSTER(human_in_range) || is_blind(human_in_range))
			continue

		if(DT_PROB(60, seconds_per_tick))
			human_in_range.adjust_hallucinations_up_to(10 SECONDS, 240 SECONDS)

		if(DT_PROB(40, seconds_per_tick))
			human_in_range.set_jitter_if_lower(10 SECONDS)

		if(human_in_range.getStaminaLoss() <= 85 && DT_PROB(30, seconds_per_tick))
			human_in_range.emote(pick("giggle", "laugh"))
			human_in_range.adjustStaminaLoss(10)

		if(DT_PROB(25, seconds_per_tick))
			human_in_range.set_dizzy_if_lower(10 SECONDS)

/obj/item/sharpener/eldritch
	name = "Master's Whetstone"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "cult_sharpener"
	desc = "An ancient block of metal from the abyss."
	force = 5
	increment = 4
	max = 30
	prefix = "abyss-sharpened"
	requires_sharpness = 1
