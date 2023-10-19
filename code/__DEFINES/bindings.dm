#define AUXMOS "auxmos"

/turf/proc/__update_auxtools_turf_adjacency_info()
	call_ext(AUXMOS, "byond:hook_infos_ffi")(src)

/turf/proc/update_air_ref()
	call_ext(AUXMOS, "byond:hook_register_turf_ffi")(src)

/datum/controller/subsystem/air/proc/process_excited_groups_auxtools(remaining)
	call_ext(AUXMOS, "byond:groups_hook_ffi")(src, remaining)

/datum/controller/subsystem/air/proc/process_turfs_auxtools(remaining)
	call_ext(AUXMOS, "byond:process_turf_hook_ffi")(src, remaining)

/datum/controller/subsystem/air/proc/finish_turf_processing_auxtools(time_remaining)
	call_ext(AUXMOS, "byond:finish_process_turfs_ffi")(time_remaining)

/datum/controller/subsystem/air/proc/thread_running()
	call_ext(AUXMOS, "byond:thread_running_hook_ffi")()

/datum/controller/subsystem/air/proc/process_turf_equalize_auxtools(remaining)
	call_ext(AUXMOS, "byond:equalize_hook_ffi")(remaining)

/datum/gas_mixture/proc/__auxtools_parse_gas_string(string)
	call_ext(AUXMOS, "byond:parse_gas_string_ffi")(src, string)

/datum/controller/subsystem/air/proc/get_max_gas_mixes()
	call_ext(AUXMOS, "byond:hook_max_gas_mixes_ffi")()

/datum/controller/subsystem/air/proc/get_amt_gas_mixes()
	call_ext(AUXMOS, "byond:hook_amt_gas_mixes_ffi")()

/proc/equalize_all_gases_in_list(list/gas_list)
	call_ext(AUXMOS, "byond:equalize_all_hook_ffi")(gas_list)

/datum/gas_mixture/proc/get_oxidation_power(temp)
	call_ext(AUXMOS, "byond:oxidation_power_hook_ffi")(src, temp)

/datum/gas_mixture/proc/get_fuel_amount(temp)
	call_ext(AUXMOS, "byond:fuel_amount_hook_ffi")(src, temp)

/datum/gas_mixture/proc/equalize_with(total)
	call_ext(AUXMOS, "byond:equalize_with_hook_ffi")(src, total)

/datum/gas_mixture/proc/transfer_ratio_to(datum/gas/other, ratio)
	call_ext(AUXMOS, "byond:transfer_ratio_hook_ffi")(src, other, ratio)

/datum/gas_mixture/proc/transfer_to(datum/gas/other, moles)
	call_ext(AUXMOS, "byond:transfer_hook_ffi")(src, other, moles)

/datum/gas_mixture/proc/adjust_heat()
	call_ext(AUXMOS, "byond:adjust_heat_hook_ffi")()

/datum/gas_mixture/proc/react(datum/holder)
	call_ext(AUXMOS, "byond:react_hook_ffi")(src, holder)

/datum/gas_mixture/proc/compare(other)
	call_ext(AUXMOS, "byond:compare_hook_ffi")(src, other)

/datum/gas_mixture/proc/clear()
	call_ext(AUXMOS, "byond:clear_hook_ffi")(src)

/datum/gas_mixture/proc/mark_immutable()
	call_ext(AUXMOS, "byond:mark_immutable_hook_ffi")(src)

/datum/gas_mixture/proc/scrub_into(datum/gas/into, ratio_v, gas_list)
	call_ext(AUXMOS, "byond:scrub_into_hook_ffi")(src, into, ratio_v, gas_list)

/datum/gas_mixture/proc/get_by_flag(flag_val)
	call_ext(AUXMOS, "byond:get_by_flag_hook_ffi")(src, flag_val)

/datum/gas_mixture/proc/__remove_by_flag(datum/gas/into, flag_val, amount_val)
	call_ext(AUXMOS, "byond:remove_by_flag_hook_ffi")(src, into, flag_val, amount_val)

/datum/gas_mixture/proc/divide(num_val)
	call_ext(AUXMOS, "byond:divide_hook_ffi")(src, num_val)

/datum/gas_mixture/proc/multiply(num_val)
	call_ext(AUXMOS, "byond:multiply_hook_ffi")(src, num_val)

/datum/gas_mixture/proc/subtract(num_val)
	call_ext(AUXMOS, "byond:subtract_hook_ffi")(src, num_val)

/datum/gas_mixture/proc/add(num_val)
	call_ext(AUXMOS, "byond:add_hook_ffi")(src, num_val)

