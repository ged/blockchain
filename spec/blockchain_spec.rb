#!/usr/bin/env rspec -cfd

require_relative 'spec_helper'

require 'blockchain'


describe Blockchain do

	it "has a logger" do
		expect( described_class.logger ).to be_a( Loggability::Logger )
	end

end

