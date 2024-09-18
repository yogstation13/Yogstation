/world/SetupLogs()
	. = ..()
	set_db_log_directory()

/proc/set_db_log_directory()
	set waitfor = FALSE
	if(!GLOB.round_id || !SSdbcore.IsConnected())
		return
	var/datum/db_query/set_log_directory = SSdbcore.NewQuery({"
		UPDATE `[format_table_name("round")]`
		SET
			`log_directory` = :log_directory
		WHERE
			`id` = :round_id
	"}, list("log_directory" = GLOB.log_directory, "round_id" = GLOB.round_id))
	set_log_directory.Execute()
	QDEL_NULL(set_log_directory)
