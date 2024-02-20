/client/proc/cmd_view_polls()
	set category = "Server"
	set name = "View poll results"

	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, span_danger("Failed to establish database connection."))
		return

	var/datum/DBQuery/query_poll_get = SSdbcore.NewQuery("SELECT id, question FROM [format_table_name("poll_question")] WHERE Now() > starttime ORDER BY starttime DESC")
	if(!query_poll_get.warn_execute())
		qdel(query_poll_get)
		return
	var/output = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><div align='center'><B>Player polls</B><hr><table>"
	var/i = 0
	var/rs = REF(src)
	while(query_poll_get.NextRow())
		var/pollid = query_poll_get.item[1]
		var/pollquestion = query_poll_get.item[2]
		output += "<tr bgcolor='#[ (i % 2 == 1) ? "e2e2e2" : "e2e2e2" ]'><td><a href=\"byond://?src=[rs];pollidshow=[pollid]\"><b>[pollquestion]</b></a></td></tr>"
		i++
	qdel(query_poll_get)
	output += "</table></BODY></HTML>"
	if(!QDELETED(src))
		src << browse(output,"window=playerpolllist;size=500x300")


/client/proc/poll_results(pollid = -1)
	if(!check_rights(R_ADMIN))
		return
	if(pollid == -1)
		return
	pollid = text2num(pollid)
	if(!pollid)
		return
	if(!SSdbcore.IsConnected())
		to_chat(usr, span_danger("Failed to establish database connection."))
		return
	var/datum/DBQuery/select_query = SSdbcore.NewQuery("SELECT polltype, question, adminonly, multiplechoiceoptions, starttime, endtime FROM [format_table_name("poll_question")] WHERE id = :pollid", list("pollid" = pollid))
	select_query.Execute()
	var/question = ""
	var/polltype = ""
	var/adminonly = 0
	var/multiplechoiceoptions = 0
	var/starttime = ""
	var/endtime = ""
	var/found = 0
	while(select_query.NextRow())
		polltype = select_query.item[1]
		question = select_query.item[2]
		adminonly = text2num(select_query.item[3])
		multiplechoiceoptions = text2num(select_query.item[4])
		starttime = select_query.item[5]
		endtime = select_query.item[6]
		found = 1
		break
	qdel(select_query)
	if(!found)
		to_chat(src, span_warning("Poll question details not found."))
		return

	if(polltype == POLLTYPE_MULTI)
		question += " (Choose up to [multiplechoiceoptions] options)"
	if(adminonly)
		question = "(<font color='#997700'>Admin only poll</font>) " + question

	var output = "<!DOCTYPE html><html><HEAD><meta charset='UTF-8'></HEAD><body>"
	if(polltype == POLLTYPE_MULTI || polltype == POLLTYPE_OPTION)
		select_query = SSdbcore.NewQuery("SELECT text, (SELECT COUNT(optionid) FROM [format_table_name("poll_vote")] WHERE optionid = [format_table_name("poll_option")].id GROUP BY optionid) AS votecount FROM [format_table_name("poll_option")] WHERE pollid = :pollid", list("pollid" = pollid));
		select_query.Execute()
		var/list/options = list()
		var/total_votes = 1
		var/total_percent_votes = 1
		var/max_votes = 1
		while(select_query.NextRow())
			var/text = select_query.item[1]
			var/votecount = text2num(select_query.item[2])
			total_percent_votes += votecount
			total_votes += votecount
			if(votecount > max_votes)
				max_votes = votecount
			options[++options.len] = list(text, votecount)
		qdel(select_query)
		// fuck ie.
		output += {"
		<table width='900' align='center' bgcolor='#eeffee' cellspacing='0' cellpadding='4'>
		<tr bgcolor='#ddffdd'>
			<th colspan='4' align='center'>[question]<br><font size='1'><b>[starttime] - [endtime]</b></font></th>
		</tr>
		<tr bgcolor='#ddffdd'>
			<th colspan='4' align='center'><div style='width:700px;position:relative'>"}
		var/list/colors = list("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3", "#a6d854", "#ffd92f", "#e5c494", "#b3b3b3")
		var/color_index = 0
		for(var/list/option in options)
			var/bar_width = option[2] * 700 / total_votes
			var/percentage = "[round(option[2] * 100 / total_percent_votes)]%"
			color_index++
			if(color_index > colors.len)
				color_index = 1
			output += "<div style='width:[bar_width]px;height:[5]px;background-color:[colors[color_index]];float:left' title='[option[1]] ([percentage])'></div>"
		output += "</div><br><font size='2'><b>(Hover over the colored bar to read description)</b></font></tr>"
		for(var/list/option in options)
			var/bar_width = option[2] * 390 / max_votes
			var/percentage = "[round(option[2] * 100 / total_percent_votes)]%"
			output += "<tr><td width='300' align='right'>[option[1]]</td>"
			output += "<td width='100' align='center'><b>[option[2]]</b></td>"
			output += "<td width='100' align='center'><b>[percentage]</b></td>"
			output += "<td width='400' align='left'><div style='width:[bar_width]px;height:10px;display:inline-block;background-color:#08b000'></div></td>"
		output += "</table>"
	if(polltype == POLLTYPE_RATING)
		output += {"
		<table width='900' align='center' bgcolor='#eeffee' cellspacing='0' cellpadding='4'>
		<tr bgcolor='#ddffdd'>
			<th colspan='4' align='center'>[question]<br><font size='1'><b>[starttime] - [endtime]</b></font></th>
		</tr>"}
		select_query = SSdbcore.NewQuery("SELECT id, text, (SELECT AVG(rating) FROM [format_table_name("poll_vote")] WHERE optionid = [format_table_name("poll_option")].id AND rating != 'abstain') AS avgrating, (SELECT COUNT(rating) FROM [format_table_name("poll_vote")] WHERE optionid = [format_table_name("poll_option")].id AND rating != 'abstain') AS countvotes, minval, maxval FROM [format_table_name("poll_option")] WHERE pollid = :pollid", list("pollid" = pollid))
		select_query.Execute()
		while(select_query.NextRow())
			output += {"
			<tr>
				<td align='right' width='300'>[select_query.item[2]]</th>
				<td align='center' width='100'><b>N = [select_query.item[4]]</b></th>
				<td align='center' width='100'><b>AVG = [select_query.item[3]]</b></th>
				<td align='left' width='400'><table width='400 style='table-layout: fixed'>"}
			var/optionid = select_query.item[1]
			var/totalvotes = text2num(select_query.item[4])
			var/minval = text2num(select_query.item[5])
			var/maxval = text2num(select_query.item[6])
			var/maxvote = 1
			var/list/votecounts = list()
			for(var/I in minval to maxval)
				var/datum/DBQuery/rating_query = SSdbcore.NewQuery("SELECT COUNT(rating) AS countrating FROM [format_table_name("poll_vote")] WHERE optionid = :optionid AND rating = :I GROUP BY rating", list("optionid" = optionid, "I" = I))
				rating_query.Execute()
				var/votecount = 0
				while(rating_query.NextRow())
					votecount = text2num(rating_query.item[1])
				qdel(rating_query)
				votecounts["[I]"] = votecount
				if(votecount > maxvote)
					maxvote = votecount
			for(var/I in minval to maxval)
				var/votecount = votecounts["[I]"]
				var/bar_width = votecount * 200 / maxvote
				output += {"
				<tr>
					<td align='center' width='50'><b>[I]</b></td>
					<td align='center' width='50'>[votecount]</td>
					<td align='center' width='75'>([votecount / totalvotes]%)</td>
					<td width='200'><div style='width:[bar_width]px;height:10px;display:inline-block;background-color:#08b000'></div></td>
				</tr>"}
			output += "</table></td></tr>"
		output += "</table>"
		qdel(select_query)
	if(polltype == POLLTYPE_TEXT)
		select_query = SSdbcore.NewQuery("SELECT replytext, COUNT(replytext) AS countresponse, GROUP_CONCAT(DISTINCT ckey SEPARATOR ', ') as ckeys FROM [format_table_name("poll_textreply")] WHERE pollid = :pollid GROUP BY replytext ORDER BY countresponse DESC", list("pollid" = pollid));
		select_query.Execute()
		output += {"
		<table width='900' align='center' bgcolor='#eeffee' cellspacing='0' cellpadding='4'>
		<tr bgcolor='#ddffdd'>
			<th colspan='2' align='center'>[question]<br><font size='1'><b>[starttime] - [endtime]</b></font></th>
		</tr>"}
		while(select_query.NextRow())
			var/replytext = select_query.item[1]
			var/countresponse = select_query.item[2]
			var/ckeys = select_query.item[3]
			output += {"
			<tr>
				<td>[check_rights(R_EVERYTHING) ? "[ckeys] " : ""]([countresponse] player\s) responded with:</td>
				<td style='border:1px solid #888888'>[replytext]</td>
			</tr>"}
		qdel(select_query)
		output += "</table>"
	output += "</body></html>"

	src << browse(output,"window=pollresults;size=950x500")
