/datum/ai_project/crypto_miner
	name = "Crypto Miner"
	description = "Allocating spare CPU capacity to mining crypto currency should be able to help fund the station budget. This would however reduce AI research point generation by 50%"
	category = AI_PROJECT_MISC
	
	research_cost = 2000
	

/datum/ai_project/crypto_miner/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	dashboard.crypto_mining = TRUE

/datum/ai_project/crypto_miner/stop()
	dashboard.crypto_mining = FALSE
	..()
