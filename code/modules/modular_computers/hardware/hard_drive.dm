/obj/item/computer_hardware/hard_drive
	name = "hard disk drive"
	desc = "A small HDD, for use in basic computers where power efficiency is desired."
	power_usage = 25
	icon_state = "harddisk_mini"
	critical = 1
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_HDD
	var/max_capacity = 128
	var/used_capacity = 0
	var/list/stored_files = list()		// List of stored files on this drive. DO NOT MODIFY DIRECTLY!
	///Static list of default programs that come with ALL computers, here so computers don't have to repeat this.
	///Yog TODO: IT SHOULD BE STATIC BUT IT ISN'T BECAUSE WE HANDLE THE HARD DRIVES AWKWARDLY
	var/list/datum/computer_file/default_programs = list(
		/datum/computer_file/program/computerconfig,
		/datum/computer_file/program/ntnetdownload,
		/datum/computer_file/program/filemanager,
	)

/obj/item/computer_hardware/hard_drive/Initialize(mapload)
	. = ..()
	install_default_programs()

/obj/item/computer_hardware/hard_drive/Destroy()
	for(var/file in stored_files)
		qdel(file)
	stored_files = null
	return ..()

/obj/item/computer_hardware/hard_drive/on_remove(obj/item/modular_computer/remove_from, mob/user)
	remove_from.shutdown_computer()

/obj/item/computer_hardware/hard_drive/proc/install_default_programs()
	for(var/programs in default_programs)
		var/datum/computer_file/program_type = new programs
		store_file(program_type)

/obj/item/computer_hardware/hard_drive/examine(user)
	. = ..()
	. += span_notice("It has [max_capacity] GQ of storage capacity.")

/obj/item/computer_hardware/hard_drive/diagnostics(mob/user)
	..()
	// 999 is a byond limit that is in place. It's unlikely someone will reach that many files anyway, since you would sooner run out of space.
	to_chat(user, "NT-NFS File Table Status: [stored_files.len]/999")
	to_chat(user, "Storage capacity: [used_capacity]/[max_capacity]GQ")

// Use this proc to add file to the drive. Returns the file on success and FALSE on failure. Contains necessary sanity checks.
/obj/item/computer_hardware/hard_drive/proc/store_file(datum/computer_file/file_storing)
	if(!can_store_file(file_storing))
		return FALSE

	if(!check_functionality())
		return FALSE

	if(!stored_files)
		return FALSE

	// This file is already stored. Don't store it again.
	if(file_storing in stored_files)
		return TRUE

	file_storing.holder = src

	if(istype(file_storing, /datum/computer_file/program))
		var/datum/computer_file/program/P = file_storing
		P.computer = holder

	stored_files.Add(file_storing)
	recalculate_size()
	return file_storing

// Use this proc to remove file from the drive. Returns TRUE on success and FALSE on failure. Contains necessary sanity checks.
/obj/item/computer_hardware/hard_drive/proc/remove_file(datum/computer_file/file_removing)
	if(!file_removing || !istype(file_removing))
		return FALSE

	if(!stored_files)
		return FALSE

	if(!check_functionality())
		return FALSE

	if(file_removing in stored_files)
		stored_files -= file_removing
		recalculate_size()
		return TRUE
	return FALSE

// Loops through all stored files and recalculates used_capacity of this drive
/obj/item/computer_hardware/hard_drive/proc/recalculate_size()
	var/total_size = 0
	for(var/datum/computer_file/F in stored_files)
		total_size += F.size

	used_capacity = total_size

// Checks whether file can be stored on the hard drive. We can only store unique files, so this checks whether we wouldn't get a duplicity by adding a file.
/obj/item/computer_hardware/hard_drive/proc/can_store_file(datum/computer_file/file_storing)
	if(!file_storing || !istype(file_storing))
		return FALSE

	if(file_storing in stored_files)
		return FALSE

	var/name = file_storing.filename + "." + file_storing.filetype
	for(var/datum/computer_file/file in stored_files)
		if((file.filename + "." + file.filetype) == name)
			return FALSE

	// In the unlikely event someone manages to create that many files.
	// BYOND is acting weird with numbers above 999 in loops (infinite loop prevention)
	if(stored_files.len >= 999)
		return FALSE
	if((used_capacity + file_storing.size) > max_capacity)
		return FALSE
	return TRUE


