require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe SimpleColumnSearch do
  before(:each) do
    Person.delete_all
    
    @jqr = Person.create(:first_name => 'Elijah', :last_name => 'Miller', :alias => 'jqr')
    @iggzero = Person.create(:first_name => 'Kristopher', :last_name => 'Chambers', :alias => 'iggzero')
    @mogis = Person.create(:first_name => 'Brent', :last_name => 'Wooden', :alias => 'mogis')
    @shakewell = Person.create(:first_name => 'Amanda', :last_name => 'Miller', :alias => 'shakewell')
    
    @users = [@jqr, @iggzero, @mogis, @shakewell]
  end

  it "should not allow SQL injection" do
    Person.search(%q{'"`}).should == []
  end

  it "should get an error when the match type is unrecognized" do
    lambda {
      Person.simple_column_search :first_name, :name => :bad_match_type, :match => :typo_city
    }.should raise_error(SimpleColumnSearch::InvalidMatcher)
  end

  describe "single column search default match" do
    it "should find someone by exact first name" do
      Person.search_first_name_default_match('Elijah').should == [@jqr]
    end
    
    it "should find someone by start of first name" do
      Person.search_first_name_default_match('Eli').should == [@jqr]
    end
    
    it "should not find someone by middle of first name" do
      Person.search_first_name_default_match('lija').should == []
    end
    
    it "should not find someone by end of first name" do
      Person.search_first_name_default_match('jah').should == []
    end
  end
  
  describe "single column search exact match" do
    it "should find someone by exact first name" do
      Person.search_first_name_exact('Elijah').should == [@jqr]
    end
      
    it "should not find someone by start of first name" do
      Person.search_first_name_exact('Eli').should == []
    end
      
    it "should not find someone by middle of first name" do
      Person.search_first_name_exact('lija').should == []
    end
      
    it "should not find someone by end of first name" do
      Person.search_first_name_exact('jah').should == []
    end
  end
  
  describe "single column search start match" do
    it "should find someone by exact first name" do
      Person.search_first_name_start('Elijah').should == [@jqr]
    end
      
    it "should find someone by start of first name" do
      Person.search_first_name_start('Eli').should == [@jqr]
    end
      
    it "should not find someone by middle of first name" do
      Person.search_first_name_start('lija').should == []
    end
      
    it "should not find someone by end of first name" do
      Person.search_first_name_start('jah').should == []
    end
  end
  
  describe "single column search middle match" do
    it "should find someone by exact first name" do
      Person.search_first_name_middle('Elijah').should == [@jqr]
    end
      
    it "should find someone by start of first name" do
      Person.search_first_name_middle('Eli').should == [@jqr]
    end
      
    it "should find someone by middle of first name" do
      Person.search_first_name_middle('lija').should == [@jqr]
    end
      
    it "should find someone by end of first name" do
      Person.search_first_name_middle('jah').should == [@jqr]
    end
  end
  
  describe "single column search end match" do
    it "should find someone by exact first name" do
      Person.search_first_name_end('Elijah').should == [@jqr]
    end
      
    it "should not find someone by start of first name" do
      Person.search_first_name_end('Eli').should == []
    end
      
    it "should not find someone by middle of first name" do
      Person.search_first_name_end('lija').should == []
    end
      
    it "should find someone by end of first name" do
      Person.search_first_name_end('jah').should == [@jqr]
    end
  end

  describe "multi column search" do
    it "should find someone by first name" do
      Person.search('Eli').should == [@jqr]
    end
      
    it "should find someone by last name" do
      Person.search('Chambers').should == [@iggzero]
    end
      
    it "should find someone by alias" do
      Person.search('mogis').should == [@mogis]
    end
    
    
    it "should not be case sensitive" do
      Person.search('amanda').should == [@shakewell]
    end
    
    
    it "should find multiple people by last name" do
      Person.search('Miller').should == [@jqr, @shakewell]
    end
    
    
    it "should limit results by all terms" do
      Person.search('E Miller').should == [@jqr]
      Person.search('K C').should == [@iggzero]
      Person.search('Br Wo mo').should == [@mogis]
      Person.search('shake Miller').should == [@shakewell]
    end
  end

  describe "query escaping" do
    it "should escape the query string when asked so" do
      Person.search_escape_query("\tmillers\n").should == [@jqr, @shakewell]
    end

    it "should fail without escaping" do
      Person.search("\tmillers\n").should == []
    end
  end

  describe "multi column search with lambda match" do
    it "should find someone by first name (start match)" do
      Person.search_match_lambda('Eli').should == [@jqr]
    end
  
    it "should find someone by last name if it's exact match" do
      Person.search_match_lambda('Miller').should == [@jqr, @shakewell]
    end

    it "should not find someone by last name unless it's exact match" do
      Person.search_match_lambda('Mill').should == []
    end
  end
end
