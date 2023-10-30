/obj/item/pseudocider
	name = "syndicate pseudocider"
	desc = "A syndicate device that triggers upon taking damage, making you invisible and leaving behind a fake body."
	icon = 'icons/obj/device.dmi'
	icon_state = "pocketwatch-closed"
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/toggle_pseudocider)
	var/active = FALSE
	var/mob/living/carbon/fake_corpse
	COOLDOWN_DECLARE(fake_death_timer)
	var/fake_death_cooldown = 20 SECONDS

/obj/item/pseudocider/Initialize(mapload)
	. = ..()
	// Meant to work from the pocket as well
	RegisterSignals(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_PICKUP), PROC_REF(assign_user))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(drop_user))
	RegisterSignal(src, COMSIG_ITEM_ATTACK_SELF, PROC_REF(self_attack))

/obj/item/pseudocider/proc/assign_user(datum/source, mob/living/carbon/user)
	SIGNAL_HANDLER
	if(!istype(user))
		return
	RegisterSignal(user, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(fake_death))

/obj/item/pseudocider/proc/drop_user(datum/source, mob/living/carbon/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOB_APPLY_DAMAGE)

/obj/item/pseudocider/proc/self_attack(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!iscarbon(user))
		return
	if(HAS_TRAIT(user, TRAIT_NOINTERACT))
		return
	if(!COOLDOWN_FINISHED(src, fake_death_timer) && !active)
		to_chat(user, span_notice("\The [src] refuses to open! Wait [COOLDOWN_TIMELEFT(src, fake_death_timer)/10] more seconds!"))
		return
	active = !active
	if(active)
		icon_state = "pocketwatch-open"
	else
		icon_state = "pocketwatch-closed"
	update_appearance(UPDATE_ICON)

