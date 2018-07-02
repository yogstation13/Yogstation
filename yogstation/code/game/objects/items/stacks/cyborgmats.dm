#define BORG_MATERIAL_AMOUNT round(source.energy / cost)

/obj/item/stack/cable_coil/cyborg
	materials = list(MAT_METAL=BORG_MATERIAL_AMOUNT * 10, MAT_GLASS=BORG_MATERIAL_AMOUNT * 5)

/obj/item/stack/rods/cyborg
	materials = list(MAT_METAL=(BORG_MATERIAL_AMOUNT * (MINERAL_MATERIAL_AMOUNT * 0.5))

/obj/item/stack/sheet/glass/cyborg
	materials = list(MAT_GLASS=(BORG_MATERIAL_AMOUNT * MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/rglass/cyborg
	materials = list(MAT_METAL=(BORG_MATERIAL_AMOUNT * (MINERAL_MATERIAL_AMOUNT * 0.5), MAT_GLASS=(BORG_MATERIAL_AMOUNT * MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/metal/cyborg
	materials = list(MAT_METAL=(BORG_MATERIAL_AMOUNT * MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/tile/plasteel/cyborg
	materials = list(MAT_METAL=(BORG_MATERIAL_AMOUNT * (MINERAL_MATERIAL_AMOUNT * 0.25))