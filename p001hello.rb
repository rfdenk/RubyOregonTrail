require_relative 'ot_item'
require_relative 'ot_ox'
require_relative 'ot_terrain'

def clear_the_screen
  print "\e[2J\e[f"   #clear the screen
end

class Game
  @@terrain = [Store.new, Grassland.new, Grassland.new, Destination.new]
  
  def initialize()
    @day=1
    @distance=0
    @money=1000
    
    @inventory=[] #bulk items, like food and hay
    @items = []   #individual, name-able items, like wagons, oxen, and people
    
    @action = :stay_put
    current_terrain = @@terrain[@distance]
  end

  def current_terrain=(t)
    puts 'Setting current terrain to ' + t.to_s
    @current_terrain = t
  end
  def current_terrain
    @current_terrain
  end
  
  def count_items_of_type(type)
    @items.count { |i| i.is_a? type }
  end
  
  def count_humans
    return count_items_of_type(Human)
  end
  
  def list_items_of_type(type)
    @items.select { |i| i.is_a? type }
  end
  
  def pass_one_day
      more_to_do = true
      pass_count = 0
      
      @items.each { |i| i.start_day }
      
      while more_to_do do
        more_to_do = false;
        pass_count = pass_count + 1
        @items.each do |i|
          if(i.stuff_to_do?)
            i.pass_time(self, pass_count)
            more_to_do = i.stuff_to_do?
          end
        end # inventory.each
      end # while more to do
      
      @items.delete_if { |i| i.marked_for_removal? }
  end
  
  def stay_put(daystowait=1)
    @action = :stay_put
    daystowait.times do
      @day = @day + 1
      pass_one_day
    end # towait.times
  end
  
  def staying_put?
    return @action == :stay_put
  end
  
  def advance_to_next_terrain
    puts 'atnt ' + self.to_s
    
    @action=:travel
    @day = @day + 1
    
    if(!current_terrain.is_a? Destination)
      @distance = @distance + 1
    end
    
    puts 'Distance = ' + @distance.to_s
    @current_terrain = @@terrain[@distance]
    
    new_items = []
    @items.each do |i|
      if i.keep_while_travelling?
        new_items.push(i)
      end
    end
    @items = new_items
    pass_one_day
  end
  
  def travelling?
    return @action=:travel
  end
  
  
  def buy(item_class, quantity=1)
    item = nil
    if @money > (item_class.price * quantity)
      item = acquire(item_class, quantity)
      @money -= item_class.price * quantity
    end
    return item
  end
  
  def acquire(item_class, quantity=1)
    item = nil
    if(item_class < BulkInventoryItem)
      #puts 'Adding ' + item_class.describe_quantity(quantity) + ' to inventory'
      quantity.times do |c| 
        item = item_class.new;
        @inventory.push(item); 
      end
    else
      item = item_class.new
      #puts 'Adding ' + item.describe()
      @items.push(item)
    end
    return item
  end
  
  def remove_item(item)
    @items.delete(item)
  end
  
  def remove_from_inventory(item)
    used_item = @inventory.delete(item)
    #used_item.use(self)
  end
  
  def find_item_of_class(item_class)
    @items.each do |i|
      if(i.class == item_class); return i; end
    end
    return nil
  end
  
  def find_inventory_item_of_class(item_class)
    @inventory.each do |i|
      if(i.class == item_class); return i; end
    end
    return nil
  end
  
  def list_inventory
    li = {}
    @inventory.each do |i|
      if(li[i.class])
        li[i.class] += 1
      else
        li[i.class] = 1
      end
    end
    return li
  end
  
  def show_status
    puts 'day = ' + @day.to_s
    puts 'distance travelled = ' +@distance.to_s 
    puts 'money = ' + @money.to_s
    puts 'items = '
    n = 1
    @items.each { |i| puts '   ' + n.to_s + ') ' + i.describe; n+=1 }
    puts 'inventory = '
    list_inventory.each { |i,q| puts '   ' + i.describe_quantity(q) }
    ''
  end
  
  def interact_with_inventory
    
    while true do
      clear_the_screen
      show_status
      puts
      print 'Select an item number, or enter x to return to terrain > '
      choice = gets.chomp
      if(choice == 'x')
        break
      end
      choice = choice.to_i
      item = get_item(choice-1)
      if(item)
        ax = item.actions
        ax.each do |t,v|
          puts '> ' + t
        end
        choice = gets.chomp
        params = choice.split(' ', 2)
        puts(params)
        item.perform_action(params[0], params[1], self)
      end
      
    end
  end
  
  def get_item(index)
    @items.at(index)
  end
  
  attr_reader :day, :distance, :money, :inventory, :items

  
  
  
  def show_main_menu
  end
  
