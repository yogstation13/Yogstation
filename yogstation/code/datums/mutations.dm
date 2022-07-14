/datum/mutation/human/cluwne

	name = "Cluwne"
	quality = NEGATIVE
	locked = TRUE
	text_gain_indication = span_danger("You feel like your brain is tearing itself apart.")

/datum/mutation/human/cluwne/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.dna.add_mutation(CLOWNMUT)
	owner.dna.add_mutation(EPILEPSY)
	owner.setOrganLoss(ORGAN_SLOT_BRAIN,199)

	var/mob/living/carbon/human/H = owner

	if(!istype(H.wear_mask, /obj/item/clothing/mask/yogs/cluwne))
		if(!H.temporarilyRemoveItemFromInventory(H.wear_mask))
			qdel(H.wear_mask)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/yogs/cluwne(H), SLOT_WEAR_MASK)
	if(!istype(H.w_uniform, /obj/item/clothing/under/yogs/cluwne))
		if(!H.temporarilyRemoveItemFromInventory(H.w_uniform))
			qdel(H.w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/yogs/cluwne(H), SLOT_W_UNIFORM)
	if(!istype(H.shoes, /obj/item/clothing/shoes/yogs/cluwne))
		if(!H.temporarilyRemoveItemFromInventory(H.shoes))
			qdel(H.shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/yogs/cluwne(H), SLOT_SHOES)

	owner.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/white(owner), SLOT_GLOVES) // this is purely for cosmetic purposes incase they aren't wearing anything in that slot
	owner.equip_to_slot_or_del(new /obj/item/storage/backpack/clown(owner), SLOT_BACK) // ditto

/datum/mutation/human/cluwne/on_life(mob/living/carbon/human/owner)
	if((prob(15) && owner.IsUnconscious()))
		owner.setOrganLoss(ORGAN_SLOT_BRAIN,199) // there I changed it to setBrainLoss
		switch(rand(1, 6))
			if(1)
				owner.say("HONK")
			if(2 to 5)
				owner.emote("scream")
			if(6)
				owner.Stun(1)
				owner.Knockdown(20)
				owner.Jitter(500)

/datum/mutation/human/cluwne/on_losing(mob/living/carbon/human/owner)
	owner.adjust_fire_stacks(1)
	owner.IgniteMob()
	owner.dna.add_mutation(CLUWNEMUT)

/mob/living/carbon/human/proc/cluwneify()
	dna.add_mutation(CLUWNEMUT)
	emote("scream")
	regenerate_icons()
	visible_message(span_danger("[src]'s body glows green, the glow dissipating only to leave behind a cluwne formerly known as [src]!"), \
					span_danger("Your brain feels like it's being torn apart, and after a short while, you notice that you've become a cluwne!"))
	flash_act()

/datum/mutation/human/tourettes/on_life()
	if(prob(10) && owner.stat == CONSCIOUS)
		owner.Stun(2 SECONDS)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
		var/x_offset_old = owner.pixel_x
		var/y_offset_old = owner.pixel_y
		var/x_offset = owner.pixel_x + rand(-2,2)
		var/y_offset = owner.pixel_y + rand(-1,1)
		animate(owner, pixel_x = x_offset, pixel_y = y_offset, time = 0.1 SECONDS)
		animate(owner, pixel_x = x_offset_old, pixel_y = y_offset_old, time = 0.1 SECONDS)

/datum/mutation/human/hulk
	species_allowed = list()
