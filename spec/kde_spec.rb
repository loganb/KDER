require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")


describe Kder do
  before do
    @test_arr =10_000.times.map{ rand(100)}
  end
  it "gives a kde for a small array" do 
    resp = Kder.kde([1,2,3] )#@test_arr, Bandwidth.silverman(@test_arr, @test_arr.standard_deviation))
    resp.size.should eq(2)
    # TODO expand the tests
  end
  it "gives a kde for a large array" do 
    resp = Kder.kde @test_arr
    resp.size.should eq(2)
    # TODO expand the tests
  end
  context "Singlular value cases" do 
    before(:each) do
      @source = Array.new(20,2.0)
      @result = Kder.kde(@source)
    end
    it "returns a valid KDE" do 
      @result.first.size.should be > 2
      max = @result.first.max
      min = @result.first.min
      (max-min).should be > 0.0
    end
  end

  describe ".kdevec" do
    it "is identical to .kde for the unit vector" do
      arr = [1,2,3]
      expect(described_class.kde(arr,0.1)).to eq(described_class.kdevec(arr.map { |a| [a, 1] }, 0.1))
    end
  end

  describe ".kdemultivec" do
    it "is identical to .kdevec for the unit vector" do
      arr = [[1, 1],[2, 1],[3, 1]]
      expect(described_class.kdevec(arr,0.1)).to eq(described_class.kdemultivec(arr, 0.1))
    end
  end
end
