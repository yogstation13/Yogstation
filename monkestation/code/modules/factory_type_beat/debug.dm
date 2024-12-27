/proc/count_lists()
#ifndef OPENDREAM
	var/list_count = 0
	for(var/list/list)
		list_count++

	var/file = file("data/list_count/[GLOB.round_id].txt")

	WRITE_FILE(file, list_count)
#endif

/proc/save_types()
#ifndef OPENDREAM
	var/datum/D
	var/atom/A
	var/list/counts = new
	for(A) counts[A.type] = (counts[A.type]||0) + 1
	for(D) counts[D.type] = (counts[D.type]||0) + 1

	var/F = file("data/type_tracker/[GLOB.round_id]-stat_track.txt")
	for(var/i in counts)
		WRITE_FILE(F, "[i]\t[counts[i]]\n")
#endif

/proc/save_datums()
#ifndef OPENDREAM
	var/datum/D
	var/list/counts = new
	for(D) counts[D.type] = (counts[D.type]||0) + 1

	var/F = file("data/type_tracker/[GLOB.round_id]-datums-[world.time].txt")
	for(var/i in counts)
		WRITE_FILE(F, "[i]\t[counts[i]]\n")
#endif
