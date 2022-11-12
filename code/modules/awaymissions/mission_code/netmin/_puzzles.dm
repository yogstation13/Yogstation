GLOBAL_VAR_INIT(decrypted_puzzle_disks, 0)

/obj/item/disk/puzzle
	name = "encrypted floppy drive"
	desc = "Likely contains the access key to a locked door."
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/decrypted = FALSE
	var/id
	var/decryption_progress = 0

/obj/item/disk/puzzle/examine(mob/user)
	. = ..()
	. += "The disk seems to be [decrypted ? "decrypted" : "encrypted"]."
