//command lockers population
//RD locker
/obj/structure/closet/secure_closet/RD/PopulateContents()
	..()
	new /obj/item/clipboard/yog/paperwork/rd(src)
	new /obj/item/card/id/departmental_budget/sci(src)

//HoS locker
/obj/structure/closet/secure_closet/hos/PopulateContents()
	..()
	new /obj/item/clipboard/yog/paperwork/hos(src)

//HoP's locker
/obj/structure/closet/secure_closet/hop/PopulateContents()
	..()
	new /obj/item/clipboard/yog/paperwork/hop(src)
	new /obj/item/card/id/departmental_budget/srv(src)

//warden's locker
/obj/structure/closet/secure_closet/warden/PopulateContents()
	..()
	new /obj/item/clipboard/yog/paperwork/warden(src)
	new /obj/item/card/id/departmental_budget/sec(src)

//captain's locker
/obj/structure/closet/secure_closet/captains/PopulateContents()
	..()
	new /obj/item/clipboard/yog/paperwork/captain(src)
	new /obj/item/card/id/departmental_budget/civ(src)

//CE's locker
/obj/structure/closet/secure_closet/engineering_chief/PopulateContents()
	..()
	new /obj/item/clipboard/yog/paperwork/ce(src)
	new /obj/item/card/id/departmental_budget/eng(src)

//CMO's locker
/obj/structure/closet/secure_closet/CMO/PopulateContents()
	..()
	new /obj/item/clipboard/yog/paperwork/cmo(src)
	new /obj/item/card/id/departmental_budget/med(src)