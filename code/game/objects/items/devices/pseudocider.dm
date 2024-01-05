/obj/item/pseudocider
	name = "syndicate pseudocider"
	desc = "A syndicate device that triggers upon taking damage, making you invisible and leaving behind a fake body."
	icon = 'icons/obj/device.dmi'
	icon_state = "pocketwatch-closed"
	base_icon_state = "pocketwatch"
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/toggle_pseudocider)
	var/active = FALSE
	var/mob/living/carbon/fake_corpse
	COOLDOWN_DECLARE(fake_death_timer)
	var/fake_death_cooldown = 30 SECONDS

/obj/item/pseudocider/update_icon_state()
	icon_state = "[base_icon_state][active ? "-open" : "-closed"]"
	return ..()

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

	// Set up the mob to be identical
	if(ishuman(copied_mob))
		fake_corpse = visually_duplicate_human(copied_mob, TRUE)
	else
		fake_corpse = new copied_mob.type
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
				cloth.add_blood_DNA(detective_work.blood_DNA) // authentic
			cloth.update_icon(UPDATE_OVERLAYS)
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
	ADD_TRAIT(copied_mob, TRAIT_SILENT_FOOTSTEPS, PSEUDOCIDER_TRAIT)

	if(damagetype == STAMINA)
		fake_corpse.Paralyze(100 SECONDS)
	else
		INVOKE_ASYNC(fake_corpse, TYPE_PROC_REF(/mob/living,death))
	addtimer(CALLBACK(src, PROC_REF(unfake_death), copied_mob, fake_corpse), 7 SECONDS)

/obj/item/pseudocider/proc/unfake_death(mob/living/carbon/copied_mob, mob/living/carbon/fake_corpse)
	active = FALSE
	update_appearance(UPDATE_ICON)

	COOLDOWN_START(src, fake_death_timer, fake_death_cooldown)

	if(!QDELETED(copied_mob) && istype(copied_mob))
		REMOVE_TRAIT(copied_mob, TRAIT_SILENT_FOOTSTEPS, PSEUDOCIDER_TRAIT)
		animate(copied_mob, 0.5 SECONDS, alpha = 255)
		REMOVE_TRAIT(copied_mob, TRAIT_NOINTERACT, "[type]")
		REMOVE_TRAIT(copied_mob, TRAIT_RESISTDAMAGESLOWDOWN, "[type]")

	if(!QDELETED(fake_corpse) && istype(fake_corpse))
		fake_corpse.visible_message(span_notice("The body vanishes! It was a fake!"))
		animate(fake_corpse, 0.5 SECONDS, alpha = 0)
		QDEL_IN(fake_corpse, 0.6 SECONDS)
