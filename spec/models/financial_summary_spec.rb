describe FinancialSummary do
  let!(:user) { create(:user) }

  # Feel free to change what the subject-block returns
  subject { FinancialSummary.new(user_id: user.id, currency: :usd) }

  it 'summarizes over one day' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12,:usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10,:usd))

      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(7.67,:usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5,:cad))

      create(:transaction, user: user,
             action: :debit, category: :ante,
             amount: Money.from_amount(3,:usd))

      create(:transaction, user: user,
             action: :debit, category: :withdraw,
             amount: Money.from_amount(20,:cad))
    end

    expect(subject.one_day.cnt(:deposit)).to eq(2)
    expect(subject.one_day.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.one_day.cnt(:purchase)).to eq(1)
    expect(subject.one_day.amount(:purchase)).to eq(Money.from_amount(7.67, :usd))

    expect(subject.one_day.cnt(:refund)).to eq(0)
    expect(subject.one_day.amount(:refund)).to eq(Money.from_amount(0, :usd))

    expect(subject.one_day.total).to eq(Money.from_amount(16.79, :usd))
  end

  it 'summarizes over seven days' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12,:usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10,:usd))

      create(:transaction, user: user,
             action: :debit, category: :withdraw,
             amount: Money.from_amount(7,:usd))
    end

    Timecop.travel(Time.now - 10.days) do
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(131,:usd))

      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(7.67,:usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5,:cad))

      create(:transaction, user: user,
             action: :debit, category: :ante,
             amount: Money.from_amount(11,:usd))
    end

    expect(subject.seven_days.cnt(:deposit)).to eq(2)
    expect(subject.seven_days.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.seven_days.cnt(:purchase)).to eq(0)
    expect(subject.seven_days.amount(:purchase)).to eq(Money.from_amount(0, :usd))

    expect(subject.seven_days.cnt(:refund)).to eq(0)
    expect(subject.seven_days.amount(:refund)).to eq(Money.from_amount(0, :usd))

    expect(subject.seven_days.total).to eq(Money.from_amount(5.12, :usd))
  end

  it 'summarizes over lifetime' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12,:usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10,:usd))

      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(120,:usd))
    end

    Timecop.travel(Time.now - 30.days) do
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(3.33,:usd))

      create(:transaction, user: user,
             action: :debit, category: :withdraw,
             amount: Money.from_amount(7.67,:usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5,:cad))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(13.45,:usd))
    end

    expect(subject.lifetime.cnt(:deposit)).to eq(2)
    expect(subject.lifetime.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.lifetime.cnt(:purchase)).to eq(2)
    expect(subject.lifetime.amount(:purchase)).to eq(Money.from_amount(123.33, :usd))

    expect(subject.lifetime.cnt(:refund)).to eq(1)
    expect(subject.lifetime.amount(:refund)).to eq(Money.from_amount(13.45, :usd))

    expect(subject.lifetime.cnt(:withdraw)).to eq(1)
    expect(subject.lifetime.amount(:withdraw)).to eq(Money.from_amount(7.67, :usd))
  end
end
