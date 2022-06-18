
//make incision
/datum/surgery_step/incise
	name = "make incision"
	implements = list(TOOL_SCALPEL = 100, /obj/item/melee/transforming/energy/sword = 75, /obj/item/kitchen/knife = 65,
		/obj/item/shard = 45, /obj/item = 30) // 30% success with any sharp item.
	time = 1.6 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	var/bleeding = 5 //how much bleeding you get from this being done

/datum/surgery_step/incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to make an incision in [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to make an incision in [target]'s [parse_zone(target_zone)].",
		"[user] begins to make an incision in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/incise/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE

	return TRUE

/datum/surgery_step/incise/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if ishuman(target)
		var/mob/living/carbon/human/H = target
		if (!(NOBLOOD in H.dna.species.species_traits) && bleeding)
			display_results(user, target, span_notice("Blood pools around the incision in [H]'s [parse_zone(target_zone)]."),
				"Blood pools around the incision in [H]'s [parse_zone(target_zone)].",
				"")
			var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
			if(BP)
				BP.generic_bleedstacks += bleeding
	return TRUE

/datum/surgery_step/incise/nobleed
	fuckup_damage = 0
	bleeding = 0

/datum/surgery_step/incise/nobleed/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to <i>carefully</i> make an incision in [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to <i>carefully</i> make an incision in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to <i>carefully</i> make an incision in [target]'s [parse_zone(target_zone)]."))

//clamp bleeders
/datum/surgery_step/clamp_bleeders
	name = "clamp bleeders"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_WIRECUTTER = 60, /obj/item/stack/packageWrap = 35, /obj/item/stack/cable_coil = 15)
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_step/clamp_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to clamp bleeders in [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to clamp bleeders in [target]'s [parse_zone(target_zone)].",
		"[user] begins to clamp bleeders in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/clamp_bleeders/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		var/obj/item/bodypart/affecting = target.get_bodypart(target_zone)
		affecting?.heal_damage(20,0)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/BP = H.get_bodypart(target_zone)
		if(BP)
			BP.generic_bleedstacks -= 3
	return ..()

//retract skin
/datum/surgery_step/retract_skin
	name = "retract skin"
	implements = list(TOOL_RETRACTOR = 100, TOOL_SCREWDRIVER = 45, TOOL_WIRECUTTER = 35)
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to retract the skin in [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].",
		"[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].")



//close incision
/datum/surgery_step/close
	name = "mend incision"
	implements = list(TOOL_CAUTERY = 100, /obj/item/gun/energy/laser = 90, TOOL_WELDER = 70,
		/obj/item = 30) // 30% success with any hot item.
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/cautery1.ogg'
	success_sound = 'sound/surgery/cautery2.ogg'
	fuckup_damage_type = BURN

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to mend the incision in [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to mend the incision in [target]'s [parse_zone(target_zone)].",
		"[user] begins to mend the incision in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/close/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.is_hot()

	return TRUE

/datum/surgery_step/close/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		var/obj/item/bodypart/affecting = target.get_bodypart(target_zone)
		affecting?.heal_damage(45,0)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/BP = H.get_bodypart(target_zone)
		if(BP)
			BP.generic_bleedstacks -= 10
	return ..()

/datum/surgery_step/close/nofail
	fuckup_damage = 0

//saw bone
/datum/surgery_step/saw
	name = "saw bone"
	implements = list(TOOL_SAW = 100, /obj/item/melee/transforming/energy/sword/cyborg/saw = 100,
		/obj/item/melee/arm_blade = 75, /obj/item/mounted_chainsaw = 65, /obj/item/twohanded/required/chainsaw = 50,
		/obj/item/twohanded/fireaxe = 50, /obj/item/hatchet = 35, /obj/item/kitchen/knife/butcher = 25)
	time = 5.4 SECONDS
	preop_sound = list(
		/obj/item/circular_saw = 'sound/surgery/saw.ogg',
		/obj/item/melee/arm_blade = 'sound/surgery/scalpel1.ogg',
		/obj/item/twohanded/fireaxe = 'sound/surgery/scalpel1.ogg',
		/obj/item/hatchet = 'sound/surgery/scalpel1.ogg',
		/obj/item/kitchen/knife/butcher = 'sound/surgery/scalpel1.ogg',
		/obj/item = 'sound/surgery/scalpel1.ogg',
	) 
	fuckup_damage = 20

/datum/surgery_step/saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to saw through the bone in [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to saw through the bone in [target]'s [parse_zone(target_zone)].",
		"[user] begins to saw through the bone in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/saw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(50, BRUTE, "[target_zone]", wound_bonus=CANT_WOUND)
	display_results(user, target, span_notice("You saw [target]'s [parse_zone(target_zone)] open."),
		"[user] saws [target]'s [parse_zone(target_zone)] open!",
		"[user] saws [target]'s [parse_zone(target_zone)] open!")
	return 1

//drill bone
/datum/surgery_step/drill
	name = "drill bone"
	implements = list(TOOL_DRILL = 100, /obj/item/pickaxe/drill = 60, /obj/item/mecha_parts/mecha_equipment/drill = 60, TOOL_SCREWDRIVER = 20)
	time = 30
	fuckup_damage = 15

/datum/surgery_step/drill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to drill into the bone in [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].",
		"[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/drill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You drill into [target]'s [parse_zone(target_zone)]."),
		"[user] drills into [target]'s [parse_zone(target_zone)]!",
		"[user] drills into [target]'s [parse_zone(target_zone)]!")
	return 1
