module Wafoo
  module Helper
    def output_table(ipsets_list)
      table = Terminal::Table.new(:headings => ['Type', 'IPSet ID', 'IPSet Name', 'WebACL ID', 'WebACL Name'],
                                  :rows => ipsets_list)
      puts table
    end

    def split_cidr(ipset)
      addr = NetAddr::CIDR.create(ipset)
      addr.enumerate
    end

    def added_print(message)
      "\e[32m" + message + "\e[0m"
    end

    def info_print(message)
      "\e[36m" + message + "\e[0m"
    end

    def removed_print(message)
      "\e[31m" + message + "\e[0m"
    end

    alias error_print removed_print
  end
end
