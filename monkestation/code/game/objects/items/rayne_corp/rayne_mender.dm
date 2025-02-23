#define RAYNE_MENDER_SPEECH "monkey_companies/rayne_mender.json"
/// How long the gun should wait between speaking to lessen spam
#define RAYNE_MENDER_SPEECH_COOLDOWN 5 SECONDS
/// What color is the default kill mode for these guns, used to make sure the chat colors are right at roundstart
#define DEFAULT_RUNECHAT_COLOR "#06507a"

/obj/item/storage/medkit/rayne
	name = "Rayne Corp Health Analyzer Kit"
	icon = 'monkestation/icons/obj/rayne_corp/rayne.dmi'
	icon_state = "rayne_medkit"
	inhand_icon_state = "coronerkit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_flags = NOBLUDGEON
	var/speech_json_file = RAYNE_MENDER_SPEECH
	COOLDOWN_DECLARE(last_speech)
	damagetype_healed = HEAL_ALL_DAMAGE

/obj/item/storage/medkit/rayne/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_slots = 14
	atom_storage.max_total_storage = 28

/obj/item/storage/medkit/rayne/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		speak_up("pickup")

/obj/item/storage/medkit/rayne/dropped(mob/user, silent)
	. = ..()
	if(src in user.contents)
		return // If they're still holding us or have us on them, dw about it
	speak_up("putdown")

/obj/item/storage/medkit/rayne/PopulateContents()
	if(empty)
		return
	var/static/list/items_inside = list(
		/obj/item/stack/medical/suture/medicated = 2,
		/obj/item/stack/medical/mesh/advanced = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants = 2,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 2,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 1,
		/obj/item/reagent_containers/hypospray/medipen/morphine = 1,
		/obj/item/reagent_containers/hypospray/medipen/salbutamol = 1,
		/obj/item/storage/pill_bottle/multiver = 1
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/rayne/attack(mob/living/M, mob/living/carbon/human/user)
	if(!user.can_read(src) || user.is_blind())
		return

	flick("[icon_state]-scan", src) //makes it so that it plays the scan animation upon scanning, including clumsy scanning

	if(ispodperson(M))
		speak_up("podnerd")
		return

	user.visible_message(span_notice("[user] analyzes [M]'s vitals."))
	playsound(user.loc, 'sound/items/healthanalyzer.ogg', 50)
	healthscan(user, M, 0, FALSE)
	add_fingerprint(user)
	judge_health(M)

//This proc controls what the medkit says when scanning a person, and recommends a best course of treatment (barely)
/obj/item/storage/medkit/rayne/proc/judge_health(mob/living/target)

	var/obj/item/organ/internal/brain/targetbrain
	if(target.on_fire)
		speak_up("onfire")
		return
	if(ishuman(target))
		if(!target.get_organ_slot(ORGAN_SLOT_BRAIN))
			speak_up("nobrain")
			return
		else
			targetbrain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
			if(targetbrain.damage > 150)
				speak_up("braindamage")
				return

		if((target?.blood_volume <= BLOOD_VOLUME_SAFE) && !HAS_TRAIT(target, TRAIT_NOBLOOD))
			speak_up("lowblood")
			return

	var/brute = target.getBruteLoss()
	var/oxy = target.getOxyLoss()
	var/tox = target.getToxLoss()
	var/burn = target.getFireLoss()
	var/big = max(brute,oxy,burn,tox)
	if((brute + burn) >= 350)
		speak_up("fuckedup")
		return
	if(big >= 5)
		if(brute == big)
			speak_up("brute")
			return
		if(burn == big)
			speak_up("burn")
			return
		if(tox == big)
			speak_up("tox")
			return
		if(oxy == big)
			speak_up("oxy")
			return
	if(target.stat == DEAD)
		speak_up("dead")
		return

	speak_up("fine")
	return


/obj/item/storage/medkit/rayne/proc/speak_up(json_string, ignores_cooldown = FALSE)
	if(!json_string)
		return
	if(!ignores_cooldown && !COOLDOWN_FINISHED(src, last_speech))
		return
	say(pick_list_replacements(speech_json_file, json_string))
	playsound(src, 'sound/creatures/tourist/tourist_talk.ogg', 15, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = rand(3.5))
	Shake(2, 2, 1 SECONDS)
	COOLDOWN_START(src, last_speech, RAYNE_MENDER_SPEECH_COOLDOWN)

#undef DEFAULT_RUNECHAT_COLOR
#undef RAYNE_MENDER_SPEECH_COOLDOWN
#undef RAYNE_MENDER_SPEECH
