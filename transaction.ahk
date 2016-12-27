class TransactionClass
{
	tags := []
	owner := ""
	
	__new(amount, desc, transDate)
	{
		this.amount := amount
		this.desc := desc
		this.transDate := transDate
		return this
	}
}