/obj/item/clothing/suit/space/space_ninja/process(delta_time)
	//Runs in the background while the suit is initialized.
	//Requires charge or stealth to process.
	if(!s_initialized)
		return //failsafe

	if(cell.charge > 0)
		if(s_coold > 0)
			s_coold = max(0, s_coold - delta_time)//Checks for ability s_cooldown first.

		cell.charge -= s_cost * delta_time//s_cost is the default energy cost each ntick, usually 5.
		if(stealth)//If stealth is active.
			cell.charge -= s_acost * delta_time

	else
		cell.charge = 0
		cancel_stealth()
