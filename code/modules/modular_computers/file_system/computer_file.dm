/datum/computer_file
	var/filename = "NewFile" 								// Placeholder. No spacebars
	var/filetype = "XXX" 									// File full names are [filename].[filetype] so like NewFile.XXX in this case
	var/size = 1											// File size in GQ. Integers only!
	var/obj/item/computer_hardware/hard_drive/holder	// Holder that contains this file.
	var/unsendable = FALSE										// Whether the file may be sent to someone via NTNet transfer or other means.
	var/undeletable = FALSE										// Whether the file may be deleted. Setting to TRUE prevents deletion/renaming/etc.
	var/uid													// UID of this file
	var/static/file_uid = 0
	var/can_print = FALSE

/datum/computer_file/New()
	..()
	uid = file_uid++

/datum/computer_file/Destroy()
	if(!holder)
		return ..()

	holder.remove_file(src)
	// holder.holder is the computer that has drive installed. If we are Destroy()ing program that's currently running kill it.
	if(holder.holder && holder.holder.active_program == src)
		holder.holder.kill_program(forced = TRUE)
	holder = null
	return ..()

// Returns independent copy of this file.
/datum/computer_file/proc/clone(rename = FALSE)
	var/datum/computer_file/temp = new type
	temp.unsendable = unsendable
	temp.undeletable = undeletable
	temp.size = size
	if(rename)
		temp.filename = filename + "(Copy)"
	else
		temp.filename = filename
	temp.filetype = filetype
	return temp

/datum/computer_file/proc/calculate_size()
	return

/datum/computer_file/proc/get_contents()
	return

/datum/computer_file/proc/get_all_contents()
	var/list/contents = get_contents()
	var/list/all_contents = contents
	for(var/datum/computer_file/file in contents)
		all_contents |= file.get_all_contents()
	return all_contents

/datum/computer_file/proc/print(var/drop = FALSE)
	return
