class IExplorerClass
{
	__new()
	{
		this.comObj :=  ComObjCreate("InternetExplorer.Application")
		return this
	}
	
	visible(val)
	{
		this.comObj.visible := val
		return this
	}
	
	navigate(url)
	{
		this.comObj.navigate(url)
		While(this.comObj.readyState != 4)
		{
			sleep 50
		}
		return this
	}
	
	waitFor(name)
	{
		while true
		{
			url := this.comObj.LocationName
			IfInString, url, % name
			{	
				break
			}
			debug("Waiting for location: " name)
			sleep 500
		}
		return this
	}
	
	waitForFullLoad()
	{
		While(this.comObj.document.readyState != "complete" || this.comObj.busy)
		{
			notify(this.comObj.readyState "`n" this.comObj.document.readyState)
			Sleep, 50
		}
		return this		
	}
	
	getElementById(id)
	{
		return this.comObj.document.getElementById(id)
	}
	getElementsByClassName(name)
	{
		return this.comObj.document.getElementsByClassName(name)
	}
}