# coding: utf-8
require 'bundler/setup'
require 'fileutils'
require 'windstorm'

def valid_path?(path)
  return false unless path
  return false unless File.exist?(path)
  true
end

def valid_file?(file)
  return false unless valid_path?(file)
  return false unless File.file?(file)
  true
end

desc 'help : tasks help'
task :help do
  puts <<-EOS
tasks help:
test   : test execute with define yaml file and source file
  rake test:[each task name] define_file source_file [-- opts]
create : create [ruby source | executable] file
  rake create:[source | execute] language_name define_file [-- opts]
sample : sample execute
  rake sample:[each sample name]

more helps : rake [test | create | sample]:help
  EOS
end

namespace :test do

  args = lambda do
    _args = ARGV.dup
    _args.shift # task name

    files = []
    params = {}
    _args.each do |a|
      case a
      when '-l', '--loose'
        params[:loose] = true
      when '-d', '--debug'
        params[:debug] = true
      else
        files << a if valid_file?(a)
      end
    end
    {:file => files, :params => params}
  end.call

  desc 'test : help test options'
  task :help do
    puts <<-EOS
rake test:[each task name] define_file source_file [-- opts]
opts:
  -d, --debug : debug mode
  -l, --loose : loose mode (loose check on execute)
    EOS
  end

  desc 'test : filter commands words from source'
  task :filter do
    files = args[:file]
    ex = Windstorm::Executor.create_from_file(files.first)
    p ex.filter_from_file(files.last)
    exit
  end

  desc 'test : build commands list from source'
  task :build do
    files = args[:file]
    ex = Windstorm::Executor.create_from_file(files.first)
    p ex.build_from_file(files.last)
    exit
  end

  desc 'test : debug execute from source'
  task :debug do
    files = args[:file]
    ex = Windstorm::Executor.create_from_file(files.first)
    puts ex.debug_execute_from_file(files.last, args[:params])
    exit
  end

  desc 'test : execute from source'
  task :execute do
    files = args[:file]
    ex = Windstorm::Executor.create_from_file(files.first)
    puts ex.execute_from_file(files.last, args[:params])
    exit
  end

end

namespace :create do

  def parse_args
    _args = ARGV.dup
    _args.shift # task name

    name = _args.shift
    raise 'invalid name (you can use [_0-9a-zA-Z])' unless (name && name.match(/\A[_0-9a-zA-Z]+\Z/))
    dfile = _args.shift
    raise 'define file not found' unless valid_file?(dfile)

    expect = nil
    ruby_path = nil
    output_path = nil
    params = {}
    _args.each do |a|
      if expect
        case expect
        when :ruby
          raise "path not found => #{a}" unless valid_file?(a)
          ruby_path = a
        when :output
          raise "path not found => #{a}" unless valid_path?(a)
          output_path = a
        end
        expect = nil
      else
        case a
        when '-d', '--debug'
          params[:debug] = true
        when '-l', '--loose'
          params[:loose] = true
        when '-o', '--output-path'
          expect = :output
        when '-r', '--ruby-path'
          expect = :ruby
        end
      end
    end

    output_path ||= lambda do
      path = File.join(File.dirname(__FILE__), 'bin')
      FileUtils.mkdir(path) unless File.exist?(path)
      path
    end.call

    ruby_path ||= lambda do
      path = File.join(RbConfig::CONFIG['bindir'], 'ruby')
      raise "you need -r/--ruby-path option : ruby path not found => #{path}" unless File.exist?(path)
      path
    end.call

    {
      :name => name,
      :dfile => dfile,
      :params => params,
      :ruby => ruby_path,
      :output => output_path
    }
  end

  def create_source(args)
    tf = File.join(File.dirname(__FILE__), 'tmpl.rb')
    raise 'tmpl not found' unless valid_file?(tf)
    tmpl = File.read(tf)
    table = YAML.load(File.read(args[:dfile]))
    source = tmpl.gsub('_*_TABLE_*_', table.to_yaml)
    source.gsub!('_*_PARAMS_*_', args[:params].to_yaml)

    source_path = File.join(args[:output], "#{args[:name]}.rb")
    File.open(source_path, 'w') do |f|
      f.puts source
    end
    raise "source create failed => #{source}" unless valid_file?(source_path)

    source_path
  end

  desc 'create : help create options'
  task :help do
    puts <<-"EOS"
rake create:[source | exec] name define_file [-- opts]
opts:
  -d, --debug : debug mode is default
  -l, --loose : loose mode is default
  -o [path], --output-path [path] : output path, already exists
    (default : #{File.join(File.dirname(__FILE__), 'bin')})
  -r [path], --ruby-path [path]   : executable ruby path
    (default : #{File.join(RbConfig::CONFIG['bindir'], 'ruby')})
    EOS
  end

  desc 'create : ruby source file'
  task :source do
    path = create_source(parse_args)
    puts "source created : #{path}"
    exit
  end

  desc 'create : executable file'
  task :exec do
    args = parse_args
    output = File.join(args[:output], args[:name])
    source = create_source(args)
    raise "source create failed => #{source}" unless valid_file?(source)

    File.open(output, 'w') do |f|
      f.puts %Q(#! #{args[:ruby]})
      f.puts File.read(source)
    end
    raise "file create failed => #{output}" unless valid_file?(output)
    File.unlink(source)

    FileUtils.chmod(0755, output)
    puts "executable file created : #{output}"
    exit
  end

end

namespace :sample do

  def sample_execute(name)
    name = name.to_s
    sample_path = File.join(File.dirname(__FILE__), 'sample', name)
    exec = File.join(sample_path, "#{name}.rb")
    define = File.join(sample_path, "#{name}.yml")
    source = File.join(sample_path, "hello.#{name}")
    opts = (ARGV.include?('-d') ? '-d' : nil)

    puts 'define:'
    puts File.read(define)
    puts '------------------------'
    puts 'source:'
    puts File.read(source)
    puts '------------------------'
    puts 'result:'
    puts %x(ruby #{exec} #{source} #{opts})
    exit
  end

  samples = [:bf, :gunma, :shoborn, :suzuha, :kitune, :miko, :qb, :misa, :jojo]
  samples.each do |s|
    desc "sample : execute '#{s} hello.#{s}'"
    task s do
      sample_execute(s)
    end
  end

  desc "sample : each sample's explain"
  task :help do
    puts <<-EOS
execute samples:
  bf      : BrainF**k (pure)
  gunma   : language for Pref. Gunma
  shoborn : language of Ascii Art (AA), like '(´･ω･`)'
  kitune  : language for kitune-san-lovers
  miko    : language of miko, use only 'm i k o M I K O ! ?'
  suzuha  : language like Suzuha Amane's letter
            (from 'STEINS; GATE' : http://steinsgate.jp/)
  qb      : language like QB's words
            (from 'Madoka-Magica' : http://www.madoka-magica.com/)
  misa    : language like Misakura's words
            (Original : http://homepage2.nifty.com/kujira_niku/okayu/misa.html)
  jojo    : language like JOJO'S BIZARRE ADVENTURE
            (Original : http://kmaebashi.com/zakki/lang0003.html)
    EOS
  end

end

task :default => :help
