class CommonweathBankAPIClass
{	
	__new(iExplorer)
	{
		this.iExplorer := iExplorer
		return this
	}
	
	getTransactions()
	{
		this.iExplorer.navigate("https://www.netbank.com.au")
		this.waitForTransactions(this.iExplorer)
			.waitForFullLoad(this.iExplorer)
		
		return this.__getTransactions(this.iExplorer)	
	}
	
	waitForTransactions()
	{
		notify("Please navigate a transaction page")
		this.iExplorer.waitFor("Netbank - Transactions")
		notify("")
		return this
	}
	
	waitForFullLoad()
	{
		this.iExplorer.waitForFullLoad()
		return this
	}

	__getTransactions()
	{
		table := this.iExplorer.getElementById("transactionsTableBody")
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
				return new TransactionClass(amount, this.trimDetails(transDetail), this.formatDate(transDate))
			}
		}
		return false
	}
	
	formatDate(date)
	{
		months := ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
		bits := strSplit(date, " ")
		day := bits[1]
		month := objIndexOf(months, bits[2])
		year := bits[3]	
		
		return year month day "000000"
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