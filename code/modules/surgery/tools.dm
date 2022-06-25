/obj/item/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "clamps"
	materials = list(/datum/material/iron=6000, /datum/material/glass=3000)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	tool_behaviour = TOOL_RETRACTOR
	w_class = WEIGHT_CLASS_TINY

/obj/item/retractor/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM || !attempt_initiate_surgery(src, M, user))
		..()

/obj/item/retractor/augment
	name = "retractor"
	desc = "Micro-mechanical manipulator for retracting stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	materials = list(/datum/material/iron=6000, /datum/material/glass=3000)
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5


/obj/item/retractor/bone
	name = "bone retractor"
	desc = "Kinda looks like a chicken bone."
	icon_state = "retractor_bone"
	toolspeed = 1.25


/obj/item/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "clamps"
	materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	tool_behaviour = TOOL_HEMOSTAT
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("attacked", "pinched")

/obj/item/hemostat/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM || !attempt_initiate_surgery(src, M, user))
		..()

/obj/item/hemostat/augment
	name = "hemostat"
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5
	attack_verb = list("attacked", "pinched")


/obj/item/hemostat/bone
	name = "hemostat"
	desc = "Bones that are strapped together with sinews. Used to stop bleeding."
	icon_state = "hemostat_bone"
	toolspeed = 1.25


/obj/item/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "cautery"
	materials = list(/datum/material/iron=2500, /datum/material/glass=750)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	tool_behaviour = TOOL_CAUTERY
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("burnt")

/obj/item/cautery/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM || !attempt_initiate_surgery(src, M, user))
		..()

/obj/item/cautery/augment
	name = "cautery"
	desc = "A heated element that cauterizes wounds."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	materials = list(/datum/material/iron=2500, /datum/material/glass=750)
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5
	attack_verb = list("burnt")


/obj/item/cautery/bone
	name = "bone cautery"
	desc = "A heated chuck of plasma strapped to a bone. It can close wounds."
	icon_state = "cautery_bone"
	toolspeed = 1.25


/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	tool_behaviour = TOOL_DRILL
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("drilled")
	sharpness = SHARP_POINTY
	wound_bonus = 10
	bare_wound_bonus = 10

/obj/item/surgicaldrill/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] rams [src] into [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide!"))
	addtimer(CALLBACK(user, /mob/living/carbon.proc/gib, null, null, TRUE, TRUE), 25)
	user.SpinAnimation(3, 10)
	playsound(user, 'sound/machines/juicer.ogg', 20, TRUE)
	SSachievements.unlock_achievement(/datum/achievement/likearecord, user.client)
	return (MANUAL_SUICIDE)

/obj/item/surgicaldrill/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM || !attempt_initiate_surgery(src, M, user))
		..()

/obj/item/surgicaldrill/augment
	name = "surgical drill"
	desc = "Effectively a small power drill contained within your arm, edges dulled to prevent tissue damage. May or may not pierce the heavens."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5
	attack_verb = list("drilled")


/obj/item/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "scalpel"
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	tool_behaviour = TOOL_SCALPEL

	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(/datum/material/iron=4000, /datum/material/glass=1000)
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	wound_bonus = 10
	bare_wound_bonus = 15

/obj/item/scalpel/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 80 * toolspeed, 100, 0)

/obj/item/scalpel/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM || !attempt_initiate_surgery(src, M, user))
		..()

/obj/item/scalpel/augment
	name = "scalpel"
	desc = "Ultra-sharp blade attached directly to your bone for extra-accuracy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(/datum/material/iron=4000, /datum/material/glass=1000)
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	toolspeed = 0.5
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED

/obj/item/scalpel/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] [pick("wrists", "throat", "stomach")] with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)


/obj/item/scalpel/bone
	name = "bone scalpel"
	desc = "Bones and a Diamond tied together to make a scalpel."
	icon_state = "scalpel_bone"
	force = 5
	toolspeed = 1.25

/obj/item/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	mob_throw_hit_sound =  'sound/weapons/pierce.ogg'
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	tool_behaviour = TOOL_SAW
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharpness = SHARP_EDGED
	wound_bonus = 15
	bare_wound_bonus = 10

/obj/item/circular_saw/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 40 * toolspeed, 100, 5, 'sound/weapons/circsawhit.ogg') //saws are very accurate and fast at butchering

/obj/item/circular_saw/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM || !attempt_initiate_surgery(src, M, user))
		..()

/obj/item/circular_saw/augment
	name = "circular saw"
	desc = "A small but very fast spinning saw. Edges dulled to prevent accidental cutting inside of the surgeon."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	toolspeed = 0.5
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharpness = SHARP_EDGED

/obj/item/circular_saw/bone
	name = "bone bonesaw"
	desc = "A bone with diamond teeth strapped to cut through bones."
	icon_state = "saw_bone"
	force = 5
	toolspeed = 1.25

/obj/item/bonesetter
	name = "bonesetter"
	desc = "For setting things right."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	tool_behaviour = TOOL_BONESET
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("corrected", "properly set")

/obj/item/bonesetter/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM || !attempt_initiate_surgery(src, M, user))
		..()

/obj/item/bonesetter/bone
	name = "bone bonesetter"
	desc = "A bonesetter made of bones... for setting bones with... bones?"
	icon_state = "bone setter_bone"
	toolspeed = 1.25

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "drapes"
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("slapped")

/obj/item/surgical_drapes/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM || !attempt_initiate_surgery(src, M, user))
		..()

