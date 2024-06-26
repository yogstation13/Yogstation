/datum/round_event_control/high_priority_bounty
	name = "High Priority Bounty"
	typepath = /datum/round_event/high_priority_bounty
	max_occurrences = 3
	weight = 20
	earliest_start = 10

/datum/round_event/high_priority_bounty
	var/datum/bank_account/account

/datum/round_event/high_priority_bounty/setup()
	var/list/datum/bank_account/candidates

	for(var/account_code as anything in SSeconomy.bank_accounts)
		var/datum/bank_account/bank_account = SSeconomy.bank_accounts[account_code]
		if(!bank_account) continue
		if(!bank_account.bounties) continue
		if(bank_account.bounties.len > 0)
			candidates += bank_account
	
	account = pick(candidates)

/datum/round_event/high_priority_bounty/announce(fake)
	priority_announce("Central Command has issued a high-priority cargo bounty to [account.account_holder]. Details have been sent to all bounty consoles.", "Nanotrasen Bounty Program")

/datum/round_event/high_priority_bounty/start()
	var/datum/bounty/bounty = random_bounty(CIV_JOB_RANDOM, account)
	if(!bounty)
		return
	bounty.mark_high_priority(3)
	account.bounties += bounty


