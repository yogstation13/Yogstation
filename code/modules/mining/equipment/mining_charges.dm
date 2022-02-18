/obj/item/grenade/plastic/miningcharge
	name = "mining charge"
	desc = "Used to make big holes in rocks. Only works on rocks!"
	icon_state = "mining-charge"
	det_time = 5 //uses real world seconds cause screw you i guess
	boom_sizes = list(1,2,4)
	alert_admins = FALSE

/obj/item/grenade/plastic/miningcharge/Initialize()
	. = ..()
	plastic_overlay = mutable_appearance(icon, "[icon_state]_active", ON_EDGED_TURF_LAYER)

/obj/item/grenade/plastic/miningcharge/attack_self(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self(user)

/obj/item/grenade/plastic/miningcharge/afterattack(atom/movable/AM, mob/user, flag)
	if(ismineralturf(AM))
		..()
	else
		to_chat(user,span_warning("The charge only works on rocks!"))

/obj/item/grenade/deconstruct(disassembled = TRUE) //no gibbing a miner with pda bombs
	if(!QDELETED(src))
		qdel(src)
