require 'pry'
require 'csv'
@coffees = []
@coffee_sales_report = []
def menu_read(file)
  i = 0
  CSV.foreach(file, headers: true) do |row|
    number = row['number']
    name = row['Name']
    sku = row['SKU']
    retail = row['Retail Price']
    purchase = row['Purchasing Price']
    @coffees[i] = {
      number: number.to_i,
      name: name,
      sku: sku.to_i,
      retail_price: retail.to_i,
      purchase_price: purchase.to_i
    }

    i += 1
  end
end

def introduction
  puts "Hello please enter (1) for Cash Register or (2) for reporting"
  @reporting_or_cashregister = gets.chomp.to_i
end

def report_read(file)
    i = 0
  CSV.foreach(file, headers: true) do |row|
    name = row['name']
    date = row['date']
    sku = row['sku']
    gross_sales = row['gross_sales']
    net_profit = row['net_profit']
    quantity = row['quantity']
    date = Date.parse(date)
    @coffee_sales_report[i] = {
      name: name,
      date: date,
      sku: sku.to_i,
      gross_sales: gross_sales.to_i,
      net_profit: net_profit.to_i,
      quantity: quantity.to_i
    }
    i += 1
  end
end

def date_range_input
  puts "Please enter a date range (Year/Month/Day)"
  @date_range = gets.chomp
  @date_range = Date.parse(@date_range)
  if @date_range.to_time > Time.now
    puts "The future"
  end
end

def find_date
  @date_ranges = @coffee_sales_report.map.find_all do |coffee|
    coffee[:date] == @date_range
  end
end

def any_date
  if @date_ranges[0] == nil
    puts "No data found for this date"
  else
    @date_ranges.each do |data|
    puts "#{data[:name]} - #{data[:date]}"
    end
  end
end


#============Cash Register Methods=================#
def format_money(amount)
  "$#{"%.2f" % amount}"
end

def valid?(num)
  !!num.match(/\A\d+(\.\d{2})*\z/)
end

def display_options
  @coffees.each do |index|
    puts "#{index[:number]} - #{index[:name]} - #{index[:purchase_price]}"
  end
end

def selection_is_valid?(selection)
  selection.to_i <= @coffees.count && selection.to_i > 0
end

def calculate_total(order)
  total = 0
  order.each do |transaction|
    total += transaction[:gross_sales]
  end
  total
end

def price_per_item(order)
  order.each do |coffee|
    puts "#{coffee[:name]} - $#{coffee[:gross_sales]} - #{coffee[:quantity]} bag(s)"
  end
end

def sales_report_write(order)
  CSV.open("report.csv", "a") do |csv|
    order.each do |coffee|
      csv << coffee.values
    end
  end
end

def date_format
  date = Time.new
  date = "#{date.year}/#{date.month}/#{date.day}"
end

def cashier_input
  order = []

  loop do
    puts "Please make a selection. Enter in 'done' to quit."
    selection = gets.chomp.downcase

    break if selection == 'done'

    if selection_is_valid?(selection)
      selection = selection.to_i - 1

      puts "Please enter quantity"
      quantity = gets.chomp.to_i

      item = @coffees[selection]
      name = item[:name]
      gross_sales = quantity * item[:purchase_price]
      net_profit = (item[:purchase_price] - item[:retail_price]) * quantity

      transaction = {
        name: name,
        date: date_format,
        sku: item[:sku],
        gross_sales: gross_sales,
        net_profit: net_profit,
        quantity: quantity
      }
      order << transaction
    else
      puts "invalid"
    end
  end
  price_per_item(order)
  @total = calculate_total(order)
  sales_report_write(order)
  puts "Transaction Total: $#{@total}"
end

def calculate_change
  loop do
    puts "Please enter amount tendered"
    amount_tendered = gets.chomp
    if valid?(amount_tendered)
      amount_tendered = amount_tendered.to_f
      return amount_tendered - @total
    else
      puts "Invalid input"
    end
  end
end

def change_due(change)
  if change > 0
    puts "===Thank You!==="
    puts "The total change due is #{format_money(change)}"
    puts Time.now.strftime("%m/%d/%Y %I:%M%p")
    puts "================"
  elsif change == 0
    puts "No change due"
  else
    puts "Warning: Customer still owes #{format_money(change).delete "-"}!"
  end
end

def cash_register_branch(file)
  menu_read(file)
  display_options
  cashier_input
  change = calculate_change
  change_due(change)
end

def reporting_branch(file)
  report_read(file)
  date_range_input
  find_date
  any_date
end

introduction
if @reporting_or_cashregister == 1
  cash_register_branch('items.csv')
elsif @reporting_or_cashregister == 2
  reporting_branch('report.csv')
end



