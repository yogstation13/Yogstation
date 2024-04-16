// CHAPLAIN CUSTOM ARMORS //
/obj/item/choice_beacon/holy
	name = "armaments beacon"
	desc = "Contains a set of armaments for the chaplain."

/obj/item/choice_beacon/holy/canUseBeacon(mob/living/user)
	if(user.mind && user.mind.holy_role)
		return ..()
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, 1)
		return FALSE

/obj/item/choice_beacon/holy/generate_display_names()
	var/static/list/holy_item_list
	if(!holy_item_list)
		holy_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/holy)
		for(var/V in templist)
			var/atom/A = V
			holy_item_list[initial(A.name)] = A
	return holy_item_list

/obj/item/choice_beacon/holy/spawn_option(obj/choice,mob/living/M)
	if(!GLOB.holy_armor_type)
		..()
		playsound(src, 'sound/effects/pray_chaplain.ogg', 40, 1)
		SSblackbox.record_feedback("tally", "chaplain_armor", 1, "[choice]")
		GLOB.holy_armor_type = choice
	else
		to_chat(M, span_warning("A selection has already been made. Self-Destructing..."))
		return

/obj/item/storage/box/holy
	name = "Templar Kit"

/obj/item/storage/box/holy/PopulateContents()
	new /obj/item/clothing/head/helmet/chaplain(src)
	new /obj/item/clothing/suit/armor/riot/chaplain(src)

/obj/item/clothing/suit/armor/riot/chaplain
	name = "crusader armour"
	desc = "A maintained, full set of plate armor, complete with a tabard. Heavy, but robust."
	icon_state = "knight_templar"
	item_state = "knight_templar"
	armor = list(MELEE = 60, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 40, BIO = 2, RAD = 0, FIRE = 0, ACID = 50) //Medieval armor was exceptional against melee weaponry and shrapnel, as highlighted by breastplate usage during the Napoleonic Wars, but suffered against ballistics
	slowdown = 0.3 //Have you ever worn full plate armor before
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	blocks_shove_knockdown = FALSE

/obj/item/clothing/head/helmet/chaplain
	name = "crusader helmet"
	desc = "A steel helmet that was often worn by religious knights of ages past. Deus Vult!"
	icon_state = "knight_templar"
	item_state = "knight_templar"
	armor = list(MELEE = 45, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 30, BIO = 2, RAD = 0, FIRE = 0, ACID = 50)
	slowdown = 0.05 //See above
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 80
	dog_fashion = null

/obj/item/storage/box/holy/student
	name = "Profane Scholar Kit"

/obj/item/storage/box/holy/student/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/studentuni(src)
	new /obj/item/clothing/head/helmet/chaplain/cage(src)

/obj/item/clothing/suit/armor/riot/chaplain/studentuni
	name = "student robe"
	desc = "The uniform of a bygone institute of learning. These robes whip the user into a speedy fervour at the cost of making them more vulnerable to damage."
	icon_state = "studentuni"
	item_state = "studentuni"
	armor = list(MELEE = -25, BULLET = -15, LASER = -15, ENERGY = -10, BOMB = -10, BIO = -2, RAD = 0, FIRE = 0, ACID = 0) //Speed-inspiring robes
	slowdown = -0.2
	body_parts_covered = ARMS|CHEST

/obj/item/clothing/head/helmet/chaplain/cage
	name = "insightful cage"
	desc = "A cage that restrains the will of the self, allowing one to see the profane world for what it is. The user will be more vulnerable but move slightly faster."
	mob_overlay_icon = 'icons/mob/large-worn-icons/64x64/head.dmi'
	icon_state = "cage"
	item_state = "cage"
	armor = list(MELEE = -15, BULLET = -10, LASER = -10, ENERGY = -5, BOMB = -5, BIO = -2, RAD = 0, FIRE = 0, ACID = 0)
	slowdown = -0.1 //very statistically significant
	flags_inv = null //doesn't actually visibly hide anything
	clothing_flags = LARGE_WORN_ICON
	worn_x_dimension = 64
	worn_y_dimension = 64
	dynamic_hair_suffix = ""

