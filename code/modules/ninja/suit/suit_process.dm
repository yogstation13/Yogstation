/obj/item/clothing/suit/space/space_ninja/proc/ntick(mob/living/carbon/human/U = affecting)
	//Runs in the background while the suit is initialized.
	//Requires charge or stealth to process.
	spawn while(s_initialized)
		if(!affecting)
			terminate()//Kills the suit and attached objects.

		else if(cell.charge > 0)
			if(s_coold > 0)
				s_coold-- //Checks for ability s_cooldown first.

			cell.charge -= s_cost * delta_time//s_cost is the default energy cost each ntick, usually 5.
			if(stealth)//If stealth is active.
				cell.charge -= s_acost * delta_time

		else
			cell.charge = 0
			cancel_stealth()

		sleep(1 SECONDS)//Checks every second.
