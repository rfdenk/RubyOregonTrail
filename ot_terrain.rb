#ot_terrain.rb
class Terrain
  INTERACT=1
  IGNORE=2
end

class Store < Terrain


  def describe_terrain(game)
    puts 'There is a store here, where you can buy many wonderful and useful things'
  end
  
  def terrain_interaction_menu(game)
      [ ["Enter the store", self, self.method(:interact)] ]
  end
  
  def interact(game)
  
    while true do
      puts 'Choose one of the following:'
      puts '1) Buy food ($1 per unit)'
      puts '2) Buy hay ($1 per bale)'
      puts '3) Buy an ox ($20 per ox)'
      puts '4) Buy a wagon'
      puts '5) Buy a gun'
      puts '6) Buy bullets'
      puts '7) Leave the store'
      puts '8) Check inventory'

      print 'pick > '
      choice = gets.chomp
      
      parts = choice.split(' ')

      if(parts[0].downcase == 'buy')
        if(parts[1] && parts[1].downcase == 'ox'); game.buy(Ox)
        elsif(parts[1] && parts[1].downcase == 'wagon'); game.buy(Wagon)
        elsif(parts[2] && parts[2].downcase == 'hay'); game.buy(Hay, parts[1].to_i)
        elsif(parts[2] && parts[2].downcase == 'food'); game.buy(Food, parts[1].to_i)
        elsif(parts[1] && parts[1].downcase == 'gun'); game.buy(Gun)
        elsif(parts[1] && parts[2].downcase == 'bullets'); game.buy(BoxOfBullets, parts[1].to_i)
        end
      elsif parts[0].downcase == 'leave'
        break
      elsif parts[0].downcase == 'check'
        game.interact_with_inventory
      else
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
          game.buy(Wagon)
        elsif choice == 5
          game.buy(Gun)
        elsif choice == 6
          print 'number of boxes > '
          qty = gets.chomp.to_i
          game.buy(Bullet, qty)
        elsif choice == 7
          break
        elsif choice == 8
          game.interact_with_inventory
        end
      end
    end # while true until (5/leave)

  end # interact

  def wildgame; 0; end
  def forage; 0; end
  
  
end # class Store < Terrain


class Grassland < Terrain

  def describe_terrain(game)
    puts 'This is grassland, where you can forage your livestock and hunt.'
  end
  
  def terrain_interaction_menu(game)
      [["Hunt for food", self, self.method(:hunt)]]
  end
  
   def interact(game)
  
    while true do
      puts 'Choose one of the following:'
      puts '1) Hunt'
      puts '2) Check inventory'
      puts '3) Sleep'

      print 'pick > '
      choice = gets.chomp
      
      parts = choice.split(' ')
      
      if(parts[0] && parts[0].downcase == 'hunt'); hunt(game)
      elsif(parts[0] && parts[0].downcase == 'check'); game.interact_with_inventory
      elsif(parts[0] && parts[0].downcase == 'sleep'); break
      end
    end
  end
  
  def hunt(game)
    gun = game.find_item_of_class(Gun)
    bullets = game.find_inventory_item_of_class(BoxOfBullets)
    if(!gun)
      puts 'You cannot hunt because you don\'t have a gun'
    elsif(!bullets)
      puts 'You cannot hunt because you are out of bullets'
    else
      game.remove_from_inventory(bullets);
      catch = rand(4) * 10
      puts "You caught #{catch} units of food!"
      if(catch > 0)
        game.acquire(Food, catch)
      end
    end
  end
  
  def wildgame; 10; end
  def forage; 30; end
  
end

class RiverFord < Terrain

  def describe(game)
    while true do
      puts 'This is river ford, where you can fill up on water and fish.'
      puts 'Choose one of the following:'
      puts '1) Spend the day here'
      puts '2) Return to action menu'
      print 'pick > '
      choice = gets.chomp.to_i
      if(choice == 1); return Terrain::INTERACT; end
      if(choice == 2); return Terrain::IGNORE; end
      puts
      puts 'Speak up, sonny! My hearing\'s not as good as it used to be!'
      puts
    end

  end
  
  def interact(game)
  end
  
  def wildgame; 10; end
  def forage; 5; end
  
end

class Desert < Terrain

  def describe(game)
    while true do
      puts 'This is desert, where you can slowly die of thirst.'
      puts 'Choose one of the following:'
      puts '1) Stay a while'
      puts '2) Return to action menu'
      print 'pick > '
      choice = gets.chomp.to_i
      if(choice == 1); return Terrain::INTERACT; end
      if(choice == 2); return Terrain::IGNORE; end
      puts
      puts 'Speak up, sonny! My hearing\'s not as good as it used to be!'
      puts
    end

  end
  
  def interact(game)
  end
  
  def wildgame; 0; end
  def forage; 0; end
  
end

class Destination
  def describe_terrain(game)
    puts('You made it! You are in the Oregon Territory!')
  end
  
  def interact(game)
    puts('You made it!')
  end
  
  def wildgame; 100; end
  def forage; 100; end
  
end


