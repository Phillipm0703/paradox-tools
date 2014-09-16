require "yaml"
require "pathname"
require "set"

require_relative "paradox_game"
require_relative "paradox_mod_file_serializer"

class Pathname
  def write(content)
    open("w"){|fh| fh.write(content)}
  end
end

class ParadoxModBuilder
  def initialize(game, target)
    @game = game
    @target = Pathname(target)
    @localization = {}
  end
  def compare_with_reference!(reference)
    diff_paradox = __dir__ + "/../bin/diff_paradox"
    system *%W[#{diff_paradox} --normalize #{reference} #{@target}]
  end
  def localization!(group, locs)
    @localization[group] ||= {}
    locs.each do |tag, name|
      @localization[group][tag] = name
    end
  end
  def save_localization!
    # YAML is about as much a standard as CSV, use Paradox compatible output instead of yaml gem
    @localization.each do |group, data|
      create_file!("localisation/#{group}_l_english.yml",
        [0xEF, 0xBB, 0xBF].pack("C*") + # UTF-8 BOM, WTF?
        "l_english:\n" +
        data.map{|k,v| " #{k}: \"#{v}\"\n"}.join
      )
    end
  end
  def build!
    ensure_target_clear!
    build_mod_files!
    save_localization!
  end
  def ensure_target_clear!
    system "trash", @target.to_s
    @target.mkpath
  end
  def build_mod_files!
    raise "SubclassResponsibility"
  end
  # This is so you can apply multiple patches to same file
  def resolve(name)
    if (@target + name).exist?
      @target + name
    else
      @game.resolve(name)
    end
  end
  def create_file!(name, content)
    (@target + name).parent.mkpath
    (@target + name).write(content)
  end
  def patch_file!(name, force_create: false, reencode: false)
    content = resolve(name).read
    content = content.force_encoding("windows-1252").encode("UTF-8") if reencode
    new_content = yield(content.dup)
    new_content = new_content.encode("windows-1252") if reencode
    create_file!(name, new_content) if content != new_content or force_create
  end
  def patch_defines_lua!(changes)
    patch_file!("common/defines.lua") do |content|
      changes.each do |variable, orig, updated|
        content.sub!(/^(\s+#{variable}\s*=\s*)(.*?)(\s*,)/) do
          if $2 == orig.to_s
            "#{$1}#{updated}#{$3}"
          else
            raise "Tried to change `#{variable}' from `#{orig}' to `#{updated}', but is it `#{$2}' instead"
          end
        end or raise("Tried to change `#{variable}' from `#{orig}' to `#{updated}', can't find it in the file")
      end
      content
    end
  end
  def patch_mod_files!(pattern, &blk)
    matches = @game.glob(pattern)
    raise "No matches found for `#{pattern}'" if matches.size == 0
    matches.each do |path|
      patch_mod_file!(path, &blk)
    end
  end
  def patch_mod_file!(path)
    patch_file!(path, reencode: true) do |content|
      orig_node = ParadoxModFile.new(string: content).parse!
      node = Marshal.load(Marshal.dump(orig_node)) # deep clone
      yield(node)
      if node == orig_node
        content
      else
        ParadoxModFileSerializer.serialize(node, orig_node)
      end
    end
  end
  def create_mod_file!(path, node)
    create_file! path, ParadoxModFileSerializer.serialize(node).encode("windows-1252")
  end
end
