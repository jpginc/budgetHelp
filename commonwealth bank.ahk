class CommonweathBankAPIClass
{
	iexplorer := false
	debugOn := false
	
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
	
	waitForLogin()
	{
		notify("Please login")
		this.waitFor("Netbank - Home")
		notify("")
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
}