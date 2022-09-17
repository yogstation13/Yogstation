GLOBAL_VAR_INIT(powersink_transmitted, 0)

/obj/item/powersink/examine(mob/user)
	. = ..()
	. += "The power dial reads [DisplayPower(power_drained)] out of [DisplayPower(max_power)]."

/obj/item/powersink/process()
	if(!attached)
		set_mode(DISCONNECTED)
		return

	var/datum/powernet/PN = attached.powernet
	if(PN)
		set_light(5)

		// found a powernet, so drain up to max power from it

		var/drained = min ( drain_rate, PN.avail )
		PN.load += drained
		power_drained += drained
		on_drain(drained)

	if(power_drained > max_power * 0.98)
		if (!admins_warned)
			admins_warned = TRUE
			message_admins("Power sink at ([x],[y],[z] - <A HREF='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) is 95% full. Explosion imminent.")
		playsound(src, 'sound/effects/screech.ogg', 100, 1, 1)

	if(power_drained >= max_power)
		STOP_PROCESSING(SSobj, src)
		explosion(src.loc, 4,8,16,32)
		qdel(src)

/obj/item/powersink/proc/on_drain(drained)
	var/datum/powernet/PN = attached.powernet
	if(drained < drain_rate)
		for(var/obj/machinery/power/terminal/T in PN.nodes)
			if(istype(T.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = T.master
				if(A.operating && A.cell)
					A.cell.charge = max(0, A.cell.charge - 50)
					power_drained += 50
					if(A.charging == 2) // If the cell was full
						A.charging = 1 // It's no longer full
