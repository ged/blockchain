#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'blockchain/ledger'

describe Blockchain::Ledger do


	let( :instance ) { described_class.new }

	def valid_proof( ledger )
		return Blockchain::ProofOfWork.
			find( ledger.last_block.proof, ledger.last_block.previous_hash )	
	end

	def invalid_proof( ledger )
		return valid_proof( ledger ) - 1
	end


	it "is created with a valid genesis block" do
		expect( instance ).to be_valid
		expect( instance.last_block ).to be_a( Blockchain::Block )
		expect( instance.last_block.index ).to eq( 0 )
	end


	it "allows a block to be added for all current transactions" do
		expect {
			instance.add_transaction( from: 'me', to: 'you' )
			instance.add_block
		}.to change { instance.last_block }
		expect( instance ).to be_valid
	end


	it "isn't valid if any of the blocks are invalid" do
		instance.add_transaction( from: 'me', to: 'escrow' )
		instance.add_block
		instance.add_transaction( from: 'escrow', to: 'holding company' )
		instance.add_block
		instance.add_transaction( from: 'holding company', to: 'you' )
		instance.add_block
		instance.add_transaction( from: 'you', to: 'vault' )
		instance.add_block

		new_payload = MessagePack.pack([ {from: 'holding company', to: 'attacker'} ])

		forged_block1 = instance.chain[3].dup
		forged_block1.payload.replace( new_payload )
		forged_block1.payload_hash.replace( Digest::SHA2.hexdigest(new_payload) )
		forged_block1.instance_variable_set( :@proof, forged_block1.send(:calculate_proof_of_work) )

		forged_block2 = instance.chain[4].dup
		forged_block2.instance_variable_set( :@previous_block, forged_block1 )

		instance.chain[ 3, 2 ] = [ forged_block1, forged_block2 ]

		expect( instance ).to_not be_valid
		expect( instance.invalid_blocks ).to include( forged_block2 )
	end


	it "yields to an optional transaction callback when creating a block" do
		expect {
			instance.add_block do
				instance.add_transaction( from: 'me', to: 'you' )
			end
		}.to change { instance.last_block }
		expect( instance ).to be_valid
		expect( instance.last_block.transactions ).to eq( [{from: 'me', to: 'you'}] )
	end

end