/obj/item/storage/box/holy/sentinel
	name = "Stone Sentinel Kit"

/obj/item/storage/box/holy/sentinel/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/ancient(src)
	new /obj/item/clothing/head/helmet/chaplain/ancient(src)

/obj/item/clothing/suit/armor/riot/chaplain/ancient
	name = "ancient armour"
	desc = "Armor worn by ancient ethereal protectors, covered head to toe in the stone of Borealia's cavernous walls. Tiny holes in the armor permit the light of their skin to peer through."
	icon_state = "knight_ancient"
	item_state = "knight_ancient"
	armor = list(MELEE = 65, BULLET = 20, LASER = 15, ENERGY = 15, BOMB = 20, BIO = 4, RAD = 0, FIRE = 40, ACID = 60) //LITERALLY made of stone; this is BASICALLY miner armor with HARD slowdown
	slowdown = 0.4 //ROCK; full set is slowdown equal to firesuit

/obj/item/clothing/head/helmet/chaplain/ancient
	name = "ancient helmet"
	desc = "A helmet worn by a relict ethereal knight."
	icon_state = "knight_ancient"
	item_state = "knight_ancient"
	armor = list(MELEE = 50, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 15, BIO = 4, RAD = 0, FIRE = 40, ACID = 60)
	slowdown = 0.1 //Pretty sure riot is just strictly better because lmao

/obj/item/storage/box/holy/witchhunter
	name = "Witchhunter Kit"

/obj/item/storage/box/holy/witchhunter/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/witchhunter(src)
	new /obj/item/clothing/head/helmet/chaplain/witchunter_hat(src)

/obj/item/clothing/suit/armor/riot/chaplain/witchhunter
	name = "witch hunter garb"
	desc = "An armored coat sported by the Inquisition, a holy organization that arose in response to humanity's contact with the otherworldly supernatural."
	icon_state = "witchhunter"
	item_state = "witchhunter"
	armor = list(MELEE = 40, BULLET = 10, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 40) //Basically faster Dark Templar but you lose out on a lot of the non-melee armor
	slowdown = 0.1
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/head/helmet/chaplain/witchunter_hat
	name = "witch hunter hat"
	desc = "The hat of a respected inquisitor, layered with protective plating."
	icon_state = "witchhunterhat"
	item_state = "witchhunterhat"
	armor = list(MELEE = 30, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 5, BIO = 0, RAD = 0, FIRE = 0, ACID = 40)
	slowdown = 0
	flags_inv = HIDEEYES
	flags_cover = HEADCOVERSEYES

/obj/item/storage/box/holy/follower
	name = "Followers of the Chaplain Kit"

/obj/item/storage/box/holy/follower/PopulateContents()
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/leader(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)

/obj/item/clothing/suit/hooded/chaplain_hoodie
	name = "follower hoodie"
	desc = "Hoodie made for acolytes of the chaplain."
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant)
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood

