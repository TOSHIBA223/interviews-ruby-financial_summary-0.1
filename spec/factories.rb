FactoryBot.define do
  factory :user do
    email { FFaker::Internet.safe_email }

  end

  factory :wallet do
    balance { Money.from_amount(0, :usd) }
    association :user, factory: :user
  end

  factory :transaction do
    amount { Money.from_amount(1, :usd) }
    action { [:credit, :debit].shuffle.first }
    category {
      if action == :credit
        [:deposit, :refund, :purchase].shuffle.first
      elsif action == :debit
        [:withdraw, :ante].shuffle.first
      end
    }
    association :user, factory: :user
  end
end