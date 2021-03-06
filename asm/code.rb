class Code
  def dest(input)
    result = 0
    m = 1; d = 2; a = 4

    result = result | m if input =~ /M/
    result = result | d if input =~ /D/
    result = result | a if input =~ /A/
   
    "%03d" % result.to_s(2)
  end


  def jump(input)
    codes = {
          'JGT' => '001',
          'JEQ' => '010',
          'JGE' => '011',
          'JLT' => '100',
          'JNE' => '101',
          'JLE' => '110',
          'JMP' => '111'
    }
    
    (input.nil? || !codes.keys.include?(input)) ?
     '000' :
     codes[input] 
  end

  def comp(input)
    key = input.gsub /M/, 'A'

    codes = {
       '0'    => '101010',
       '1'    => '111111',
       '-1'   => '111010',
       'D'    => '001100',
       'A'    => '110000',
       '!D'   => '001101',
       '!A'   => '110001',
       '-D'   => '001111',
       '-A'   => '110011',
       'D+1'  => '011111',
       'A+1'  => '110111',
       'D-1'  => '001110',
       'A-1'  => '110010',
       'D+A'  => '000010',
       'D-A'  => '010011',
       'A-D'  => '000111',
       'D&A'  => '000000',
       'D|A'  => '010101'
    }

    codes[key]
  end

end