/obj/item/clothing/head/hooded/chaplain_hood
	name = "follower hood"
	desc = "Hood made for acolytes of the chaplain."
	icon_state = "chaplain_hood"
	armor = list(MELEE = 5, BULLET = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HEAD //Is this redundant?
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/hooded/chaplain_hoodie/leader
	name = "leader hoodie"
	desc = "Hoodie worn by apocalyptic cult leaders. Bling water not included."
	icon_state = "chaplain_hoodie_leader"
	item_state = "chaplain_hoodie_leader"
	armor = list(MELEE = 25, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 5, BIO = 0, RAD = 0, FIRE = 0, ACID = 25) //I don't know specially layered clothing?
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood/leader

/obj/item/clothing/head/hooded/chaplain_hood/leader
	name = "leader hood"
	desc = "The cowl of a fanatical prodigy."
	icon_state = "chaplain_hood_leader"
	armor = list(MELEE = 15, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 25)

/obj/item/storage/box/holy/darktemplar
	name = "Founder Kit of the Black Templars"

/obj/item/storage/box/holy/darktemplar/PopulateContents()
	new /obj/item/clothing/suit/space/hardsuit/darktemplar(src)
	new /obj/item/clothing/suit/space/hardsuit/darktemplar(src)
	new /obj/item/clothing/suit/space/hardsuit/darktemplar(src)
	new /obj/item/clothing/suit/space/hardsuit/darktemplar/chap(src)

/obj/item/clothing/suit/space/hardsuit/darktemplar
	name = "Black Templar armor"
	desc = "Apprentice-rated power armor developed by the Black Templars, a Confederate militant group that cuts out corruption and treachery without mercy."
	icon_state = "darktemplar-follower0"
	item_state = "darktemplar-follower0"
	cold_protection = null
	min_cold_protection_temperature = null
	heat_protection = null
	max_heat_protection_temperature = null
	clothing_flags = null
	armor = list(MELEE = 25, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 15, BIO = 30, RAD = 30, FIRE = 70, ACID = 50) //Crappier version of the standard armor
	slowdown = 0.25 //No sir you are NOT a space marine you are in CHUNKY power armor
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/darktemplar

/obj/item/clothing/suit/space/hardsuit/darktemplar/chap
	name = "Black Templar chaplain battle armor"
	desc = "A suit of power armor worn by the zealous Black Templars. A fear-inspiring sight for heretics and dissenters."
	icon_state = "darktemplar-chaplain0"
	item_state = "darktemplar-chaplain0"
	armor = list(MELEE = 40, BULLET = 15, LASER = 25, ENERGY = 15, BOMB = 25, BIO = 60, RAD = 40, FIRE = 90, ACID = 80) //Hilariously similar to the goliath cloak but with slowdown because lmao; ultimately made of more advanced, sci-fi materials
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/darktemplar

/obj/item/clothing/head/helmet/space/hardsuit/darktemplar
	name = "Black Templar helmet"
	desc = "A custom-made Black Templar helmet. The words 'Contempt is Armour' and 'Purge Heresy' are written on the side."
	icon_state = "darktemplar-follower1"
	item_state = "darktemplar-follower1"
	armor = list(MELEE = 20, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 30, RAD = 30, FIRE = 70, ACID = 50)
	cold_protection = null
	min_cold_protection_temperature = null
	heat_protection = null
	max_heat_protection_temperature = null
	flash_protect = 0 //We are not giving four mfers free flash protection
	clothing_flags = null
	strip_delay = 50
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/darktemplar/chap
	name = "Black Templar chaplain battle helmet"
	desc = "A custom-made Black Templar chaplain battle helmet. The words 'Excise Corruption' and 'The Razebringer Protects' are written on the side."
	icon_state = "darktemplar-chaplain1"
	item_state = "darktemplar-chaplain1"
	armor = list(MELEE = 30, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 20, BIO = 60, RAD = 40, FIRE = 90, ACID = 80)

/obj/item/storage/box/holy/flagelanteschains
	name = "Flagenantes Kit"

/obj/item/storage/box/holy/flagelanteschains/PopulateContents()
	new /obj/item/clothing/suit/hooded/flagelantes_chains(src)

/obj/item/clothing/suit/hooded/flagelantes_chains
	name = "flagellant's chains"
	desc = "Chains worn by those who wish to purify themselves through pain. They slow the wearer down initialy, but give divine haste the more pain they endure."
	icon_state = "flagelantes_chains"
	item_state = "flagelantes_chains"
	armor = list(MELEE = -15, BULLET = -15, LASER = -15, ENERGY = -15, BOMB = -15, BIO = -15, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	mutantrace_variation = MUTANTRACE_VARIATION //No leg squishing
	resistance_flags = FIRE_PROOF | ACID_PROOF //No turning to ash/mush in the quest for pain
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant)
	hoodtype = /obj/item/clothing/head/hooded/flagelantes_chains_hood
	var/wrap = FALSE
	var/obj/effect/abstract/particle_holder/flagelantes_effect
	var/total_wounds
	var/speed_message = FALSE
	var/footstep = 1
	var/footstep_max = 2

/obj/item/clothing/suit/hooded/flagelantes_chains/equipped(mob/M, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING && iscarbon(M)) //Signals for sensing damage, healing, wounds, and movement
		RegisterSignal(M, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(handle_damage))
		RegisterSignal(M, COMSIG_MOB_APPLY_HEALING, PROC_REF(on_heal))
		RegisterSignal(M, COMSIG_CARBON_GAIN_WOUND, PROC_REF(handle_wound_add))
		RegisterSignal(M, COMSIG_CARBON_LOSE_WOUND, PROC_REF(handle_wound_remove))
		RegisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_move))
	else
		UnregisterSignal(M, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_MOB_APPLY_HEALING, COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_MOVABLE_MOVED))

