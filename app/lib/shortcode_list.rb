module ShortcodeList

	def self.parse(full_text, post_id) # this function is the public interface
    self.extract_lists(full_text)    
	end

  def self.list_regex
    /\[list(.*?)\](.*?)\[\/list\]/m
  end
  def self.item_regex
    /\[item(.*?)\](.*?)\[\/item\]/m
  end

  def self.parse_args(text)
    text.squeeze(' ').split(' ').inject({}) do |obj, item|
        k, v = item.split('=')
        obj[k.to_sym] = v
        obj
    end
  end  

  def self.get_list_bookends(args)
    return ["<div><ol>", "</ol></div>"] if args[:type] == 'ol'
    
    ["<ul>", "</ul>"]
  end

  def self.get_item_bookends(args)    
    return ["<li>", "</li>"] if args[:type] == 'ol'

    ["<li>", "</li>"]
  end

  def self.extract_lists(full_text)    
    full_text.gsub(self.list_regex) do |capture|
      args = self.parse_args($1)
      list_start, list_end = self.get_list_bookends(args)
      [ list_start,
        self.render_list(args: args, contents: $2),
        list_end
      ].join("")
    end 
  end

  def self.render_list(args: nil, contents: "")
    contents.gsub(self.item_regex) do |capture|
      item_start, item_end = self.get_item_bookends(args)
      [ item_start,
        $2,
        item_end
      ].join("")
    end
  end

end