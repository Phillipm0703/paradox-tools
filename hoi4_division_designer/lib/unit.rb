class Unit
  extend Memoist
  attr_reader :unit_type, :missing_equipment

  def initialize(unit_type, country)
    @database = country.database
    @unit_type = unit_type
    @country = country
    @equipment = {}
    @missing_equipment = Set.new
    @unit_type.equipment.each do |name, count|
      equipment = @country.equipment_map[name]
      unless equipment
        equipment = @database.fallback_equipment_map.fetch(name)
        @missing_equipment << equipment
      end
      @equipment[equipment] = count
    end
    @country_bonuses = @country.unit_bonuses_for(@unit_type.key)
  end

  %i[
    suppression hp supply_use manpower training_time weight
    special_forces? can_be_parachuted? frontline? name group
    ].each do |key|
    define_method(key) { @unit_type.send(key) }
  end

  attr_reader :equipment

  memoize def terrain_bonuses
    base = {}
    base.recursively_merge!(@unit_type.terrain_bonuses)
    if @country_bonuses["terrain_bonuses"]
      base.recursively_merge!(@country_bonuses["terrain_bonuses"]){|a,b| (a+b).round(3)}
    end
    base
  end

  memoize def soft_attack
    base = @equipment.map{|eq, count| eq.soft_attack || 0}.sum
    base * (1 + @unit_type.soft_attack + (@country_bonuses["soft_attack"] || 0))
  end

  memoize def hard_attack
    base = @equipment.map{|eq, count| eq.hard_attack || 0}.sum
    base * (1 + @unit_type.hard_attack + (@country_bonuses["hard_attack"] || 0))
  end

  memoize def air_attack
    base = @equipment.map{|eq, count| eq.air_attack || 0}.sum
    base * (1 + @unit_type.air_attack + (@country_bonuses["air_attack"] || 0))
  end

  memoize def defense
    base = @equipment.map{|eq, count| eq.defense || 0}.sum
    base * (1 + @unit_type.defense + (@country_bonuses["defense"] || 0))
  end

  memoize def breakthrough
    base = @equipment.map{|eq, count| eq.breakthrough || 0}.sum
    base * (1 + @unit_type.breakthrough + (@country_bonuses["breakthrough"] || 0))
  end

  memoize def piercing
    base = @equipment.map{|eq, count| eq.ap_attack || 0}.sum
    base * (1 + (@country_bonuses["ap_attack"] || 0))
  end

  memoize def hardness
    base = @equipment.map{|eq, count| eq.hardness || 0}.sum
    base * (1 + (@country_bonuses["hardness"] || 0))
  end

  def org
    base = @unit_type.org
    base + (@country_bonuses["max_organisation"] || 0)
  end

  def recovery_rate
    base = @unit_type.recovery_rate
    base + (@country_bonuses["default_morale"] || 0)
  end

  def reliability_factor
    base = @unit_type.reliability_factor
    base + (@country_bonuses["reliability_factor"] || 0)
  end

  def casualty_trickleback
    base = @unit_type.casualty_trickleback
    base + (@country_bonuses["casualty_trickleback"] || 0)
  end

  def experience_loss_factor
    base = @unit_type.experience_loss_factor
    base + (@country_bonuses["experience_loss_factor"] || 0)
  end

  def initiative
    base = @unit_type.initiative
    base + (@country_bonuses["initiative"] || 0)
  end

  def equipment_capture_factor
    base = @unit_type.equipment_capture_factor
    base + (@country_bonuses["equipment_capture_factor"] || 0)
  end

  def supply_consumption_factor
    base = @unit_type.supply_consumption_factor
    base + (@country_bonuses["supply_consumption_factor"] || 0)
  end

  def fuel_consumption_factor
    base = @unit_type.fuel_consumption_factor
    base + (@country_bonuses["fuel_consumption_factor"] || 0)
  end

  def suppression_factor
    base = @unit_type.suppression_factor || 0
    base + (@country_bonuses["suppression_factor"] || 0)
  end

  def combat_width
    base = @unit_type.combat_width
    base + (@country_bonuses["combat_width"] || 0)
  end

  def armor
    @equipment.map{|eq, count| eq.armor_value || 0}.sum
  end

  def fuel_consumption
    base = @equipment.map{|eq, count| eq.fuel_consumption || 0}.sum
    base * (@unit_type.own_equipment_fuel_consumption_mult || 1)
  end

  def recon
    base = @unit_type.recon
    base + (@country_bonuses["recon"] || 0)
  end

  def entrenchment
    base = @unit_type.entrenchment
    base + (@country_bonuses["entrenchment"] || 0)
  end

  def ic_cost
    @equipment.map{|eq, count| eq.build_cost_ic * count}.sum
  end

  def speed
    # Unclear what to do when multiply types are used. Mot uses mot(12)+inf(4)
    equipment_speed = @equipment.map{|eq, count| eq.maximum_speed}.compact.max || 4.0
    equipment_speed * (1 + @unit_type.maximum_speed)
  end
end
