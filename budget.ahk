deubg := true
c := new BudgetClass(new CommonweathBankAPIClass(), new GoodBudgetAPIClass())
c.update()
return

#u::
{
	MsgBox here
	c.update()
	return
}

class BudgetClass
{
	__new(bankApi, budgetAppApi)
	{
		this.budgetAppApi := budgetAppApi
		this.bankApi := bankApi
		
		return this
	}
	
	update()
	{
		bankTransactions := this.bankApi.getTransactions()
		budgetedTransactions := this.budgetAppApi.getTransactions()
		this.addTransactions(this.removeAlreadyAdded(bankTransactions, budgetedTransactions))
		return this
	}
	
	addTransactions(transactions)
	{
		for index, transaction in transactions
		{
			MsgBox % arrayToString(transaction)
			this.budgetAppApi.addNewTransaction(transaction)
		}
		return this
	}
	
	removeAlreadyAdded(fromBank, fromBudget)
	{
		notAdded := []
		for index, transaction1 in fromBank
		{
			alreadyAdded := false
			for index2, transaction2 in fromBudget
			{
				if(transaction1.equals(transaction2))
				{
					debug("already added!")
					alreadyAdded := true
					break
				}
			}
			if(!alreadyAdded)
			{
				notAdded.insert(transaction1)
			}
		}
		return notAdded
	}
}

#include commonFunctions.ahk
#include commonwealth bank.ahk
#include transaction.ahk
#include goodBudgetAPI.ahk