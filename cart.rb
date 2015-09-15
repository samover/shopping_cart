require 'date'

class ShoppingCart
      
  def initialize
    @day = Date.today #Date.today.wday
    @cost = 0
    @items_in_cart = []
    @discount_articles = []
  end
  
  def add(object)
    @cost += object.price
    @items_in_cart << object
  end
  
  def cost
    @cost
  end
  
  def amount_items
    @items_in_cart.count
  end
  
  def print_receipt
    items = @items_in_cart.collect { |item| "#{item.name} #{item.price.to_s.rjust(30-item.name.length)} EUR\n"}.join
    disc_items = @discount_articles.collect { |item| "#{item[0]} #{item[1].to_s.rjust(30-item[0].length)} EUR\n" }.join
    receipt = "#{@day.strftime("%A, %d %b %Y")}\n-----------------------\n#{items}\nDiscounts: \n#{disc_items}\n\nTotal cost: #{@cost.to_s.rjust(19)} EUR"
    IO.write(__dir__ + "/receipt.txt", receipt)
  end
  
  def discount
        
    @items_in_cart.each do |item|
      if item.class == Fruit
        disc = 10.0/100
        @cost -= (item.price * disc) if @day.strftime("%a") == 'Sat' || @day.strftime("%a") == 'Sun'
        @discount_articles << [item.name, - item.price * disc]
      elsif item.class == HouseWares
        disc = 5.0/100
        @cost -= (item.price * disc) if item.price > 100 
        @discount_articles << [item.name, - item.price * disc]
      end
    end
    
    if @items_in_cart.length > 5 
      disc = @cost * 10.0/100
      @cost -= disc    
      @discount_articles << ['More than five items: ', - disc]
    end
    
  end
end

class Stuff 
  
  @@price_src = __dir__ + "/price_list.txt"

  attr_reader :name, :price
  
  def initialize(name)
    @name = name
    @price = find_price(@name)
  end
  
  def find_price(name)
    line = File.readlines(@@price_src).select{ |line| line =~ /#{name}/ }.to_s.match(/\d+/)
    line[0].to_i
  end
    
end

class Fruit < Stuff
  
end

class HouseWares < Stuff

end

class Dry_Food < Stuff
  
end

class Fish < Stuff
  
end


cart = ShoppingCart.new

apple = Fruit.new("apple")
banana = Fruit.new("banana")

cart.add apple
cart.add banana
cart.add HouseWares.new("vacuum cleaner")
cart.add Fish.new("anchovies")
cart.add apple
cart.add apple

puts "The total cost of your shopping cart before discount amounts to #{cart.cost} EUR."  #=> 30
puts "You have #{cart.amount_items} items in your shopping cart."
cart.discount
puts "The total cost of your shopping cart after discount amounts to #{cart.cost} EUR."  #=> 30
cart.print_receipt