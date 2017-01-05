Gui, Add, ActiveX, w1000 h700 vthis.iExplorerGuiTest, Shell.Explorer
gui show
temp := new this.iExplorerClass(this.iExplorerGuiTest)
test := new GoodBudgetAPIClass()
test.getTransactions(temp)
test.addNewTransaction(new TransactionClass(99, "a meaningful description", "12 dec 2016"), temp)
test.addNewTransaction(new TransactionClass(99, "a meaningful description", "1 dec 2016"), temp)
ExitApp

Class GoodBudgetAPIClass
{
	defaultEnvelope := "To Assign"
	
	__new(iExplorer)
	{
		this.iExplorer
		return this
	}
	
	getTransactions()
	{
		this.iExplorer.navigate("https://goodbudget.com/home")
		sleep 5000
		this.waitForHome(this.iExplorer)
			.waitForFullLoad(this.iExplorer)
		return this.csvToTransactions(this.getTransactionsAsCSV(this.iExplorer))
	}
	
	getTransactionsAsCSV()
	{
		notify("Exporting existing budget, please wait...")
		req := ComObjCreate("Msxml2.XMLHTTP")
		req.open("GET", "https://goodbudget.com/transactions/export", false)
		req.send()
		Clipboard := req.responseText
		MsgBox % req.responseText
		ExitApp
		notify("")
		return req.responseText
	}
	
	waitForHome()
	{
		notify("Please login to GoodBudget")
		this.iExplorer.waitFor("Home | Goodbudget")
		notify("")
		return this
	}
	
	waitForFullLoad()
	{
		this.iExplorer.waitForFullLoad()
		return this
	}
	
	trimDetails(details)
	{
		return regexReplace(details, "^\s*Open transaction details\s*")
	}
	
	setValue(id, value)
	{
		this.iExplorer.activateWindow()
		this.iExplorer.getElementById(id).value := ""
		sleep 50
		this.iExplorer.getElementById(id).focus()
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
		sleep 3000 ;its  rate limited?
		this.iExplorer.getElementsByClassName("btn addTransaction")[0].click()
		sleep 500
		this.setValue("expense-date", this.formatDate(transaction.transDate))
			.setValue("expense-receiver", transaction.desc, this.iExplorer)		
			.setValue("expense-amount", transaction.amount, this.iExplorer)		
		send {tab}
		sleep 50
		send % this.defaultEnvelope

		this.iExplorer.getElementById("addTransactionSave").click()
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
#include iExplorer.ahk