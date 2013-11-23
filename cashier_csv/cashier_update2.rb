#program requires pretty_print gem

require 'pry'
require 'csv'
require 'table_print'

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
      retail_price: retail.to_f,
      purchase_price: purchase.to_f
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
    time = row['time']
    sku = row['sku']
    gross_sales = row['gross_sales']
    cost_of_goods = row['cost of goods']
    net_profit = row['net_profit']
    quantity = row['quantity']
    date = Date.parse(date)
    @coffee_sales_report[i] = {
      name: name,
      date: date,
      time: time,
      sku: sku.to_i,
      gross_sales: gross_sales.to_f,
      cost_of_goods: cost_of_goods.to_f,
      net_profit: net_profit.to_f,
      quantity: quantity.to_f
    }
    i += 1
  end
end

def date_range_input
  puts "Please enter a date range (Year/Month/Day)"
  @date_range = gets.chomp
  begin
    @date_range = Date.parse(@date_range)
      if @date_range.to_time > Time.now
        puts "Error: That date range is in the future."
      end
  rescue
    puts "Invalid Date Entry"
  end
end

def find_date
  @date_ranges = @coffee_sales_report.map.find_all do |coffee|
    coffee[:date] == @date_range
  end
end

def daily_totals
  x = [[0],[0], [0]]
  @date_ranges.each do |key, value|
    x[0] << key[:gross_sales]
    x[1] << key[:net_profit]
    x[2] << key[:net_profit]
  end
  puts "Gross sales: #{x[0].inject(:+)}"
  puts "Net Profit: #{x[1].inject(:+)}"
  puts "Quantity Sold: #{x[2].inject(:+)}"
end

def information_for_date
  if @date_ranges[0] == nil
    puts "No data found for this date"
  else
    tp @date_ranges
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
    puts "#{index[:number]} - #{index[:name]} - #{index[:re_price]}"
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

def time_format
  time = Time.new
  time.strftime("%H:%M")
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
      quantity = gets.chomp.to_f

      item = @coffees[selection]
      name = item[:name]
      gross_sales = quantity * item[:retail_price]
      net_profit = (item[:retail_price] - item[:purchase_price]) * quantity
      cost_of_goods = (item[:purchase_price] * quantity)
      transaction = {
        name: name,
        date: date_format,
        time: time_format,
        sku: item[:sku],
        gross_sales: gross_sales,
        cost_of_goods: cost_of_goods,
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
  daily_totals
  information_for_date
end

introduction
if @reporting_or_cashregister == 1
  cash_register_branch('items.csv')
elsif @reporting_or_cashregister == 2
  reporting_branch('report.csv')
end



