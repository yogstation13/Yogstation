/datum/symptom/anime_hair
	name = "Pro-tagonista Syndrome"
	desc = "Causes the infected to believe they are the center of the universe. Outcome may vary depending on symptom strength."
	stage = 3
	max_count = 1
	max_chance = 20
	max_multiplier = 4
	badness = EFFECT_DANGER_ANNOYING
	severity = 3
	/// The affected mob's old hair color, so it can be restored upon deactivation.
	var/old_haircolor = ""
	/// A weakref to the katana given by the symptom, so it can be destroyed upon deactivation.
	var/datum/weakref/katana_ref

/datum/symptom/anime_hair/first_activate(mob/living/carbon/mob)
	mob.AddComponentFrom(REF(src), /datum/component/fluffy_tongue)

/datum/symptom/anime_hair/activate(mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		var/list/hair_colors = list("pink","red","green","blue","purple")
		var/hair_color = pick(hair_colors)

		old_haircolor = affected.hair_color

		if(!isethereal(affected)) //ethereals have weird custom hair color handling
			switch(hair_color)
				if("pink")
					affected.hair_color = "#e983d8"
				if("red")
					affected.hair_color = "#E01631"
				if("green")
					affected.hair_color = "#008000"
				if("blue")
					affected.hair_color = "#0000FF"
				if("purple")
					affected.hair_color = "#800080"
			affected.update_body()

		if(multiplier)
			if(multiplier >= 1.5)
				//Give them schoolgirl outfits /obj/item/clothing/under/costume/schoolgirl
				var/list/outfits = list(
					/obj/item/clothing/under/costume/schoolgirl,
					/obj/item/clothing/under/costume/schoolgirl/red,
					/obj/item/clothing/under/costume/schoolgirl/green,
					/obj/item/clothing/under/costume/schoolgirl/orange
					)
				var/outfit_path = pick(outfits)
				var/obj/item/clothing/under/costume/schoolgirl/schoolgirl = new outfit_path
				ADD_TRAIT(schoolgirl, TRAIT_NODROP, REF(src))
				if(affected.w_uniform && !istype(affected.w_uniform, /obj/item/clothing/under/costume/schoolgirl))
					affected.dropItemToGround(affected.w_uniform,1)
					affected.equip_to_slot(schoolgirl, ITEM_SLOT_ICLOTHING)
				if(!affected.w_uniform)
					affected.equip_to_slot(schoolgirl, ITEM_SLOT_ICLOTHING)
			if(multiplier >= 1.8)
				//Kneesocks /obj/item/clothing/shoes/kneesocks
				var/obj/item/clothing/shoes/kneesocks/kneesock = new /obj/item/clothing/shoes/kneesocks
				ADD_TRAIT(kneesock, TRAIT_NODROP, REF(src))
				if(affected.shoes && !istype(affected.shoes, /obj/item/clothing/shoes/kneesocks))
					affected.dropItemToGround(affected.shoes,1)
					affected.equip_to_slot(kneesock, ITEM_SLOT_FEET)
				if(!affected.w_uniform)
					affected.equip_to_slot(kneesock, ITEM_SLOT_FEET)

			if(multiplier >= 2)
				//Regular cat ears /obj/item/clothing/head/kitty
				var /obj/item/clothing/head/costume/kitty/kitty = new  /obj/item/clothing/head/costume/kitty
				if(affected.head && !istype(affected.head,  /obj/item/clothing/head/costume/kitty))
					affected.dropItemToGround(affected.head, TRUE)
					affected.equip_to_slot(kitty, ITEM_SLOT_HEAD)
				if(!affected.head)
					affected.equip_to_slot(kitty, ITEM_SLOT_HEAD)

			if(multiplier >= 2.5 && !katana_ref && !QDELETED(mob.client) && !mob.client.is_afk()) // if you wish to use the weapon of an anime protagonist, you must accept the consequences of looking like one
				var/katana_type = (multiplier >= 3) ? /obj/item/katana : /obj/item/toy/katana
				var/obj/item/katana = new katana_type
				if(affected.put_in_hands(katana, del_on_fail = TRUE))
					katana_ref = WEAKREF(katana)

/datum/symptom/anime_hair/deactivate(mob/living/carbon/mob)
	mob.RemoveComponentSource(REF(src), /datum/component/fluffy_tongue)
	to_chat(mob, span_notice("You no longer feel quite like the main character."))
	var/obj/item/katana = katana_ref?.resolve()
	if(!QDELETED(katana))
		var/turf/drop_loc = katana.drop_location()
		var/mob/katana_loc = katana.loc
		if(ismob(katana_loc))
			katana_loc.temporarilyRemoveItemFromInventory(katana, force = TRUE)
			katana_loc.visible_message(span_warning("[katana_loc]'s [katana] rapidly crumbles to dust!"), span_danger("Your [katana] rapidly crumbles to dust, turning into a useless pile of ash on the floor!"))
		else if(isturf(katana_loc))
			katana_loc.visible_message(span_warning("\The [katana] rapidly crumbles to dust, turning into a useless pile of ash on the floor!"))
		if(drop_loc)
			new /obj/effect/decal/cleanable/ash(drop_loc)
		qdel(katana)
	katana_ref = null
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		if(affected.shoes && istype(affected.shoes, /obj/item/clothing/shoes/kneesocks))
			REMOVE_TRAIT(affected.shoes, TRAIT_NODROP, REF(src))
		if(affected.w_uniform && istype(affected.w_uniform, /obj/item/clothing/under/costume/schoolgirl))
			REMOVE_TRAIT(affected.w_uniform, TRAIT_NODROP, REF(src))

		affected.hair_color = old_haircolor
