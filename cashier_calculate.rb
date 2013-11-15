def valid?(num)
  if !num.match(/\A\d+(\.\d{2})*\z/)
    puts "Warning invalid number"
  end
end

puts "What amount is due?"
amount_due = gets.chomp
valid?(amount_due)

puts "What is the amount tendered?"
amount_tend = gets.chomp
valid?(amount_tend)

change_due = amount_tend.to_f - amount_due.to_f
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
