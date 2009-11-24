require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveEnum::Base do
  it 'should return empty array from :all method when no values defined' do
    ActiveEnum.enum_classes = []
    class NewEnum < ActiveEnum::Base
    end
    ActiveEnum.enum_classes.should == [NewEnum]
  end

  it 'should return empty array from :all method when no values defined' do
    define_enum.all.should == []
  end

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

  it 'should increment value ids when defined without ids' do
    enum = define_enum do
      value :name => 'Name 1'
      value :name => 'Name 2'
    end
    enum.all.should == [[1,'Name 1'], [2, 'Name 2']]
  end

  it 'should raise error is the id is a duplicate' do
    lambda do
      define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 1, :name => 'Name 2'
      end
    end.should raise_error(ActiveEnum::DuplicateValue)
  end

  it 'should raise error is the name is a duplicate' do
    lambda do
      define_enum do
        value :id => 1, :name => 'Name'
        value :id => 2, :name => 'Name'
      end
    end.should raise_error(ActiveEnum::DuplicateValue)
  end

  it 'should return sorted values by id from :all' do
    enum = define_enum do
      value :id => 2, :name => 'Name 2'
      value :id => 1, :name => 'Name 1'
    end
    enum.all.first[0].should == 1
  end

  it 'should return sorted values by id using order setting from :all' do
    enum = define_enum do
			order :desc
      value :id => 1, :name => 'Name 1'
      value :id => 2, :name => 'Name 2'
    end
    enum.all.first[0].should == 2
  end

  it 'should return array of ids' do
    enum = define_enum do
      value :id => 1, :name => 'Name 1'
      value :id => 2, :name => 'Name 2'
    end
    enum.ids.should == [1,2]
  end

  it 'should return array of names' do
    enum = define_enum do
      value :id => 1, :name => 'Name 1'
      value :id => 2, :name => 'Name 2'
    end
    enum.names.should == ['Name 1', 'Name 2']
  end

  describe "element reference method" do

    it 'should return name when given an id' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      enum[1].should == 'Name 1'
    end

    it 'should return id when given a name' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      enum['Name 1'].should == 1
    end

    it 'should return id when given a symbol of the name' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      enum[:Name_1].should == 1
      enum[:name_1].should == 1
    end

  end

  it 'should return array for select helpers from to_select' do
    enum = define_enum do
      value :id => 1, :name => 'Name 1'
      value :id => 2, :name => 'Name 2'
    end
    enum.to_select.should == [['Name 1',1], ['Name 2',2]]
  end

  it 'should return array sorted using order setting from to_select' do
    enum = define_enum() do
			order :desc
      value :id => 1, :name => 'Name 1'
      value :id => 2, :name => 'Name 2'
    end
    enum.to_select.should == [['Name 2',2], ['Name 1',1]]
  end

  def define_enum(&block)
    Class.new(ActiveEnum::Base, &block)
  end

end