// Tries to find the file by filename. Returns null on failure
/obj/item/computer_hardware/hard_drive/proc/find_file_by_name(filename)
	if(!check_functionality())
		return null

	if(!filename)
		return null

	if(!stored_files)
		return null

	for(var/datum/computer_file/F in stored_files)
		if(F.filename == filename)
			return F
	return null

/obj/item/computer_hardware/hard_drive/try_insert(obj/item/I, mob/living/user)
	if(!holder)
		return FALSE

	for(var/datum/computer_file/file in stored_files)
		if(file.try_insert(I, user))
			return TRUE

	return FALSE

/obj/item/computer_hardware/hard_drive/advanced
	name = "advanced hard disk drive"
	desc = "A hybrid HDD, for use in higher grade computers where balance between power efficiency and capacity is desired."
	max_capacity = 256
	power_usage = 50 					// Hybrid, medium capacity and medium power storage
	icon_state = "harddisk_mini"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/computer_hardware/hard_drive/super
	name = "super hard disk drive"
	desc = "A high capacity HDD, for use in cluster storage solutions where capacity is more important than power efficiency."
	max_capacity = 512
	power_usage = 100					// High-capacity but uses lots of power, shortening battery life. Best used with APC link.
	icon_state = "harddisk_mini"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/computer_hardware/hard_drive/cluster
	name = "cluster hard disk drive"
	desc = "A large storage cluster consisting of multiple HDDs for usage in dedicated storage systems."
	power_usage = 500
	max_capacity = 2048
	icon_state = "harddisk"
	w_class = WEIGHT_CLASS_NORMAL

// For tablets, etc. - highly power efficient.
/obj/item/computer_hardware/hard_drive/small
	name = "solid state drive"
	desc = "An efficient SSD for portable devices."
	power_usage = 10
	max_capacity = 64
	icon_state = "ssd_mini"
	w_class = WEIGHT_CLASS_TINY
	custom_price = 15

// For silicon integrated tablets.
/obj/item/computer_hardware/hard_drive/small/integrated/install_default_programs()
	..()
	var/datum/computer_file/program/pdamessager/P = store_file(new/datum/computer_file/program/pdamessager(src))
	var/obj/item/modular_computer/stored = holder
	if(!stored && istype(loc, /obj/item/modular_computer))
		stored = loc
	if(P && istype(stored?.loc, /mob/living/silicon))
		var/mob/living/silicon/R = stored.loc
		var/jobname
		if(R.job)
			jobname = R.job
		else if(istype(R, /mob/living/silicon/robot))
			jobname = "[R.designation ? "[R.designation] " : ""]Cyborg"
		else if(R.designation)
			jobname = R.designation
		else if(istype(R, /mob/living/silicon/ai))
			jobname = "AI"
		else if(istype(R, /mob/living/silicon/pai))
			jobname = "pAI"
		else
			jobname = "Silicon"
		P.username = "[R.real_name] ([jobname])" // This is (and hopefully remains to be) created after silicons are named
		P.receiving = TRUE
	if(istype(stored?.loc, /mob/living/silicon/robot)) // RoboTact is for cyborgs only, not AIs
		store_file(new /datum/computer_file/program/robotact(src))

// Syndicate variant - very slight better
/obj/item/computer_hardware/hard_drive/small/syndicate
	desc = "An efficient SSD for portable devices developed by a rival organisation."
	power_usage = 8
	max_capacity = 70
	var/datum/antagonist/traitor/traitor_data // Syndicate hard drive has the user's data baked directly into it on creation
	default_programs = list(
		/datum/computer_file/program/computerconfig,
		/datum/computer_file/program/ntnetdownload/emagged,
		/datum/computer_file/program/filemanager,
	)

/// For PDAs, comes pre-equipped with PDA messaging
/obj/item/computer_hardware/hard_drive/small/pda
/obj/item/computer_hardware/hard_drive/small/pda/install_default_programs()
	..()
	store_file(new/datum/computer_file/program/themeify(src))
	store_file(new/datum/computer_file/program/pdamessager(src))

/// For tablets given to nuke ops
/obj/item/computer_hardware/hard_drive/small/nukeops
	power_usage = 8
	max_capacity = 70
	default_programs = list(
		/datum/computer_file/program/computerconfig,
		/datum/computer_file/program/ntnetdownload/syndicate,
		/datum/computer_file/program/filemanager,
	)

/obj/item/computer_hardware/hard_drive/micro
	name = "micro solid state drive"
	desc = "A highly efficient SSD chip for portable devices."
	power_usage = 2
	max_capacity = 32
	icon_state = "ssd_micro"
	w_class = WEIGHT_CLASS_TINY
