#ot_item.rb
class InventoryItem
  def perform_action(verb, params, game)
    action = actions()[verb]
    if(action)
      action.call(params, game)
    else
      puts "Unrecognized verb #{verb}"
    end
  end
  
  def start_day
    @handle_marker = :do_stuff
  end
  def stuff_to_do?
    @handle_marker == :do_stuff
  end
  def end_day
    @handle_marker = :all_done
  end
  def mark_for_removal
    @handle_marker = :remove
  end
  def marked_for_removal?
    @handle_marker == :remove
  end
  
  FINISHED = 0
  ASK_AGAIN = 1
  REMOVE = 2
  
end

class BulkInventoryItem < InventoryItem

  def keep_while_travelling?
    true
   end
   
end

class IndividualInventoryItem < InventoryItem

  def keep_while_travelling?
    true
  end
   
end


class Gun < IndividualInventoryItem
  
  def initialize
    @name = 'Gun'
    @status = :gun_ok
  end
  
  def name; 'Gun'; end

  def describe()
    'A gun that is ' + ((@status == :gun_ok) ? 'working' : 'broken')
  end
  
  def self.price; 20; end
  
  def pass_time(game, pass_count)
    end_day
  end

  def fix(params, game)
    @status = :gun_ok
  end

  def actions
    if(@status == :gun_ok)
      {  }
    else
      { 'fix' => self.method(:fix) }
    end
  end
  
end

class BoxOfBullets < BulkInventoryItem
  def initialize
    @age = 0
  end
  
  def name; 'Box of bullets'; end
  def self.describe_quantity(quantity = 1); quantity.to_s + ' box' + (quantity > 1 ? 'es of bullets': ' of bullets'); end 
  def self.price; 1; end
  def self.weight(quantity); quantity * 2; end
  def self.volume(quantity); quantity * 2; end

  
  def pass_time(game, pass_count)
    if pass_count == 1; @age+=1; end
    return false
  end
  
  def discard(param, game); puts('Discarding box of bullets'); game.remove_from_inventory(self); end
  
  def actions
    {'discard' => self.method(:discard) }
  end
end