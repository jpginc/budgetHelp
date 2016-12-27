deubg := true
c := new BudgetClass(new CommonweathBankAPIClass(), "")
ExitApp
#x::ExitApp

class BudgetClass
{
	__new(bankApi, budgetAppApi)
	{
		transactions := bankApi.getTransactions()
		MsgBox % arrayToString(transactions)
		clipboard := arrayToString(transactions)
		return this
	}
}

#include commonFunctions.ahk
#include commonwealth bank.ahk
#include transaction.ahk