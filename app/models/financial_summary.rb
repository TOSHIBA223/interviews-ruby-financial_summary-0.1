class FinancialSummary
  def initialize(input)
    @user_id = input[:user_id]
    @currency = input[:currency].to_s.upcase
  end

  def one_day
    transactions.one_day
  end

  def seven_days
    transactions.seven_days
  end

  def lifetime
    transactions
  end

  private

  def transactions
    Transaction.where(user_id: @user_id, amount_currency: @currency)
               .select(:amount_cents, :category)
  end
end
