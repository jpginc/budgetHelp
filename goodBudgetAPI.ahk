test := new GoodBudgetAPIClass()
test.getTransactions()
ExitApp

Class GoodBudgetAPIClass
{
	iexplorer := false
	exportFileNameWithPath :=  A_Temp "\budgettmp.txt"
	
	__new()
	{
		return this
	}
	
	getTransactions()
	{
		if(! this.iexplorer)
		{
			this.init()
		}
		this.waitForHome()
			.waitForFullLoad()
		existingBudget := this.exportTransactionsAsCSV()
		Clipboard := existingBudget
		MsgBox % existingBudget
		return this.__getTransactions()	
	}
	
	init()
	{
		this.iexplorer := ComObjCreate("InternetExplorer.Application")
		this.iexplorer.visible := true
		this.iexplorer.navigate("https://goodbudget.com/home")
		return this
	}
	
	waitFor(name)
	{
		while true
		{
			url := this.iexplorer.LocationName
			IfInString, url, % name
			{	
				break
			}
			this.debug(url)
			sleep 500
		}
		return this
	}
	
	exportTransactionsAsCSV()
	{
		notify("Exporting existing budget, please wait...")
		this.iexplorer.document.getElementById("export-txns").click()
		WinActivate, Home | Goodbudget - Internet Explorer
		sleep 500
		send {f6}{tab}
		sleep 500
		send {down 2}{enter}
		WinWaitActive, Save As
		Clipboard := this.exportFileNameWithPath
		send ^v{enter}
		send !y
		sleep 500
		FileRead, budget, % this.exportFileNameWithPath
		notify("Existing budget downloaded")
		FileDelete, % this.exportFileNameWithPath
		return budget
	}
	waitForHome()
	{
		notify("Please login")
		this.waitFor("Home | Goodbudget")
		notify("")
		return this
	}
	
	waitForFullLoad()
	{
		While(this.iexplorer.readyState != 4 || this.iexplorer.document.readyState != "complete" || this.iexplorer.busy)
		{
			Sleep, 50
		}
		return this
	}
	
	__getTransactions()
	{
		table := this.iexplorer.document.getElementById("transactionsTableBody")
		transactions := []
		
		loop, % table.rows.length
		{
			transDate := false
			amount := false
			transDetail := false
			cells := table.rows.item(A_Index - 1).cells
			loop % cells.length
			{
				cellClass := cells[A_Index - 1].className
				value := cells[A_Index -1].innerText
				IfInString, cellClass, date
				{
					transDate := value 
				}
				IfInString, cellClass, debit
				{
					amount := value
				}IfInString, cellClass, arrow
				{
					transDetail := value
				}
				
			}
			
			if(transDate && amount && transDetail) 
			{
				transactions.Insert(new TransactionClass(amount, this.trimDetails(transDetail), transDate))
			} 
		}
		return transactions
	}
	
	trimDetails(details)
	{
		return regexReplace(details, "^\s*Open transaction details\s*")
	}
	
	
	getAllTransactions()
	{
		return this
	}
	
	addNewTransactions()
	{
		
	}

}
#x::ExitApp
#Include commonFunctions.ahk