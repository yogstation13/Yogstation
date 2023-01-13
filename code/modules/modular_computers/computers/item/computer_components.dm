/obj/item/modular_computer/proc/can_install_component(obj/item/computer_hardware/try_install, mob/living/user = null)
	if(!try_install.can_install(src, user))
		return FALSE

	if(try_install.w_class > max_hardware_size)
		to_chat(user, span_warning("This component is too large for \the [src]!"))
		return FALSE

	if(try_install.expansion_hw)
		if(LAZYLEN(expansion_bays) >= max_bays)
			to_chat(user, "<span class='warning'>All of the computer's expansion bays are filled.</span>")
			return FALSE
		if(LAZYACCESS(expansion_bays, try_install.device_type))
			to_chat(user, "<span class='warning'>The computer immediately ejects /the [try_install] and flashes an error: \"Hardware Address Conflict\".</span>")
			return FALSE

	if(all_components[try_install.device_type])
		to_chat(user, span_warning("This computer's hardware slot is already occupied by \the [all_components[try_install.device_type]]."))
		return FALSE
	return TRUE


/// Installs component.
/obj/item/modular_computer/proc/install_component(obj/item/computer_hardware/install, mob/living/user = null)
	if(!can_install_component(install, user))
		return FALSE

	if(user && !user.transferItemToLoc(install, src))
		return FALSE

	if(install.expansion_hw)
		LAZYSET(expansion_bays, install.device_type, install)
	all_components[install.device_type] = install

	to_chat(user, span_notice("You install \the [install] into \the [src]."))
	install.holder = src
	install.forceMove(src)
	install.on_install(src, user)


// Uninstalls component.
/obj/item/modular_computer/proc/uninstall_component(obj/item/computer_hardware/H, mob/living/user = null)
	if(H.holder != src) // Not our component at all.
		return FALSE
	if(H.expansion_hw)

		LAZYREMOVE(expansion_bays, H.device_type)
	all_components.Remove(H.device_type)

	to_chat(user, span_notice("You remove \the [H] from \the [src]."))

	H.forceMove(get_turf(src))
	H.holder = null
	H.on_remove(src, user)
	if(enabled && !use_power())
		shutdown_computer()
	update_icon()
	return TRUE


// Checks all hardware pieces to determine if name matches, if yes, returns the hardware piece, otherwise returns null
/obj/item/modular_computer/proc/find_hardware_by_name(name)
	for(var/i in all_components)
		var/obj/O = all_components[i]
		if(O.name == name)
			return O
	return null
