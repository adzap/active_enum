require "spec_helper"

describe ActiveEnum do

  describe ".define" do
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
  end

  describe ".setup" do
    before :all do
      @original = ActiveEnum.use_name_as_value
    end

    it 'should pass module into block as configuration object' do
      ActiveEnum.use_name_as_value.should be_false
      ActiveEnum.setup {|config| config.use_name_as_value = true }
      ActiveEnum.use_name_as_value.should be_true
    end
    
    after :all do
      ActiveEnum.use_name_as_value = @original
    end
  end

  describe ".extend_classes!" do
    it 'should add enumerate extensions to given classes' do
      ActiveEnum.extend_classes = [NotActiveRecord]

      NotActiveRecord.should_not respond_to(:enumerate)

      ActiveEnum.extend_classes!

      NotActiveRecord.should respond_to(:enumerate)
    end
  end

  it 'should use the memory store by default' do
    ActiveEnum.storage.should == :memory
  end

end
