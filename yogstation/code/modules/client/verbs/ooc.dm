/client/proc/find_admin_rank(client)
	var/client/C = client

	switch(C.holder.rank.name)

		if("CouncilMember")
			return "\[Council\]"

		if("Moderator")
			return "\[Mod\]"

		if("Administrator")
			return "\[Admin\]"

		if("ModeratorOnProbation")
			return "\[ModOnProbation\]"

		if("Bot")
			return "\[YogBot\]"

		if("RetiredAdmin")
			return "\[Retmin\]"

		else
			return "\[[C.holder.rank.name]\]"