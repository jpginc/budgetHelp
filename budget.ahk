﻿deubg := true
c := new BudgetClass(new CommonweathBankAPIClass(), new GoodBudgetAPIClass())
Gui, Add, Text, vnotifyText, Press the update button to start!`n`n
Gui, add, button, vupdateButton gUpdate, Update
Gui, add, button, gquit, Quit
gui, show, w500 h500
return

quit:
GuiClose:
{
	ExitApp
}
update:
#u::
{
	GuiControl, disable, updateButton
	c.update()
	GuiControl, enable, updateButton
	notify("Done! press update to go again")
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
		this.addTransactions(this.2017OrLater(this.removeAlreadyAdded(bankTransactions, budgetedTransactions)))
		MsgBox update complete
		return this
	}
	
	2017OrLater(transactions)
	{
		later := []
		startOf2017 := "20170101000000"
		for index, transaction in transactions
		{
			if(transaction.date > startOf2017)
			{
				later.insert(transaction)
			}
		}
		return later
	}
	
	addTransactions(transactions)
	{
		for index, transaction in transactions
		{
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
#Include iexplorer.ahk