class Transaction < ApplicationRecord
  CREDIT_CATEGORY = %w[deposit refund purchase]
  DEBIT_CATEGORY = %w[withdraw ante]

  monetize :amount_cents

  validate :action_category_match
  validate :must_be_greater_than_zero

  belongs_to :user

  class << self
    def one_day
      @t = where("created_at >= ?", 1.day.ago.utc)
    end

    def seven_days
      @t = where("created_at >= ?", 1.week.ago.utc)
    end

    def lifetime
      @t = where('')
    end

    def cnt(category)
      @t.select { |trans| trans.category.to_sym == category }.size
    end

    def amount(category)
      sum = Money.new(0, "USD")

      @t.each do |trans|
        if trans.category.to_sym == category
          sum += trans.amount
        end
      end

      sum
    end

    def total
      sum = Money.new(0, "USD")

      @t.each do |trans|
        if trans.category.in? Transaction::CREDIT_CATEGORY
          sum += trans.amount
        elsif trans.category.in? Transaction::DEBIT_CATEGORY
          sum -= trans.amount
        end
      end

      sum
    end
  end

  private

  def action_category_match
    if action.to_sym == :credit
      unless category.in? CREDIT_CATEGORY
        errors.add(:base, 'Credits must be in category deposit, refund or purchase.')
      end
    elsif action.to_sym == :debit
      unless category.in? DEBIT_CATEGORY
        errors.add(:base, 'Debits must be in category withdraw or ante.')
      end
    end
  end

  def must_be_greater_than_zero
    errors.add(:amount, 'Must be greater than 0') if amount <= Money.from_amount(0, amount_currency)
  end
end
