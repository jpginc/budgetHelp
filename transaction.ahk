class TransactionClass
{
	tags := []
	owner := ""
	
	__new(amount, desc, transDate)
	{
		this.amount := amount
		this.desc := trim(desc)
		this.transDate := transDate
		return this
	}
}