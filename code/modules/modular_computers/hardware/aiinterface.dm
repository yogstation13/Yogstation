/obj/item/computer_hardware/ai_interface
	name = "portable AI network interface"
	desc = "A module allowing this computer to interface with local AI networks. Only works with portable computers"
	power_usage = 15 //W
	icon_state = "card_mini"
	w_class = WEIGHT_CLASS_SMALL // Can't be installed into tablets/PDAs
	device_type = MC_AI_NETWORK
	expansion_hw = TRUE

	var/obj/structure/ethernet_cable/connected_cable = null


// Called when component is installed into PC.
/obj/item/computer_hardware/ai_interface/on_install(obj/item/modular_computer/M, mob/living/user = null)
	RegisterSignal(M, COMSIG_MOVABLE_MOVED, .proc/parent_moved)


/obj/item/computer_hardware/ai_interface/on_remove(obj/item/modular_computer/M, mob/living/user = null)	
	UnregisterSignal(M, COMSIG_MOVABLE_MOVED)
	connected_cable = null

/obj/item/computer_hardware/ai_interface/proc/parent_moved()	
	if(connected_cable)
		if(!connected_cable.Adjacent(holder.physical))
			connected_cable = null

/obj/item/computer_hardware/ai_interface/proc/connect_cable(obj/structure/ethernet_cable/EC)
	connected_cable = EC
	//TODO: Reset timers and such in here

/obj/item/computer_hardware/ai_interface/proc/get_network()
	if(!connected_cable)
		return FALSE
	return connected_cable.network


/obj/item/computer_hardware/ai_interface/can_install(obj/item/modular_computer/M, mob/living/user = null)
	if(!ismachinery(M.physical) && !M.physical.anchored)
		return ..()
	to_chat(user, span_warning("\The [src] is incompatible with stationary computers!"))
	return FALSE
