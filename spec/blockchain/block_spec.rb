#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'blockchain/block'


describe Blockchain::Block do

	let( :transactions ) do
		[ {from: 'me', to: 'escrow'}, {from: 'escrow', to: 'you'}, {from: 'you', to: 'vault'} ]
	end

	let( :pow_strategy ) { Blockchain::ProofOfWork }

	let( :genesis_block ) { described_class.new(pow_strategy, []) }


	it "serializes and hashes its payload" do
		instance = described_class.new( pow_strategy, transactions, genesis_block )

		expect( instance.payload ).to be_a( String )
		expect( MessagePack.unpack(instance.payload) ).to be_an( Array ).and( all be_a(Hash) )
		expect( instance.payload_hash ).to eq( Digest::SHA2.hexdigest(instance.payload) )
	end


	it "provides a convenience method for deserializing its payload" do
		instance = described_class.new( pow_strategy, transactions, genesis_block )
		
		expect( instance.transactions ).to eq( transactions )
	end


	it "is frozen" do
		instance = described_class.new( pow_strategy, transactions, genesis_block )

		expect( instance ).to be_frozen
	end


	it "knows it is invalid if its payload hash has changed" do
		instance = described_class.new( pow_strategy, transactions, genesis_block )

		new_payload = MessagePack.pack([
			{from: 'me', to: 'escrow'},
			{from: 'escrow', to: 'you'},
			{from: 'you', to: 'attacker vault'}
		])
		forged = instance.dup
		forged.payload.replace( new_payload )

		expect( forged ).to_not be_valid
		expect( forged ).to_not have_valid_payload
	end


	it "knows it is invalid if its previous block has been changed" do
		block1 = genesis_block.create_next( *transactions )
		block2 = block1.create_next
		block3 = block2.create_next

		new_payload = MessagePack.pack([
			{from: 'me', to: 'escrow'},
			{from: 'escrow', to: 'you'},
			{from: 'you', to: 'attacker vault'}
		])
		forged_block1 = block1.dup
		forged_block1.payload.replace( new_payload )
		forged_block1.payload_hash.replace( Digest::SHA2.hexdigest(new_payload) )
		forged_block1.instance_variable_set( :@proof, forged_block1.send(:calculate_proof_of_work) )

		forged_block2 = block2.dup
		forged_block2.instance_variable_set( :@previous_block, forged_block1 )

		forged_block3 = block3.dup
		forged_block3.instance_variable_set( :@previous_block, forged_block2 )

		expect( forged_block1 ).to be_valid
		expect( forged_block2 ).to_not be_valid
		expect( forged_block2 ).to_not have_valid_previous_hash
	end


	it "calculates its index automatically" do
		block1 = genesis_block.create_next
		block2 = block1.create_next
		block3 = block2.create_next

		expect( block1.index ).to eq( 1 )
		expect( block2.index ).to eq( 2 )
		expect( block3.index ).to eq( 3 )
	end

end

