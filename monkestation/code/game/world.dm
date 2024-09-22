/world/SetupLogs()
	. = ..()
	set_db_log_directory()

/proc/set_db_log_directory()
	set waitfor = FALSE
	if(!GLOB.round_id || !SSdbcore.IsConnected())
		return
	var/datum/db_query/set_log_directory = SSdbcore.NewQuery({"
		UPDATE [format_table_name("round")]
		SET
			`log_directory` = :log_directory
		WHERE
			`id` = :round_id
	"}, list("log_directory" = GLOB.log_directory, "round_id" = GLOB.round_id))
	set_log_directory.Execute()
	QDEL_NULL(set_log_directory)

/proc/get_log_directory_by_round_id(round_id)
	if(!isnum(round_id) || round_id <= 0 || !SSdbcore.IsConnected())
		return
	var/datum/db_query/query_log_directory = SSdbcore.NewQuery({"
		SELECT `log_directory`
		FROM
			[format_table_name("round")]
		WHERE
			`id` = :round_id
	"}, list("round_id" = round_id))
	if(!query_log_directory.warn_execute())
		qdel(query_log_directory)
		return
	if(!query_log_directory.NextRow())
		qdel(query_log_directory)
		CRASH("Failed to get log directory for round [round_id]")
	var/log_directory = query_log_directory.item[1]
	QDEL_NULL(query_log_directory)
	if(!rustg_file_exists(log_directory))
		CRASH("Log directory '[log_directory]' for round ID [round_id] doesn't exist!")
	return log_directory
