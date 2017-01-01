class CommonweathBankAPIClass
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
		this.iexplorer := ComObjCreate("InternetExplorer.Application")
		this.iexplorer.visible := true
		this.iexplorer.navigate("https://www.netbank.com.au")
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
			debug(url)
			sleep 500
		}
		return this
	}
	
	waitForTransactions()
	{
		this.waitFor("Netbank - Transactions")
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
				value := trim(cells[A_Index -1].innerText)
				IfInString, cellClass, date
				{
					transDate := value 
				}
				IfInString, cellClass, debit
				{
					IfInString, value, -$
					{
						amount := value
					}
				}IfInString, cellClass, arrow
				{
					transDetail := value
				}
				
			}
			
			if(transDate && amount && transDetail && (! InStr(transDetail, "PENDING -")))
			{
				transactions.Insert(new TransactionClass(amount, this.trimDetails(transDetail), transDate))
			} 
		}
		return transactions
	}
	
	trimDetails(details)
	{
		;some descriptions don't have an option transaction details thing for some reason
		return regexReplace(regexReplace(details, "^\s*Open transaction details\s*"), "^\s*")
	}	
}