deubg := true
c := new BudgetClass()
ExitApp
#x::ExitApp

class BudgetClass
{
	iexplorer := false
	fileName := "budgetData.txt"
	debugOn := true
	
	__new()
	{
		this.init()
			.waitForLogin()
			.waitForTransactions()
			.waitForFullLoad()
			.getTransactions()
		return this
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
			this.debug(url)
			sleep 500
		}
		return this
	}
	
	waitForLogin()
	{
		this.notify("Please login")
		this.waitFor("Netbank - Home")
		return this.notify("")
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
	
	
	getTransactions()
	{
		Clipboard := this.iexplorer.Document.Body.innerhtml
		
		return this
	}
	
	notify(toNotify)
	{
		ToolTip, % toNotify
		return this
	}
	
	debug(toDebug)
	{
		if(this.debugOn)
		{
			this.notify(toDebug)
		}
		return this
	}
	
}