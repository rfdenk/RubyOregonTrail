#ot_ox.rb
require_relative 'ot_item.rb'

class Ox < IndividualInventoryItem

  @@instance_count = 0
  
  def initialize
    @@instance_count += 1
    @name = 'Ox #' + @@instance_count.to_s
    @nutrition = 100
    @alive = true
  end
  
  def name; 'Ox'; end

  def describe()
    hunger = 'full'
    if(!@alive); hunger = 'dead'
    elsif(@nutrition < 30); hunger = 'almost dead'
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
      if(game.staying_put? && game.current_terrain.forage > 0)
        puts 'The ox named ' + @name + ' is foraging for food'
        @nutrition += game.current_terrain.forage
        if(@nutrition > 100); @nutrition = 100; end
      end
      
      if(@nutrition < 20) 
        puts 'An ox named ' + @name + ' has starved to death'
        @alive = false
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
    puts 'Killing the ox named ' + @name
    @alive = false
  end
  
  def butcher(params, game)
    if(@alive); kill(params, game); end
    puts('Butchering an ox')
    game.remove_item(self)
    game.acquire(Food, @nutrition)
  end
  
  def release(params, game)
    # out of the goodness of your heart, you let the ox go, I guess...
    game.remove_item(self)
  end
 
  def actions
    if(@alive)
      { 'name' => self.method(:setname), 'feed' => self.method(:feed), 'kill' => self.method(:kill), 'release' => self.method(:release) }
    else
      { 'butcher' => self.method(:butcher) }
    end
  end
  
  def keep_while_travelling?
    @alive
  end
  
end
