/*
Makes variations possible with code only.
This is mainly to prevent creating new map files when creating variations if possible. - Hopek
*/

/obj/effect/variation
	name = "variation"
	icon = 'icons/effects/landmarks_variation.dmi'
	icon_state = "generic_green"
	var/variations // number of variations
	var/choice // chosen variation by choice()
	var/chosen // has a choice been made for this place?
	var/location_place // location of placement calculated from reference
	var/ref_x // x of reference
	var/ref_y // y of reference
	var/ref_z // z of reference

/obj/effect/variation/Initialize()
	chosen = FALSE

/obj/effect/variation/proc/place(x, y , item , direction)
	if(!x)
		x = 0
	if(!y)
		y = 0
	if(item)
		location_place = locate((ref_x + x) , (ref_y + y) , ref_z)
		if(islist(item))
			for(var/I in item)
				if(direction)
					var/obj/H = new I(location_place)
					H.dir = direction
					return
				else
					new I(location_place)
		else
			if(direction)
				var/obj/H = new item(location_place)
				H.dir = direction
			else
				new item(location_place)
	return

/obj/effect/variation/proc/choice()
	if(choice == "" || choice == 0)
		choice = 1
	if(!chosen)
		ref_x = src.x
		ref_y = src.y
		ref_z = src.z
		qdel(src) // deletes the landmark after storing location values in choice() so it doesn't show up on the final product
		chosen = TRUE
		choice = rand(1,variations)
		log_world("Chosen variation [choice] out of [variations] for [name]. Spawning on [ref_x],[ref_y],[ref_z].")
		return choice
	else
		return choice

// sec

obj/effects/variation/sec
	icon = 'icons/effects/landmarks_variation.dmi'
	icon_state = "generic_red"

/obj/effect/variation/box/sec/brig_cell
	name = "Brig cell variation"
	variations = 2
	
/obj/effect/variation/box/sec/brig_cell/Initialize()
	 // chooses between two basic cell variations

	var/list/bed = list(
		/obj/structure/bed,
		/obj/item/bedsheet/prisoner
	)
	var/closet = /obj/structure/closet/secure_closet/brig/cell

	if(choice() == 1)
		//variation 1 , default;  bed left side
		place(0,0,bed)
		place(2,0,closet)

	if(choice() == 2)
		//variation 2 , bed right side
		place(2,0,bed)
		place(0,0,closet)
	

/obj/effect/variation/box/sec/brig_cell/perma
	name = "perma cell variation"
	variations = 4

/obj/effect/variation/box/sec/brig_cell/perma/Initialize() // chooses between four perma cell variations

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

	if(choice() == 1)
		//variation 1 ; Default . 
		place(0,1,bed)
		place(2,0,table)
		place(2,1,stool)

	if(choice() == 2)
		//variation 2 ; bed right corner
		place(2,1,bed)
		place(0,0,table)
		place(0,1,stool)

	if(choice() == 3)
		//variation 3 ; bed bottom left corner
		place(0,0,bed)
		place(2,1,table)
		place(2,0,stool)

	if(choice() == 4)
		//variation 4 ; bed bottom right corner
		place(2,0,bed)
		place(0,1,table)
		place(0,0,stool)


// Medbay

/obj/effect/variation/box/medbay/morgue
	name = "Morgue variation"
	variations = 5

/obj/effect/variation/box/medbay/morgue/Initialize()

	var/table = /obj/structure/table
	var/box = /obj/item/storage/box/bodybags
	var/pen = /obj/item/pen
	var/paper = /obj/item/paper/guides/jobs/medical/morgue
	var/casket = /obj/structure/bodycontainer/morgue

	if(choice() == 1)
		// variation 1; default
		place(0,0,table)
		place(0,4,table)
		place(0,0,paper)
		place(0,4,box)
		place(0,4,pen)
		place(0,1,casket,EAST)
		place(0,2,casket,EAST)
		place(0,3,casket,EAST)
		place(3,1,casket,WEST)
		place(3,2,casket,WEST)
		place(3,3,casket,WEST)
		place(4,1,casket,EAST)
		place(4,2,casket,EAST)
		place(4,3,casket,EAST)

	if(choice() == 2)
		// variation 2
		place(0,0,table)
		place(0,1,table)
		place(0,0,paper)
		place(0,1,box)
		place(0,1,pen)
		place(2,0,casket,NORTH)
		place(3,0,casket,NORTH)
		place(4,0,casket,NORTH)
		place(2,2,casket,WEST)
		place(3,2,casket,EAST)
		place(5,3,casket,WEST)
		place(0,4,casket,SOUTH)
		place(1,4,casket,SOUTH)
		place(2,4,casket,SOUTH)

	if(choice() == 3)
		// variation 3; default
		place(0,0,table)
		place(0,4,table)
		place(0,0,paper)
		place(0,4,box)
		place(0,4,pen)
		place(0,1,casket,EAST)
		place(0,2,casket,EAST)
		place(0,3,casket,EAST)
		place(2,4,casket,SOUTH)
		place(2,0,casket,NORTH)
		place(3,0,casket,NORTH)
		place(5,1,casket,WEST)
		place(5,2,casket,WEST)
		place(5,3,casket,WEST)

	if(choice() == 4)
		// variation 4; default
		place(4,3,table)
		place(4,3,box)
		place(4,3,paper)
		place(4,3,pen)
		place(0,0,casket,NORTH)
		place(0,2,casket,EAST)
		place(0,4,casket,SOUTH)
		place(1,4,casket,SOUTH)
		place(2,0,casket,NORTH)
		place(3,0,casket,NORTH)
		place(3,2,casket,WEST)
		place(3,3,casket,WEST)
		place(4,2,casket,EAST)

	if(choice() == 5)
		// variation 5; default
		place(1,2,table)
		place(1,3,table)
		place(1,2,paper)
		place(1,3,box)
		place(1,3,pen)
		place(2,0,casket,WEST)
		place(3,0,casket,EAST)
		place(2,2,casket,SOUTH)
		place(2,3,casket,NORTH)
		place(3,2,casket,SOUTH)
		place(3,3,casket,NORTH)
		place(5,1,casket,EAST)
		place(5,2,casket,EAST)
		place(5,3,casket,EAST)