/obj/item/surgical_drapes/goliath
	name = "goliath drapes"
	desc = "Probably not the most hygienic but what else are you gonna use?"
	icon_state = "surgical_drapes_goli"

/obj/item/organ_storage //allows medical cyborgs to manipulate organs without hands
	name = "organ storage bag"
	desc = "A container for holding body parts."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	item_flags = SURGICAL_TOOL

/obj/item/organ_storage/afterattack(obj/item/I, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(I, /obj/machinery/smartfridge))
		return
	if(contents.len)
		to_chat(user, span_notice("[src] already has something inside it."))
		return
	if(!isorgan(I) && !isbodypart(I))
		to_chat(user, span_notice("[src] can only hold body parts!"))
		return

	user.visible_message("[user] puts [I] into [src].", span_notice("You put [I] inside [src]."))
	icon_state = "evidence"
	var/xx = I.pixel_x
	var/yy = I.pixel_y
	I.pixel_x = 0
	I.pixel_y = 0
	var/image/img = image("icon"=I, "layer"=FLOAT_LAYER)
	img.plane = FLOAT_PLANE
	I.pixel_x = xx
	I.pixel_y = yy
	add_overlay(img)
	add_overlay("evidence")
	desc = "An organ storage container holding [I]."
	I.forceMove(src)
	w_class = I.w_class

/obj/item/organ_storage/attack_self(mob/user)
	if(contents.len)
		var/obj/item/I = contents[1]
		clear_organ()
		user.visible_message("[user] dumps [I] from [src].", span_notice("You dump [I] from [src]."))
		I.forceMove(get_turf(src))
	else
		to_chat(user, "[src] is empty.")
	return

/obj/item/organ_storage/proc/clear_organ()
	cut_overlays()
	icon_state = "evidenceobj"
	desc = "A container for holding body parts."

/obj/item/surgical_processor //allows medical cyborgs to scan and initiate advanced surgeries
	name = "\improper Surgical Processor"
	desc = "A device for scanning and initiating surgeries from a disk or operating computer."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_flags = NOBLUDGEON
	var/list/advanced_surgeries = list()

/obj/item/surgical_processor/afterattack(obj/item/O, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(O, /obj/item/disk/surgery))
		to_chat(user, span_notice("You load the surgery protocol from [O] into [src]."))
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 1 SECONDS, O))
			advanced_surgeries |= D.surgeries
		return TRUE
	if(istype(O, /obj/machinery/computer/operating))
		to_chat(user, span_notice("You copy surgery protocols from [O] into [src]."))
		var/obj/machinery/computer/operating/OC = O
		if(do_after(user, 1 SECONDS, O))
			advanced_surgeries |= OC.advanced_surgeries
		return TRUE
	return

/obj/item/scalpel/advanced
	name = "laser scalpel"
	desc = "An advanced scalpel which uses laser technology to cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel_a"
	hitsound = 'sound/weapons/blade1.ogg'
	force = 16
	toolspeed = 0.7
	light_color = LIGHT_COLOR_GREEN
	sharpness = SHARP_EDGED


/obj/item/scalpel/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_SCALPEL)
		tool_behaviour = TOOL_SAW
		to_chat(user, span_notice("You increase the power, now it can cut bones."))
		set_light(2)
		force += 1 //we don't want to ruin sharpened stuff
		icon_state = "saw_a"
	else
		tool_behaviour = TOOL_SCALPEL
		to_chat(user, span_notice("You lower the power, it can now make precise incisions."))
		set_light(1)
		force -= 1
		icon_state = "scalpel_a"

/obj/item/scalpel/advanced/examine()
	. = ..()
	. += " It's set to [tool_behaviour == TOOL_SCALPEL ? "scalpel" : "saw"] mode."

/obj/item/retractor/advanced
	name = "mechanical pinches"
	desc = "An agglomerate of rods and gears."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor_a"
	toolspeed = 0.7

/obj/item/retractor/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_RETRACTOR)
		tool_behaviour = TOOL_HEMOSTAT
		to_chat(user, span_notice("You set the [src] to hemostat mode."))
		icon_state = "hemostat_a"
	else
		tool_behaviour = TOOL_RETRACTOR
		to_chat(user, span_notice("You set the [src] to retractor mode."))
		icon_state = "retractor_a"

/obj/item/retractor/advanced/examine()
	. = ..()
	. += " It resembles a [tool_behaviour == TOOL_RETRACTOR ? "retractor" : "hemostat"]."

/obj/item/cautery/advanced
	name = "searing tool"
	desc = "It projects a high power laser used for medical application."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery_a"
	hitsound = 'sound/items/welder.ogg'
	toolspeed = 0.7
	light_color = LIGHT_COLOR_RED

/obj/item/cautery/advanced/Initialize()
	. = ..()
	set_light(1)

/obj/item/cautery/advanced/attack_self(mob/user)

	if(tool_behaviour == TOOL_CAUTERY)
		playsound(get_turf(user),'sound/items/welderdeactivate.ogg',50,1)
		to_chat(user, span_notice("You focus the lensess, it is now set to drilling mode."))
		tool_behaviour = TOOL_DRILL
		icon_state = "surgicaldrill_a"
	else
		playsound(get_turf(user),'sound/weapons/tap.ogg',50,1)
		to_chat(user, span_notice("You dilate the lenses, setting it to mending mode."))
		tool_behaviour = TOOL_CAUTERY
		icon_state = "cautery_a"

/obj/item/cautery/advanced/examine()
	. = ..()
	. += " It's set to [tool_behaviour == TOOL_DRILL ? "drilling" : "mending"] mode."