end # class Game


















class Human < IndividualInventoryItem
  def initialize
    @name = 'No Name'
    @nutrition = 100
  end
  
  def name; 'Human'; end
  #def self.describe_quantity(quantity = 1); quantity.to_s + ' ox' + (quantity > 1 ? 'en' : ''); end
  
  def describe()
    hunger = 'full'
    if(@nutrition < 30); hunger = 'almost dead'
    elsif(@nutrition < 50); hunger = 'very hungry'
    elsif(@nutrition < 80); hunger = 'hungry'
    end
    'A human named ' + @name + ' who is ' + hunger + ' (' + @nutrition.to_s + ')'
  end
  
  def self.price; 0; end
  
  def pass_time(game, pass_count)

    if(@nutrition < 20)
      puts @name + ' has starved to death'
      #game.remove_item(self)
      mark_for_removal
      return
    end

    if pass_count == 1
      @nutrition = @nutrition - 10
    end
    
    
    food = game.find_inventory_item_of_class(Food)
    
    if(@nutrition < 100 && food)
      puts "#{@name} has nutrition #{@nutrition}; therefore #{@name} eats"
      game.remove_from_inventory(food);
      @nutrition += 10;
    else
      end_day   # I'm full, or there's no more food to eat; I'm done for the day
    end
    
  end

  def setname(name, game)
    @name = name
  end
  
  
 
  def actions
    { 'name' => self.method(:setname) }
  end

end

class Food < BulkInventoryItem

  def initialize
    @age = 0
  end
  
  def name; 'Food'; end
  def self.describe_quantity(quantity = 1); quantity.to_s + ' unit' + (quantity > 1 ? 's of food': 'of food'); end 
  def self.price; 1; end
  def self.weight(quantity); quantity * 2; end
  def self.volume(quantity); quantity * 2; end

  
  def pass_time(game, pass_count)
    if pass_count == 1; @age+=1; end
    return false
  end
  
  def eat(param, game); puts('Eating food'); game.remove_from_inventory(self); end
  def discard(param, game); puts('Discarding food'); game.remove_from_inventory(self); end
  
  def actions
    {'eat' => self.method(:eat), 'discard' => self.method(:discard) }
  end
  
end

class Hay < BulkInventoryItem

  def initialize
    @age = 0
  end
  
  def name; 'Hay'; end
  def self.describe_quantity(quantity = 1); quantity.to_s + ' bale' + (quantity > 1 ? 's of hay' : ' of hay'); end 
  def self.price; 1; end
  def self.weight(quantity); quantity * 2; end
  def self.volume(quantity); quantity * 2; end

  
  def pass_time(game, pass_count)
    if pass_count == 1; @age+=1; end
    return false
  end
  
  def actions
    {}
  end
end


class Wagon < IndividualInventoryItem

  @@instance_count = 0
  
  def initialize
    @@instance_count += 1
    @name = 'Wagon #' + @@instance_count.to_s
    @nutrition = 100
    @status = :wagon_ok
  end
  
  def name; 'Wagon'; end

  def describe()
    state = ''
    if @status == :wagon_broken; state = 'broken '; end
    "A #{@status} wagon"
  end
  
  def self.price; 200; end
  
  def pass_time(game, pass_count)
  
    # check the game: if we are staying put, and the terrain is grassy, then the ox will eat on its own.
    if(pass_count == 1 && game.travelling?)
      if(rand(100) < 5)
        @status = :wagon_broken
        puts 'A wagon has broken'
      end
    end
    end_day
  end

  def setname(name, game)
    @name = name
  end
  
  def feed(params, game)
    hay = game.find_inventory_item_of_class(Hay)
    if(hay)
      game.remove_from_inventory(hay)
      @nutrition += 10
      if(@nutrition > 100); @nutrition = 100; end
    end
  end
  
  def kill(params, game)
    # one oxen becomes @nutrition foods when you kill it
    puts('Killing an ox')
    game.remove_item(self)
    game.acquire(Food, @nutrition)
  end
  
  def release(params, game)
    # out of the goodness of your heart, you let the ox go, I guess...
    game.remove_item(self)
  end
 
  def actions
    { 'name' => self.method(:setname), 'feed' => self.method(:feed), 'kill' => self.method(:kill), 'release' => self.method(:release) }
  end
  
  def keep_while_travelling?
    @status == :wagon_ok
  end
end


