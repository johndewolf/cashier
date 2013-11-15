def valid?(num)
  !!num.match(/\A\d+(\.\d{2})*\z/)
end

exit = "done"
item_totals = []
item_input = 0

until item_input == exit
  puts "What is the sale price? (Enter done to quit)"
  item_input = gets.chomp
  valid?(item_input) ? item_totals << item_input.to_f : nil
end

puts "Here are your item prices: (Enter done when finished)"
item_totals.each{|x| puts "$#{"%.2f" % x}"}
item_totals = item_totals.inject(0){|sum, x| sum + x}
puts "Here is your total: $#{"%.2f" % item_totals}"

puts "Please enter the amount tendered: "
amount_tendered = gets.chomp.to_f

change_due = amount_tendered - item_totals

if change_due > 0
  puts "===Thank You!==="
  puts "The total change due is $#{"%.2f" % change_due}"
  puts Time.now.strftime("%m/%d/%Y %I:%M%p")
  puts "================"
elsif change_due == 0
  puts "No change due"
else change_due < 0
  puts "Warning: Customer still owes #{change_due.abs}!"
end