/obj/item/pseudocider/proc/fake_death(mob/living/carbon/copied_mob, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(HAS_TRAIT(copied_mob, TRAIT_NOINTERACT))
		return
	if(!active)
		return
	if(!COOLDOWN_FINISHED(src, fake_death_timer))
		return
	if(damage <= 0)
		return
	if(!istype(copied_mob))
		return
	if(copied_mob.stat > CONSCIOUS)
		return
	var/turf/copy_location = get_turf(copied_mob)
	if(!istype(copy_location))
		return

	COOLDOWN_START(src, fake_death_timer, fake_death_cooldown) // sanity

	fake_corpse = new copied_mob.type
	if(copied_mob.dna?.species)
		INVOKE_ASYNC(fake_corpse, TYPE_PROC_REF(/mob,set_species), new copied_mob.dna.species.type)
		fake_corpse.dna.features = LAZYCOPY(copied_mob.dna.features)

	// Set up the mob to be identical
	if(ishuman(fake_corpse) && ishuman(copied_mob))
		var/mob/living/carbon/human/fake_human_corpse = fake_corpse
		var/mob/living/carbon/human/copied_human_mob = copied_mob
		fake_human_corpse.real_name = copied_human_mob.name
		fake_human_corpse.name = copied_human_mob.name
		fake_human_corpse.gender = copied_human_mob.gender
		fake_human_corpse.eye_color = copied_human_mob.eye_color
		var/obj/item/organ/eyes/organ_eyes = fake_human_corpse.getorgan(/obj/item/organ/eyes)
		if(organ_eyes)
			organ_eyes.eye_color = copied_human_mob.eye_color
			organ_eyes.old_eye_color = copied_human_mob.eye_color
		fake_human_corpse.hair_color = copied_human_mob.hair_color
		fake_human_corpse.facial_hair_color = copied_human_mob.facial_hair_color
		fake_human_corpse.skin_tone = copied_human_mob.skin_tone
		fake_human_corpse.hair_style = copied_human_mob.hair_style
		fake_human_corpse.facial_hair_style = copied_human_mob.facial_hair_style
		fake_human_corpse.underwear = copied_human_mob.underwear
		fake_human_corpse.undershirt = copied_human_mob.undershirt
		fake_human_corpse.socks = copied_human_mob.socks
		fake_human_corpse.update_body()
		fake_human_corpse.update_hair()
		fake_human_corpse.update_body_parts()

		// Clothes for humans
		if(copied_human_mob.w_uniform)
			equip_item_to_human_corpse(copied_human_mob.w_uniform, ITEM_SLOT_ICLOTHING, fake_human_corpse)
		if(copied_human_mob.wear_suit)
			equip_item_to_human_corpse(copied_human_mob.wear_suit, ITEM_SLOT_OCLOTHING, fake_human_corpse)
		if(copied_human_mob.s_store)
			equip_item_to_human_corpse(copied_human_mob.s_store, ITEM_SLOT_SUITSTORE, fake_human_corpse)
		if(copied_human_mob.back)
			equip_item_to_human_corpse(copied_human_mob.back, ITEM_SLOT_BACK, fake_human_corpse)
		if(copied_human_mob.belt)
			equip_item_to_human_corpse(copied_human_mob.belt, ITEM_SLOT_BELT, fake_human_corpse)
		if(copied_human_mob.ears)
			equip_item_to_human_corpse(copied_human_mob.ears, ITEM_SLOT_EARS, fake_human_corpse)
		if(copied_human_mob.glasses)
			equip_item_to_human_corpse(copied_human_mob.glasses, ITEM_SLOT_EYES, fake_human_corpse)
		if(copied_human_mob.gloves)
			equip_item_to_human_corpse(copied_human_mob.gloves, ITEM_SLOT_GLOVES, fake_human_corpse)
		if(copied_human_mob.shoes)
			equip_item_to_human_corpse(copied_human_mob.shoes, ITEM_SLOT_FEET, fake_human_corpse)
		if(copied_human_mob.wear_id)
			equip_item_to_human_corpse(copied_human_mob.wear_id, ITEM_SLOT_ID, fake_human_corpse)
			fake_human_corpse.sec_hud_set_ID()

		for(var/obj/item/implant/implant_instance in copied_human_mob.implants)
			var/obj/item/implant/implant_copy = new implant_instance.type
			implant_copy.implant(fake_human_corpse, null, TRUE)
			QDEL_IN(implant_copy, 6.5 SECONDS) // anti duping

		copied_human_mob.sec_hud_set_implants()
	else
		// Clothes for monkeys (and xenos?)
		for(var/obj/item/clothing/equipped as anything in copied_mob.get_equipped_items())
			var/obj/item/clothing/cloth = new equipped.type
			cloth.name = equipped.name
			cloth.icon = equipped.icon
			cloth.icon_state = equipped.icon_state
			cloth.item_state = equipped.item_state
			cloth.damaged_clothes = equipped.damaged_clothes
			if(HAS_BLOOD_DNA(equipped))
				var/datum/component/forensics/detective_work = equipped.GetComponent(/datum/component/forensics)
				cloth.add_blood_DNA(detective_work.blood_DNA) // authentic lol
			cloth.update_appearance(UPDATE_NAME | UPDATE_ICON)
			cloth.item_flags |= DROPDEL
			if(!fake_corpse.equip_to_appropriate_slot(cloth))
				QDEL_NULL(cloth)

	// Damage
	INVOKE_ASYNC(fake_corpse, TYPE_PROC_REF(/mob/living,take_overall_damage), copied_mob.get_damage_amount(BRUTE), copied_mob.get_damage_amount(BURN))
	INVOKE_ASYNC(fake_corpse, TYPE_PROC_REF(/mob/living,take_overall_damage), damagetype == BRUTE ? damage : 0, damagetype == BURN ? damage : 0)

	// Fake key + client so they don't appear catatonic/ssd
	fake_corpse.key = "#[rand(1000,9999)]#FakeCorpse"
	fake_corpse.fake_client = TRUE

	// Put the mob in place of the user
	fake_corpse.dir = copied_mob.dir
	fake_corpse.forceMove(copy_location)
	// and vanish the user
	copied_mob.alpha = 0
	ADD_TRAIT(copied_mob, TRAIT_NOINTERACT, "[type]")
	ADD_TRAIT(copied_mob, TRAIT_HIGHRESISTDAMAGESLOWDOWN, "[type]")
	// also make their footsteps silent
	var/datum/component/footstep/footsteps = copied_mob.GetComponent(/datum/component/footstep)
	var/stored_footstep_volume = footsteps.volume
	footsteps.volume = 0

	if(damagetype == STAMINA)
		fake_corpse.Paralyze(100 SECONDS)
	else
		INVOKE_ASYNC(fake_corpse, TYPE_PROC_REF(/mob/living,death))
	addtimer(CALLBACK(src, PROC_REF(unfake_death), copied_mob, stored_footstep_volume, fake_corpse), 7 SECONDS)

/obj/item/pseudocider/proc/unfake_death(mob/living/carbon/copied_mob, stored_footstep_volume, mob/living/carbon/fake_corpse)
	active = FALSE
	icon_state = "pocketwatch-closed"
	update_appearance(UPDATE_ICON)

	COOLDOWN_START(src, fake_death_timer, fake_death_cooldown)

	if(!QDELETED(copied_mob) && istype(copied_mob))
		var/datum/component/footstep/footsteps = copied_mob.GetComponent(/datum/component/footstep)
		footsteps.volume = stored_footstep_volume
		animate(copied_mob, 0.5 SECONDS, alpha = 255)
		REMOVE_TRAIT(copied_mob, TRAIT_NOINTERACT, "[type]")
		REMOVE_TRAIT(copied_mob, TRAIT_RESISTDAMAGESLOWDOWN, "[type]")

	if(!QDELETED(fake_corpse) && istype(fake_corpse))
		fake_corpse.visible_message(span_notice("The body vanishes! It was a fake!"))
		animate(fake_corpse, 0.5 SECONDS, alpha = 0)
		QDEL_IN(fake_corpse, 0.6 SECONDS)

/obj/item/pseudocider/proc/equip_item_to_human_corpse(obj/item/item_instance, slot, mob/living/carbon/human/corpse)
	var/obj/item/item_copy = new item_instance.type

	// Update ID + HUD
	if(istype(item_instance, /obj/item/card/id))
		var/obj/item/card/id/id_copy = item_copy
		var/obj/item/card/id/id_instance = item_instance
		id_copy.registered_name = id_instance.registered_name
		id_copy.assignment = id_instance.assignment
		id_copy.originalassignment = id_instance.originalassignment

	// Update ID + HUD but if it's in a PDA
	if(istype(item_instance, /obj/item/modular_computer/tablet))
		var/obj/item/modular_computer/tablet/tablet_copy = item_copy
		var/obj/item/modular_computer/tablet/tablet_instance = item_instance
		tablet_copy.finish_color = tablet_instance.finish_color
		var/obj/item/computer_hardware/card_slot/card_slot = tablet_instance.all_components[MC_CARD]
		if(card_slot?.stored_card)
			var/obj/item/card/id/id_copy = new card_slot.stored_card.type
			var/obj/item/card/id/id_instance = card_slot.stored_card
			id_copy.registered_name = id_instance.registered_name
			id_copy.assignment = id_instance.assignment
			id_copy.originalassignment = id_instance.originalassignment
			var/obj/item/computer_hardware/card_slot/card_slot_copy = tablet_copy.all_components[MC_CARD]
			if(!card_slot_copy)
				card_slot_copy = new
				tablet_copy.install_component(card_slot_copy)
			id_copy.forceMove(card_slot_copy)
			card_slot_copy.stored_card = id_copy

			tablet_copy.update_label()


	// Update damaged clothing
	if(isclothing(item_instance))
		var/obj/item/clothing/cloth_copy = item_copy
		var/obj/item/clothing/cloth_instance = item_instance
		cloth_copy.damaged_clothes = cloth_instance.damaged_clothes

	// Swap the lights, don't want the seccies following our trail of light!
	if(item_instance.light_on)
		item_instance.set_light_on(FALSE)
		item_copy.set_light_on(TRUE)

	// In case of chameleon clothes or otherwise
	item_copy.name = item_instance.name
	item_copy.icon = item_instance.icon
	item_copy.icon_state = item_instance.icon_state
	item_copy.item_state = item_instance.item_state

	if(HAS_BLOOD_DNA(item_instance))
		var/datum/component/forensics/detective_work = item_instance.GetComponent(/datum/component/forensics)
		item_copy.add_blood_DNA(detective_work.blood_DNA) // authentic lol

	item_copy.update_appearance(UPDATE_NAME | UPDATE_ICON)

	// So you can attempt to take off the clothes to prevent meta, but they will be deleted anyways
	item_copy.item_flags |= DROPDEL

	corpse.equip_to_slot_if_possible(item_copy, slot, TRUE, TRUE, TRUE, TRUE, TRUE) // he's TRUE you know
