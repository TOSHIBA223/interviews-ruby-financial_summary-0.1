class Wallet < ApplicationRecord
  monetize :balance_cents

  validate :support_usd_cad

  belongs_to :user

  private

  def support_usd_cad
    unless balance_currency.to_s.downcase.in? %w[usd cad]
      errors.add(:balance_currency, 'Only support for USD, CAD currencies')
    end
  end
end
