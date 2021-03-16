/obj/item/clothing/shoes/yogs/trainers
	name = "Black and white sneakers"
	desc = "Cheaply made shoes endorsed by several famous rappers such as Lil' Ling, XXXGreentext and Ash Drake, they're comfortable and have a reactive midsole. This pair is black and white."
	icon_state = "oreo"
	item_state = "oreo"

/obj/item/clothing/shoes/yogs/trainers/red
	name = "Black and red sneakers"
	desc = "Cheaply made shoes endorsed by several famous rappers such as Lil' Ling, XXXGreentext and Ash Drake, they're comfortable and have a reactive midsole. This pair looks familiar."
	icon_state = "red"
	item_state = "red"

/obj/item/clothing/shoes/yogs/trainers/white
	name = "Quadrouple white sneakers"
	desc = "Cheaply made shoes endorsed by several famous rappers such as Lil' Ling, XXXGreentext and Ash Drake, they're comfortable and have a reactive midsole. This pair is white."
	icon_state = "cream"
	item_state = "cream"

/obj/item/clothing/shoes/yogs/trainers/zebra
	name = "Zebra print sneakers"
	desc = "Cheaply made shoes endorsed by several famous rappers such as Lil' Ling, XXXGreentext and Ash Drake, they're comfortable and have a reactive midsole. Put them back in the zoo enclosure you got them from."
	icon_state = "zebra"
	item_state = "zebra"

/obj/item/clothing/shoes/yogs/trainers/darkbrown
	name = "Rare brown sneakers"
	desc = "A fine example of artificial scarcity at its finest! This pair of sneakers is worth a worrying amount of money"
	icon_state = "moonrock"
	item_state = "moonrock"

/obj/item/clothing/shoes/yogs/trainers/black
	name = "Rare vox black sneakers"
	desc = "A fine example of artificial scarcity at its finest! This pair of sneakers is worth a worrying amount of money. This pair is black and red."
	icon_state = "pirate"
	item_state = "pirate"

/obj/item/shoe_protector
	icon = 'yogstation/icons/obj/shoeprotector.dmi'
	name = "cleaning spray"
	icon_state = "shoeprotect"
	desc = "A spray that will clean the blood off of shoes / clothing items, the product description is written exclusively in slang using hip terms such as 'family' and 'Brudda'."
	var/charges = 10
	var/max_charges = 10
	var/infinite = FALSE


/obj/item/shoe_protector/ultra
	icon_state = "ultraprotect"
	name = "mt-x04 Multiphasic 'Flux' temporally shifted shoe cleaning spray"
	desc = "This shoe cleaning spray uses the latest in reverse temporal engineering to retroactively go back in time to when it was being made (in its current, unfilled state) so that the factory automatically fills it back up for you as if it were hot off the assembly line, meaning that this spraycan will still be full of liquid long after the universe ends."
	charges = 20
	max_charges = 20
	infinite = TRUE

/obj/item/shoe_protector/examine(mob/user)
	. = ..()
	. += "This bottle has [charges*10] ml of [max_charges*10] ml left in it"

/obj/item/shoe_protector/afterattack(obj/I, mob/user)
	.=..()
	if(infinite && !charges)
		to_chat(user, "WARNING! Low liquid volume detected. Engaging time-jump.")
		do_time_jump()
		return FALSE
	if(istype(I, /obj/item/clothing))
		if(charges)
			I.wash(CLEAN_WASH)
			playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
			to_chat(user, "You've successfully cleaned [I] with [src]")
			charges --

/obj/item/shoe_protector/proc/do_time_jump()
	visible_message("[src] fades out of existence!")
	playsound(src.loc, 'sound/effects/empulse.ogg', 100, 1)
	playsound(get_turf(src), 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
	icon_state = "ultraprotect-timejump"
	charges = 0
	infinite = FALSE
	SpinAnimation(1000,1)
	addtimer(CALLBACK(src, .proc/do_time_jump_return), 50)

/obj/item/shoe_protector/proc/do_time_jump_return()
	playsound(src.loc, 'sound/effects/empulse.ogg', 100, 1)
	playsound(get_turf(src), 'sound/magic/ethereal_enter.ogg', 50, 1, -1)
	icon_state = initial(icon_state)
	charges = max_charges
	infinite = TRUE
	SpinAnimation(0,0)
	visible_message("[src] pops back into existence! It's fully refilled.")