/obj/item/clothing/suit/hooded/flagelantes_chains/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_MOB_APPLY_HEALING, COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_MOVABLE_MOVED))
	REMOVE_TRAIT(M, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	total_wounds = 0
	slowdown = 0
	if(flagelantes_effect)
		QDEL_NULL(flagelantes_effect)

/obj/item/clothing/suit/hooded/flagelantes_chains/ToggleHood() //So people can't just quickly wear it whenever they want to
	var/mob/living/carbon/human/H = src.loc
	if(wrap) //Make sure they're not already trying to wear it
		to_chat(H, span_warning("You're already wrapping the chains around yourself!."))
		return
	else if(!suittoggled)
		if(H.wear_suit != src)
			to_chat(H, span_warning("You must be wearing [src] to put up the hood!"))
			return
		if(H.head)
			to_chat(H, span_warning("You're already wearing something on your head!"))
			return
		to_chat(H, span_notice("You start wrapping the chains around yourself."))
		H.visible_message(span_warning("[H] starts wrapping [src] around themselves!"))
		playsound(get_turf(src), 'sound/spookoween/chain_rattling.ogg', 10, TRUE, -1)
		wrap = TRUE
		if(!do_after(H, 3 SECONDS, H))
			wrap = FALSE
			H.balloon_alert(H, "You were interupted!")
			return //Stop it from completing if they move
		if(ishuman(src.loc))
			if(H.equip_to_slot_if_possible(hood,ITEM_SLOT_HEAD,0,0,1))
				suittoggled = TRUE
				src.icon_state = "[initial(icon_state)]_t"
				H.update_inv_wear_suit()
				for(var/X in actions)
					var/datum/action/A = X
					A.build_all_button_icons()
				ADD_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, type)// Ignore damage slowdown
				change_slowdown(H, slowdown) //Change clothing slowdown based on damage
		wrap = FALSE			
	else
		RemoveHood()
		REMOVE_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, type)
		total_wounds = 0
		slowdown = 0
		if(flagelantes_effect)
			QDEL_NULL(flagelantes_effect)

/obj/item/clothing/suit/hooded/flagelantes_chains/proc/handle_damage(mob/living/carbon/human/H, damage, damagetype, def_zone)

	SIGNAL_HANDLER

	if(suittoggled) //Make sure it only checks when the hood is up
		change_slowdown(H, slowdown) //Change speed when damaged

/obj/item/clothing/suit/hooded/flagelantes_chains/proc/on_heal(mob/living/carbon/human/H, amount, damtype)

	SIGNAL_HANDLER

	if(suittoggled) //Make sure it only checks when the hood is up
		change_slowdown(H, slowdown) //Change speed when healed

/obj/item/clothing/suit/hooded/flagelantes_chains/proc/handle_wound_add(mob/living/carbon/human/H, datum/wound/W, obj/item/bodypart/L)

	SIGNAL_HANDLER

	if(suittoggled) //Make sure it only checks when the hood is up
		change_slowdown(H, slowdown) //Change speed when gaining a wound


