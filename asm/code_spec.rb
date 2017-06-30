require './code'

describe Code do
  before :each do
    @code = Code.new
  end

  context 'dest' do
   
    it 'should return 000 when input is nil' do
      result = @code.dest nil  
      expect(result).to eq '000'
    end

    it 'should return correct data' do
       input = {
        'M'   => '001',
        'D'   => '010',
        'A'   => '100',
        'MD'  => '011',
        'AM'  => '101',
        'AD'  => '110',
        'AMD' => '111'
      }
      
      input.each do |input, expected|
        result = @code.dest input
        expect(result).to eq expected
      end 
    end
  end

  context 'jump' do
   it 'should return 000 when input is nil' do
        result = @code.jump nil  
        expect(result).to eq '000'
      end

      it 'should return correct data' do
         input = {
          'JGT' => '001',
          'JEQ' => '010',
          'JGE' => '100',
          'JLT' => '011',
          'JNE' => '101',
          'JLE' => '110',
          'JMP' => '111'
        }
        
        input.each do |input, expected|
          result = @code.jump input
          expect(result).to eq expected
        end 
      end
  end

  context 'comp' do
   it 'should return correct data' do
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
      
     codes.each do |input, expected|
          result = @code.comp input
          expect(result).to eq expected
      end 
    end 

  it 'should handle M symbols' do
      codes = {
       '0'    => '101010',
       '1'    => '111111',
       '-1'   => '111010',
       'D'    => '001100',
       'M'    => '110000',
       '!D'   => '001101',
       '!M'   => '110001',
       '-D'   => '001111',
       '-M'   => '110011',
       'D+1'  => '011111',
       'M+1'  => '110111',
       'D-1'  => '001110',
       'M-1'  => '110010',
       'D+M'  => '000010',
       'D-M'  => '010011',
       'M-D'  => '000111',
       'D&M'  => '000000',
       'D|M'  => '010101'
    }
    
    codes.each do |input, expected|
      result = @code.comp input
      expect(result).to eq expected
    end 

  end
  end 
end
