class Transaction < ApplicationRecord
  CREDIT_CATEGORY = %w[deposit refund purchase]
  DEBIT_CATEGORY = %w[withdraw ante]

  monetize :amount_cents

  validate :action_category_match
  validate :must_be_greater_than_zero

  belongs_to :user

  scope :one_day, -> { where("created_at >= ?", 1.day.ago.utc) }
  scope :seven_days, -> { where("created_at >= ?", 1.week.ago.utc) }

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

class ActiveRecord::Relation
  def count(category)
    select { |trans| trans.category.to_sym == category }.size
  end

  def amount(category)
    zero = Money.new(0, "USD")
    self.reduce(zero) do |sum, trans|
      trans.category.to_sym == category ? sum + trans.amount : sum
    end
  end

  def total
    sum = Money.new(0, "USD")
    self.each do |trans|
      if trans.category.in? Transaction::CREDIT_CATEGORY
        sum += trans.amount
      elsif trans.category.in? Transaction::DEBIT_CATEGORY
        sum -= trans.amount
      end
    end
    sum
  end
end
