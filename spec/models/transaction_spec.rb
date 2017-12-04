require 'rails_helper'

describe Transaction do
  subject { build(:transaction) }

  it 'can have [deposit, purchase, refund] category on credit action' do
    subject.action = :credit
    subject.category = :deposit
    expect(subject.valid?).to eq(true)

    subject.action = :credit
    subject.category = :withdraw
    expect(subject.valid?).to eq(false)

    subject.action = :credit
    subject.category = :refund
    expect(subject.valid?).to eq(true)

    subject.action = :credit
    subject.category = :purchase
    expect(subject.valid?).to eq(true)
  end

  it 'can have [withdraw, ante] category on debit action' do
    subject.action = :debit
    subject.category = :deposit
    expect(subject.valid?).to eq(false)

    subject.action = :debit
    subject.category = :withdraw
    expect(subject.valid?).to eq(true)

    subject.action = :debit
    subject.category = :ante
    expect(subject.valid?).to eq(true)
  end

  it 'must have greater than zero amount' do
    subject.amount = Money.from_amount(0, :usd)
    expect(subject.valid?).to eq(false)

    subject.amount = Money.from_amount(-1, :usd)
    expect(subject.valid?).to eq(false)

    subject.amount = Money.from_amount(0.01, :usd)
    expect(subject.valid?).to eq(true)
  end
end