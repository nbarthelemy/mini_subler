require 'cocaine'

module MiniSubler
    
  class Command
    
    def self.vendored
      gem_root = File.expand_path '../../..', __FILE__
      s = Command.new
      s.command_path = File.join gem_root, "vendor", "SublerCLI"
      s
    end
    
    attr_accessor :command_path
    
    def get_metadata(file_path)
      file_path = File.expand_path file_path
      metadata_text = Cocaine::CommandLine.new(self.command_path, "-source :source -listmetadata", source: file_path).run
      hash = {}
      metadata_text.each_line do |line|
        if line.include?(self.command_path)
          # Do nothing
        else
          split = line.split ": "
          hash[split[0].parameterize("_").to_sym] = split[1].chomp
        end
      end
      hash
    rescue
      nil
    end
    
    def set_metadata(file_path, hash)
      file_path = File.expand_path file_path
      line = Cocaine::CommandLine.new(self.command_path, "-dest :source -metadata :metadata", source: file_path, metadata: subler_hash_to_argument(hash_to_subler_hash(hash)))
      puts line.command
      puts line.run
    rescue
      nil
    end
        
    def hash_to_subler_hash(h)
      n = {}
      h.each do |key, value|
        n[key.to_s.titleize.gsub("Tv", "TV").gsub("Number", "#")] = value
      end
      n
    end
    
    def subler_hash_to_hash(h)
      n = {}
      h.each do |tag_name, tag_value|
        n[tag_name.gsub("#", "Number").parameterize("_").to_sym] = tag_value
      end
      n
    end
    
    def subler_hash_to_argument(h)
      s = ""
      h.each do |key, value|
       s << "{#{escape key}:#{escape value}}" 
      end
      s
    end
    
    def escape(s)
      s.gsub("{", "&#123;").gsub("{", "&#125;").gsub(":", "&#58;")
    end

  end
  
end