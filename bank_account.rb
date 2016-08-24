#Access Faker gem
require 'Faker'

#Create Bank module
module Bank

  #Create Account class
  class Account

    #Allow for reader rights for instance variables id and balance
    attr_reader :id, :balance, :owner_info

    #Define intialize method. Default balance is 0. Raises ArgumentError if initialized with a negative balance.
    def initialize(owner, balance = 0)
      @id = Faker::Number.number(9)
      raise ArgumentError, "You can not create a new account with a negative balance." if balance < 0
      @balance = balance
      @owner_info = owner
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
      puts "Name: #{@owner_info.name}"
      puts "Address: #{@owner_info.address}"
      puts "Email: #{@owner_info.email}"
    end

  end

end

#Create Owner class outside of
class Owner

  #Allow reader and writer rights for users
  attr_accessor :name, :address, :email

  #Define intialize method with owner information stored in instance variables.
  def initialize(name, address, email)
    @name = name
    @address = address
    @email = email
  end

end



#Test Code Lines

#Create new Owner Arthur Read. He opens up two different accounts.
customer1 = Owner.new("Arthur Read", "123 Library Ln, Elmwood City, MA 02134", "ARead123@gmail.com")

account1 = Bank::Account.new(customer1, 100)
account1.withdraw(30) #=> should output balance = 70
account1.deposit(20) #=> should output balance = 90
account1.owner_info #=> should output owner information.

#Arthur opens a second account with intial balance of 20. But he tries to withdraw more than his balance.
account2 = Bank::Account.new(customer1, 20)
account2.withdraw(30) #=> should display warning
account2.withdraw(20) #=> should withdraw properly; balance = 0

#Arthur opens up a third account with a negative balance
account3 = Bank::Account.new(customer1, -50) #=> should output argument error.
