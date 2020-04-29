/proc/render_stats(list/stats, user, sort = /proc/cmp_generic_stat_item_time)
	sortTim(stats, sort, TRUE)

	var/list/lines = list()

	for (var/entry in stats)
		var/list/data = stats[entry]
		lines += "[entry] => [num2text(data[STAT_ENTRY_TIME], 10)]ms ([data[STAT_ENTRY_COUNT]]) (avg:[num2text(data[STAT_ENTRY_TIME]/(data[STAT_ENTRY_COUNT] || 1), 99)])"

	if (user)
		user << browse("<html><head><meta charset='UTF-8'></head><body><ol><li>[lines.Join("</li><li>")]</li></ol></body></html>", "window=[url_encode("stats:[REF(stats)]")]")

	. = lines.Join("\n")
