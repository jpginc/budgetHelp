class TransactionClass
{	
	/*
	 * the date is expected to be in the format YYYYMMDDHH24MISS
	 * amount should just be a number. it will remove ",", "-" and "$" from the string
	 */
	__new(amount, desc, transDate)
	{
		this.amount := this.fixAmount(amount)
		this.desc := desc
		this.transDate := transDate
		return this
	}
	
	fixAmount(amount)
	{
		StringReplace, amount, amount, -, , All
		StringReplace, amount, amount, $, , All
		StringReplace, amount, amount, `,, , All
		return amount
	}
	
	equals(otherTransaction)
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