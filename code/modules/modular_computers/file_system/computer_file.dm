/datum/computer_file
	///The name of the internal file shown in file management.
	var/filename = "NewFile"
	///The type of file format the file is in, placed after filename. PNG, TXT, ect. This would be NewFile.XXX
	var/filetype = "XXX"
	///How much GQ storage space the file will take to store. Integers only!
	var/size = 1
	///Holder that contains this file.
	var/obj/item/computer_hardware/hard_drive/holder
	///Whether the file may be sent to someone via NTNet transfer or other means.
	var/unsendable = FALSE
	///Whether the file may be deleted. Setting to TRUE prevents deletion/renaming/etc.
	var/undeletable = FALSE
	///The computer file's personal ID
	var/uid
	///Static ID to ensure all IDs are unique.
	var/static/file_uid = 0

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

/datum/computer_file/proc/try_insert(obj/item/inserted_item, mob/living/user = null)
	return FALSE
