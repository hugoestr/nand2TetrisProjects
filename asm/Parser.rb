class Parser
  attr_reader  :a, :address, :current, :comp, :dest, :jump, :symbol, :sym_table

  def initialize
    @current = -1
    @code = []
    
    sym_table_reset 
    reset_mnemonics 
  end

  def load(file)
    code = File.readlines file
    reset code
  end

  def load_s(text)
    code = text.split 
    reset code
  end

  def current_line
    @code[@current] unless @current < 0
  end

  def has_more_commands?
    !@code.nil? && (@current + 1) < @code.length
  end

  def advance
      @current += 1
      reset_mnemonics 
      decode @code[@current]
  end

  def decode(input)
    line = clean input
    type = command_type line
    
    case type
    when :a_command, :l_command
      decode_al_command line
    when :c_command
      decode_c_command line
    end
  end

  def command_type?
    command_type @code[@current]
  end

  def command_type(input)
    line = clean input
    return :a_command if line =~ /@/ 
    return :l_command if line =~ /\(.*\)/ 

    :c_command 
  end

  def get_address(key)
    result = nil

    if @sym_table.include? key
      result = @sym_table[key]
    end

    result
  end

  def add_label(key, address)
    unless @sym_table.include? key
      @sym_table[key] = address 
    end
  end 
  
  def add_variable(key)
    result = nil

    unless @sym_table.include? key
      @sym_table[key] = @symbol_index
      result = @symbol_index
      @symbol_index += 1
    else
      result = get_address key
    end

    result
  end

  def reset_current
    @current = -1
  end

  def ready?
    !@code.nil?
  end

  def is_symbol?(input)
    result = false
    result = true if input =~ /^[^0-9][A-Za-z_$:\.0-9]+/
    result
  end

  private
  
  def decode_al_command(line)
    decoded =  line.match /[@\(](?<address>.*)\)?/
    @address = decoded[:address].gsub /\)$/ , '' 
    @symbol = @address if @address =~ /^[^0-9][A-Za-z_$:\.0-9]+/ 
  end

  def decode_c_command(line)
    decoded = line.match /(?<dest>^.*)=(?<comp>.*$)/ unless line.nil?

    if line =~ /;/
      decoded = line.match /(?<comp>^.*);(?<jump>.*$)/
    end

    if !decoded.nil?
      @comp = decoded[:comp] if decoded.names.include? 'comp'
      @jump = decoded[:jump] if decoded.names.include? 'jump'
      @dest = decoded[:dest] if decoded.names.include? 'dest'
    end

    set_a
  end

  def set_a
    unless @comp.nil?
      if @comp =~ /M/
        @a = '1'
      end
    end
  end

  def clean(line)
    temp = strip_comments line
    result = strip_space temp unless temp.nil?
  end

  def strip_comments(line)
    line.gsub /\/\/.*$/, '' unless line.nil?
  end

  def strip_space(line)
    line.gsub(/ /, '')
  end
  
  def reset(lines)
    no_comments = lines.select {|line| line !~ /^\/\//}
    @code = no_comments.select {|line| line !~ /^$/}
    @current = -1
    sym_table_reset
  end

  def sym_table_reset
    @symbol_index = 16
    
    @sym_table = {
      'SP'      => 0,
      'LCL'     => 1,
      'ARG'     => 2,
      'THIS'    => 3,
      'THAT'    => 4,
      'R0'      => 0,
      'R1'      => 1,
      'R2'      => 2,
      'R3'      => 3,
      'R4'      => 4,
      'R5'      => 5,
      'R6'      => 6,
      'R7'      => 7,
      'R8'      => 8,
      'R9'      => 9,
      'R10'     => 10,
      'R11'     => 11,
      'R12'     => 12,
      'R13'     => 13,
      'R14'     => 14,
      'R15'     => 15,
      'SCREEN'  => 16384,
      'KDB'     => 25576,
    }
  end
 
  def reset_mnemonics
    @symbol  = nil
    @comp = nil
    @jump = nil
    @dest = nil
    @a = '0'
  end
end


