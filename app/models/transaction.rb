class Transaction < ApplicationRecord
  monetize :amount_cents

  validate :action_category_match
  validate :must_be_greater_than_zero

  belongs_to :user

  scope :one_day, -> { where("created_at >= ?", 1.day.ago.utc) }
  scope :seven_days, -> { where("created_at >= ?", 1.week.ago.utc) }

  private

  def action_category_match
    if action.to_sym == :credit
      if !%w[deposit refund purchase].include?(category)
        errors.add(:base, 'Credits must be in category deposit, refund or purchase.')
      end
    elsif action.to_sym == :debit
      if !%w[withdraw ante].include?(category)
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
end
