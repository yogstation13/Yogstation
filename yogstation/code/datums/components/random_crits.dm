/datum/component/random_crits
》var/crit_rate = 5
》var/crit_rate_max = 70
》var/crit_rate_increase = 10 //% crit chance per hit
》var/crit_dropoff_coeff = .6 //% of crit chance remaining after dropoff

/datum/component/random_crits/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
  var/crit_damage = current * 2 //random crits deal 3x damage, minus force
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/on_attack)

/datum/component/random_crits/proc/on_attack(datum/source, mob/living/target, mob/user)
》prob(crit_rate)
》》target.apply_damage(crit_damage, BRUTE, user.zone_selected, 0)
》》user.visible_message("<span class='danger'>"[user]'s [parent] scores a random crit!!"</span>")
》if(!target.stat && target.ckey)
》》crit_rate += crit_rate_increase
》》if(crit_rate > crit_rate_max)
》》crit_rate = crit_rate_max

/datum/component/random_crits/process()
》crit_rate *= crit_dropoff_coeff
》if(crit_rate < initial(crit_rate)
》》crit_rate = initial(crit_rate)
