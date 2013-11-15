def valid?(num)
  !!num.match(/\A\d+(\.\d{2})*\z/)
end

puts "What amount is due?"
amount_due = gets.chomp


if valid?(amount_due) == false
  puts "Warning invalid number"
else
  puts "What is the amount tendered?"
  amount_tend = gets.chomp
  if valid?(amount_tend) == false
    puts "Warning invalid number"
  else
    change_due = amount_tend.to_f - amount_due.to_f
      if change_due > 0
        puts "Your change is: $#{"%.2f" % change_due}"
        puts "Time of transaction: #{Time.now}"
      elsif change_due == 0
        puts "No change due"
      else change_due < 0
        puts "Warning: Customer still owes #{change_due.abs}!"
      end
  end
end
