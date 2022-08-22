#define DUMPTIME 3000

/datum/bank_account
	var/account_holder = "Rusty Venture"
	var/account_balance = 0
	var/payday_modifier
	var/datum/job/account_job
	var/list/bank_cards = list()
	var/add_to_accounts = TRUE
	var/account_id
	var/being_dumped = FALSE //pink levels are rising
	var/withdrawDelay = 0
	var/is_bourgeois = FALSE // Marks whether we've tried giving them the achievement already, this round.
	var/bounties_claimed = 0 // Marks how many bounties this person has successfully claimed

/datum/bank_account/New(newname, job, modifier = 1)
	var/limiter = 0
	while(limiter < 10)
		account_id = rand(111111,999999)
		if(!("[account_id]" in SSeconomy.bank_accounts))
			break
		limiter += 1
	
	if(limiter >= 10)
		message_admins("Infinite loop prevented in bank account creation, unable to find bank account after [limiter] tries. Something has broken.")

	if(add_to_accounts)
		SSeconomy.bank_accounts["[account_id]"] = src
	account_holder = newname
	account_job = job
	payday_modifier = modifier

/datum/bank_account/Destroy()
	if(add_to_accounts)
		SSeconomy.bank_accounts -= "[account_id]"
	return ..()

/datum/bank_account/proc/dumpeet()
	being_dumped = TRUE
	withdrawDelay = world.time + DUMPTIME

/datum/bank_account/proc/_adjust_money(amt)
	account_balance += amt
	if(account_balance > 1000000 && !is_bourgeois) // if we are now a millionaire, give the achievement
		//So we currently only know what is *supposed* to be the real_name of the client's mob. If we can find them, we can get them this achievement.
		for(var/x in GLOB.player_list)
			var/mob/M = x
			if(M.real_name == account_holder)
				SSachievements.unlock_achievement(/datum/achievement/cargo/bourgeois, M.client)
				is_bourgeois = TRUE
				//break would result in the possibility of this being given to changeling who has duplicated the millionaire, and not to the actual millionaire.

/datum/bank_account/proc/has_money(amt)
	return account_balance >= amt

/datum/bank_account/proc/adjust_money(amt)
	if((amt < 0 && has_money(-amt)) || amt > 0)
		_adjust_money(amt)
		return TRUE
	return FALSE

/datum/bank_account/proc/transfer_money(datum/bank_account/from, amount)
	if(from.has_money(amount))
		adjust_money(amount)
		from.adjust_money(-amount)
		return TRUE
	return FALSE

/datum/bank_account/proc/payday(amt_of_paychecks)
	var/money_to_transfer = account_job.paycheck * payday_modifier * amt_of_paychecks
	var/stolen_money = (1 - payday_modifier) * account_job.paycheck * amt_of_paychecks
	GLOB.stolen_paycheck_money += stolen_money
	adjust_money(money_to_transfer)
	bank_card_talk("Payday processed, account now holds $[account_balance].")

/datum/bank_account/proc/bank_card_talk(message, force)
	if(!message || !bank_cards.len)
		return
	for(var/obj/A in bank_cards)
		var/mob/card_holder = recursive_loc_check(A, /mob)
		if(ismob(card_holder)) //If on a mob
			if(card_holder.client && !(card_holder.client.prefs.chat_toggles & CHAT_BANKCARD) && !force)
				return

			card_holder.playsound_local(get_turf(card_holder), 'sound/machines/twobeep_high.ogg', 50, TRUE)
			if(card_holder.can_hear())
				to_chat(card_holder, "[icon2html(A, card_holder)] *[message]*")
		else if(isturf(A.loc)) //If on the ground
			for(var/mob/M in hearers(1,get_turf(A)))
				if(M.client && !(M.client.prefs.chat_toggles & CHAT_BANKCARD) && !force)
					return
				playsound(A, 'sound/machines/twobeep_high.ogg', 50, TRUE)
				A.audible_message("[icon2html(A, hearers(A))] *[message]*", null, 1)
				break
		else
			for(var/mob/M in A.loc) //If inside a container with other mobs (e.g. locker)
				if(M.client && !(M.client.prefs.chat_toggles & CHAT_BANKCARD) && !force)
					return
				M.playsound_local(get_turf(M), 'sound/machines/twobeep_high.ogg', 50, TRUE)
				if(M.can_hear())
					to_chat(M, "[icon2html(A, M)] *[message]*")

/datum/bank_account/department
	account_holder = "Guild Credit Agency"
	var/department_id = "REPLACE_ME"
	add_to_accounts = FALSE

/datum/bank_account/department/New(dep_id, budget)
	department_id = dep_id
	account_balance = budget
	account_holder = SSeconomy.department_accounts[dep_id]
	SSeconomy.generated_accounts += src

#undef DUMPTIME
