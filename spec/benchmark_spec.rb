require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")


describe Kder do
  context "BENCHMARKING" do 
    require 'ruby-prof'
    before do
      @test_arr =10_000.times.map{ rand(100)}
      @size = 1_000
    end
    skip "gives a kde for a large array" do 
      pending("does not appear to do anything")
      resp = Kder.kde @test_arr
      resp.size.should eq(2)
      # TODO expand the tests
    end
    skip "base time for an array of #{@times}" do 
      pending("does not appear to do anything")
      @test_arr = @size.times.map{ rand(100)}
      time = Time.now
      resp = Kder.kde @test_arr
      puts "Time passed: #{Time.now - time}"
      # p resp
    end
    skip "PROFILES a KDE for an array of #{@times}" do 
      pending("doesn't test anything")
      @test_arr = @size.times.map{ rand(100)}
      result = RubyProf.profile do 
        resp = Kder.kde @test_arr
      end
      file = "ruby_profile_kde_#{Time.now.to_i}.html"
      File.open(file, 'w') do |io|
        printer = RubyProf::GraphHtmlPrinter.new(result)
        printer.print(io, {})
      end
    end
  end # BENCHMARKING
end

