module Wafoo
  module Helper
    def output_table(ipsets_list)
      table = Terminal::Table.new(:headings => ['Type', 'IPSets ID', 'Name'],
                                  :rows => ipsets_list)
      puts table
    end

    def added_print(message)
      "\e[32m" + message + "\e[0m"
    end

    def removed_print(message)
      "\e[31m" + message + "\e[0m"
    end
  end
end
