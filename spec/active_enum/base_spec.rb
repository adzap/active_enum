require "spec_helper"

describe ActiveEnum::Base do

  describe ".store" do
    it 'should load the storage class instance using the storage setting' do
      ActiveEnum::Base.send(:store).should be_instance_of(ActiveEnum::Storage::MemoryStore)
    end
  end

  describe ".enum_classes" do
    it 'should return all enum classes defined use class definition' do
      ActiveEnum.enum_classes = []
      class NewEnum < ActiveEnum::Base; end
      ActiveEnum.enum_classes.should == [NewEnum]
    end

    it 'should return all enum classes defined using define block' do
      ActiveEnum.enum_classes = []
      ActiveEnum.define do
        enum(:bulk_new_enum) { }
      end
      ActiveEnum.enum_classes.should == [BulkNewEnum]
    end
  end

  describe ".all" do
    it 'should return an empty array when no values defined' do
      define_enum.all.should == []
    end

    it 'should return an array of arrays with all values defined as [id, name]' do
      enum = define_enum do
        value :name => 'Name 1'
        value :name => 'Name 2'
      end
      enum.all.should == [[1,'Name 1'], [2, 'Name 2']]
    end
  end

  describe ".value" do
    it 'should allow me to define a value with an id and name' do
      enum = define_enum do
        value :id => 1, :name => 'Name'
      end
      enum.all.should == [[1,'Name']]
    end

    it 'should allow me to define a value with a name only' do
      enum = define_enum do
        value :name => 'Name'
      end
      enum.all.should == [[1,'Name']]
    end

    it 'should allow me to define a value as hash with id as key and name as value' do
      enum = define_enum do
        value 1 => 'Name'
      end
      enum.all.should == [[1,'Name']]
    end

    it 'should allow to define meta data value with extra key value pairs' do
      enum = define_enum do
        value :id => 1, :name => 'Name', :description => 'extra'
      end
      enum.all.should == [[1,'Name',{:description => 'extra'}]]
    end

    it 'should increment value ids when defined without ids' do
      enum = define_enum do
        value :name => 'Name 1'
        value :name => 'Name 2'
      end
      enum.all.should == [[1,'Name 1'], [2, 'Name 2']]
    end

    it 'should raise error if the id is a duplicate' do
      expect {
        define_enum do
          value :id => 1, :name => 'Name 1'
          value :id => 1, :name => 'Name 2'
        end
      }.to raise_error(ActiveEnum::DuplicateValue)
    end

    it 'should raise error if the name is a duplicate' do
      expect {
        define_enum do
          value :id => 1, :name => 'Name'
          value :id => 2, :name => 'Name'
        end
      }.to raise_error(ActiveEnum::DuplicateValue)
    end
  end

  describe ".meta" do
    it 'should return meta values hash for a given index value' do
      enum = define_enum do
        value :id => 1, :name => 'Name', :description => 'extra'
      end
      enum.meta(1).should == {:description => 'extra'}
    end

    it 'should return empty hash for index with no meta defined' do
      enum = define_enum do
        value :id => 1, :name => 'Name'
      end
      enum.meta(1).should == {}
    end

  end

  context "sorting" do
    it 'should return values ascending by default' do
      enum = define_enum do
        value :id => 2, :name => 'Name 2'
        value :id => 1, :name => 'Name 1'
      end
      enum.all.should == [[1,'Name 1'], [2, 'Name 2']]
    end

    it 'should return sorted values by id using order setting' do
      enum = define_enum do
        order :desc
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      enum.all.should == [[2, 'Name 2'], [1,'Name 1']]
    end

    it 'should return sorted values by id using order setting' do
      enum = define_enum do
        order :natural
        value :id => 3, :name => 'Name 3'
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      enum.all.should == [[3,'Name 3'], [1,'Name 1'], [2, 'Name 2']]
    end
  end

  describe ".ids" do
    it 'should return array of ids' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      enum.ids.should == [1,2]
    end
  end

  describe ".names" do
    it 'should return array of names' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      enum.names.should == ['Name 1', 'Name 2']
    end
  end

  context "element reference method" do
    context 'integer ids' do
      let(:enum) {
        define_enum do
          value :id => 1, :name => 'Name 1'
          value :id => 2, :name => 'Name 2'
        end
      }

      it 'should return name when given an id' do
        enum[1].should == 'Name 1'
      end

      it 'should return id when given a name' do
        enum['Name 1'].should == 1
      end

      it 'should return id when given a symbol of the name' do
        enum[:Name_1].should == 1
        enum[:name_1].should == 1
      end
    end
  end

  describe ".include?" do
    let(:enum) {
      define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
    }

    it "should return true if value is a fixnum and matches an id" do
      enum.include?(1).should be_true
    end

    it "should return false if value is a fixnum and does not match an id" do
      enum.include?(3).should be_false
    end

    it "should return true if value is a string and matches a name" do
      enum.include?('Name 1').should be_true
    end

    it "should return false if value is a string and does not match a name" do
      enum.include?('No match').should be_false
    end
  end

  describe ".to_select" do
    it 'should return array for select helpers' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      enum.to_select.should == [['Name 1',1], ['Name 2',2]]
    end

    it 'should return array sorted using order setting' do
      enum = define_enum do
        order :desc
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      enum.to_select.should == [['Name 2',2], ['Name 1',1]]
    end
  end

  def define_enum(&block)
    Class.new(ActiveEnum::Base, &block)
  end

end
