require 'net/https'
require 'json'
require 'mysql2'

class ExpenseApp
  SQL_Server = "localhost"
  SQL_Port = 3306
  SQL_User = "dashing"
  SQL_Pass = "24518000tablet"
  SQL_Database = "expenses"

  attr_reader :enterStatus, :category, :payment, :cost, :questionStat, :sendReady, :costStat, :shareStat

  def initialize()
    @enterStatus = 0
    @category = 0
    @payment = 0
    @cost = 0
    @questionStat = 0
    @sendReady = 0
    @costStat = 0
    @shareStat = 0
  end

  def expenseButton(button)
    temp = button[4..6]
    payArray = ["Usa", "Pay", "Ama", "Pur"]
    catArray = ["Foo", "Liv", "Soc", "Els"]
    puts temp
    if (temp == 'Per')
      addNum(".", "null")
    elsif (temp == 'Sen')
      addNum("SEND", "null")
    elsif (temp == 'Res')
      addNum("RESET", "null")
    elsif (payArray.include? temp)
      addNum("PAY", button)
    elsif (catArray.include? temp)
      addNum("CAT", button)
    elsif ((temp == "Yes") || (temp == "Nop"))
      addNum("CHOICE", button)
    else
      addNum("NUMBER", button)
    end
  end
    

  def addNum(type, value)
    if (type == "PAY")
      if (@enterStatus == 0)
        send_event('expenseInfo', { title: "Now Select a Category" })
        @payment = value[4..(value.length - 1)]
        @enterStatus = 1
      else
        @payment = value[4..(value.length - 1)]
        send_event('expenseInfo', { title: "Now Enter a Price", message: "Cost: " })
      end
    elsif (type == "CAT")
      if (@enterStatus == 0)
        send_event('expenseInfo', { title: "Now Select a Payment" })
        @category = value[4..(value.length - 1)]
        @enterStatus = 1
      else
        @category = value[4..(value.length - 1)]
        send_event('expenseInfo', { title: "Now Enter a Price", message: "Cost: " })
      end
    elsif (type == "RESET")
      initialize()
      expenseStart()
    elsif (type == "SEND") && !(@sendReady == 1)
      #send stuff
      time = Time.new
      if (time.month.to_s.length == 1)
        month = "0" + time.month.to_s
      else
        month = time.month.to_s
      end
      if (time.day.to_s.length == 1)
        day = "0" + time.day.to_s
      else
        day = time.day.to_s
      end
      currentTime = time.year.to_s + month + day

      client = Mysql2::Client.new(
        :host => SQL_Server,
        :username => SQL_User,
        :password => SQL_Pass,
        :port => SQL_Port,
        :database => SQL_Database )

      expense_id = Random.new_seed.to_s[8..14]
      categoryF = %Q[INSERT INTO #{payment} ( expense_id, expense_cat, expense_cost, submission_date ) VALUES (#{expense_id}, "#{@category}", #{@cost}, #{currentTime} );]
      client.query("#{categoryF}")
      puts @category
      puts @payment
      puts @cost
    elsif (type == "CHOICE") && (@questionStat == 1)
      #question stuff
    elsif (type == "NUMBER") && (category != 0) && (payment != 0)
      if (@costStat == 0)
        @cost = value[4]
        temp = "Cost: $" + @cost
        send_event('expenseInfo', { message: "#{temp}" })
        send_event('costSend', { background_class: "background_green" })
        @costStat = 1
      else
        @cost = @cost + value[4]
        temp = "Cost: $" + @cost
        send_event('expenseInfo', { message: "#{temp}" })
      end
    elsif (type == ".")
      @cost = @cost + "."
      temp = "Cost: $" + @cost
      send_event('expenseInfo', { message: "#{temp}" })
    end
  end

  def expenseStart()
    send_event('expenseInfo', { title_class: "title_big", middle_class: "middle_big", message_class: "message_big", title: "Select Category or Payment", middle: "", message: "" })
  end

end
