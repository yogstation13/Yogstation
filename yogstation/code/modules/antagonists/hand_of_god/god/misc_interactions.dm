#define GOD_LIGHTKILL_MAX 5
#define GOD_LIGHTKILL_COST 10
#define GOD_LIGHTKILL_RECHARGE 900

/obj/machinery/light/attack_god(mob/camera/hog_god/god, modifier = FALSE) //HoG god can kill maximum of 5 lights within a minute and a half.
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
	addtimer(CALLBACK(god, .proc/lightttts), GOD_LIGHTKILL_RECHARGE)
	
#undef GOD_LIGHTKILL_MAX
#undef GOD_LIGHTKILL_COST
#undef GOD_LIGHTKILL_RECHARGE
