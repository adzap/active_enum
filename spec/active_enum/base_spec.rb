require "spec_helper"

describe ActiveEnum::Base do

  describe ".store" do
    it 'should load the storage class instance using the storage setting' do
      expect(ActiveEnum::Base.send(:store)).to be_instance_of(ActiveEnum::Storage::MemoryStore)
    end
  end

  describe ".enum_classes" do
    it 'should return all enum classes defined use class definition' do
      ActiveEnum.enum_classes = []
      class NewEnum < ActiveEnum::Base; end
      expect(ActiveEnum.enum_classes).to eq([NewEnum])
    end

    it 'should return all enum classes defined using define block' do
      ActiveEnum.enum_classes = []
      ActiveEnum.define do
        enum(:bulk_new_enum) { }
      end
      expect(ActiveEnum.enum_classes).to eq([BulkNewEnum])
    end
  end

  describe ".values" do
    it 'should return an empty array when no values defined' do
      expect(define_enum.values).to eq([])
    end

    it 'should return an array of arrays with all values defined as [id, name]' do
      enum = define_enum do
        value :name => 'Name 1'
        value :name => 'Name 2'
      end
      expect(enum.values).to eq([[1,'Name 1'], [2, 'Name 2']])
    end
  end

  describe ".value" do
    it 'should allow me to define a value with an id and name' do
      enum = define_enum do
        value :id => 1, :name => 'Name'
      end
      expect(enum.values).to eq([[1,'Name']])
    end

    it 'should allow me to define a value with a name only' do
      enum = define_enum do
        value :name => 'Name'
      end
      expect(enum.values).to eq([[1,'Name']])
    end

    it 'should allow me to define a value as hash with id as key and name as value' do
      enum = define_enum do
        value 1 => 'Name'
      end
      expect(enum.values).to eq([[1,'Name']])
    end

    it 'should allow to define meta data value with extra key value pairs' do
      enum = define_enum do
        value :id => 1, :name => 'Name', :description => 'extra'
      end
      expect(enum.values).to eq([[1,'Name',{:description => 'extra'}]])
    end

    it 'should increment value ids when defined without ids' do
      enum = define_enum do
        value :name => 'Name 1'
        value :name => 'Name 2'
      end
      expect(enum.values).to eq([[1,'Name 1'], [2, 'Name 2']])
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
      expect(enum.meta(1)).to eq({:description => 'extra'})
    end

    it 'should return empty hash for index with no meta defined' do
      enum = define_enum do
        value :id => 1, :name => 'Name'
      end
      expect(enum.meta(1)).to eq({})
    end

  end

  context "sorting" do
    it 'should return values ascending by default' do
      enum = define_enum do
        value :id => 2, :name => 'Name 2'
        value :id => 1, :name => 'Name 1'
      end
      expect(enum.values).to eq([[1,'Name 1'], [2, 'Name 2']])
    end

    it 'should return sorted values by id using order setting' do
      enum = define_enum do
        order :desc
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      expect(enum.values).to eq([[2, 'Name 2'], [1,'Name 1']])
    end

    it 'should return sorted values by id using order setting' do
      enum = define_enum do
        order :natural
        value :id => 3, :name => 'Name 3'
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      expect(enum.values).to eq([[3,'Name 3'], [1,'Name 1'], [2, 'Name 2']])
    end
  end

  describe ".ids" do
    it 'should return array of ids' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      expect(enum.ids).to eq([1,2])
    end
  end

  describe ".names" do
    it 'should return array of names' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      expect(enum.names).to eq(['Name 1', 'Name 2'])
    end
  end

  context "element reference method" do
    let(:enum) {
      define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
    }

    it 'should return name when given an id' do
      expect(enum[1]).to eq('Name 1')
    end

    it 'should return id when given a name' do
      expect(enum['Name 1']).to eq(1)
    end

    it 'should return id when given a symbol of the name' do
      expect(enum[:Name_1]).to eq(1)
      expect(enum[:name_1]).to eq(1)
    end

    context "for missing value" do
      it "should return nil for missing id" do
        expect(enum['Not a value']).to eq nil
      end

      it "should return nil for missing name" do
        expect(enum[0]).to eq nil
      end

      context "with raise_on_not_found" do
        with_config :raise_on_not_found, true

        it "should raise ActiveEnum::NotFound for missing id" do
          expect { enum['Not a value'] }.to raise_error(ActiveEnum::NotFound)
        end

        it "should raise ActiveEnum::NotFound for missing name" do
          expect { enum[0] }.to raise_error(ActiveEnum::NotFound)
        end
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
      expect(enum.include?(1)).to be_truthy
    end

    it "should return false if value is a fixnum and does not match an id" do
      expect(enum.include?(3)).to be_falsey
    end

    it "should return true if value is a string and matches a name" do
      expect(enum.include?('Name 1')).to be_truthy
    end

    it "should return false if value is a string and does not match a name" do
      expect(enum.include?('No match')).to be_falsey
    end
  end

  describe ".to_select" do
    it 'should return array for select helpers' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      expect(enum.to_select).to eq([['Name 1',1], ['Name 2',2]])
    end

    it 'should return array sorted using order setting' do
      enum = define_enum do
        order :desc
        value :id => 1, :name => 'Name 1'
        value :id => 2, :name => 'Name 2'
      end
      expect(enum.to_select).to eq([['Name 2',2], ['Name 1',1]])
    end
  end

  describe ".to_grouped_select" do
    it 'should return array for grouped select helpers grouped by meta key value' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1', :category => 'Foo'
        value :id => 2, :name => 'Name 2', :category => 'Bar'
      end

      expect(enum.to_grouped_select(:category)).to eq([
        [ 'Foo', [ ['Name 1',1] ] ],
        [ 'Bar', [ ['Name 2',2] ] ]
      ])
    end

    it 'should group any value missing the group_by key by nil' do
      enum = define_enum do
        value :id => 1, :name => 'Name 1', :category => 'Foo'
        value :id => 2, :name => 'Name 2'
      end

      expect(enum.to_grouped_select(:category)).to eq([
        [ 'Foo', [ ['Name 1',1] ] ],
        [ nil, [ ['Name 2',2] ] ]
      ])
    end
  end

  def define_enum(&block)
    Class.new(ActiveEnum::Base, &block)
  end

end
