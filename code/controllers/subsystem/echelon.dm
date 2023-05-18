SUBSYSTEM_DEF(echelon)
	name = "ECHELON"
	init_order = INIT_ORDER_ECHELON
	flags = SS_NO_FIRE
	var/enabled = TRUE

/datum/controller/subsystem/echelon/Initialize(timeofday, zlevel)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/echelon/proc/is_exception(ckey)
	PRIVATE_PROC(TRUE)

	var/datum/DBQuery/query_get_flags = SSdbcore.NewQuery({"
		SELECT
			flags
		FROM [format_table_name("bound_credentials")]
		WHERE
			ckey = :ckey AND
			FIND_IN_SET('[DB_BOUND_CREDENTIALS_FLAG_ALLOW_PROXIES]', flags) 
	"}, list("ckey" = ckey))
	if(!query_get_flags.Execute())
		qdel(query_get_flags)
		return FALSE

	var/result = query_get_flags.rows.len >= 1
	qdel(query_get_flags)
	return result


/datum/controller/subsystem/echelon/proc/is_using_proxy(ip)
	PRIVATE_PROC(TRUE)

	if(IsAdminAdvancedProcCall()) return

	var/datum/DBQuery/query_get_cached_matches = SSdbcore.NewQuery({"
		SELECT
			JSON_VALUE(data, "$.should_block")
		FROM [format_table_name("proxy_cache")]
		WHERE
			(ip = INET_ATON(:ip))
	"}, list("ip" = ip))

	//This is just the cached value, we can carry on if this fails
	if(!query_get_cached_matches.Execute())
		var/msg = "An error occured while attempting to fetch a cached proxy result. Check server sql logs."
		log_world(msg)
		message_admins(msg)
	else if(query_get_cached_matches.NextRow())
		var/result = query_get_cached_matches.item[1] == "true"
		qdel(query_get_cached_matches)
		return result
	qdel(query_get_cached_matches)

	//At this point, we couldnt fetch a cached value 
	var/datum/http_request/req = new()
	var/url = CONFIG_GET(string/vpn_lookup_api)
	url = replacetextEx(url, "{key}", CONFIG_GET(string/vpn_lookup_key))
	url = replacetextEx(url, "{ip}", ip)
	req.prepare(RUSTG_HTTP_METHOD_GET, url)
	req.begin_async()
	UNTIL(req.is_complete())
	var/datum/http_response/res = req.into_response()
	var/json = json_decode(res.body)

	var/datum/DBQuery/query_update_cache = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("proxy_cache")]
			SET ip = INET_ATON(:ip), data = :data
	"}, list("ip" = ip, "data" = res.body))
	query_update_cache.Execute();
	qdel(query_update_cache)

	var/status = json["status"]
	switch(status)
		if("warning")
			var/msg = "The proxy checking API has returned a warning. Please inform a server operator."
			log_world(msg)
			message_admins(msg)
		if("denied")
			var/msg = "The proxy checking API has refused to answer. Please inform a server operator. The ip [ip] was let through by default."
			log_world(msg)
			message_admins(msg)
			return FALSE
		if("error")
			var/msg = "Unable to fetch proxy information. Please inform a server operator. The ip [ip] was let through by default."
			log_world(msg)
			message_admins(msg)
			return FALSE
	

	return json["should_block"] == "true"
		

/datum/controller/subsystem/echelon/proc/is_match(ckey, ip, allow_exceptions=TRUE)
	if(!CONFIG_GET(string/vpn_lookup_api) || !CONFIG_GET(string/vpn_lookup_key))
		return FALSE
	if(!enabled)
		return FALSE
	
	if(allow_exceptions && is_exception(ckey)) return FALSE

	return is_using_proxy(ip)

		
	