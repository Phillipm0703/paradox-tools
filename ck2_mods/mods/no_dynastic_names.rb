require_relative "base"

class NoDynasticNamesGameModification < CK2GameModification
  def apply!
    patch_mod_files!("common/cultures/*.txt") do |node|
      node.each do |group_name, group|
        group.each do |culture_name, culture|
          next if culture_name == "graphical_culture"
          next if culture_name == "second_graphical_culture"
          next if culture_name == "graphical_cultures"
          culture.delete! "dynasty_title_names"
        end
      end
    end
  end
end
