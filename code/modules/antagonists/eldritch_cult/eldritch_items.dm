/obj/item/living_heart
	name = "living heart"
	desc = "Link to the worlds beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "living_heart"
	w_class = WEIGHT_CLASS_SMALL
	///Target
	var/mob/living/carbon/human/target

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
	background_icon_state = "bg_ecult"
	button_icon_state = "shatter"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN
	var/mob/living/carbon/human/holder
	var/obj/item/gun/magic/hook/sickly_blade/sword

/datum/action/innate/heretic_shatter/Grant(mob/user, obj/object)
	sword = object
	holder = user
	//i know what im doing
	return ..()

/datum/action/innate/heretic_shatter/IsAvailable()
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

/obj/item/gun/magic/hook/sickly_blade
	name = "sickly blade"
	desc = "A sickly green crescent blade, decorated with an ornamental eye. You feel like you're being watched..."
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
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	var/datum/action/innate/heretic_shatter/linked_action
	/// Hook stuff
	item_flags = NEEDS_PERMIT // doesn't include NOBLUDGEON for obvious reasons
	recharge_rate = 3 // seconds
	ammo_type = /obj/item/ammo_casing/magic/hook/sickly_blade
	fire_sound = 'sound/effects/snap.ogg'

/obj/item/gun/magic/hook/sickly_blade/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, span_warning("The [name] grumbles quietly. It is not yet ready to fire again!"))

/obj/item/ammo_casing/magic/hook/sickly_blade
	projectile_type = /obj/item/projectile/hook/sickly_blade

/obj/item/projectile/hook/sickly_blade
	damage = 0
	knockdown = 0
	immobilize = 2 // there's no escape
	range = 5 // hey now cowboy
	armour_penetration = 0 // no piercing shields
	hitsound = 'sound/effects/gravhit.ogg'

/obj/item/projectile/hook/sickly_blade/on_hit(atom/target, blocked)
	. = ..()
	if(iscarbon(target) && blocked != 100)
		var/mob/living/carbon/C = target
		for(var/obj/item/shield/riot/R in C.get_all_gear())
			R.shatter() // Shield :b:roke
			qdel(R)

/obj/item/gun/magic/hook/sickly_blade/Initialize()
	. = ..()
	linked_action = new(src)

/obj/item/gun/magic/hook/sickly_blade/pickup(mob/user)
	. = ..()
	linked_action.Grant(user, src)

/obj/item/gun/magic/hook/sickly_blade/dropped(mob/user, silent)
	. = ..()
	linked_action.Remove(user, src)

/obj/item/gun/magic/hook/sickly_blade/attack(mob/living/M, mob/living/user)
	if(!(IS_HERETIC(user) || IS_HERETIC_MONSTER(user)))
		to_chat(user,span_danger("You feel a pulse of some alien intellect lash out at your mind!"))
		var/mob/living/carbon/human/human_user = user
		human_user.AdjustParalyzed(5 SECONDS)
		return FALSE
	return ..()

/obj/item/gun/magic/hook/sickly_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie || !proximity_flag || target == user)
		return
	var/list/knowledge = cultie.get_all_knowledge()
	for(var/X in knowledge)
		var/datum/eldritch_knowledge/eldritch_knowledge_datum = knowledge[X]
		eldritch_knowledge_datum.on_eldritch_blade(target,user,proximity_flag,click_parameters)

/obj/item/gun/magic/hook/sickly_blade/rust
	name = "rusted blade"
	desc = "This crescent blade is decrepit, wasting to dust. Yet still it bites, catching flesh with jagged, rotten teeth."
	icon_state = "rust_blade"
	item_state = "rust_blade"

/obj/item/gun/magic/hook/sickly_blade/ash
	name = "ashen blade"
	desc = "Molten and unwrought, a hunk of metal warped to cinders and slag. Unmade, it aspires to be more than it is, and shears soot-filled wounds with a blunt edge."
	icon_state = "ash_blade"
	item_state = "ash_blade"

/obj/item/gun/magic/hook/sickly_blade/flesh
	name = "flesh blade"
	desc = "A crescent blade born from a fleshwarped creature. Keenly aware, it seeks to spread to others the excruciating pain it has endured from dread origins."
	icon_state = "flesh_blade"
	item_state = "flesh_blade"

/obj/item/clothing/neck/eldritch_amulet
	name = "warm eldritch medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulse of a thousand others."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	///What trait do we want to add upon equipiing
	var/trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	..()
	if(ishuman(user) && user.mind && slot == SLOT_NECK && (IS_HERETIC(user) || IS_HERETIC_MONSTER(user)) )
		ADD_TRAIT(user, trait, CLOTHING_TRAIT)
		user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	..()
	REMOVE_TRAIT(user, trait, CLOTHING_TRAIT)
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "piercing eldritch medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into improbable shapes."
	trait = TRAIT_XRAY_VISION

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flash_protect = 2

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	item_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/gun/magic/hook/sickly_blade, /obj/item/forbidden_book)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	// slightly better than normal cult robes
	armor = list(MELEE = 50, BULLET = 50, LASER = 50,ENERGY = 50, BOMB = 35, BIO = 20, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Toxic to the close minded. Healing to those with knowledge of the beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldrich_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)