/datum/gas_mixture/proc/adjust_multi()
	call_ext(AUXMOS, "byond:adjust_multi_hook_ffi")()

/datum/gas_mixture/proc/adjust_moles_temp(id_val, num_val, temp_val)
	call_ext(AUXMOS, "byond:adjust_moles_temp_hook_ffi")(src, id_val, num_val, temp_val)

/datum/gas_mixture/proc/adjust_moles(id_val, num_val)
	call_ext(AUXMOS, "byond:adjust_moles_hook_ffi")(src, id_val, num_val)

/datum/gas_mixture/proc/set_moles(gas_id, amt_val)
	call_ext(AUXMOS, "byond:set_moles_hook_ffi")(src, gas_id, amt_val)

/datum/gas_mixture/proc/get_moles(gas_id)
	call_ext(AUXMOS, "byond:get_moles_hook_ffi")(src, gas_id)

/datum/gas_mixture/proc/set_volume(vol_arg)
	call_ext(AUXMOS, "byond:set_volume_hook_ffi")(src, vol_arg)

/datum/gas_mixture/proc/partial_heat_capacity(gas_id)
	call_ext(AUXMOS, "byond:partial_heat_capacity_ffi")(src, gas_id)

/datum/gas_mixture/proc/set_temperature(arg_temp)
	call_ext(AUXMOS, "byond:set_temperature_hook_ffi")(src, arg_temp)

/datum/gas_mixture/proc/get_gases()
	call_ext(AUXMOS, "byond:get_gases_hook_ffi")(src)

/datum/gas_mixture/proc/temperature_share()
	call_ext(AUXMOS, "byond:temperature_share_hook_ffi")()

/datum/gas_mixture/proc/copy_from(datum/gas/giver)
	call_ext(AUXMOS, "byond:copy_from_hook_ffi")(src, giver)

/datum/gas_mixture/proc/__remove(datum/gas/into, amount_arg)
	call_ext(AUXMOS, "byond:remove_hook_ffi")(src, into, amount_arg)

/datum/gas_mixture/proc/__remove_ratio(datum/gas/into, ratio_arg)
	call_ext(AUXMOS, "byond:remove_ratio_hook_ffi")(src, into, ratio_arg)

/datum/gas_mixture/proc/merge(datum/gas/giver)
	call_ext(AUXMOS, "byond:merge_hook_ffi")(src, giver)

/datum/gas_mixture/proc/thermal_energy()
	call_ext(AUXMOS, "byond:thermal_energy_hook_ffi")(src)

/datum/gas_mixture/proc/return_volume()
	call_ext(AUXMOS, "byond:return_volume_hook_ffi")(src)

/datum/gas_mixture/proc/return_temperature()
	call_ext(AUXMOS, "byond:return_temperature_hook_ffi")(src)

/datum/gas_mixture/proc/return_pressure()
	call_ext(AUXMOS, "byond:return_pressure_hook_ffi")(src)

/datum/gas_mixture/proc/total_moles()
	call_ext(AUXMOS, "byond:total_moles_hook_ffi")(src)

/datum/gas_mixture/proc/set_min_heat_capacity(arg_min)
	call_ext(AUXMOS, "byond:min_heat_cap_hook_ffi")(src, arg_min)

/datum/gas_mixture/proc/heat_capacity()
	call_ext(AUXMOS, "byond:heat_cap_hook_ffi")(src)

/datum/gas_mixture/proc/__gasmixture_unregister()
	call_ext(AUXMOS, "byond:unregister_gasmixture_hook_ffi")(src)

/datum/gas_mixture/proc/__gasmixture_register()
	call_ext(AUXMOS, "byond:register_gasmixture_hook_ffi")(src)

/proc/process_atmos_callbacks(remaining)
	call_ext(AUXMOS, "byond:atmos_callback_handle_ffi")(remaining)

/proc/finalize_gas_refs()
	call_ext(AUXMOS, "byond:finalize_gas_refs_ffi")()

/datum/controller/subsystem/air/proc/auxtools_update_reactions()
	call_ext(AUXMOS, "byond:update_reactions_ffi")()

/proc/auxtools_atmos_init(datum/auxgm/gas_data)
	call_ext(AUXMOS, "byond:hook_init_ffi")(gas_data)

/proc/_auxtools_register_gas(datum/gas/gas)
	call_ext(AUXMOS, "byond:hook_register_gas_ffi")(gas)

/proc/__auxmos_shutdown()
	call_ext(AUXMOS, "byond:auxmos_shutdown_ffi")()

