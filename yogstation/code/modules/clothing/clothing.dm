/obj/item/clothing/ears/yogs
	alternate_worn_icon = 'yogstation/icons/mob/ears.dmi'
	icon = 'yogstation/icons/obj/clothing/ears.dmi'

/obj/item/clothing/glasses/yogs
	alternate_worn_icon = 'yogstation/icons/mob/eyes.dmi'
	icon = 'yogstation/icons/obj/clothing/glasses.dmi'

/obj/item/clothing/gloves/yogs
	alternate_worn_icon = 'yogstation/icons/mob/hands.dmi'
	icon = 'yogstation/icons/obj/clothing/gloves.dmi'

/obj/item/clothing/head/yogs
	alternate_worn_icon = 'yogstation/icons/mob/head.dmi'
	icon = 'yogstation/icons/obj/clothing/hats.dmi'

/obj/item/clothing/neck/yogs
	alternate_worn_icon = 'yogstation/icons/mob/neck.dmi'
	icon = 'yogstation/icons/obj/clothing/neck.dmi'

/obj/item/clothing/mask/yogs
	alternate_worn_icon = 'yogstation/icons/mob/mask.dmi'
	icon = 'yogstation/icons/obj/clothing/masks.dmi'

/obj/item
	var/list/alternate_screams = list()

/obj/item/clothing/shoes/yogs
	alternate_worn_icon = 'yogstation/icons/mob/feet.dmi'
	icon = 'yogstation/icons/obj/clothing/shoes.dmi'

/obj/item/clothing/suit/yogs
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'

/obj/item/clothing/under/yogs
	alternate_worn_icon = 'yogstation/icons/mob/uniform.dmi'
	icon = 'yogstation/icons/obj/clothing/uniforms.dmi'

/obj/item/clothing/back/yogs
	alternate_worn_icon = 'yogstation/icons/mob/back.dmi'
	icon = 'yogstation/icons/obj/clothing/back.dmi'

/obj/item/storage/belt/yogs
	alternate_worn_icon = 'yogstation/icons/mob/belt.dmi'
	icon = 'yogstation/icons/obj/clothing/belts.dmi'
	
/obj/item/clothing/torncloth
	name = "strip of torn cloth"
	desc = "Looks like it was pulled from a piece of clothing with considerable force. Could be used for a makeshift bandage if worked a little bit on a sturdy surface."
	icon = 'yogstation/icons/obj/items.dmi'
	icon_state = "clothscrap"
	
/obj/item/clothing/under/proc/handle_tear(mob/user)
	if(!tearable)
		return

	take_teardamage(20)
	permeability_coefficient += 0.20
	if (user)
		if (user.loc)
			new /obj/item/clothing/torncloth(user.loc)
			if(!QDELETED(src))
				user.visible_message("You hear cloth tearing.", "A segment of [src] falls away to the floor, torn apart.", "*riiip*")
	return TRUE
	
/obj/item/clothing/under/proc/take_teardamage(amount)
	var/bearer = loc
	if(tearhealth - amount < 0)
		visible_message(break_message(), break_message())
		qdel(src)
	if (ishuman(bearer))
		var/mob/living/carbon/human/H = bearer
		H.update_inv_w_uniform()
	tearhealth -= amount
	
/obj/item/clothing/under/verb/rip()
	set name = "Tear cloth from garment"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	src.handle_tear(usr)
	
/obj/item/clothing/under/proc/break_message()
	return "<span class='warning'>[src] falls apart and breaks!</span>"
	
/obj/item/clothing/under/examine(mob/user)
	..()
	if(tearhealth)
		switch (tearhealth)
			if (100)
				to_chat(user, "It appears to be in pristine condition.")
			if (80)
				to_chat(user, "The garment appears to be torn slightly.")
			if (60)
				to_chat(user, "Segments of the fabric are torn away to the seams.")
			if (40)
				to_chat(user, "The garment is badly damaged, several seams completely torn away.")
			if (20)
				to_chat(user, "The basic form of the garment is barely holding together, the bulk badly torn.")