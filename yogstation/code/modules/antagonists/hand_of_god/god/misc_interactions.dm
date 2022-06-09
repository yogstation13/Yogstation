#define GOD_LIGHTKILL_MAX 5
#define GOD_LIGHTKILL_COST 10
#define GOD_LIGHTKILL_RECHARGE 900

/obj/machinery/light/attack_god(mob/camera/hog_god/god, modifier) //HoG god can kill maximum of 5 lights within a minute and a half.
	if(god.lights_breaked_recently >= GOD_LIGHTKILL_MAX)
		to_chat(god, span_notice("You breaked too much lights recently. Go and have a break."))
		return
	if(god.cult.energy < GOD_LIGHTKILL_COST)
		to_chat(god, span_notice("You don't have enough energy to break the light, you need atleast [GOD_LIGHTKILL_COST]."))
		flicker(rand(10, 20))
		return
	break_light_tube(0)	
	god.cult.energy -= GOD_LIGHTKILL_COST
	god.lights_breaked_recently += 1
	god.lighttimer(GOD_LIGHTKILL_RECHARGE)
	
#undef GOD_LIGHTKILL_MAX
#undef GOD_LIGHTKILL_COST
#undef GOD_LIGHTKILL_RECHARGE

#define GOD_APC_DISABLE_COST 90
#define GOD_APC_DISABLE_DURATION 30 SECONDS
#define GOD_APC_DISABLE_CAST 3 SECONDS

/obj/machinery/power/apc/attack_god(mob/camera/hog_god/god, modifier)
	if(god.cult.energy < GOD_APC_DISABLE_COST)
		to_chat(god, span_notice("You don't have enough energy to disable this APC, you need atleast [GOD_APC_DISABLE_COST]."))
		return
	to_chat(god, span_notice("You start disabling the APC..."))
	do_sparks(5, TRUE, src)
	if(!do_after(god, GOD_APC_DISABLE_CAST, src))
		return
	if(god.cult.energy < GOD_APC_DISABLE_COST) //Check again
		to_chat(god, span_notice("You fail to disable the APC."))	
		return
	if(energy_fail(GOD_APC_DISABLE_DURATION))
		to_chat(god, span_notice("You sucessfully disable the APC."))	
		god.cult.energy -= GOD_APC_DISABLE_COST
	else 	
		to_chat(god, span_notice("You fail to disable the APC."))	

#undef GOD_APC_DISABLE_COST 
#undef GOD_APC_DISABLE_DURATION 
#undef GOD_APC_DISABLE_CAST 
