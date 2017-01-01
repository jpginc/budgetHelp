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
	
	
	isEqual(otherTransaction)
	{
		return otherTransaction.amount == this.amount && otherTransaction.transDate == this.transDate && this.descriptionMatches(otherTransaction.desc)
	}
	
	descriptionMatches(otherDesc)
	{
		;to allow us to change the description in the budget app vs the bank's description i will say it's equal if 
		;either of the strings is a substring of the other
		return instr(otherDesc, this.desc) || instr(this.desc, otherDesk)
	}
}