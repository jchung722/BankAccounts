#Access Faker gem
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
      @balance = balance.to_i
      @create_date = date
      @owner_info = owner
    end

    #Class method all
    def self.all
      @collection = []
      CSV.open("accounts.csv", 'r').each do |line|
        @collection << Account.new(line[0],line[1],line[2])
      end
      return @collection
    end

    #Class method find(id)
    def self.find(id)
      @match = 0
      CSV.open("accounts.csv", 'r').each do |line|
        if line[0] == id
          @match = Account.new(line[0], line[1], line[2])
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
      puts "Name: #{@owner_info.name}"
      puts "Address: #{@owner_info.address}"
      puts "Email: #{@owner_info.email}"
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
    CSV.open("owners.csv", 'r').each do |line|
      @collection << Owner.new(line[0], line[1], line[2], line[3], line[4], line[5])
    end
    return @collection
  end

  #Class method find(id)
  def self.find(id)
    @match = 0
    CSV.open("owners.csv", 'r').each do |line|
      if line[0] == id
        @match = Owner.new(line[0], line[1], line[2], line[3], line[4], line[5])
      end
    end
    return @match
  end

end



#Test Code Lines

#Create new Owner Arthur Read. He opens up two different accounts.
customer1 = Owner.new("1", "Read", "Arthur", "123 Library Lane", "Elmwood City", "Massachusetts")
#
# account1 = Bank::Account.new(customer1, 100)
# account1.withdraw(30) #=> should output balance = 70
# account1.deposit(20) #=> should output balance = 90
# account1.owner_info #=> should output owner information.
#
# #Arthur opens a second account with intial balance of 20. But he tries to withdraw more than his balance.
# account2 = Bank::Account.new(customer1, 20)
# account2.withdraw(30) #=> should display warning
# account2.withdraw(20) #=> should withdraw properly; balance = 0
#
# #Arthur opens up a third account with a negative balance
# account3 = Bank::Account.new(customer1, -50) #=> should output argument error.


csv = CSV.read("accounts.csv")
id = csv[0][0]
balance = csv[0][1]
date = csv[0][2]

account = Bank::Account.new(id, balance, date, customer1)
puts account.id
puts account.balance
puts account.create_date
puts Bank::Account.all
puts "Your match is #{Bank::Account.find("1215")}"

puts Owner.all
puts "Your match is #{Owner.find("15")}"
