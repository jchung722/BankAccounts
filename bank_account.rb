#Access necessary gems and etc.
require 'chronic'
require 'csv'

#Create Bank module
module Bank

  #Create Account class
  class Account

    #Allow for reader rights for instance variables id and balance
    attr_reader :id, :balance, :owner_info, :create_date

    #Define intialize method. Default balance is 0. Raises ArgumentError if initialized with a negative balance.
    def initialize (id, balance = 0, date = Time.now, owner = 0)
      @id = id.to_i
      raise ArgumentError, "You can not create a new account with a negative balance." if balance.to_i < 0
      @balance = balance.to_f
      @create_date = date
      @owner_info = owner
    end

    #Class method all
    def self.all
      @collection = []
      CSV.open("support/accounts.csv", 'r').each do |line|
        @collection << Account.new(line[0],line[1].to_f/100,line[2])
      end
      return @collection
    end

    #Class method find(id)
    def self.find(id)
      @match = 0
      CSV.open("support/accounts.csv", 'r').each do |line|
        if line[0] == id
          @match = Account.new(line[0], line[1].to_f/100, line[2])
        end
      end
      return @match
    end

    #Define withdraw method. Outputs warning message if there is not enough balance to withdraw amount of money.
    def withdraw(money)
      if @balance - money < 0
        puts "Warning: You do not have enough money to withdraw #{money} dollars.
        Try again. You have a balance of #{@balance} dollars."
      else
        @balance = @balance - money
        puts "#{money} dollars were withdrawn. You now have #{@balance} dollars in your bank account."
      end
      return @balance
    end

    #Define deposit method. Outputs new balance after money is deposited into account.
    def deposit(money)
      @balance = @balance + money
      puts "#{money} dollars were deposited. You now have #{@balance} dollars in your bank account."
      return @balance
    end

    #Define owner_info method. Displays owner information.
    def owner_info
      puts "Name: #{@owner_info.firstn} #{@owner_info.lastn}"
      puts "Address: #{@owner_info.street}, #{@owner_info.city}, #{@owner_info.state}"
    end

  end

  #Create SavingsAccount class
  class SavingsAccount < Account

    def initialize(id, balance = 0, date = Time.now, owner = 0)
      super
      raise ArgumentError, "You need at least $10 to create a savings account." if balance.to_i < 10
    end

    def withdraw(money)
      if @balance - money - 2 < 10
        puts "Warning: Withdrawing $#{money} will put your balance below the
        minimum $10 balance (including $2 withdrawal fee). Your balance is $#{@balance}."
      else
        @balance = @balance - money - 2
        puts "You withdrew $#{money}. There is a $2 fee. Your new balance is $#{@balance}."
      end
      return @balance
    end

    def add_interest(rate)
      interest = @balance * rate / 100
      @balance = @balance + interest
      return interest
    end

  end

  #Create CheckingAccount class
  class CheckingAccount < Account

    def initialize (id, balance = 0, date = Time.now, owner = 0)
      super
      @checks_used = 0
    end

    def withdraw(money)
      if @balance - money - 1 < 0
        puts "Warning: You do not have a sufficient balance to withdraw $#{money} including the
        $1 withdrawal fee. Your balance is #{@balance}."
      else
        @balance = @balance - money - 1
        puts "You withdrew $#{money}. There is a $1 fee. Your new balance is $#{@balance}."
      end
      return @balance
    end

    def withdraw_using_check(money)

      @checks_used += 1

      if @checks_used == 1 || @checks_used == 2 || @checks_used == 3
        if @balance - money < -10
          puts "Warning: You do not have a sufficient balance to withdraw $#{money}.
          Your balance is #{@balance}."
        else
          @balance = @balance - money
          puts "Check #{@checks_used}: You withdrew $#{money}. Your new balance is $#{@balance}."
        end
      else
        if @balance - money - 2 < -10
          puts "Warning: You do not have a sufficient balance to withdraw $#{money} including the
          $2 withdrawal fee. Your balance is #{@balance}."
        else
          @balance = @balance - money - 2
          puts "Check #{@checks_used}: You withdrew $#{money}. There is a $2 fee. Your new balance is $#{@balance}."
        end
      end
      return @balance

    end

    def reset_checks
      @checks_used = 0
    end

  end

  #Create MoneyMarket class
  class MoneyMarket < Account

    MAX_TRANSACTIONS = 6
    attr_reader :good_standing, :transaction
    def initialize(id, balance = 0, date = Time.now, owner = 0)
      super
      raise ArgumentError, "You need at least $10,000 to create a savings account." if balance.to_i < 10000
      @transaction = 0
      @good_standing = true
    end

    def transaction_count

      if @balance >= 10000
        @transaction += 1
        @good_standing = true
      else
        puts "You do not have sufficient funds to make transactions. Your current balance is $#{@balance}. Please deposit at least $#{10000-@balance} to continue transactions."
        @good_standing = false
      end

      if @transaction > MAX_TRANSACTIONS
        puts "You have already made 6 transactions this month."
        @good_standing = false
      end

      return @good_standing
    end

    def withdraw(money)
      transaction_count
      if @good_standing == false
        return @balance
      end

      if @balance - money - 100 < 0
        puts "WARNING: Insufficient funds to make transaction (including $100 transaction fee)."
        @transaction -= 1
      elsif @balance - money - 100 < 10000 && @balance - money - 100 > 0
        @balance = @balance - money - 100
        puts "Transaction #{@transaction}: WARNING: You withdrew $#{money}. Because this puts your balance under the minimum balance,there is a $100 transaction fee. Your new balance is $#{@balance}."
      else
        @balance = @balance - money
        puts "Transaction #{@transaction}: You withdrew $#{money}. Your new balance is $#{@balance}."
      end
      return @balance
    end

    def deposit(money)
      if @balance < 10000
        @balance = @balance + money
        puts "Thank you for the deposit! Your balance is $#{@balance}."
      else
      transaction_count
        if @good_standing == false
          return @balance
        end
        @balance = @balance + money
        puts "Transaction #{@transaction}:Thank you for the deposit! Your balance is $#{@balance}."
      end
      return @balance
    end

    def add_interest(rate)
      interest = @balance * rate / 100
      @balance = @balance + interest
      return interest
    end

    def reset_transactions
      @transaction = 0
    end

  end

