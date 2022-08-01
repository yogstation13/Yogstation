/obj/item/psychic_power/tinker
	name = "psychokinetic crowbar"
	icon_state = "tinker"
	force = 1
	tool_behaviour = TOOL_CROWBAR

/obj/item/psychic_power/tinker/attack_self()

	if(!owner || loc != owner)
		return

	var/choice = input("Select a tool to emulate.","Power") as null|anything in list(TOOL_CROWBAR, TOOL_SCREWDRIVER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, "dismiss")
	if(!choice)
		return

	if(!owner || loc != owner)
		return

	if(choice == "Dismiss")
		owner.playsound_local(soundin = 'sound/effects/psi/power_fail.ogg')
		owner.dropItemToGround(src)
		return

	tool_behaviour = choice
	name = "psychokinetic [tool_behaviour]"
	to_chat(owner, "<span class='notice'>You begin emulating \a [tool_behaviour].</span>")
	owner.playsound_local(soundin = 'sound/effects/psi/power_fabrication.ogg')
