

/datum/symptom/pthroat
	name = "Pierrot's Throat"
	desc = "Overinduces a sense of humor in the infected, causing them to be overcome by the spirit of a clown."
	stage = 3
	max_multiplier = 4
	badness = EFFECT_DANGER_HINDRANCE
	severity = 2

/datum/symptom/pthroat/activate(mob/living/carbon/mob)
	if(ismouse(mob))
		var/mob/living/basic/mouse/mouse = mob
		mouse.icon_state = "mouse_clown"
		mouse.icon_living = "mouse_clown"
		mouse.icon_dead = "mouse_clown_dead"
		mouse.held_state = "mouse_clown"

	mob.say(pick("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk..."))
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		if(multiplier >=2) //clown mask added
			var/obj/item/clothing/mask/gas/clown_hat/virus/virusclown_hat = new /obj/item/clothing/mask/gas/clown_hat/virus
			if(affected.wear_mask && !istype(affected.wear_mask, /obj/item/clothing/mask/gas/clown_hat/virus))
				affected.dropItemToGround(mob.wear_mask, TRUE)
				affected.equip_to_slot(virusclown_hat, ITEM_SLOT_MASK)
			if(!affected.wear_mask)
				affected.equip_to_slot(virusclown_hat, ITEM_SLOT_MASK)
		if(multiplier >=3) //clown shoes added
			var/obj/item/clothing/shoes/clown_shoes/virusshoes = new /obj/item/clothing/shoes/clown_shoes
			if(affected.shoes && !istype(affected.shoes, /obj/item/clothing/shoes/clown_shoes))
				affected.dropItemToGround(affected.shoes, TRUE)
				affected.equip_to_slot(virusshoes, ITEM_SLOT_FEET)
			if(!affected.shoes)
				affected.equip_to_slot(virusshoes, ITEM_SLOT_FEET)
		if(multiplier >=4) //clown suit added
			var/obj/item/clothing/under/rank/civilian/clown/virussuit = new /obj/item/clothing/under/rank/civilian/clown
			if(affected.w_uniform && !istype(affected.w_uniform, /obj/item/clothing/under/rank/civilian/clown))
				affected.dropItemToGround(affected.w_uniform, TRUE)
				affected.equip_to_slot(virussuit, ITEM_SLOT_ICLOTHING)
			if(!affected.w_uniform)
				affected.equip_to_slot(virussuit, ITEM_SLOT_ICLOTHING)

/datum/symptom/pthroat/first_activate(mob/living/carbon/mob)
	RegisterSignal(mob, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/symptom/pthroat/deactivate(mob/living/carbon/mob)
	UnregisterSignal(mob, COMSIG_MOB_SAY)

/datum/symptom/pthroat/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	var/list/split_message = splittext(message, " ") //List each word in the message
	var/applied = 0
	for (var/i in 1 to length(split_message))
		if(prob(3 * multiplier)) //Stage 1: 3% Stage 2: 6% Stage 3: 9% Stage 4: 12%
			if(findtext(split_message[i], "*") || findtext(split_message[i], ";") || findtext(split_message[i], ":"))
				continue
			split_message[i] = "HONK"
			if (applied++ > stage)
				break
	if (applied)
		speech_args[SPEECH_SPANS] |= SPAN_CLOWN // a little bonus
	message = jointext(split_message, " ")
	speech_args[SPEECH_MESSAGE] = message
