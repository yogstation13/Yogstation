/datum/symptom/wizarditis
	name = "Wizarditis"
	max_multiplier = 4
	stage = 3
	desc = "Some speculate that this virus is the cause of the Space Wizard Federation's existence. Subjects affected show the signs of brain damage, yelling obscure sentences or total gibberish. On late stages subjects sometime express the feelings of inner power, and, cite, 'the ability to control the forces of cosmos themselves!' A gulp of strong, manly spirits usually reverts them to normal, humanlike, condition."
	badness = EFFECT_DANGER_HARMFUL

/datum/symptom/wizarditis/activate(mob/living/carbon/affected_mob)
	switch(round(multiplier))
		if(2)
			if(prob(10))
				affected_mob.say(pick("You shall not pass!", "Expeliarmus!", "By Merlins beard!", "Feel the power of the Dark Side!"), forced = "wizarditis")
			if(prob(10))
				to_chat(affected_mob, span_danger("You feel [pick("that you don't have enough mana", "that the winds of magic are gone", "an urge to summon familiar")]."))
		if(3)
			if(prob(10))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"), forced = "wizarditis")
			if(prob(10))
				to_chat(affected_mob, span_danger("You feel [pick("the magic bubbling in your veins","that this location gives you a +1 to INT","an urge to summon familiar")]."))
		if(4)
			if(prob(10))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!","STI KALY!","EI NATH!"), forced = "wizarditis")
				return
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel [pick("the tidal wave of raw power building inside","that this location gives you a +2 to INT and +1 to WIS","an urge to teleport")]."))
				spawn_wizard_clothes(50, affected_mob)
			if(prob(1))
				teleport(affected_mob)


/datum/symptom/wizarditis/proc/spawn_wizard_clothes(chance = 0, mob/living/carbon/affected_mob)
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/wizard = affected_mob
		if(prob(chance))
			if(!istype(wizard.head, /obj/item/clothing/head/wizard))
				if(!wizard.dropItemToGround(wizard.head))
					qdel(wizard.head)
				wizard.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(wizard), ITEM_SLOT_HEAD)
			return
		if(prob(chance))
			if(!istype(wizard.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(!wizard.dropItemToGround(wizard.wear_suit))
					qdel(wizard.wear_suit)
				wizard.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(wizard), ITEM_SLOT_OCLOTHING)
			return
		if(prob(chance))
			if(!istype(wizard.shoes, /obj/item/clothing/shoes/sandal/magic))
				if(!wizard.dropItemToGround(wizard.shoes))
					qdel(wizard.shoes)
			wizard.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/magic(wizard), ITEM_SLOT_FEET)
			return
	else
		var/mob/living/carbon/wizard = affected_mob
		if(prob(chance))
			var/obj/item/staff/staff = new(wizard)
			if(!wizard.put_in_hands(staff))
				qdel(staff)


/datum/symptom/wizarditis/proc/teleport(mob/living/carbon/affected_mob)
	var/list/theareas = get_areas_in_range(80, affected_mob)
	for(var/area/space/unsafe in theareas)
		theareas -= unsafe

	if(!theareas || !theareas.len)
		return

	var/area/thearea = pick(theareas)

	var/list/L = list()
	var/turf/mob_turf = get_turf(affected_mob)
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!is_valid_z_level(T, mob_turf))
			continue
		if(T.name == "space")
			continue
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L)
		return

	affected_mob.say("SCYAR NILA [uppertext(thearea.name)]!", forced = "wizarditis teleport")
	affected_mob.forceMove(pick(L))

	return
