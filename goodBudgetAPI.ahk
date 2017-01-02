test := new GoodBudgetAPIClass()
;~ test.getTransactions()
test.addNewTransaction(new TransactionClass(99, "a meaningful description", "12 dec 2016"))
test.addNewTransaction(new TransactionClass(99, "a meaningful description", "1 dec 2016"))
ExitApp

Class GoodBudgetAPIClass
{
	iexplorer := false
	exportFileNameWithPath :=  A_Temp "\budgettmp.txt"
	defaultEnvelope := "To Assign"
	
	__new()
	{
		this.init()
			.waitForFullLoad()
		return this
	}
	
	getTransactions()
	{
		this.waitForHome()
			.waitForFullLoad()
		return this.csvToTransactions(this.getTransactionsAsCSV())
	}
	
	init()
	{
		this.iexplorer := new IExplorerClass()
		this.iexplorer.visible(true)
			.navigate("https://goodbudget.com/home")
		return this
	}
	
	getTransactionsAsCSV()
	{
		notify("Exporting existing budget, please wait...")
		this.iexplorer.getElementById("export-txns").click()
		this.activateWindow()
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
		notify("")
		return budget
	}
	
	activateWindow()
	{
		WinActivate, Home | Goodbudget - Internet Explorer
		return this
	}
	
	waitForHome()
	{
		notify("Please login to GoodBudget")
		this.iexplorer.waitFor("Home | Goodbudget")
		notify("")
		return this
	}
	
	waitForFullLoad()
	{
		this.iexplorer.waitForFullLoad()
		return this
	}
	
	trimDetails(details)
	{
		return regexReplace(details, "^\s*Open transaction details\s*")
	}
	
	setValue(id, value)
	{
		this.activateWindow()
		this.iexplorer.getElementById(id).value := ""
		sleep 50
		this.iexplorer.getElementById(id).focus()
		sleep 50
		Clipboard := value
		Send ^v
		sleep 50
		return this
	}
	
	/*
	 * attempts to format the date, if it fails then the original value is returned
	 * hopefully the date is already formatted....
	 */
	formatDate(date)
	{
		formatTime, fixedDate, % date, MM/dd/yyyy
		return fixedDate ? fixedDate : date
	}
	
	addNewTransaction(transaction)
	{
		sleep 3000 ;its fucking rate limited?
		this.iexplorer.getElementsByClassName("btn addTransaction")[0].click()
		sleep 500
		this.setValue("expense-date", this.formatDate(transaction.transDate))
			.setValue("expense-receiver", transaction.desc)		
			.setValue("expense-amount", transaction.amount)		
		send {tab}
		sleep 50
		send % this.defaultEnvelope

		this.iexplorer.getElementById("addTransactionSave").click()
		return this
	}
	
	csvToTransactions(csv)
	{
		transactions := []
		headingsToIndex := this.__getHeadingToIndex(csv)
		transDateColumn := headingsToIndex["Date"]
		transDescColumn := headingsToIndex["Name"]
		transAmountColumn := headingsToIndex["Amount"]
		
		StringReplace, csv, csv, `r`n, `n, All
		Loop, parse, csv, `n
		{
			if(A_index == 1) 
			{
				continue ;skip the headers
			}
			values := this.csvSplit(A_loopfield)
			if(values[transDateColumn] && values[transDescColumn] && values[transAmountColumn])
			{
				transactions.Insert(new TransactionClass(values[transAmountColumn], values[transDescColumn], values[transDateColumn]))
			}
		}
		debug(ArrayToString(transactions))
		return transactions
	}
	
	csvSplit(line)
	{
		split := []
		loop, parse, line, csv
		{
			split.insert(A_LoopField)
		}
		return split
	}
	
	__getHeadingToIndex(csv)
	{
		headingsToIndex := []
		Loop, parse, csv, `n
		{
			headers := this.csvSplit(A_loopfield)
			for index, value in headers
			{
				headingsToIndex[value] := index
			}
			return headingsToIndex
		}
		return ""
	}
}
#Include commonFunctions.ahk
#Include transaction.ahk