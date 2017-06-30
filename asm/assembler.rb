require '.\parser'
require '.\code'

class Assembler
  attr_accessor :debug

  def initialize
    @parser = Parser.new 
    @coder  = Code.new 
    @debug = false
  end

  def translate(file)
    @parser.load file
    first_pass
    second_pass
  end

  def first_pass
    line = 0
    
    while @parser.has_more_commands?
      @parser.advance
      puts "p1 code: #{@parser.current_line}" if @debug
      puts "command: #{@parser.command_type?} symbol: #{@parser.symbol}" if @debug
     
      if @parser.command_type? == :l_command
        @parser.add_label @parser.symbol, line  
      else
        line += 1
      end
    end

    puts @parser.sym_table.inspect if @debug
  end

  def second_pass
    @parser.reset_current
    while @parser.has_more_commands?
      @parser.advance
      puts "p2 code: #{@parser.current_line}" if @debug
      
      case @parser.command_type?
        when :a_command
          puts translate_a 
        when :c_command
          puts translate_c
      end
    end
  end

  def translate_a
    location = @parser.address 
    address = 0

    if @parser.is_symbol? location
      address = @parser.add_variable location  
    else
      address = location.to_i
    end
    
    '0' << ("%015d" % address.to_s(2))
  end

  def translate_c
    a    = @parser.a
    comp = @coder.comp @parser.comp
    dest = @coder.dest @parser.dest
    jump = @coder.jump @parser.jump

    "111#{a}#{comp}#{dest}#{jump}"
  end
  
end

if __FILE__== $0
  file = ARGV.first 
  assembler = Assembler.new
  #assembler.debug = true

  assembler.translate file
end
