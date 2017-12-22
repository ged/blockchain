#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'block/proof_of_work'


describe Block::ProofOfWork do


	it "can find a valid proof" do
		result = described_class.find( 1121 )
		expect( result ).to be_an( Integer )
		expect( Digest::SHA2.hexdigest("1121:#{result}") ).to end_with( '0000' )
	end


	it "knows a valid proof when it sees one" do
		expect( described_class.valid_proof?( 8, 17639 ) ).to be_truthy
	end


end

