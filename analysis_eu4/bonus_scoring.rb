# It starts with 139 different bonuses, need to filter them down to manageable levels
class BonusScoring
  def initialize
    @ht = Hash.new(0)
  end

  def round!
    @ht.each do |k,v|
      @ht[k] = v.round(6) if v.is_a?(Float)
    end
  end

  def to_h
    round!
    @ht.dup
  end

  def keys
    @ht.keys
  end

  def method_missing(*args)
    if args.size == 2
      k, v = *args
      if @ht.has_key?(k)
        @ht[k] += v
      else
        @ht[k] = v
      end
    else
      super
    end
  end

  ### Bonus conversions ###

  [
    # This is probbaly a net negative, since you're less likely to get random same dynasty with another country
    :heir_chance,

    # Presitge is just so irrelevant let's not bother tracking it
    :prestige,
    :prestige_decay,
    :prestige_from_land,
    :prestige_from_naval,

    # loans are basically irrelevant
    :interest,

    # unless you only own 1-2 ports, it's completely irrelevant
    :global_ship_recruit_speed,
    :global_regiment_recruit_speed,

    # if you have to worry about that, you're doing something wrong
    :enemy_core_creation,

    # These are so godawfully underpowered we might just as well ignore them
    :rebel_support_efficiency,
    :embargo_efficiency,
    :global_spy_defence,
    :spy_offence,

    # Ignored because ridiculously underpowered
    :culture_conversion_cost,

    # Was pretty close to irrelevant, not sure how much it matters post 1.12
    :global_garrison_growth,
    :garrison_size,

    # Examples when it matters are extremely conditional
    :trade_range_modifier,

    # AI is completely immune to naval attrition, so this is extremely conditional (player only)
    :naval_attrition,

    # Influence matters but we have no idea which direction you care about
    :mr_aristocrats_influence,
    :mr_guilds_influence,
    :mr_traders_influence,
    :bureaucrats_influence,
    :enuchs_influence,
    :temples_influence,

    # Far too conditional
    :devotion,
    :church_power_modifier,
  ].each do |k|
    define_method(k){|_| }
  end

  # Bonus itself is completely irrelevant, even if you play merc game there are always enough
  # This bonus (12/100%) is actually converted further to relative bonus assuming base force limit 50
  # so +25% possible mercenaries (+3 absolute force limit) is assumed to translate to
  # 6% land force limit
  def possible_mercenaries(v)
    land_forcelimit(12*v)
  end

  # They aren't worth the same, but very conditional and hard to judge value
  def may_infiltrate_administration(v)
    extra_minor_abilities 1
  end
  def may_sow_discontent(v)
    extra_minor_abilities 1
  end
  def may_sabotage_reputation(v)
    extra_minor_abilities 1
  end
  def may_force_march(v)
    extra_minor_abilities 1
  end
  def reduced_stab_impacts(v)
    extra_minor_abilities 1
  end

  def may_explore(v)
    @ht[:may_explore] += 1.0
  end
  def auto_explore_adjacent_to_colony(v)
    # Very weak explore variant, might be good enough for some countries
    may_explore 0.25
  end

  # Assume used 75% of the time
  def diplomatic_upkeep(v)
    monthly_dip_points 0.75 * v
  end
  def free_leader_pool(v)
    monthly_mil_points 0.75 * v
  end

  # This generated some monthly increase, just without cap increase
  # since it's so rare to be at cap, let's count it as 90% as good
  def manpower_recovery_speed(v)
    global_manpower_modifier 0.90 * v
  end

  # Assume 20% of your armies are in attrition mode on average,
  # and your army size is equal to your manpower pool size on average
  def land_attrition(v)
    global_manpower_modifier -0.2*v
  end

  # Assume provinces are 80% your religion, 5% heretic, 15% heathen
  # Usually much higher your religion, but weighting critical times higher.
  def tolerance_own(v)
    global_revolt_risk -v * 0.80
  end
  def tolerance_heretic(v)
    global_revolt_risk -v * 0.05
  end
  def tolerance_heathen(v)
    global_revolt_risk -v * 0.15
  end
  # Assume they map 1:1 in value between 1.7 and 1.8
  def global_unrest(v)
    global_revolt_risk v
  end

  # For most countries army tradition will be much higher than navy tradition
  # Assume average 25% navy and 75% army tradition
  def navy_tradition_decay(v)
    navy_tradition -0.25*v
  end
  def army_tradition_decay(v)
    army_tradition -0.75*v
  end

  # Assume 2 diplomats, and diplomats spending 25% of their time fabricating, 25% improving relations
  # Since this is 1/(1-x) not 1+x (50% reduction means you get 200% work done, not 150% work)
  # I arbitrarily added 1.5x factor here, but it's really just ballpark.
  #
  # Justifying trade conflicts may take 1% of your diplomat-time - likely far less but there's some extra value
  # from time sensitivity here
  #
  # Signs opposite since it's time vs modifier
  def fabricate_claims_time(v)
    diplomats 2 * 1.5 * 0.25 * -v
  end
  def improve_relation_modifier(v)
    diplomats 2 * 1.5 * 0.25 * v
  end
  def justify_trade_conflict_time(v)
    diplomats 2 * 1.5 * 0.01 * -v
  end

  # Hard cold facts:
  # * 22400 points spent on ideas, or 5/month
  # * 54000 base points spent on tech, or 12/month (actual differs, but modifier is applied to base not total)
  def idea_cost(v)
    monthly_mixed_monarch_points 5 * -v
  end
  def technology_cost(v)
    monthly_adm_points 4 * -v
    monthly_dip_points 4 * -v
    monthly_mil_points 4 * -v
  end
  def mil_tech_cost_modifier(v)
    monthly_mil_points 4 * -v
  end
  def dip_tech_cost_modifier(v)
    monthly_dip_points 4 * -v
  end
  def adm_tech_cost_modifier(v)
    monthly_adm_points 4 * -v
  end

  # Assuming +1 stab button / 15 years (base cost 100, mods apply to this not total)
  # It's not uncommon to be at permanent +2/+3 due to events, but then you could be deep in negative territory
  # due to westernization etc.
  def stability_cost_modifier(v)
    monthly_adm_points (-v * 100.0 / 12 / 15)
  end
  # Assuming one reduce WE button press every 25 years
  # It's somewhat common early game, late game not really
  def war_exhaustion_cost(v)
    monthly_dip_points (-v * 75.0 / 12 / 25)
  end
  # -2 WE is worth 75 dip
  # Assume you are at positive-enough-to-care WE 50% of the time
  # This is *monthly* number
  def war_exhaustion(v)
    monthly_dip_points -v*(75.0/2.0)*0.50
  end
  # Assuming reduce inflation button is used once / 50 years
  def inflation_action_cost(v)
    monthly_adm_points (-v * 75.0 / 12 / 50)
  end
  # -2 inflation is worth 75 adm
  # Assume you are at positive-enough-to-care inflation 25% of the time
  # This is *annual* number
  def inflation_reduction(v)
    monthly_adm_points v*(75.0/2.0/12)*0.25
  end
  # Assume average of 6dev/year cored before efficiency unlocks,
  # proportionally more after efficiency
  def core_creation(v)
    monthly_adm_points (-v * 10.0 * 6.0 / 12)
  end
  # Assume average of 6dev/year diploannexed before efficiency unlocks,
  # proportionally more after efficiency
  def diplomatic_annexation_cost(v)
    monthly_dip_points (-v * 10.0 * 6.0 / 12)
  end
  # Assume 2 unjustified demand for base of 50 each every 10 years
  def unjustified_demands(v)
    monthly_dip_points (-v * 50 * 2 / 120)
  end

  # Based on simulations average AI country presses the button 28 times during the game
  # and average base cost is 65 (= mean number of times it was used before on same province is 3)
  # This means average monthly development spending is 0.4
  #
  # Big assumption is that humans are same as AI here
  def development_cost(v)
    buttons_per_month = 28.0/(1820-1444)/12
    monthly_mixed_monarch_points (buttons_per_month * 65 * -v)
  end

  # Assume: 16 inf, 4 cav, 6 art stacks
  # so upkeep is: 160 inf (35%) / 100 cav (25%) / 180 art (40%)
  # However since infantry takes most beating, and they cost most reinforce costs by far,
  # adjust that to: 50% inf, 20% cav, 30% art
  # For combat ability assume the same except lower artillery since it's really siege unit for most of the game to:
  # 50% inf, 30% cav, 20% art
  # For land units cost and maintenance are proportional

  # For navy it's harder to make good assumptions.
  # First, ships need to be rebuilt and maintenance cost are not proportional to recruitment costs
  # TCO over 40 years (when it will need to be rebuilt if not sunk yet):
  # * heavy     - 250.16
  # * light     -  59.84
  # * galley    -  25.84
  # * transport -  31.20
  #
  # Actual fleet composition being extremely dependent on your circumstances,
  # but decent ballpark figures are:
  # 50% light ships, 10% heavy ships, 15% galleys, 25% transports
  #
  # So costs are:
  # 45% light, 37% heavy, 6% galley, 12% transport
  #
  # and maintenance is 70% of total cost
  #
  # Since land units last forever I assume maintenance is 90% of the cost
  #
  # Of course nations with big galley cost discounts might go full galley spam because of them,
  # but then you get into naval force limit issues etc. It's too conditional to consider here
  #
  # As for power, by canons/hull strength we can sort of assume ballpark figures:
  # 1 heavy = 3 lights or galleys = 6 transports
  # so total power of your fleet would then be:
  # 30% heavy, 45% light, 15% galley, 10% transport

  # http://www.eu4wiki.com/Land_warfare#Comparison
  def infantry_cost(v)
    calculated_land_cost 0.50 * v
  end
  def cavalry_cost(v)
    calculated_land_cost 0.20 * v
  end
  def artillery_cost(v)
    calculated_land_cost 0.30 * v
  end
  def global_regiment_cost(v)
    calculated_land_cost v
  end
  def infantry_power(v)
    land_unit_power 0.50 * v
  end
  def cavalry_power(v)
    land_unit_power 0.30 * v
  end
  def artillery_power(v)
    land_unit_power 0.20 * v
  end

  def heavy_ship_cost(v) # not seen anywhere
    calculated_ship_cost 0.37 * v
  end
  def light_ship_cost(v)
    calculated_ship_cost 0.45 * v
  end
  def galley_cost(v)
    calculated_ship_cost 0.06 * v
  end
  def transport_cost(v) # not seen anywhere
    calculated_ship_cost 0.12 * v
  end
  def global_ship_cost(v)
    calculated_ship_cost v
  end

  def naval_maintenance_modifier(v)
    calculated_ship_cost 0.7*v
  end
  def land_maintenance_modifier(v)
    calculated_land_cost 0.9*v
  end

  def heavy_ship_power(v)
    naval_unit_power 0.30 * v
  end
  def light_ship_power(v)
    naval_unit_power 0.45 * v
  end
  def galley_power(v)
    naval_unit_power 0.15 * v
  end
  def transport_power(v)
    naval_unit_power 0.10 * v
  end

  # Assume ships spend 20% of time in repairs
  # And half of that could be avoided if they could reapir at sea
  def sea_repair(v)
    raise unless v == true
    naval_unit_power 0.2*0.5
  end
  def global_ship_repair(v)
    naval_unit_power v*0.2
  end

  # Assume your light ships spend 20% of their time blockading, so you need fewer if you have blockade efficiency
  def blockade_efficiency(v)
    light_ship_cost -v*0.20
  end

  # Assume your light ships spend 10% of their time privateering, so they hive you more money with privateer efficiency
  # Assume you get 2x as much money as with trade steering on average in situations where you want to privateer
  def privateer_efficiency(v)
    trade_steering 2*v*0.1
  end

  # Assume 25% of nodes are inland, so this bonus is worth 25% of trade steering bonus
  def caravan_power(v)
    trade_steering 0.25*v
  end

  # Discipline is twice as powerful as combat ability as it affects
  # both damage dealt (like combat ability) and damage taken:
  # damage dealt = (100% + combat ability) * (100% + discipline modifiers) * other stuff
  # damage taken =                           (100% - discipline modifiers) * other stuff
  # (durability is naval equivalent of discipline)
  def discipline(v)
    land_unit_power(2*v)
  end
  def ship_durability(v)
    naval_unit_power(2*v)
  end
  # Morale increases morale damage, and defense. Discipline does that and regular damage/defense,
  # so morale is worth about half as much as discipline
  def land_morale(v)
    land_unit_power 0.5 * v
  end
  def naval_morale(v)
    naval_unit_power 0.5 * v
  end

  # 1 fire pip is worth 20%/20%/0%/0% (fire dmg, fire morale dmg, shock dmg, shock morale dmg)
  # 10% discipline is worth 10%/20%/10%/20% - and you won't always have leaders
  # So let's say leader pip is worth 5% discipline
  #
  # For naval units you will very rarely have leaders, so half that value again
  def leader_land_fire(v)
    land_unit_power 0.05 * v
  end
  def leader_land_shock(v)
    land_unit_power 0.05 * v
  end
  def leader_naval_fire(v)
    naval_unit_power 0.025 * v
  end
  def leader_naval_shock(v)
    naval_unit_power 0.025 * v
  end

  # Assume 25% heretic 75% heathen
  def global_heretic_missionary_strength(v)
    global_missionary_strength 0.25 * v
  end

  # Extra pip speeds up siege by about 17%
  # Asssume 30% of sieges have leaders
  def leader_siege(v)
    siege_ability v*0.17*0.30
  end

  # I assume this adds to base of 15% (20% in home territory) not 100%
  # I doesn't translate to anything, but let's just guess that army which instantly recovered
  # morale every monthly tick would be 10% better. That's not as good as it sounds since it still
  # won't matter during combat, or if combat happens same month as previous one.

  def recover_army_morale_speed(v)
    land_unit_power v*0.1
  end
  def recover_navy_morale_speed(v)
    naval_unit_power v*0.1
  end

  # Guestimate that 2x reinforcement speed would make land units 10% more effective
  def reinforce_speed(v)
    land_unit_power v*0.1
  end

  # +1/year with 5% default decay makes it stabilize at 20 higher level
  # This results in regular bonuses, and better leaders
  #
  # PIPs according to http://www.eu4wiki.com/Military_tradition#Military_leaders
  def army_tradition(v)
    level = 0.2 * v

    land_morale 0.25*level
    manpower_recovery_speed 0.1*level
    recover_army_morale_speed 0.1*level
    siege_ability 0.05*level

    leader_siege 1.5*level
    leader_land_fire 2.25*level
    leader_land_shock 2.25*level
    leader_land_manuever 2.25*level
  end

  def navy_tradition(v)
    level = 0.2 * v

    naval_morale 0.25*level
    blockade_efficiency 1.0*level
    trade_steering 1.0*level
    recover_navy_morale_speed 0.1*level
    privateer_efficiency 0.25*level

    leader_naval_shock 2.25*level
    leader_naval_fire 2.25*level
    leader_naval_manuever 2.25*level
  end

  # These are somewhat relevant early game.
  # If you're over force limit, any force limit %X increase is basically %X maintenance reduction
  # (except light ships suffer square of that, as some cheap exploit prevention trick probably)
  #
  # Assuming you're going to be over your force limit 20% of the time
  # Actual number will be less, but it's weighted towards more desperate times
  #
  # Assume 10% of your land force limit comes from vassals, which is probably too much
  def land_forcelimit_modifier(v)
    calculated_land_cost -0.2*v
  end
  def vassal_forcelimit_bonus(v)
    land_forcelimit_modifier 0.1*v
  end
  def naval_forcelimit_modifier(v)
    calculated_ship_cost -0.2*v
  end

  def cb_on_primitives(v)
    extra_cbs 1
  end
  def cb_on_overseas(v)
    extra_cbs 1
  end
  # Holy War and Cleansing of Heresy are two great CBs
  # Defender of the Faith not counted as it only gives you CB on people you already have good CBs on (one of two above)
  def cb_on_religious_enemies(v)
    extra_cbs 2
  end
  def idea_claim_colonies(v)
    extra_cbs 1
  end

  # Assuming half of your trade power is spent on steering, and you capture half of the value of trade steered again
  # 25% of your trade power in your home node, 75% abroad
  # 50% of your total trade power from provinces (does that include buildings and province modifiers or just base???)
  #
  # These ratios are based on a lot of assumptions
  def trade_steering(v)
    global_trade_power 0.5*v
  end
  def global_prov_trade_power_modifier(v)
    global_trade_power 0.5*v
  end
  def global_own_trade_power(v)
    global_trade_power 0.25*v
  end
  def global_foreign_trade_power(v)
    global_trade_power 0.75*v
  end
  def global_trade_power(v)
    trade_efficiency 0.5*v
  end
  def global_trade_income_modifier(v)
    trade_efficiency v
  end
  # I'm just guessing here...
  def global_trade_goods_size_modifier(v)
    trade_efficiency v*0.5
  end
  # This is extremely hard. Inland nodes are often extremely competitive (HRE), so this bonus matter little
  # Assume total 500 trade power in node, and that node would increase your trade income by 20% if fully controlled
  def merchant_steering_to_inland(v)
    trade_efficiency (v/500.0)*0.2
  end

  # Numbers based on AI games, 1.12.0, typical medium-big countries, ~1625 or so.
  #
  # From a few simulations, ballpark figures for income of a typical medium-big country:
  # 30% tax, 20% production, 40% trade, 5% gold, 2% tariff, 2% vassal, 1% loot
  # But these are *totals*, and we're modifying base numbers:
  # Typical modifiers mid-game are:
  # +25% tax, +50% production, +50% trade, +25% vassal, +25% tariff, +0% loot
  # Since these bonuses are additive not multiplicative we need to go back to base numbers
  # before adding bonus
  #
  # For costs:
  # 25% army, 25% fort, 20% advisors, 10% navy, 30% balance (which I assume goes for 20% buildings, 10% other stuff)
  # I'll assume of that army spending, 5% is mercs, 5% is reinforcement, 90% is regular maintenance
  #
  # This isn't really true, since incomes from simualion already come with many modifiers, mostly positive,
  # and these idea bonuses apply to base not total, so for most part this is going to overestimate
  # how much value you'll be getting.

  def production_efficiency(v)
    money (0.20/1.50)*v
  end
  def trade_efficiency(v)
    money (0.40/1.50)*v
  end
  def global_tax_modifier(v)
    money (0.30/1.25)*v
  end
  def global_tariffs(v)
    money (0.02/1.25)*v
  end
  def vassal_income(v)
    money (0.02/1.25)*v
  end
  def loot_amount(v)
    money 0.01*v
  end
  def fort_maintenance_modifier(v)
    money 0.25*-v
  end
  def advisor_cost(v)
    money 0.25*-v
  end
  def calculated_land_cost(v)
    money 0.25*-v
  end
  def calculated_ship_cost(v)
    money 0.10*-v
  end
  def build_cost(v)
    money 0.20*-v
  end
  def mercenary_cost(v)
    calculated_land_cost 0.05*v
  end
  def merc_maintenance_modifier(v)
    # For mercs I put maintenance as 50% since they tend to be disbanded when no longer needed
    mercenary_cost 0.5*v
  end
  def no_cost_for_reinforcing(v)
    raise unless v == true
    calculated_land_cost -0.05
  end

  # Multiply by 50% chance that you're Catholic. This might be low for national ideas since only nations that start
  # Scale by 1/12 since it's annual number
  #
  # After that it's reasonable estimate that each papal influence point
  # is worth about as much as adm point as you can use 100 to buy +1 stability
  def papal_influence(v)
    monthly_adm_points(v * 0.5 / 12.0)
  end

  # Far too conditional
  def monthly_fervor_increase(v)
  end

  # Assumes:
  #   2 diplomats - 25% time in travel
  #   2 merchant  -  1% time in travel
  #   1 colonist  - 10% time in travel
  def envoy_travel_time(v)
    diplomats -2*0.25*v
    merchants -2*0.01*v
    colonists -1*0.10*v
  end

  # This is potentially useful, but it's so extremely conditional (only emperor) I'm not going to score it
  def imperial_authority(v)
  end

  # Since you always park a unit on your colony, and they never can kill your unit
  # (unless you upgrade tech that same month and it goes to 0 morale or such nonsense)
  # it never matters
  #
  # However wiki says this also doubles native contribution to manpower and base tax
  # which is actually relevant.
  # Guesstimating this as 20% colonial growth at 2 colonists
  def reduced_native_attacks(v)
    raise unless v == true
    colonists 2*0.2
  end

  # Growth triggers once a year
  # Settler chance triggers once a month for chance of 1% of +25 colonists
  # Assume 90% of colonies have settlers, and 75% of them are under cap where this is relevant
  def colonist_placement_chance(v)
    global_colonial_growth 25*0.01*12*0.90*0.75
  end

  # Assume on aveareg you'll be using 50% of this bonus
  # Utilization depends on bonus of course, +10% unity is good for everyone, +50% is probably a bit wasted
  def religious_unity(v)
    stability_cost_modifier v*0.5
    global_revolt_risk -2*v*0.5
  end

  # Not sure how that works since it's unique USA thing
  # I'm assuming it just removes intolerance. With average -4 intolerance and 20% wrong religion provinces
  # that's what it amounts to
  def no_religion_penalty(v)
    global_revolt_risk -4*0.2
  end

  # Assume it affects 5% of your provinces, and avearge -RR is -2
  def years_of_nationalism(v)
    global_revolt_risk (2*0.05*v)
  end

  # Assume that on average 50% reduction will make 0.5 cultures accepted which would otherwise not be,
  # and they'd be in a different culture group, and that it will affect 10% of provinces.
  # I know these don't add up, but they're ballpark figures over a lot of scenarios.

  def accepted_culture_threshold(v)
    affected = 0.5 * 0.10 * (v/-0.5)
    global_revolt_risk -2*affected
    global_tax_modifier 0.33*affected
    global_missionary_strength 0.02*affected
    global_manpower_modifier 0.33*affected
  end

  ### Higher level calculations ###
  # Assume strength of the military is 80% army 20% navy.
  def land_unit_power(v)
    military_power 0.8*v
  end
  def naval_unit_power(v)
    military_power 0.2*v
  end

  # These are ballpark estimates how good this is
  # Naval is much more important since it's also used for exploration
  def leader_land_manuever(v)
    land_unit_power 0.01*v
  end
  def leader_naval_manuever(v)
    naval_unit_power 0.02*v
  end

  # Assume 10% of AE comes from discovered actions
  def discovered_relations_impact(v)
    ae_impact 0.1*v
  end

  # Counting 200% range extension worth as much as extra colonist - it's extremely conditional
  def range(v)
    colonists 0.5*v
  end

  # Guess base numbers of 50 land, 50 naval
  def land_forcelimit(v)
    land_forcelimit_modifier(v/50.0)
  end

  def naval_forcelimit(v)
    naval_forcelimit_modifier(v/50.0)
  end

  def score
    total = 0
    @ht.each do |k,v|
      case k
      # Base unit of value
      when :monthly_mixed_monarch_points
        # This is meant for unpredictable mix, for 1/1/1 like all tech just use explicit values
        total += v
      when :monthly_dip_points
        total += v*1.1
      when :monthly_adm_points
        total += v*1.1
      when :monthly_mil_points
        total += v*0.8
      when :colonists
        # Definitely the most important agent type by huge margin
        total += 3*v
      when :diplomats
        # 3rd diplomat is arguably worth more, but it falls down fast
        # Diplomats became more important in 1.12 as you only have 2 not 3 after embassy got removed
        # 1.12.1 code implies that kingdom/empire will get 1 free diplomat, but that doesn't work yet
        total += 2*v
      when :missionaries
        total += 0.75*v
      when :merchants
        # This also provides +5 naval force limit per merchant beyond 2nd, not counted separately
        # They became less relevant as you can get them from CNs and trade companies, at least
        # if you're western tech
        total += 0.75*v
      when :global_missionary_strength
        total += 75.0*v
      when :global_revolt_risk
        total -= 1.0*v
      when :global_autonomy
        total += -10.0*v
      when :province_warscore_cost
        # 20% discount would be worth 2 mp
        total -= 10.0*v
      when :money
        # Doubling the money
        total += v*10
      when :siege_ability
        # Doubling siege speed
        total += v*5
      when :defensiveness
        # Slowing down enemy sieges x2
        total += v*1
      when :military_power
        # Doubling military power
        total += v*10
      when :global_manpower_modifier
        # Doubling total manpower
        total += v*3
      when :global_colonial_growth
        total += v/25.0
      when :extra_minor_abilities
        total += v*0.5
      when :extra_cbs
        total += v*2.0
      when :legitimacy
        total += v*0.5
      when :republican_tradition
        total += v*100.0 # value at 2x legitimacy, uses different scale
      when :may_explore
        total += v*2
      when :advisor_pool
        # This is far less valuable now that you can just buy it for small amount of money
        total += 0.25*v
      when :hostile_attrition
        total += 1*v
      when :relations_decay_of_me
        total += 2*v
      when :ae_impact
        total -= 2*v
      when :diplomatic_reputation
        # This is back to being good
        total += v
      when :migration_cooldown
        # Extremely situational
      else
        warn "#{k} not scored"
      end
    end
    total.round(4)
  end
end
