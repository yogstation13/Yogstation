/obj/item/disk/artifact
	name = "artifact data disk"
	desc = "A disk for storing an artifacts effect data. Can be put into an xray machine to maybe copy artifact data, or an artifact wand for it's effect."
	icon_state = "rndmajordisk"
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)
	var/datum/artifact_effect/effect
	var/datum/artifact_activator/activator
	var/datum/artifact_fault/fault
	var/read_only = FALSE //Well, it's still a floppy disk
	obj_flags = UNIQUE_RENAME
/obj/item/disk/artifact/update_name(updates)
	. = ..()
	var/newname = ""
	if(effect)
		newname += " ([effect.type_name]) "
	if(activator)
		newname += " |[activator.name]| "
	if(fault)
		newname += " ![fault.name]! "
	name = initial(name) + newname

/obj/item/disk/artifact/attack_self(mob/user)
	read_only = !read_only
	to_chat(user, "<span class='notice'>You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"].</span>")

/obj/item/disk/artifact/examine(mob/user)
	. = ..()
	. += "The write-protect tab is set to [src.read_only ? "protected" : "unprotected"]."
