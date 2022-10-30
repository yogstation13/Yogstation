#define HIJACK_TIME 2400
#define COG_TIME 2400

/mob/living/silicon/ai/proc/process_hijack()
	if(hijacking)
		if(prob(5))
			to_chat(src, span_danger("Warning! Exploitation detected at /dev/ttyS0!"))
		if(world.time >= hijack_start+HIJACK_TIME && mind)
			mind.add_antag_datum(ANTAG_DATUM_HIJACKEDAI)
			message_admins("[ADMIN_LOOKUPFLW(src)] has been hijacked!")
			icon_state = "ai-red"
			QDEL_NULL(hijacking)
			update_icons()

/mob/living/silicon/ai/proc/process_integrate()
	if(!cogging)
		return
	if(world.time >= cog_start+COG_TIME && mind)
		add_servant_of_ratvar(src)
		can_download = FALSE //rat'var protects us against the cucking console
		QDEL_NULL(cogging)

#undef HIJACK_TIME 
#undef COG_TIME