/obj/item/clothing/suit/hooded/flagelantes_chains/proc/handle_wound_remove(mob/living/carbon/human/H, datum/wound/W, obj/item/bodypart/L)

	SIGNAL_HANDLER

	if(suittoggled) //Make sure it only checks when the hood is up
		change_slowdown(H, slowdown) //Change speed when losing a wound

/obj/item/clothing/suit/hooded/flagelantes_chains/proc/change_slowdown(mob/living/carbon/human/H, starting_slowdown)
	var/health_percent = H.health / H.maxHealth
	var/final_slowdown = 0

	total_wounds = length(H.all_wounds) //Thanks Molti, Baimo, and Bibby

	if(total_wounds < 0)
		total_wounds = 0

	switch(total_wounds) //Change slowdown based on wounds
		if(1)
			final_slowdown += -0.1
		if(2)
			final_slowdown += -0.2
		if(3 to INFINITY) //Max of three wounds for slowdown calculation
			final_slowdown += -0.4

	switch(health_percent) //Change slowdown based on health
		if(0.90 to INFINITY)
			final_slowdown += 1
		if(0.80 to 0.89)
			final_slowdown += 0.5
		if(0.50 to 0.79)
			final_slowdown += 0
		if(0.30 to 0.49)
			final_slowdown += -0.2
		if(0.10 to 0.29)
			final_slowdown += -0.4
		if(0 to 0.9)
			final_slowdown += -0.6

	slowdown = final_slowdown //set slowdown

	if(slowdown == -1) //Alert the user and those around that they've achieved MAXIMUM OVERDRIVE
		if(!speed_message)
			to_chat(H, span_notice("You feel yourself grow closer to the divine as your sins seep out of the chains!."))
			H.visible_message(span_warning("[H] starts sweating profusely!"))
			speed_message = TRUE
	else
		speed_message = FALSE

	appearance_change(H, slowdown) //Add particles depending on slowdown

	change_footstep(slowdown) //Change occurance of chain noise

	if(slowdown > starting_slowdown) //Show bubble alert based on starting and new slowdown
		H.balloon_alert(H, "You slow down!")
	else if(slowdown < starting_slowdown)
		H.balloon_alert(H, "You speed up!")

/obj/item/clothing/suit/hooded/flagelantes_chains/proc/appearance_change(mob/living/carbon/human/H, slowdown)
	switch(slowdown)
		if(-0.9 to 1)
			if(flagelantes_effect)
				QDEL_NULL(flagelantes_effect) //Remove particle effect
		if(-INFINITY to -1)
			if(!flagelantes_effect)
				flagelantes_effect = new(H, /particles/droplets)
				flagelantes_effect.color = "#a41c1c"

/obj/item/clothing/suit/hooded/flagelantes_chains/proc/change_footstep(slowdown) //So the chain sounds are not spammed at higher speeds
	switch(slowdown)
		if(0 to 1)
			footstep_max = 2
		if(-0.3 to -0.1)
			footstep_max = 3
		if(-0.9 to -0.4)
			footstep_max = 4
		if(-INFINITY to -1)
			footstep_max = 5

/obj/item/clothing/suit/hooded/flagelantes_chains/proc/on_mob_move()
	var/mob/living/carbon/human/H = loc
	if(!istype(H) || H.wear_suit != src)
		return
	if(footstep > footstep_max)
		playsound(src, 'sound/weapons/chainhit.ogg', 3, 1)
		footstep = 0
	else
		footstep++

/obj/item/clothing/head/hooded/flagelantes_chains_hood
	name = "flagellant's hood"
	desc = "A hood worn by flagellants to hide their face."
	icon = 'icons/obj/clothing/hats/hats.dmi'
	mob_overlay_icon = 'icons/mob/clothing/head/head.dmi'
	icon_state = "flagelantes_chains_hood"
	item_state = "flagelantes_chains_hood"
	armor = list(MELEE = -15, BULLET = -15, LASER = -15, ENERGY = -15, BOMB = -15, BIO = -15, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HEAD
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR|HIDEMASK
	resistance_flags = FIRE_PROOF | ACID_PROOF
