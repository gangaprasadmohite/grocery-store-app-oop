require_relative "groceries"
require 'terminal-table/import'

class GenerateReceipt
  attr_reader :total, :menu, :order, :amount_saved, :receipt_table, :item, :quantity, :price, :sale_qun, :sale_price, :items_price

  def initialize(order)
    @total = 0
    @menu = Groceries::ITEMS
    @order = order
    @amount_saved = 0
    @receipt_table = []
    @item = nil,
    @quantity = nil,
    @price = nil,
    @sale_qun = nil,
    @sale_price = nil
    @items_price = nil
  end

  def self.checkout(order)
    new(order).checkout
  end

  def checkout
    order.each{ |item, quantity| item_in_sale(item, quantity) }
    receipt
  end

  def item_in_sale(item,quantity)
    menu.each do |menu_item| 
      if menu_item["name"] == item
        @item = item
        @quantity = quantity
        @price = menu_item["price"]
        @sale_qun = menu_item["sale_qun"]
        @sale_price = menu_item["sale_price"] 
        billing
      end
    end
  end

  def billing
    sale_qun && quantity >= sale_qun ? discount_billing : normal_billing
  end

  def discount_billing
    price_of_simliar_item_in_sale
    cal_saved_amount
  end

  def normal_billing
    price_of_simliar_item
  end

  def price_of_simliar_item_in_sale
    @items_price = sale_price + (price * (quantity - sale_qun))
    common_job
  end

  def price_of_simliar_item
    @items_price = quantity * price
    common_job
  end

  def common_job
    add_to_receipt_table
    add_total
  end

  def add_total
    @total += items_price
  end

  def cal_saved_amount
    @amount_saved += ((sale_qun * price) - sale_price)
  end

  def add_to_receipt_table
    @receipt_table << [item, quantity, items_price]
  end

  def generate_receipt_table
    items_table = table { |t|
      t.headings = "Item", "Quantity", "Price"
      receipt_table.each { |row| t << row }
    }
  end

  def receipt
    puts" #{generate_receipt_table} \n 
    Total price : $#{total.round(2)} \n 
    You saved $#{amount_saved.round(2)} today"
  end

  def show_total
    checkout
    total.round(2)
  end

  def show_saved_amount
    checkout
    amount_saved.round(2)
  end

  def show_receipt_table
    checkout
    puts" #{generate_receipt_table}"
  end
end