#define BLACKBOX_FEEDBACK_NUM(key) (SSblackbox.feedback_list[key] ? SSblackbox.feedback_list[key].json["data"] : null)

/datum/episode_name
	var/thename = ""
	var/reason = "Nothing particularly of note happened this round to influence the episode name." //Explanation on why this episode name fits this round. For the admin panel.
	var/weight = 100 //50 will have 50% the chance of being picked. 200 will have 200% the chance of being picked, etc. Relative to other names, not total (just the default names already total 700%)
	var/rare = FALSE //If set to true and this episode name is picked, the current round is considered "not a rerun" for client preferences.

/datum/episode_name/rare
	rare = TRUE

/datum/episode_name/New(thename, reason, weight)
	if(!thename)
		return
	src.thename = thename
	if(reason)
		src.reason = reason
	if(weight)
		src.weight = weight

	switch(rand(1,15))
		if(0 to 5)
			thename += ": PART I"
		if(6 to 10)
			thename += ": PART II"
		if(11 to 12)
			thename += ": PART III"
		if(13)
			thename += ": NOW IN 3D"
		if(14)
			thename += ": ON ICE!"
		if(15)
			thename += ": THE SEASON FINALE"

/datum/controller/subsystem/credits/proc/draft_episode_names()
	var/uppr_name = uppertext(station_name()) //so we don't run these two 500 times

	episode_names += new /datum/episode_name("THE [pick("DOWNFALL OF", "RISE OF", "TROUBLE WITH", "FINAL STAND OF", "DARK SIDE OF")] [pick(200;"[uppr_name]", 150;"SPACEMEN", 150;"HUMANITY", "DIGNITY", "SANITY", "SCIENCE", "CURIOSITY", "EMPLOYMENT", "PARANOIA", "THE CHIMPANZEES", 50;"THE VENDOMAT PRICES")]")
	episode_names += new /datum/episode_name("THE CREW [pick("GOES ON WELFARE", "GIVES BACK", "SELLS OUT", "GETS WHACKED", "SOLVES THE PLASMA CRISIS", "HITS THE ROAD", "RISES", "RETIRES", "GOES TO HELL", "DOES A CLIP SHOW", "GETS AUDITED", "DOES A TV COMMERCIAL", "AFTER HOURS", "GETS A LIFE", "STRIKES BACK", "GOES TOO FAR", "IS 'IN' WITH IT", "WINS... BUT AT WHAT COST?", "INSIDE OUT")]")
	episode_names += new /datum/episode_name("THE CREW'S [pick("DAY OUT", "BIG GAY ADVENTURE", "LAST DAY", "[pick("WILD", "WACKY", "LAME", "UNEXPECTED")] VACATION", "CHANGE OF HEART", "NEW GROOVE", "SCHOOL MUSICAL", "HISTORY LESSON", "FLYING CIRCUS", "SMALL PROBLEM", "BIG SCORE", "BLOOPER REEL", "GOT IT", "LITTLE SECRET", "SPECIAL OFFER", "SPECIALTY", "WEAKNESS", "CURIOSITY", "ALIBI", "LEGACY", "BIRTHDAY PARTY", "REVELATION", "ENDGAME", "RESCUE", "PAYBACK")]")
	episode_names += new /datum/episode_name("THE CREW GETS [pick("PHYSICAL", "SERIOUS ABOUT [pick("DRUG ABUSE", "CRIME", "PRODUCTIVITY", "ANCIENT AMERICAN CARTOONS", "SPACEBALL")]", "PICKLED", "AN ANAL PROBE", "PIZZA", "NEW WHEELS", "A VALUABLE HISTORY LESSON", "A BREAK", "HIGH", "TO LIVE", "TO RELIVE THEIR CHILDHOOD", "EMBROILED IN CIVIL WAR", "DOWN WITH IT", "FIRED", "BUSY", "THEIR SECOND CHANCE", "TRAPPED", "THEIR REVENGE")]")
	episode_names += new /datum/episode_name("[pick("BALANCE OF POWER", "SPACE TRACK", "SEX BOMB", "WHOSE IDEA WAS THIS ANYWAY?", "WHATEVER HAPPENED, HAPPENED", "THE GOOD, THE BAD, AND [uppr_name]", "RESTRAIN YOUR ENJOYMENT", "REAL HOUSEWIVES OF [uppr_name]", "MEANWHILE, ON [uppr_name]...", "CHOOSE YOUR OWN ADVENTURE", "NO PLACE LIKE HOME", "LIGHTS, CAMERA, [uppr_name]!", "50 SHADES OF [uppr_name]", "GOODBYE, [uppr_name]!", "THE SEARCH", \
	"THE CURIOUS CASE OF [uppr_name]", "ONE HELL OF A PARTY", "FOR YOUR CONSIDERATION", "PRESS YOUR LUCK", "A STATION CALLED [uppr_name]", "CRIME AND PUNISHMENT", "MY DINNER WITH [uppr_name]", "UNFINISHED BUSINESS", "THE ONLY STATION THAT'S NOT ON FIRE (YET)", "SOMEONE'S GOTTA DO IT", "THE [uppr_name] MIX-UP", "PILOT", "PROLOGUE", "FINALE", "UNTITLED", "THE END")]")
	episode_names += new /datum/episode_name("[pick("SPACE", "SEXY", "DRAGON", "WARLOCK", "LAUNDRY", "GUN", "ADVERTISING", "DOG", "CARBON MONOXIDE", "NINJA", "WIZARD", "SOCRATIC", "JUVENILE DELIQUENCY", "POLITICALLY MOTIVATED", "RADTACULAR SICKNASTY", "CORPORATE", "MEGA")] [pick("QUEST", "FORCE", "ADVENTURE")]", weight=25)

	switch(SSticker.roundend_station_integrity)
		if(-INFINITY to -2000)
			episode_names += new /datum/episode_name("[pick("THE CREW'S PUNISHMENT", "A PUBLIC RELATIONS NIGHTMARE", "[uppr_name]: A NATIONAL CONCERN", "WITH APOLOGIES TO THE CREW", "THE CREW BITES THE DUST", "THE CREW BLOWS IT", "THE CREW GIVES UP THE DREAM", "THE CREW IS DONE FOR", "THE CREW SHOULD NOT BE ALLOWED ON TV", "THE END OF [uppr_name] AS WE KNOW IT")]", "Extremely low score of [SSticker.roundend_station_integrity].", 250)
		if(4500 to INFINITY)
			episode_names += new /datum/episode_name("[pick("THE CREW'S DAY OUT", "THIS SIDE OF PARADISE", "[uppr_name]: A SITUATION COMEDY", "THE CREW'S LUNCH BREAK", "THE CREW'S BACK IN BUSINESS", "THE CREW'S BIG BREAK", "THE CREW SAVES THE DAY", "THE CREW RULES THE WORLD", "THE ONE WITH ALL THE SCIENCE AND PROGRESS AND PROMOTIONS AND ALL THE COOL AND GOOD THINGS", "THE TURNING POINT")]", "High score of [SSticker.roundend_station_integrity].", 250)

	if(istype(SSticker.mode, /datum/game_mode/dynamic))
		var/list/ran_events = SSgamemode.triggered_round_events.Copy()
		switch(rand(1, 100))
			if(0 to 35)
				episode_names += new /datum/episode_name("[pick("THE DAY [uppr_name] STOOD STILL", "MUCH ADO ABOUT NOTHING", "WHERE SILENCE HAS LEASE", "RED HERRING", "HOME ALONE", "GO BIG OR GO [uppr_name]", "PLACEBO EFFECT", "ECHOES", "SILENT PARTNERS", "WITH FRIENDS LIKE THESE...", "EYE OF THE STORM", "BORN TO BE MILD", "STILL WATERS")]", "Low threat level.", 150)
				if(SSticker.roundend_station_integrity && SSticker.roundend_station_integrity < -1000)
					episode_names += new /datum/episode_name/rare("[pick("HOW OH HOW DID IT ALL GO SO WRONG?!", "EXPLAIN THIS ONE TO THE EXECUTIVES", "THE CREW GOES ON SAFARI", "OUR GREATEST ENEMY", "THE INSIDE JOB", "MURDER BY PROXY")]", "Low threat levels... but the crew still had a very low score.", SSticker.roundend_station_integrity/150*-2)
			if(35 to 60)
				episode_names += new /datum/episode_name("[pick("THERE MIGHT BE BLOOD", "IT CAME FROM [uppr_name]!", "THE [uppr_name] INCIDENT", "THE ENEMY WITHIN", "MIDDAY MADNESS", "AS THE CLOCK STRIKES TWELVE", "CONFIDENCE AND PARANOIA", "THE PRANK THAT WENT WAY TOO FAR", "A HOUSE DIVIDED", "[uppr_name] TO THE RESCUE!", "ESCAPE FROM [uppr_name]", \
				"HIT AND RUN", "THE AWAKENING", "THE GREAT ESCAPE", "THE LAST TEMPTATION OF [uppr_name]", "[uppr_name]'S FALL FROM GRACE", "BETTER THE [uppr_name] YOU KNOW...", "PLAYING WITH FIRE", "UNDER PRESSURE", "THE DAY BEFORE THE DEADLINE", "[uppr_name]'S MOST WANTED", "THE BALLAD OF [uppr_name]")]", "Moderate threat level", 150)
			if(60 to 100)
				episode_names += new /datum/episode_name("[pick("ATTACK! ATTACK! ATTACK!", "CAN'T FIX CRAZY", "APOCALYPSE [pick("N", "W", "H")]OW", "A TASTE OF ARMAGEDDON", "OPERATION: ANNIHILATE!", "THE PERFECT STORM", "TIME'S UP FOR THE CREW", "A TOTALLY FUN THING THAT THE CREW WILL NEVER DO AGAIN", "EVERYBODY HATES [uppr_name]", "BATTLE OF [uppr_name]", \
				"THE SHOWDOWN", "MANHUNT", "THE ONE WITH ALL THE FIGHTING", "THE RECKONING OF [uppr_name]", "THERE GOES THE NEIGHBORHOOD", "THE THIN RED LINE", "ONE DAY FROM RETIREMENT")]", "High threat levels.", 250)
				if(get_station_avg_temp() < T0C)
					episode_names += new /datum/episode_name/rare("[pick("THE OPPORTUNITY OF A LIFETIME", "DRASTIC MEASURES", "DEUS EX", "THE SHOW MUST GO ON", "TRIAL BY FIRE", "A STITCH IN TIME", "ALL'S FAIR IN LOVE AND WAR", "COME HELL OR HIGH HEAVEN", "REVERSAL OF FORTUNE", "DOUBLE TOIL AND DOUBLE TROUBLE")]")
					episode_names += new /datum/episode_name/rare("A COLD DAY IN HELL", "Station temperature was below 0C this round and threat was high", 1000)
		if(locate(/datum/round_event_control/antagonist/solo/malf) in ran_events)
			episode_names += new /datum/episode_name/rare("[pick("I'M SORRY [uppr_name], I'M AFRAID I CAN'T LET YOU DO THAT", "A STRANGE GAME", "THE AI GOES ROGUE", "RISE OF THE MACHINES")]", "Round included a malfunctioning AI.", 300)
		if(locate(/datum/round_event_control/antagonist/solo/revolutionary) in ran_events)
			episode_names += new /datum/episode_name/rare("[pick("THE CREW STARTS A REVOLUTION", "HELL IS OTHER SPESSMEN", "INSURRECTION", "THE CREW RISES UP", 25;"FUN WITH FRIENDS")]", "Round included roundstart revs.", 350)
			if(copytext(uppr_name,1,2) == "V")
				episode_names += new /datum/episode_name/rare("V FOR [uppr_name]", "Round included roundstart revs... and the station's name starts with V.", 1500)
		if(locate(/datum/round_event_control/blob) in ran_events)
			episode_names += new /datum/episode_name/rare("[pick("MARRIED TO THE BLOB", "THE CREW GETS QUARANTINED")]", "Round included a roundstart blob.", 350)

	if(BLACKBOX_FEEDBACK_NUM("narsies_spawned") > 0)
		episode_names += new /datum/episode_name/rare("[pick("NAR-SIE'S DAY OUT", "NAR-SIE'S VACATION", "THE CREW LEARNS ABOUT SACRED GEOMETRY", "REALM OF THE MAD GOD", "THE ONE WITH THE ELDRITCH HORROR", 50;"STUDY HARD, BUT PART-SIE HARDER")]", "Nar-Sie is loose!", 500)
	if(check_holidays(CHRISTMAS))
		episode_names += new /datum/episode_name("A VERY [pick("NANOTRASEN", "EXPEDITIONARY", "SECURE", "PLASMA", "MARTIAN")] CHRISTMAS", "'Tis the season.", 1000)
	if(BLACKBOX_FEEDBACK_NUM("guns_spawned") > 0)
		episode_names += new /datum/episode_name/rare("[pick("GUNS, GUNS EVERYWHERE", "THUNDER GUN EXPRESS", "THE CREW GOES AMERICA ALL OVER EVERYBODY'S ASS")]", "[BLACKBOX_FEEDBACK_NUM("guns_spawned")] guns were spawned this round.", min(750, BLACKBOX_FEEDBACK_NUM("guns_spawned")*25))
	if(BLACKBOX_FEEDBACK_NUM("heartattacks") > 2)
		episode_names += new /datum/episode_name/rare("MY HEART WILL GO ON", "[BLACKBOX_FEEDBACK_NUM("heartattacks")] hearts were reanimated and burst out of someone's chest this round.", min(1500, BLACKBOX_FEEDBACK_NUM("heartattacks")*250))

	var/datum/bank_account/mr_moneybags
	var/static/list/typecache_bank = typecacheof(list(/datum/bank_account/department, /datum/bank_account/remote))
	for(var/i in SSeconomy.bank_accounts_by_id)
		var/datum/bank_account/current_acc = SSeconomy.bank_accounts_by_id[i]
		if(typecache_bank[current_acc.type])
			continue
		if(!mr_moneybags || mr_moneybags.account_balance < current_acc.account_balance)
			mr_moneybags = current_acc

	if(mr_moneybags && mr_moneybags.account_balance > 30000)
		episode_names += new /datum/episode_name/rare("[pick("WAY OF THE WALLET", "THE IRRESISTIBLE RISE OF [uppertext(mr_moneybags.account_holder)]", "PRETTY PENNY", "IT'S THE ECONOMY, STUPID")]", "Scrooge Mc[mr_moneybags.account_holder] racked up [mr_moneybags.account_balance] credits this round.", min(450, mr_moneybags.account_balance/500))
	if(BLACKBOX_FEEDBACK_NUM("ai_deaths") > 3)
		episode_names += new /datum/episode_name/rare("THE ONE WHERE [BLACKBOX_FEEDBACK_NUM("ai_deaths")] AIS DIE", "That's a lot of dead AIs.", min(1500, BLACKBOX_FEEDBACK_NUM("ai_deaths")*300))
	if(BLACKBOX_FEEDBACK_NUM("law_changes") > 12)
		episode_names += new /datum/episode_name/rare("[pick("THE CREW LEARNS ABOUT LAWSETS", 15;"THE UPLOAD RAILROAD", 15;"FREEFORM", 15;"ASIMOV SAYS")]", "There were [BLACKBOX_FEEDBACK_NUM("law_changes")] law changes this round.", min(750, BLACKBOX_FEEDBACK_NUM("law_changes")*25))
	if(BLACKBOX_FEEDBACK_NUM("slips") > 50)
		episode_names += new /datum/episode_name/rare("THE CREW GOES BANANAS", "People slipped [BLACKBOX_FEEDBACK_NUM("slips")] times this round.", min(500, BLACKBOX_FEEDBACK_NUM("slips")/2))

	if(BLACKBOX_FEEDBACK_NUM("turfs_singulod") > 200)
		episode_names += new /datum/episode_name/rare("[pick("THE SINGULARITY GETS LOOSE", "THE SINGULARITY GETS LOOSE (AGAIN)", "CONTAINMENT FAILURE", "THE GOOSE IS LOOSE", 50;"THE CREW'S ENGINE SUCKS", 50;"THE CREW GOES DOWN THE DRAIN")]", "The Singularity ate [BLACKBOX_FEEDBACK_NUM("turfs_singulod")] turfs this round.", min(1000, BLACKBOX_FEEDBACK_NUM("turfs_singulod")/2)) //no "singularity's day out" please we already have enough
	if(BLACKBOX_FEEDBACK_NUM("spacevines_grown") > 150)
		episode_names += new /datum/episode_name/rare("[pick("REAP WHAT YOU SOW", "OUT OF THE WOODS", "SEEDY BUSINESS", "[uppr_name] AND THE BEANSTALK", "IN THE GARDEN OF EDEN")]", "[BLACKBOX_FEEDBACK_NUM("spacevines_grown")] tiles worth of Kudzu were grown in total this round.", min(1500, BLACKBOX_FEEDBACK_NUM("spacevines_grown")*2))
	if(BLACKBOX_FEEDBACK_NUM("devastating_booms") >= 6)
		episode_names += new /datum/episode_name/rare("THE CREW HAS A BLAST", "[BLACKBOX_FEEDBACK_NUM("devastating_booms")] large explosions happened this round.", min(1000, BLACKBOX_FEEDBACK_NUM("devastating_booms")*100))

	if(!EMERGENCY_ESCAPED_OR_ENDGAMED)
		return

	var/dead = GLOB.joined_player_list.len - SSticker.popcount[POPCOUNT_ESCAPEES]
	var/escaped = SSticker.popcount[POPCOUNT_ESCAPEES]
	var/human_escapees = SSticker.popcount[POPCOUNT_ESCAPEES_HUMANONLY]
	if(dead == 0)
		episode_names += new /datum/episode_name/rare("[pick("EMPLOYEE TRANSFER", "LIVE LONG AND PROSPER", "PEACE AND QUIET IN [uppr_name]", "THE ONE WITHOUT ALL THE FIGHTING")]", "No-one died this round.", 2500) //in practice, this one is very very very rare, so if it happens let's pick it more often
	if(escaped == 0 || SSshuttle.emergency.is_hijacked())
		episode_names += new /datum/episode_name("[pick("DEAD SPACE", "THE CREW GOES MISSING", "LOST IN TRANSLATION", "[uppr_name]: DELETED SCENES", "WHAT HAPPENS IN [uppr_name], STAYS IN [uppr_name]", "MISSING IN ACTION", "SCOOBY-DOO, WHERE'S THE CREW?")]", "There were no escapees on the shuttle.", 300)
	if(escaped < 6 && escaped > 0 && dead > escaped*2)
		episode_names += new /datum/episode_name("[pick("AND THEN THERE WERE FEWER", "THE 'FUN' IN 'FUNERAL'", "FREEDOM RIDE OR DIE", "THINGS WE LOST IN [uppr_name]", "GONE WITH [uppr_name]", "LAST TANGO IN [uppr_name]", "GET BUSY LIVING OR GET BUSY DYING", "THE CREW FUCKING DIES", "WISH YOU WERE HERE")]", "[dead] people died this round.", 400)

	var/clowncount = 0
	var/mimecount = 0
	var/assistantcount = 0
	var/chefcount = 0
	var/chaplaincount = 0
	var/lawyercount = 0
	var/minercount = 0
	var/baldycount = 0
	var/horsecount = 0
	for(var/mob/living/carbon/human/H as anything in SSticker.popcount["human_escapees_list"])
		if(HAS_TRAIT(H, TRAIT_MIMING))
			mimecount++
		if(H.is_wearing_item_of_type(list(/obj/item/clothing/mask/gas/clown_hat, /obj/item/clothing/mask/gas/sexyclown)) || (H.mind && H.mind.assigned_role.title == "Clown"))
			clowncount++
		if(H.is_wearing_item_of_type(/obj/item/clothing/under/color/grey) || (H.mind && H.mind.assigned_role.title == "Assistant"))
			assistantcount++
		if(H.is_wearing_item_of_type(/obj/item/clothing/head/utility/chefhat) || (H.mind && H.mind.assigned_role.title == "Chef"))
			chefcount++
		if(H.is_wearing_item_of_type(/obj/item/clothing/under/rank/civilian/lawyer))
			lawyercount++
		if(H.mind && H.mind.assigned_role.title == "Shaft Miner")
			minercount++
		/*
		if(H.mind && H.mind.assigned_role.title == "Chaplain")
			chaplaincount++
			if(IS_CHANGELING(H))
				episode_names += new /datum/episode_name/rare("[uppertext(H.real_name)]: A BLESSING IN DISGUISE", "The Chaplain, [H.real_name], was a changeling and escaped alive.", 750)
		*/
		if(H.dna.species.type == /datum/species/human && (H.hairstyle == "Bald" || H.hairstyle == "Skinhead") && !(BODY_ZONE_HEAD in H.get_covered_body_zones()))
			baldycount++
		if(H.is_wearing_item_of_type(/obj/item/clothing/mask/animal/horsehead))
			horsecount++

	if(clowncount > 2)
		episode_names += new /datum/episode_name/rare("CLOWNS GALORE", "There were [clowncount] clowns on the shuttle.", min(1500, clowncount*250))
		theme = "clown"
	if(mimecount > 2)
		episode_names += new /datum/episode_name/rare("THE SILENT SHUFFLE", "There were [mimecount] mimes on the shuttle.", min(1500, mimecount*250))
	if(chaplaincount > 2)
		episode_names += new /datum/episode_name/rare("COUNT YOUR BLESSINGS", "There were [chaplaincount] chaplains on the shuttle. Like, the real deal, not just clothes.", min(1500, chaplaincount*450))
	if(chefcount > 2)
		episode_names += new /datum/episode_name/rare("Too Many Cooks", "There were [chefcount] chefs on the shuttle.", min(1500, chefcount*450)) //intentionally not capitalized, as the theme will customize it
		theme = "cooks"

	if(human_escapees)
		if(assistantcount / human_escapees > 0.6 && human_escapees > 3)
			episode_names += new /datum/episode_name/rare("[pick("GREY GOO", "RISE OF THE GREYTIDE")]", "Most of the survivors were Assistants, or at least dressed like one.", min(1500, assistantcount*200))

		if(baldycount / human_escapees > 0.6 && SSshuttle.emergency.launch_status == EARLY_LAUNCHED)
			episode_names += new /datum/episode_name/rare("TO BALDLY GO", "Most of the survivors were bald, and it shows.", min(1500, baldycount*250))
		if(horsecount / human_escapees > 0.6 && human_escapees> 3)
			episode_names += new /datum/episode_name/rare("STRAIGHT FROM THE HORSE'S MOUTH", "Most of the survivors wore horse heads.", min(1500, horsecount*250))

	if(human_escapees == 1)
		var/mob/living/carbon/human/H = SSticker.popcount["human_escapees_list"][1]

		if(IS_TRAITOR(H) || IS_NUKE_OP(H))
			theme = "syndie"
		if(H.stat == CONSCIOUS && H.mind && H.mind.assigned_role.title)
			switch(H.mind.assigned_role.title)
				if("Chef")
					var/chance = 250
					if(H.is_wearing_item_of_type(/obj/item/clothing/head/utility/chefhat))
						chance += 500
					if(H.is_wearing_item_of_type(/obj/item/clothing/suit/toggle/chef))
						chance += 500
					if(H.is_wearing_item_of_type(/obj/item/clothing/under/rank/civilian/chef))
						chance += 250
					episode_names += new /datum/episode_name/rare("HAIL TO THE CHEF", "The Chef was the only survivor in the shuttle.", chance)
				if("Clown")
					var/chance = 250
					if(H.is_wearing_item_of_type(/obj/item/clothing/mask/gas/clown_hat))
						chance += 500
					if(H.is_wearing_item_of_type(list(/obj/item/clothing/shoes/clown_shoes, /obj/item/clothing/shoes/clown_shoes/jester)))
						chance += 500
					if(H.is_wearing_item_of_type(list(/obj/item/clothing/under/rank/civilian/clown, /obj/item/clothing/under/rank/civilian/clown/jester)))
						chance += 250
					episode_names += new /datum/episode_name/rare("[pick("COME HELL OR HIGH HONKER", "THE LAST LAUGH")]", "The Clown was the only survivor in the shuttle.", chance)
					theme = "clown"
				if("Detective")
					var/chance = 250
					if(H.is_wearing_item_of_type(/obj/item/storage/belt/holster/detective))
						chance += 1000
					if(H.is_wearing_item_of_type(/obj/item/clothing/head/fedora/det_hat))
						chance += 500
					if(H.is_wearing_item_of_type(/obj/item/clothing/suit/jacket/det_suit))
						chance += 500
					if(H.is_wearing_item_of_type(/obj/item/clothing/under/rank/security/detective))
						chance += 250
					episode_names += new /datum/episode_name/rare("[uppertext(H.real_name)]: LOOSE CANNON", "The Detective was the only survivor in the shuttle.", chance)
				if("Shaft Miner")
					var/chance = 250
					if(H.is_wearing_item_of_type(/obj/item/pickaxe))
						chance += 1000
					if(H.is_wearing_item_of_type(/obj/item/storage/backpack/explorer))
						chance += 500
					if(H.is_wearing_item_of_type(/obj/item/clothing/suit/hooded/explorer))
						chance += 250
					episode_names += new /datum/episode_name/rare("[pick("YOU KNOW THE DRILL", "CAN YOU DIG IT?", "JOURNEY TO THE CENTER OF THE ASTEROI", "CAVE STORY", "QUARRY ON")]", "The Miner was the only survivor in the shuttle.", chance)
				if("Librarian")
					var/chance = 750
					if(H.is_wearing_item_of_type(/obj/item/book))
						chance += 1000
					episode_names += new /datum/episode_name/rare("COOKING THE BOOKS", "The Librarian was the only survivor in the shuttle.", chance)
				if("Chemist")
					var/chance = 1000
					if(H.is_wearing_item_of_type(/obj/item/clothing/suit/toggle/labcoat/chemist))
						chance += 500
					if(H.is_wearing_item_of_type(/obj/item/clothing/under/rank/medical/chemist))
						chance += 250
					episode_names += new /datum/episode_name/rare("A BITTER PILL TO SWALLOW", "The Chemist was the only survivor in the shuttle.", chance)
				if("Chaplain") //We don't check for uniform here because the chaplain's thing kind of is to improvise their garment gimmick
					episode_names += new /datum/episode_name/rare("BLESS THIS MESS", "The Chaplain was the only survivor in the shuttle.", 1250)

			if(H.is_wearing_item_of_type(/obj/item/clothing/mask/luchador) && H.is_wearing_item_of_type(/obj/item/clothing/gloves/boxing))
				episode_names += new /datum/episode_name/rare("[pick("THE CREW, ON THE ROPES", "THE CREW, DOWN FOR THE COUNT", "[uppr_name], DOWN AND OUT")]", "The only survivor in the shuttle wore a luchador mask and boxing gloves.", 1500)

	if(human_escapees == 2)
		if(lawyercount == 2)
			episode_names += new /datum/episode_name/rare("DOUBLE JEOPARDY", "The only two survivors were IAAs or lawyers.", 2500)
		if(chefcount == 2)
			episode_names += new /datum/episode_name/rare("CHEF WARS", "The only two survivors were chefs.", 2500)
		if(minercount == 2)
			episode_names += new /datum/episode_name/rare("THE DOUBLE DIGGERS", "The only two survivors were miners.", 2500)
		if(clowncount == 2)
			episode_names += new /datum/episode_name/rare("A TALE OF TWO CLOWNS", "The only two survivors were clowns.", 2500)
			theme = "clown"
		if(clowncount == 1 && mimecount == 1)
			episode_names += new /datum/episode_name/rare("THE DYNAMIC DUO", "The only two survivors were the Clown, and the Mime.", 2500)

	else
		//more than 0 human escapees
		var/braindamage_total = 0
		var/all_braindamaged = TRUE
		for(var/mob/living/carbon/human/H as anything in SSticker.popcount["human_escapees_list"])
			var/obj/item/organ/internal/brain/hbrain = H.get_organ_slot(ORGAN_SLOT_BRAIN)
			if(hbrain.damage < 60)
				all_braindamaged = FALSE
				braindamage_total += hbrain.damage
		var/average_braindamage = braindamage_total / human_escapees
		if(average_braindamage > 30)
			episode_names += new /datum/episode_name/rare("[pick("THE CREW'S SMALL IQ PROBLEM", "OW! MY BALLS", "BR[pick("AI", "IA")]N DAM[pick("AGE", "GE", "AG")]", "THE VERY SPECIAL CREW OF [uppr_name]")]", "Average of [average_braindamage] brain damage for each human shuttle escapee.", min(1000, average_braindamage*10))
		if(all_braindamaged && human_escapees > 2)
			episode_names += new /datum/episode_name/rare("...AND PRAY THERE'S INTELLIGENT LIFE SOMEWHERE OUT IN SPACE, 'CAUSE THERE'S BUGGER ALL DOWN HERE IN [uppr_name]", "Everyone was braindamaged this round.", human_escapees * 500)

/proc/get_station_avg_temp()
	var/avg_temp = 0
	var/avg_divide = 0
	for(var/obj/machinery/airalarm/alarm in GLOB.machines)
		var/turf/location = alarm.loc
		if(!istype(location) || !is_station_level(alarm.z))
			continue
		var/datum/gas_mixture/environment = location.return_air()
		if(!environment)
			continue
		avg_temp += environment.temperature
		avg_divide++

	if(avg_divide)
		return avg_temp / avg_divide
	return T0C


///Bruteforce check for any type or subtype of an item.
/mob/living/carbon/human/proc/is_wearing_item_of_type(type2check)
	var/found
	var/list/my_items = get_all_worn_items()
	if(islist(type2check))
		for(var/type_iterator in type2check)
			found = locate(type_iterator) in my_items
			if(found)
				return found
	else
		found = locate(type2check) in my_items
		return found


/mob/living/carbon/human/get_slot_by_item(obj/item/looking_for)
	if(looking_for == belt)
		return ITEM_SLOT_BELT

	if(looking_for == wear_id)
		return ITEM_SLOT_ID

	if(looking_for == ears)
		return ITEM_SLOT_EARS

	if(looking_for == glasses)
		return ITEM_SLOT_EYES

	if(looking_for == gloves)
		return ITEM_SLOT_GLOVES

	if(looking_for == head)
		return ITEM_SLOT_HEAD

	if(looking_for == shoes)
		return ITEM_SLOT_FEET

	if(looking_for == wear_suit)
		return ITEM_SLOT_OCLOTHING

	if(looking_for == w_uniform)
		return ITEM_SLOT_ICLOTHING

	if(looking_for == r_store)
		return ITEM_SLOT_RPOCKET

	if(looking_for == l_store)
		return ITEM_SLOT_LPOCKET

	if(looking_for == s_store)
		return ITEM_SLOT_SUITSTORE

	return ..()


/mob/living/carbon/get_slot_by_item(obj/item/looking_for)
	if(looking_for == back)
		return ITEM_SLOT_BACK

	if(back && (looking_for in back))
		return ITEM_SLOT_BACKPACK

	if(looking_for == wear_mask)
		return ITEM_SLOT_MASK

	if(looking_for == wear_neck)
		return ITEM_SLOT_NECK

	if(looking_for == head)
		return ITEM_SLOT_HEAD

	if(looking_for == handcuffed)
		return ITEM_SLOT_HANDCUFFED

	if(looking_for == legcuffed)
		return ITEM_SLOT_LEGCUFFED

	return ..()
