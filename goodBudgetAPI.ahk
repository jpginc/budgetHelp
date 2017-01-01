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
		return this.csvToTransactions(this.getTransactionsAsCSV())
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
	
	getTransactionsAsCSV()
	{
		notify("Exporting existing budget, please wait...")
		this.iexplorer.document.getElementById("export-txns").click()
		WinActivate, Home | Goodbudget - Internet Explorer
		sleep 500
		send {f6}{tab}
		sleep 500
		send {down 2}{enter}
		WinWait, Save As
		WinActivate
		Clipboard := this.exportFileNameWithPath
		send ^v{enter}
		send !y
		sleep 500
		FileRead, budget, % this.exportFileNameWithPath
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
	
	trimDetails(details)
	{
		return regexReplace(details, "^\s*Open transaction details\s*")
	}
	
	addNewTransactions(transaction)
	{
		return this
	}
	
	csvToTransactions(csv)
	{
		transactions := []
		headingsToIndex := this.__getHeadingToIndex(csv)
		transDateColumn := headingsToIndex["Date"]
		transDescColumn := headingsToIndex["Notes"]
		transAmountColumn := headingsToIndex["Amount"]
		
		StringReplace, csv, csv, `r`n, `n, All
		Loop, parse, csv, `n
		{
			if(A_index == 1) 
			{
				continue ;skip the headers
			}
			values := StrSplit(A_loopfield, ",")
			if(values[transDateColumn] && values[transDescColumn] && values[transAmountColumn])
			{
				transactions.Insert(new TransactionClass(values[transAmountColumn], values[transDescColumn], values[transDateColumn]))
			}
		}
		debug(ArrayToString(transactions))
		return transactions
	}
	
	__getHeadingToIndex(csv)
	{
		Loop, parse, csv, `n
		{
			headers := StrSplit(A_loopfield, ",")
			headingsToIndex := {}
			loop, % headers.maxIndex()
			{
				headingsToIndex[headers[A_Index]] := A_Index
			}
			return headingsToIndex
		}
		return ""
	}
}
#x::ExitApp
#Include commonFunctions.ahk
#Include transaction.ahk