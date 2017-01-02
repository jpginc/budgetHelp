﻿class CommonweathBankAPIClass
{
	iexplorer := false
	debugOn := false
	
	__new()
	{
		this.init()
		return this
	}
	
	getTransactions()
	{
		this.waitForTransactions()
			.waitForFullLoad()
		
		return this.__getTransactions()	
	}
	
	init()
	{
		this.iexplorer := new IExplorerClass()
		this.iexplorer.visible(true)
			.navigate("https://www.netbank.com.au")
		return this
	}
	
	waitForTransactions()
	{
		notify("Please navigate a transaction page")
		this.iexplorer.waitFor("Netbank - Transactions")
		notify("")
		return this
	}
	
	waitForFullLoad()
	{
		this.iexplorer.waitForFullLoad()
		return this
	}

	__getTransactions()
	{
		table := this.iexplorer.getElementById("transactionsTableBody")
		transactions := []
		
		loop, % table.rows.length
		{
			transaction := this.__getTransaction(table.rows.item(A_Index - 1).cells)
			if(transaction)
			{
				transactions.insert(transaction)
			}
		}
		return transactions
	}
	
	__getTransaction(cells)
	{
		transDate := false
		amount := false
		transDetail := false
		loop % cells.length
		{
			cellClass := cells[A_Index - 1].className
			value := trim(cells[A_Index -1].innerText)
			IfInString, cellClass, date
			{
				transDate := value 
			}
			IfInString, cellClass, debit
			{
				IfInString, value, -$ ;needed. for some reson credits have the debit class
				{
					amount := value
				}
			}
			IfInString, cellClass, arrow
			{
				transDetail := value
			}
		}
		if(transDate && amount && transDetail)
		{
			if(! InStr(transDetail, "PENDING -"))
			{
				return new TransactionClass(amount, this.trimDetails(transDetail), transDate)
			}
		}
		return false
	}
	
	trimDetails(details)
	{
		;note that you can't do this in one go because some transactions don't have the "Open transaction detials" text
		details := regexReplace(details, "Open transaction details")
		details := regexReplace(details, "^\s*")
		details := regexReplace(details, "\s*$")
		return details
	}	
}