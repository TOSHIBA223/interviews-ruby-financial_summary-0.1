class FinancialSummary
  def initialize(input)
    @user_id = input[:user_id]
    @currency = input[:currency].to_s.upcase
  end

  def one_day
    transactions.one_day(@currency)
  end

  def seven_days
    transactions.seven_days(@currency)
  end

  def lifetime
    transactions.lifetime(@currency)
  end

  private

  def transactions
    Transaction.where(user_id: @user_id, amount_currency: @currency)
               .select(:amount_cents, :amount_currency, :category)
  end
end
