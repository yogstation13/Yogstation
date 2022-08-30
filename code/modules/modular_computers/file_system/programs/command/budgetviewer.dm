/datum/computer_file/program/budget_monitor
	filename = "budgetmonitor"
	filedesc = "Budget Monitor"
	category = PROGRAM_CATEGORY_CMD
	program_icon_state = "id"
	extended_desc = "This program will allow you to view the financial status of your department(s)."
	transfer_access = ACCESS_HEADS
	usage_flags = PROGRAM_ALL
	requires_ntnet = 1
	size = 3
	tgui_id = "NtosBudgetMonitor"
	program_icon = "id-card"

/datum/computer_file/program/budget_monitor/ui_data()
	var/list/data = get_header_data()
	
	var/list/budgets = list()
	for(var/A in SSeconomy.department_accounts)
		var/name = SSeconomy.get_dep_account(A).account_holder
		var/money = SSeconomy.get_dep_account(A).account_balance || "0"
		budgets += list(list("name" = name, "money" = money))
	
	data["budgets"] = budgets

	return data

