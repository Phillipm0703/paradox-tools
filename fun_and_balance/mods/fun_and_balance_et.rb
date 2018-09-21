require_relative "fun_and_balance_common"

class FunAndBalanceETGameModification < FunAndBalanceCommonGameModification
  def fix_adopt_secularism_decision!
    patch_mod_file!("decisions/et_conversion_decisions.txt") do |node|
      node["religion_decisions"]["adopt_secularism"]["allow"].add! "is_subject", false
    end
  end

  def apply!
    can_convert_in_territories!
    cheaper_fort_maintenance!
    fewer_mercs!
    soft_patch_defines_lua!("fun_and_balance",
      ["NAI.DIPLOMATIC_INTEREST_DISTANCE", 150, 200],
      ["NAI.PEACE_TIME_EARLY_FACTOR", 0.75, 0.50],
      ["NAI.PEACE_WAR_EXHAUSTION_FACTOR", 1.0, 2.0],
      ["NCountry.LIBERTY_DESIRE_HISTORICAL_FRIEND", -50, -30],
      ["NCountry.LIBERTY_DESIRE_HISTORICAL_RIVAL", 50, 30],
      ["NCountry.MAX_IDEA_GROUPS_FROM_SAME_CATEGORY", 0.5, 1.0],
      ["NCountry.MERCHANT_REPUBLIC_SIZE_LIMIT", 20, 10000],
      ["NCountry.PS_CHANGE_CULTURE", 10, 5],
      ["NCountry.PS_MOVE_CAPITAL", 200, 100],
      ["NCountry.PS_MOVE_TRADE_PORT", 200, 100],
      ["NCountry.RANDOM_LUCKY_DEVELOPMENT_WEIGHT", 0.4, 0],
      ["NCountry.RANDOM_LUCKY_SLOW_TECH_PENALTY", 0.33, 1],
      ["NCountry.RANDOM_LUCKY_TECH_WEIGHT", 1, 0],
      ["NDiplomacy.ANNEX_DIP_COST_PER_DEVELOPMENT", 8, 4],
      ["NDiplomacy.DEFENDER_AE_MULT", 0.75, 0.5],
      ["NDiplomacy.INTEGRATE_VASSAL_MIN_YEARS", 10, 20],
      ["NDiplomacy.VASSALIZE_BASE_DEVELOPMENT_CAP", 100, 300],
      ["NMilitary.TRADITION_GAIN_LAND", 20, 40],
      ["NNationDesigner.IDEAS_MAX_LEVEL", 4, 10],
      ["NNationDesigner.IDEAS_PERCENTAGE_LIMIT", 50, 100],
      ["NNationDesigner.MAX_DISTANCE_TO_OWNER_AREA", 400, 1000],
      ["NNationDesigner.RULER_BASE_SKILL", 2, 3]
    )

    # Extended timeline diplomatic relations per era:
    # classical   3-2   -> 6-4
    # medieval    3-1   -> 6-2
    # (default)   3     -> 6
    # industrial  3+3   -> 6+4
    # modern      3+6   -> 6+8
    #
    # It's much less calibrated than vanilla.

    patch_mod_file!("common/static_modifiers/00_static_modifiers.txt") do |node|
      modify_node! node,
        ["base_values", "diplomatic_upkeep", 3, 6],
        ["ai_nation", "free_leader_pool", 1, 0],
        ["war", "war_exhaustion_cost", nil, 100]
    end
    # We could do something fancier here
    # patch_mod_file!("common/triggered_modifiers/et_triggered_modifiers.txt") do |node|
    #   modify_node! node,
    #     ["classical_era",  "diplomatic_upkeep", -2, -4],
    #     ["medieval_era",   "diplomatic_upkeep", -1, -2],
    #     ["industrial_era", "diplomatic_upkeep",  3,  4],
    #     ["modern_times",   "diplomatic_upkeep",  6,  8]
    # end

    anyone_can_form_byzantium!
    fix_opinions!
    fix_wargoals!
    no_naval_attrition!
    # patch_religion! - TODO
    disable_burgundy_inheritance!
    power_projection_tweaks!
    disable_call_for_peace!
    longer_cb_on_backstabbers!
    subject_tweaks!
    more_building_slots!
    everybody_can_can_claim_states!
    buff_awful_idea_groups!
    rewrite_trade_map! do |edges|
      edges - [
        ["philippines", "panama"],
        ["mexico", "panama"],
      ] + [
        ["panama", "mexico"],
        # ["patagonia", "lima"], # already there
      ]
    end
    # ET sperific
    # fix_adopt_secularism_decision!
  end
end
