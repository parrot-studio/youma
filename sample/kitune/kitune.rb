# coding: utf-8

require 'windstorm'

TABLE = <<EOS
---
:pinc:
- しっぽ
:pdec:
- おめめ
:inc:
- きつね
- かわいい
:dec:
- もふもふ
:out:
- ！
:inp:
- ？
:jmp:
- あぁぁぁぁ
:ret:
- うわぁぁぁぁ
:clip:
- もえるぅぅぅぅ
:paste:
- かわぇぇぇぇ

EOS

DEFALUT_PARAMS =<<EOS
--- {}

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
