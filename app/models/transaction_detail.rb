# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionDetail < ActiveRecord::Base

  before_create :set_balance

  # Validations
  validates_presence_of :item_id
  validates_numericality_of :quantity, greater_than: 0
  validate :balance_is_correct
  validate :change_of_item_id, unless: :new_record?
  validate :quantity_eq_balance, if: :marked_for_destruction?

  def total
    quantity * price
  end
  alias_method :subtotal, :total

  def changed_price?
    !(price === original_price)
  end

  def data_hash
    {
      id: id,
      item_id: item_id,
      original_price: original_price, 
      price: price, 
      quantity: quantity, 
      subtotal: subtotal
    }
  end

private
  def set_balance
    self.balance = quantity
  end

  def balance_is_correct
    self.errors.add(:item_id, balance_error_message) if self.balance > quantity
  end 
  
  def balance_error_message
    I18n.t('errors.messages.transaction_details.balance')
  end

  def quantity_eq_balance
    unless balance === quantity
      self.errors(:quantity, "No se puede")
    end
  end

  def change_of_item_id

  end
end
