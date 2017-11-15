require 'spec_helper'

describe Bandwidth do 
  before :each do 
    @test_arr = 1e5.to_i.times.map {rand(100)}
  end
  it "returns a value" do 
    bw = Bandwidth.silverman(@test_arr, @test_arr.standard_deviation)
    expect(bw).to be_a(Float)
    expect(bw).to be_within(0.15).of(3.1)
  end
end

