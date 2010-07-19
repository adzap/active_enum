require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Bulk enum definitions" do

  it 'should define enum constants using block' do
    ActiveEnum.define do
      enum(:foo) do
        value :id => 1, :name => 'Foo 1'
      end

      enum(:bar) do
        value :id => 1, :name => 'Bar 1'
      end
    end

    Foo.all.should == [[1,'Foo 1']]
    Bar.all.should == [[1,'Bar 1']]
  end

  it 'should use the memory store by default' do
    ActiveEnum.storage.should == :memory
  end

end
