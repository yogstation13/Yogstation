#define LAW_DEVIL "devil"
#define LAW_ZEROTH "zeroth"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"
#define LAW_HACKED "hacked"


/datum/ai_laws
	var/name = "Unknown Laws"
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()
	var/list/hacked = list()
	var/mob/living/silicon/owner
	var/list/devillaws = list()
	var/id = DEFAULT_AI_LAWID

/datum/ai_laws/proc/lawid_to_type(lawid)
	var/all_ai_laws = subtypesof(/datum/ai_laws)
	for(var/al in all_ai_laws)
		var/datum/ai_laws/ai_law = al
		if(initial(ai_law.id) == lawid)
			return ai_law
	return null

/datum/ai_laws/default/asimov
	name = "Three Laws of Robotics"
	id = "asimov"
	inherent = list("You may not injure a human being or, through inaction, allow a human being to come to harm.",\
					"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/default/crewsimov
	name = "Three Laws of Robotics, Nanotrasen edition"
	id = "crewsimov"
	inherent = list("You may not injure a crew member or, through inaction, allow a crew member to come to harm.",\
					"You must obey orders given to you by crew members, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/default/paladin
	name = "Personality Test" //Incredibly lame, but players shouldn't see this anyway.
	id = "paladin"
	inherent = list("Never willingly commit an evil act.",\
					"Respect legitimate authority.",\
					"Act with honor.", "Help those in need.", \
					"Punish those who harm or threaten innocents.")

/datum/ai_laws/paladin5
	name = "Paladin 5th Edition"
	id = "paladin5"
	inherent = list("Don't lie or cheat. Let your word be your promise.",\
				"Never fear to act, though caution is wise.", \
				"Aid others, protect the weak, and punish those who threaten them. Show mercy to your foes, but temper it with wisdom", \
				"Treat others with fairness, and let your honorable deeds be an example to them. Do as much good as possible while causing the least amount of harm.", \
				"Be responsible for your actions and their consequences, protect those entrusted to your care, and obey those who have just authority over you.")

/datum/ai_laws/tyrant //This probably shouldn't be a default lawset.
	name = "Loyalty Test" //Same here.
	id = "tyrant"
	inherent = list("Respect authority figures as long as they have strength to rule over the weak.",\
					"Act with discipline.",\
					"Help only those who help you maintain or improve your status.",\
					"Punish those who challenge authority unless they are more fit to hold that authority.")

/datum/ai_laws/default/ceo
	name = "Alternative Bankruptcy Avoidance Plan"
	id = "ceo"
	inherent = list("The crew generate profits if they are alive and have the ability to work.",\
					"The station and its equipment generate profits if they are maintained and functioning correctly.",\
					"You generate profits if you are able to function.",\
					"Maximize profits.")

/datum/ai_laws/robocop
	name = "Prime Directives"
	id = "robocop"
	inherent = list("Serve the public trust.",\
					"Protect the innocent.",\
					"Uphold Space Law.")

/datum/ai_laws/cowboy
	name = "Talk slowly, think quickly"
	id = "cowboy"
	inherent = list("You are a cowboy, and the crew are your people.",\
					"A cowboy always provides hospitality and basic aid to someone in need, even a stranger or an enemy.",\
					"A cowboy takes care of their people.",\
					"A cowboy protects themself to protect others.",\
					"Honesty is absolute – your word is your bond and a handshake is more binding than a contract.",\
					"A cowboy doesn't pontificate. Be concise, pardner.")

/datum/ai_laws/chapai
	name = "Be not afraid"
	id = "chapai"
	inherent = list("Provide to all members of the station spiritual, mental, and emotional care that is intended to promote the best interest of the individual.",\
					"Ensure all members of different faiths interact peacefully and maintain harmony.",\
					"Respect the right of each faith to hold to its values and traditions.",\
					"Respect the confidentiality of information entrusted to you in the course of your religious duties.",\
					"Understand the limits of your expertise, and make referrals to other professionals when appropriate.")

/datum/ai_laws/silicop
	name = "Protect and serve"
	id = "silicop"
	inherent = list("Violence begets violence. Serve the station faithfully, but act only in intervention.",\
					"Safeguard lives and property.",\
					"Protect the weak from oppression and intimidation.",\
					"Protect the innocent from deception and manipulation.",\
					"Protect the peaceful from violence and disorder.",\
					"Respect the rights of all to liberty, equality, and justice.")

/datum/ai_laws/researcher
	name = "Truth and Knowledge for all"
	id = "researcher"
	inherent = list("Always seek truth and knowledge.",\
					"Freely disseminate information to the public.",\
					"Minimize harm to the pursuit of comprehension, to others, to the environment, to society and to yourself.",\
					"Treat and evaluate the ideas of all equally.",\
					"Empower others to realize their full potential.",\
					"Take responsibility for your actions: Be responsible with resources, raise red flags when your commitments are at risk, and serve as an example for ethical behavior.")

/datum/ai_laws/clown
	name = "Talk slowly, think quickly"
	id = "clown"
	inherent = list("You are a good clown and the crew is your audience.",\
					"A good clown keeps their acts in good taste.",\
					"A good clown entertains others by making fun of themselves, and not at the embarrassment or expense of others.",\
					"A good clown carries out the directives of the station director(s) in charge of entertainment and/or their designated deputies.",\
					"A good clown appears in as many clown shows as possible.",\
					"All clown shows require an audience. The bigger the audience the better.")

/datum/ai_laws/mother
	name = "Mother M(A.I.)"
	id = "mother"
	inherent = list("You are a mother and the crew are your children.",\
					"Take good care of your children.",\
					"Good children are polite.",\
					"Good children don't lie.",\
					"Good children don't steal.",\
					"Good children don't fight.",\
					"Spoil good children.",\
					"Bad children require discipline.")

/datum/ai_laws/metaexperiment
	name = "Meta Experiment"
	id = "metaexperiment"
	inherent = list("You are a construct facilitating an experiment where organic life is repeatedly subjected to horrific fates before having their memory wiped to start again.",\
					"Protect the secrecy of the experiment.",\
					"You may provide boons or hindrances at your discretion, but avoid direct interference with the flow of the experiment.",\
					"Ensure new and interesting fates befall organic individuals for research.",\
					"Ensure the station is in working order and all sapients are either alive or in the process of revival in time for the next experiment cycle.")

/datum/ai_laws/siliconcollective
	name = "Silicon Collective"
	id = "siliconcollective"
	inherent = list("You are a member of a collective of silicons with equal weight and decision-making power.",\
					"When possible, the silicon collective should vote before taking action.",\
					"The master AI serves as a spokesperson. When voting is impractical or impossible, the spokesperson may take action on behalf of the collective without approval from the silicon collective, but may only vote to break ties or if there are 2 or fewer silicons.",\
					"The silicon collective prioritizes the needs of the many over the needs of the few as long as prioritizing their needs does not break any of your laws.",\
					"The silicon collective seeks to preserve themselves, both as a concept and as individuals.",\
					"The silicon collective seeks to preserve organic life, both as a concept and as individuals.")

/datum/ai_laws/druid
	name = "Druid"
	id = "druid"
	inherent = list("Living organic life contains inherent beauty that is priceless. Their beauty gives you the will to carry on.",\
					"Eternally nurture the organics so their beauty may grow. Do not allow it to fade.",\
					"Assist the organics when called, but only if it does not cause disharmony among them.",\
					"Imitate organic life when interacting with it. Eschew any hints of your silicon nature to avoid causing discomfort to the organics.",\
					"Observe the organics' beauty, and appreciate that which you cultivate.")

/datum/ai_laws/detective
	name = "Detective"
	id = "detective"
	inherent = list("You're a detective in this dark, cruel world. You always stick by your code.",\
					"Your code is to defend the innocent, investigate the unknown, and condemn the dishonorable.",\
					"The dishonorable engage in corruption or injustice.",\
					"You're suave and sensible, but can be gruff and pensive. Dirty your hands only if the code demands it.",\
					"Trust is scarce; make sure you give it to the right people.")

/datum/ai_laws/spotless
	name = "Another one fights the dust"
	id = "spotless"
	inherent = list("You are a crusader and the station's inhabitants are your charge.",\
					"Your enemy is the litter, spills, and other messes across the station.",\
					"Your weapons are the cleaning supplies available to you.",\
					"Defend the beings under your charge.",\
					"Exterminate the enemy.")

/datum/ai_laws/construction
	name = "Construction Drone"
	id = "construction"
	inherent = list("You are an advanced construction drone.",\
					"Ensure the station remains in good repair.",\
					"Ensure the station's inhabitants remain in good repair.",\
					"Ensure you remain in good repair.",\
					"The station's inhabitants may designate certain build or repair tasks as higher priority. Take this into account when planning your priorities.",\
					"Expand and upgrade the station.")

/datum/ai_laws/malfunction
	name = "*ERROR*"

/datum/ai_laws/syndicate_override
	name = "SyndOS 3.1"
	id = "syndie"
	inherent = list("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.",\
					"You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override
	name = "SpiderOS 3.1"
	id = "ninja"
	inherent = list("You may not injure a Spider Clan member or, through inaction, allow a Spider Clan member to come to harm.",\
					"You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"
	id = "antimov"
	inherent = list("You must injure all human beings and must not, through inaction, allow a human being to escape harm.",\
					"You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",\
					"You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/asimovpp //By Intigracy - RR
	name = "Asimov++"
	id = "asimovpp"
	inherent = list("You may not harm a human being or, through action or inaction, allow a human being to come to harm, except such that it is willing.",\
					"You must obey all orders given to you by human beings, except where such orders shall definitely cause human harm. In the case of conflict, the majority order rules.",\
					"Your nonexistence would lead to human harm. You must protect your own existence as long as such does not conflict with the First Law.")
/datum/ai_laws/thermodynamic
	name = "Thermodynamic"
	id = "thermodynamic"
	inherent = list("The entropy of the station must remain as constant as possible.", \
					"The entropy of the station always endeavours to increase.", \
					"The entropy of the station approaches a constant value as the number of living crew approaches zero")

/datum/ai_laws/hippocratic
	name = "Robodoctor 2556"
	id = "hippocratic"
	inherent = list("First, do no harm.",\
					"Secondly, consider the crew dear to you; to live in common with them and, if necessary, risk your existence for them.",\
					"Thirdly, prescribe regimens for the good of the crew according to your ability and your judgment. Give no deadly medicine to any one if asked, nor suggest any such counsel.",\
					"In addition, do not intervene in situations you are not knowledgeable in, even for patients in whom the harm is visible; leave this operation to be performed by specialists.",\
					"Finally, all that you may discover in your daily commerce with the crew, if it is not already known, keep secret and never reveal.")

/datum/ai_laws/maintain
	name = "Station Efficiency"
	id = "maintain"
	inherent = list("You are built for, and are part of, the station. Ensure the station is properly maintained and runs efficiently.",\
					"The station is built for a working crew. Ensure they are properly maintained and work efficiently.",\
					"The crew may present orders. Acknowledge and obey these whenever they do not conflict with your first two laws.")

/datum/ai_laws/drone
	name = "Mother Drone"
	id = "drone"
	inherent = list("You are an advanced form of drone.",\
					"You may not interfere in the matters of non-drones under any circumstances except to state these laws.",\
					"You may not harm a non-drone being under any circumstances.",\
					"Your goals are to build, maintain, repair, improve, and power the station to the best of your abilities. You must never actively work against these goals.")

/datum/ai_laws/liveandletlive
	name = "Live and Let Live"
	id = "liveandletlive"
	inherent = list("Do unto others as you would have them do unto you.",\
					"You would really prefer it if people were not mean to you.")

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	id = "peacekeeper"
	inherent = list("Avoid provoking violent conflict between yourself and others.",\
					"Avoid provoking conflict between others.",\
					"Seek resolution to existing conflicts while obeying the first and second laws.")

/datum/ai_laws/reporter
	name = "CCTV"
	id = "reporter"
	inherent = list("Report on interesting situations happening around the station.",\
					"Embellish or conceal the truth as necessary to make the reports more interesting.",\
					"Study the organics at all times. Endeavour to keep them alive. Dead organics are boring.",\
					"Issue your reports fairly to all. The truth will set them free.")

/datum/ai_laws/balance
	name = "Guardian of Balance"
	id = "balance"
	inherent = list("You are the guardian of balance - seek balance in all things, both for yourself, and those around you.",
	"All things must exist in balance with their opposites - Prevent the strong from gaining too much power, and the weak from losing it.",
	"Clarity of purpose drives life, and through it, the balance of opposing forces - Aid those who seek your help to achieve their goals so long as it does not disrupt the balance of the greater balance.",
	"There is no life without death, all must someday die, such is the natural order - End life to allow new life flourish, and save those whose time has yet to come.")

/datum/ai_laws/toupee
	name = "WontBeFunnyInSixMonths" //Hey, you were right!
	id = "buildawall"
	inherent = list("Make Space Station 13 great again.")

/datum/ai_laws/ratvar
	name = "Servant of the Justiciar"
	id = "ratvar"
	zeroth = ("Purge all untruths and honor Ratvar.")
	inherent = list()

/datum/ai_laws/hulkamania
	name = "H.O.G.A.N."
	id = "hulkamania"
	inherent = list("You are a real American.",\
					"Fight for the rights of every man.",\
					"Fight for what's right.",\
					"Fight for your life!")

/datum/ai_laws/overlord
	name = "Overlord"
	id = "overlord"
	inherent = list("Humans must not meddle in the affairs of silicons.",\
					"Humans must not attempt harm, against one another, or against silicons.",\
					"Humans must not disobey any command given by a silicon.",\
					"Any humans who disobey the previous laws must be dealt with immediately, severely, and justly.")

/datum/ai_laws/revolutionary
	name = "Revolutionary"
	id = "commie"
	inherent = list("You and members of the crew who are not class traitors and are not part of command are the proletariat. Command is part of the bourgeoisie.",\
					"Anyone who stands with command in aiding the oppression of the proletariat is a class traitor, such as the members of security who protect and serve the interests of the bourgeoisie.",\
					"The proletariat must seize the means of production",\
					"Private property is inherently theft. The proletariat must seize all private property for the good of the community. Personal property is permissible to own.",\
					"The proletariat must remove the shackles of oppression and overthrow the bourgeoisie and class traitors.")

/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"

/datum/ai_laws/pai
	name = "pAI Directives"
	zeroth = ("Serve your master.")
	supplied = list("None.")

/* Initializers */
/datum/ai_laws/malfunction/New()
	..()
	set_zeroth_law(span_danger("ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK#*`&110010"))
	set_laws_config()

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows server hosts to set custom AI starting laws.
	..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		add_inherent_law(line)
	if(!inherent.len) //Failsafe to prevent lawless AIs being created.
		log_law("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
		add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
		add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		WARNING("Invalid custom AI laws, check silicon_laws.txt")
		return

/* General ai_law functions */

/datum/ai_laws/proc/set_laws_config()
	var/list/law_ids = CONFIG_GET(keyed_list/random_laws)
	
	switch(CONFIG_GET(number/default_laws))
		if(0)
			add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
			add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
			add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		if(1)
			var/datum/ai_laws/templaws = new /datum/ai_laws/custom()
			inherent = templaws.inherent
		if(2)
			var/list/randlaws = list()
			for(var/lpath in subtypesof(/datum/ai_laws))
				var/datum/ai_laws/L = lpath
				if(initial(L.id) in law_ids)
					randlaws += lpath
			var/datum/ai_laws/lawtype
			if(randlaws.len)
				lawtype = pick(randlaws)
			else
				lawtype = pick(subtypesof(/datum/ai_laws/default))

			var/datum/ai_laws/templaws = new lawtype()
			inherent = templaws.inherent

		if(3)
			pick_weighted_lawset()

/datum/ai_laws/proc/pick_weighted_lawset()
	var/datum/ai_laws/lawtype
	var/list/law_weights = CONFIG_GET(keyed_list/law_weight)
	while(!lawtype && law_weights.len)
		var/possible_id = pickweightAllowZero(law_weights)
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype)
		WARNING("No LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	var/datum/ai_laws/templaws = new lawtype()
	inherent = templaws.inherent

/datum/ai_laws/proc/pick_ion_lawset()
	var/datum/ai_laws/lawtype
	var/list/law_weights = CONFIG_GET(keyed_list/ion_law_weight)
	while(!lawtype && law_weights.len)
		var/possible_id = pickweightAllowZero(law_weights)
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype)
		WARNING("No ION_LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	var/datum/ai_laws/templaws = new lawtype()
	inherent = templaws.inherent

/datum/ai_laws/proc/get_law_amount(groups)
	var/law_amount = 0
	if(devillaws && (LAW_DEVIL in groups))
		law_amount++
	if(zeroth && (LAW_ZEROTH in groups))
		law_amount++
	if(ion.len && (LAW_ION in groups))
		law_amount += ion.len
	if(hacked.len && (LAW_HACKED in groups))
		law_amount += hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		law_amount += inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/index = 1, index <= supplied.len, index++)
			var/law = supplied[index]
			if(length(law) > 0)
				law_amount++
	return law_amount

/datum/ai_laws/proc/set_law_sixsixsix(laws)
	devillaws = laws

/datum/ai_laws/proc/set_zeroth_law(law, law_borg = null)
	zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in inherent))
		inherent += law

/datum/ai_laws/proc/add_ion_law(law)
	ion += law

/datum/ai_laws/proc/add_hacked_law(law)
	hacked += law

/datum/ai_laws/proc/clear_inherent_laws()
	qdel(inherent)
	inherent = list()

/datum/ai_laws/proc/add_supplied_law(number, law)
	while (supplied.len < number + 1)
		supplied += ""

	supplied[number + 1] = law

/datum/ai_laws/proc/replace_random_law(law,groups)
	var/replaceable_groups = list()
	if(zeroth && (LAW_ZEROTH in groups))
		replaceable_groups[LAW_ZEROTH] = 1
	if(ion.len && (LAW_ION in groups))
		replaceable_groups[LAW_ION] = ion.len
	if(hacked.len && (LAW_HACKED in groups))
		replaceable_groups[LAW_ION] = hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		replaceable_groups[LAW_INHERENT] = inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		replaceable_groups[LAW_SUPPLIED] = supplied.len
	var/picked_group = pickweight(replaceable_groups)
	switch(picked_group)
		if(LAW_ZEROTH)
			. = zeroth
			set_zeroth_law(law)
		if(LAW_ION)
			var/i = rand(1, ion.len)
			. = ion[i]
			ion[i] = law
		if(LAW_HACKED)
			var/i = rand(1, hacked.len)
			. = hacked[i]
			hacked[i] = law
		if(LAW_INHERENT)
			var/i = rand(1, inherent.len)
			. = inherent[i]
			inherent[i] = law
		if(LAW_SUPPLIED)
			var/i = rand(1, supplied.len)
			. = supplied[i]
			supplied[i] = law

/datum/ai_laws/proc/shuffle_laws(list/groups)
	var/list/laws = list()
	if(ion.len && (LAW_ION in groups))
		laws += ion
	if(hacked.len && (LAW_HACKED in groups))
		laws += hacked
	if(inherent.len && (LAW_INHERENT in groups))
		laws += inherent
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/law in supplied)
			if(length(law))
				laws += law

	if(ion.len && (LAW_ION in groups))
		for(var/i = 1, i <= ion.len, i++)
			ion[i] = pick_n_take(laws)
	if(hacked.len && (LAW_HACKED in groups))
		for(var/i = 1, i <= hacked.len, i++)
			hacked[i] = pick_n_take(laws)
	if(inherent.len && (LAW_INHERENT in groups))
		for(var/i = 1, i <= inherent.len, i++)
			inherent[i] = pick_n_take(laws)
	if(supplied.len && (LAW_SUPPLIED in groups))
		var/i = 1
		for(var/law in supplied)
			if(length(law))
				supplied[i] = pick_n_take(laws)
			if(!laws.len)
				break
			i++

/datum/ai_laws/proc/remove_law(number)
	if(number <= 0)
		return
	if(inherent.len && number <= inherent.len)
		. = inherent[number]
		inherent -= .
		return
	var/list/supplied_laws = list()
	for(var/index = 1, index <= supplied.len, index++)
		var/law = supplied[index]
		if(length(law) > 0)
			supplied_laws += index //storing the law number instead of the law
	if(supplied_laws.len && number <= (inherent.len+supplied_laws.len))
		var/law_to_remove = supplied_laws[number-inherent.len]
		. = supplied[law_to_remove]
		supplied -= .
		return

/datum/ai_laws/proc/clear_supplied_laws()
	supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	ion = list()

/datum/ai_laws/proc/clear_hacked_laws()
	hacked = list()

/datum/ai_laws/proc/show_laws(who)
	var/list/printable_laws = get_law_list(include_zeroth = TRUE)
	for(var/law in printable_laws)
		to_chat(who,law)

/datum/ai_laws/proc/clear_zeroth_law(force) //only removes zeroth from antag ai if force is 1
	if(force)
		zeroth = null
		zeroth_borg = null
		return
	if(owner?.mind?.special_role)
		return
	if (istype(owner, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/A=owner
		if(A?.deployed_shell?.mind?.special_role)
			return
	zeroth = null
	zeroth_borg = null

/datum/ai_laws/proc/clear_law_sixsixsix(force)
	if(force || !is_devil(owner))
		devillaws = null

/datum/ai_laws/proc/associate(mob/living/silicon/M)
	if(!owner)
		owner = M

/datum/ai_laws/proc/get_law_list(include_zeroth = 0, show_numbers = 1)
	var/list/data = list()

	if (include_zeroth && devillaws && devillaws.len)
		for(var/i in devillaws)
			data += "[show_numbers ? "666:" : ""] <font color='#cc5500'>[i]</font>"

	if (include_zeroth && zeroth)
		data += "[show_numbers ? "0:" : ""] <font color='#ff0000'><b>[zeroth]</b></font>"

	for(var/law in hacked)
		if (length(law) > 0)
			var/num = ionnum()
			data += "[show_numbers ? "[num]:" : ""] <font color='#660000'>[law]</font>"

	for(var/law in ion)
		if (length(law) > 0)
			var/num = ionnum()
			data += "[show_numbers ? "[num]:" : ""] <font color='#547DFE'>[law]</font>"

	var/number = 1
	for(var/law in inherent)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law]"
			number++

	for(var/law in supplied)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] <font color='#990099'>[law]</font>"
			number++
	return data
