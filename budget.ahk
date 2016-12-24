c := new BudgetClass()
ExitApp
#x::ExitApp

class BudgetClass()
{
	iexplorer := false
	fileName := "budgetData.txt"
	
	__new()
	{
		this.iexplorer := ComObjCreate("InternetExplorer.Application")
		return this
	}
	
	waitForLogin()
	{
		
		return this
	}
	
	waitForCreditCard()
	{
	
		return this
	}
	
	
	getTransaction()
	{
		
	}
	
}