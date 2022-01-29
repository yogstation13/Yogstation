// ===== SECURITY =====

obj/effects/variation/sec
	icon = 'icons/effects/landmarks_variation.dmi'
	icon_state = "generic_red"

/obj/effect/variation/box/sec/brig_cell
	name = "Brig cell variation"
	variations = 2

/obj/effect/variation/box/sec/brig_cell/placement()
	// chooses between two basic cell variations

	var/list/bed = list(
		/obj/structure/bed,
		/obj/item/bedsheet/prisoner
	)
	var/closet = /obj/structure/closet/secure_closet/brig/cell

	switch(choice())
		if(1)
			//variation 1 , default;  bed left side
			place(0, 0, bed)
			place(2, 0, closet)
	
		if(2)
			//variation 2 , bed right side
			place(2, 0, bed)
			place(0, 0, closet)


/obj/effect/variation/box/sec/brig_cell/perma
	name = "perma cell variation"
	variations = 4

/obj/effect/variation/box/sec/brig_cell/perma/placement()
	// chooses between four perma cell variations

	var/list/bed = list(
		/obj/structure/bed,
		/obj/item/bedsheet/prisoner
	)
	var/list/table = list(
		/obj/structure/table,
		/obj/item/paper,
		/obj/item/pen
	)
	var/stool = /obj/structure/chair/stool
	
	switch(choice())
		if(1)
			//variation 1 ; Default . 
			place(0, 1, bed)
			place(2, 0, table)
			place(2, 1, stool)

		if(2)
			//variation 2 ; bed right corner
			place(2, 1, bed)
			place(0, 0, table)
			place(0, 1, stool)

		if(3)
			//variation 3 ; bed bottom left corner
			place(0, 0, bed)
			place(2, 1, table)
			place(2, 0, stool)

		if(4)
			//variation 4 ; bed bottom right corner
			place(2, 0, bed)
			place(0, 1, table)
			place(0, 0, stool)
