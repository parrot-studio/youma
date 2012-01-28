# coding: utf-8

# Copyright (C) 2005 Okayu Punch
# License & Original : http://homepage2.nifty.com/kujira_niku/okayu/misa.html

require 'windstorm'

TABLE = <<EOS
---
:pinc:
- ! '>'
- →
- ～
- ー
:pdec:
- <
- ←
- ★
- ☆
:inc:
- +
- あ
- ぁ
- お
- ぉ
:dec:
- ! '-'
- っ
- ッ
:out:
- .
- ！
:inp:
- ! ','
- ？
:jmp:
- ! '['
- 「
- 『
:ret:
- ! ']'
- 」
- 』

EOS

DEFALUT_PARAMS =<<EOS
---
:loose: true

EOS

def puts_help
  puts <<-"EOS"
usage:
  #{File.basename(__FILE__)} [opts] file
  #{File.basename(__FILE__)} [opts] [-e|--eval] code
opts:
  -h, --help   : print help
  -i, --ignore : ignore defalut params
  -d, --debug  : debug mode
  -l, --loose  : loose mode (loose check on execute)
  -f, --flash  : frash mode (each 'output' instantly)
  -s [size], --size [size] : buffer size
  -e [code], --eval [code] : one liner execute
  EOS
end

# arg parse
params = YAML.load(DEFALUT_PARAMS) || {}
ig = [ARGV.delete('-i'), ARGV.delete('--ignore')].compact
params = {} unless ig.empty?

expect = nil
file = nil
code = nil
ARGV.each do |arg|
  if expect
    case expect
    when :eval
      code = arg
    when :size
      params[:size] = arg.to_i
    end
    expect = nil
  else
    case arg
    when '-h', '--help'
      puts_help
      exit
    when '-l', '--loose'
      params[:loose] = true
    when '-d', '--debug'
      params[:debug] = true
    when '-f', '--flash'
      params[:flash] = true
    when '-e', '--eval'
      expect = :eval
    when '-s', '--size'
      expect = :size
    else
      file = arg
    end
  end
end
abort 'args parse error' if expect

# execute
begin
  ex = Windstorm::Executor.create_from_table(YAML.load(TABLE))
  rsl = case
  when code
    ex.execute(code, params)
  when file
    ex.execute_from_file(file, params)
  else
    abort 'source not found'
  end
  puts rsl unless params[:flash]
rescue => ex
  params[:debug] ? (raise ex) : (abort ex.message)
end

exit