end

#Create Owner class outside of
class Owner

  #Allow reader and writer rights for users
  attr_accessor :id, :lastn, :firstn, :street, :city, :state

  #Define intialize method with owner information stored in instance variables.
  def initialize(id, last, first, street, city, state)
    @id = id.to_i
    @lastn = last
    @firstn = first
    @street = street
    @city = city
    @state = state
  end

  #Class method all
  def self.all
    @collection = []
    CSV.open("support/owners.csv", 'r').each do |line|
      @collection << Owner.new(line[0], line[1], line[2], line[3], line[4], line[5])
    end
    return @collection
  end

  #Class method find(id)
  def self.find(id)
    @match = 0
    CSV.open("support/owners.csv", 'r').each do |line|
      if line[0] == id
        @match = Owner.new(line[0], line[1], line[2], line[3], line[4], line[5])
      end
    end
    return @match
  end

end

#################Test Code Lines###################

# #####---->>>>WAVE 1 TEST CODES<<<-----######

# #Create new Owner Arthur Read. He opens up two different accounts.
# customer1 = Owner.new("1", "Read", "Arthur", "123 Library Lane", "Elmwood City", "Massachusetts")
#
# account1 = Bank::Account.new(101, 100, Time.now, customer1)
# account1.withdraw(30) #=> should output balance = 70
# account1.deposit(20) #=> should output balance = 90
# account1.owner_info #=> should output owner information.
#
# #Arthur opens a second account with intial balance of 20. But he tries to withdraw more than his balance.
# account2 = Bank::Account.new(102, 20, Time.now, customer1)
# account2.withdraw(30) #=> should display warning
# account2.withdraw(20) #=> should withdraw properly; balance = 0

# #Arthur opens up a third account with a negative balance
# account3 = Bank::Account.new(103, -1, Time.now, customer1) #=> should output argument error.

#######----->>>>CODE TO ACCESS CSV FILES(KEEP UNCOMMENTED FOR WAVES 2 + 3 CODES)<<<<<-----#######
csv = CSV.read("support/accounts.csv")
id = csv[0][0]
balance = csv[0][1].to_f/100
date = csv[0][2]

#######------>>>>WAVE 2 TEST CODES<<<------#######

customer2 = Owner.new("1", "Read", "Dora Winifred", "123 Library Lane", "Elmwood City", "Massachusetts")
account = Bank::Account.new(id, balance, date, customer2)
puts account.id
puts account.balance
puts account.create_date
puts Bank::Account.all
puts "Your match is #{Bank::Account.find("1215")}"

puts Owner.all
puts "Your match is #{Owner.find("15")}"


#######------>>>>>>WAVE 3 TEST CODES<<<<<<-----#########

saccount = Bank::SavingsAccount.new(id, 100, date)

puts saccount.add_interest(1)
puts saccount.balance

caccount = Bank::CheckingAccount.new(id, 100, date)

caccount.withdraw_using_check(5)
caccount.withdraw_using_check(5)
caccount.withdraw_using_check(5)
caccount.reset_checks
caccount.withdraw_using_check(5)
caccount.withdraw_using_check(5)
caccount.withdraw_using_check(5)
caccount.withdraw_using_check(5)

mmaccount = Bank::MoneyMarket.new(id, 15000, date)

mmaccount.withdraw(1000)
mmaccount.withdraw(1000)
mmaccount.withdraw(1000)
mmaccount.withdraw(1000)
mmaccount.withdraw(1000)
mmaccount.withdraw(1000)
mmaccount.deposit(1000)
mmaccount.deposit(1000)
mmaccount.deposit(1000)

puts mmaccount.transaction
puts mmaccount.good_standing
puts mmaccount.add_interest(1)
puts mmaccount.balance

mmaccount.reset_transactions
puts mmaccount.withdraw(100)
