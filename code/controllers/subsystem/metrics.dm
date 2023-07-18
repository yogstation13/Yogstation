#define METRICS_BUFFER_MAX_DEFAULT 15000
#define METRICS_BUFFER_PUBLISH_DEFAULT (METRICS_BUFFER_MAX_DEFAULT / 10)

SUBSYSTEM_DEF(metrics)
	name = "Metrics"
	wait = 25 //measured in ticks
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	flags = SS_TICKER
	var/list/queue = list()
	var/world_init_time = 0 //set in world/New()
	var/last_warning = 0
	var/threshold = METRICS_BUFFER_MAX_DEFAULT

/datum/controller/subsystem/metrics/stat_entry(msg)
	msg = "Q:[length(queue)]/[threshold]([round(length(queue)/threshold*100, 0.1)]%)"
	return ..()

/datum/controller/subsystem/metrics/get_metrics()
	. = ..()
	.["$cpu"] = world.cpu
	.["$map_cpu"] = world.map_cpu
	.["$elapsed_real"] = (REALTIMEOFDAY - SSmetrics.world_init_time)
	.["$elapsed_processed"] = world.time
	if(!isnull(GLOB.round_id))
		.["$round_id"] = GLOB.round_id
	.["$clients"] = length(GLOB.clients)
	.["$runlevel"] = Master.current_runlevel

/datum/controller/subsystem/metrics/Initialize(start_timeofday)
	if(!CONFIG_GET(string/metrics_api))
		flags |= SS_NO_FIRE // Disable firing to save CPU
	return SS_INIT_SUCCESS

/datum/controller/subsystem/metrics/fire(resumed)
	var/timestamp = RUSTG_CALL(RUST_G, "unix_timestamp_int")();
	for(var/datum/controller/subsystem/SS in Master.subsystems)
		var/metrics = SS.get_metrics()
		metrics["@timestamp"] = timestamp
		ingest(metrics)

/datum/controller/subsystem/metrics/proc/ingest(line)
	if (flags & SS_NO_FIRE)
		return
	if (queue.len > threshold)
		if((last_warning + (5 MINUTES)) < world.time)
			message_admins("Metrics buffer exceeded max size, dropping data. Please report this")
			log_game("Metrics buffer exceeded max size, dropping data.")
			last_warning = world.time
		return
	
	queue[++queue.len] = line

/////////////
//Publisher//
/////////////
SUBSYSTEM_DEF(metrics_publish)
	name = "Metrics (Publish)"
	wait = 2.5 SECONDS
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	flags = SS_BACKGROUND 
	var/threshold = METRICS_BUFFER_PUBLISH_DEFAULT

/datum/controller/subsystem/metrics_publish/stat_entry(msg)
	msg = "Q:[length(SSmetrics.queue)]/[threshold]([round(length(SSmetrics.queue)/threshold*100, 0.1)]%)"
	return ..()

/datum/controller/subsystem/metrics_publish/Initialize(start_timeofday)
	if(!CONFIG_GET(string/metrics_api))
		flags |= SS_NO_FIRE // Disable firing to save CPU
	return SS_INIT_SUCCESS

/datum/controller/subsystem/metrics_publish/fire(resumed)
	if (length(SSmetrics.queue) < threshold) return

	RUSTG_CALL(RUST_G, "influxdb2_publish")(json_encode(SSmetrics.queue), CONFIG_GET(string/metrics_api), CONFIG_GET(string/metrics_token))
	SSmetrics.queue = list()


#undef METRICS_BUFFER_MAX_DEFAULT
#undef METRICS_BUFFER_PUBLISH_DEFAULT