=begin
class Ox < IndividualInventoryItem

  def initialize
    @name = 'nothing'
    @nutrition = 100
  end
  
  def name; 'Ox'; end

  def describe()
    hunger = 'full'
    if(@nutrition < 30); hunger = 'almost dead'
    elsif(@nutrition < 50); hunger = 'very hungry'
    elsif(@nutrition < 80); hunger = 'hungry'
    end
    'An ox named ' + @name + ' who is ' + hunger
  end
  
  def self.price; 20; end
  
  def pass_time(game, pass_count)
  
    # check the game: if we are staying put, and the terrain is grassy, then the ox will eat on its own.
    if(pass_count == 1)
      @nutrition -= 10;
      if(game.staying_put?)
        puts 'The ox named ' + @name + ' is foraging for food'
        @nutrition += game.current_terrain.forage
        if(@nutrition > 100); @nutrition = 100; end
      end
      
      if(@nutrition < 20) 
        puts 'An ox named ' + @name + ' has starved to death'
        kill('', game)  # you will get some food from this dead oxen, I guess
      end
    end
    return false
  end

  def setname(name, game)
    @name = name
  end
  
  def feed(params, game)
    hay = game.find_inventory_item_of_class(Hay)
    if(hay)
      game.remove_from_inventory(hay)
      @nutrition += 10
      if(@nutrition > 100); @nutrition = 100; end
    end
  end
  
  def kill(params, game)
    # one oxen becomes @nutrition foods when you kill it
    puts('Killing an ox')
    game.remove_item(self)
    game.acquire(Food, @nutrition)
  end
  
  def release(params, game)
    # out of the goodness of your heart, you let the ox go, I guess...
    game.remove_item(self)
  end
 
  def actions
    { 'name' => self.method(:setname), 'feed' => self.method(:feed), 'kill' => self.method(:kill), 'release' => self.method(:release) }
  end
  
end
=end

game = Game.new


game.acquire(Human).perform_action('name', 'Dad', game)
game.acquire(Human).perform_action('name', 'Mom', game)
game.acquire(Human).perform_action('name', 'Sally', game)
game.acquire(Human).perform_action('name', 'Conrad', game)


puts 'Welcome to the Oregon Trail!'

=begin
while true do
  puts 'You are at the start of the trail, and there is a store here.'
  puts 'You can'
  puts '1) Buy food ($1 per unit)'
  puts '2) Buy hay ($1 per bale)'
  puts '3) Buy an ox ($20 per ox)'
  puts '4) Buy a wagon'
  puts '5) Leave the store'
  puts '6) Check inventory'

  print 'pick > '
  choice = gets.chomp

  choice = choice.to_i
  if choice == 1
    print 'number of units > '
    qty = gets.chomp.to_i
    game.buy(Food, qty)
  elsif choice == 2
    print 'number of bales > '
    qty = gets.chomp.to_i
    game.buy(Hay, qty)
  elsif choice == 3
    game.buy(Ox)
  elsif choice == 4
    puts 'NYI'
  elsif choice == 5
    break
  elsif choice == 6
    game.interact_with_inventory
  end
  
end
=end


puts 'There are ' + game.list_items_of_type(Human).count.to_s + ' humans remaining in your party'

game.current_terrain = Store.new

while true do
  clear_the_screen
  #puts 'game = ' + game.to_s
  #puts
  game.show_status
  puts
  game.current_terrain.describe_terrain game
  puts
    
  puts 'ACTION MENU'
  puts
  
  puts '1) Keep moving'
  puts '2) Stay here for a day'
  puts '3) Manage inventory'
  puts '4) Quit'
  
  print('Pick > ')
  choice = gets.chomp.to_i
  
  if choice == 1
    game.advance_to_next_terrain
  elsif choice == 2
    game.current_terrain.interact(game)
    game.stay_put
  elsif choice == 3
    game.interact_with_inventory
  elsif choice == 4
    break
  end
  
=begin
  if(choice == 1)
    game.advance_to_next_terrain
  elsif(choice == 2)
    game.stay_put
  elsif(choice == 3)
    game.interact_with_inventory
  elsif(choice == 4)
    choice = game.current_terrain.describe(game)
    if(choice == Terrain::INTERACT)
      game.current_terrain.interact(game)
      # this will return when the user stops interacting with the terrain
    end
  elsif(choice == 5)
    break
  end
=end
end








#str1 = Marshal.dump(Game.new)

#game = Marshal.load(str1)

11.times do
  puts 'Waiting for one day'
  game.stay_put(1)  
  puts game.show_status
end

#puts Marshal.dump(game)
