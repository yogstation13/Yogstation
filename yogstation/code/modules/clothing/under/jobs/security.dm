/obj/item/clothing/under/yogs/krofficer
	name = "armory officer uniform"
	desc = "You have one job, don't screw it up."
	icon_state = "kr_officer_s"
	item_state = "kr_officer"
	item_color = "kr_officer_s"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE
	can_adjust = FALSE

//Brig Physician
/obj/item/clothing/under/yogs/rank/physician
	name = "brig physician's jumpsuit"
	desc = "A verstile blue and white uniform honored to hard working brig physicians who help with injured prisoners and security personel."
	icon_state = "recovery"
	item_state = "recovery"
	item_color = "recovery"
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION //I need to clean this code
	digiversion = TRUE
	digiadjusted = TRUE

/obj/item/clothing/under/yogs/rank/physician/white
	name = "white brig physician's jumpsuit"
	desc = "A classic jumpsuit that connects you to your medsci brothers and sisters."
	icon_state = "secwhite"
	item_state = "secwhite"
	item_color = "secwhite"
	alt_covers_chest = FALSE
	random_sensor = TRUE
	can_adjust = TRUE
	digiadjusted = TRUE

/obj/item/clothing/under/yogs/rank/physician/white/skirt
	name = "white brig physician's jumpskirt"
	desc = "A classic jumpskirt that connects you to your medsci brothers and sisters."
	icon_state = "secwhite_skirt"
	item_state = "secwhite_skirt"
	item_color = "secwhite_skirt"
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	digiversion = FALSE
	digiadjusted = FALSE
