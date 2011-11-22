require 'rubygems'
require 'tempfile'
require 'minitest/autorun'
$:.unshift File.expand_path("../../lib")
require 'dante'

## Kernel Extensions
require 'stringio'

module Kernel
  # Redirect standard out, standard error and the buffered logger for sprinkle to StringIO
  # capture_stdout { any_commands; you_want } => "all output from the commands"
  def capture_stdout
    return yield if ENV['DEBUG'] # Skip if debug mode

    out = StringIO.new
    $stdout = out
    $stderr = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end
end

# Process fixture
class TestingProcess
  attr_reader :tmp_path

  def initialize(name)
    @tmp_path = "/tmp/dante-#{name}.log"
  end # initialize

  def run_a!
    @tmp = File.new(@tmp_path, 'w')
    @tmp.print("Started")
    @tmp.close
  end # run_a!

  def run_b!
    begin
      @tmp = File.new(@tmp_path, 'w')
      @tmp.print "Started!!"
      sleep(100)
    rescue Dante::Runner::Abort
      @tmp.print "Abort!!"
      exit
    ensure
      @tmp.print "Closing!!"
      @tmp.close
    end
  end # run_b!
end # TestingProcess