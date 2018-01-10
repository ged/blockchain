#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'blockchain/currency'


describe Blockchain::Currency do


	UUID_PATTERN = /\p{Xdigit}{8}-(\p{Xdigit}{4}-){3}\p{Xdigit}{12}/


	let( :instance ) { described_class.new }
	let( :wallet ) { instance.create_wallet }


	it "has a Set of all wallets on the ledger" do
		expect( instance.wallets ).to be_a( Set )
	end


	describe "wallets" do


		it "can be created" do
			expect( wallet ).to be_a( String ).and( match /\A#{UUID_PATTERN}\z/ )
		end


		it "start out at 0𝓩" do
			expect( instance.balance_for(wallet) ).to eq( 0 )
		end

	end


	it "has a way to check the balance of any wallet" do
		other_wallet = instance.create_wallet

		instance.transfer( amount: 100, to: wallet, from: described_class::GENESIS_WALLET )
		instance.transfer( amount: 20, to: wallet, from: described_class::GENESIS_WALLET )
		instance.transfer( amount: 40, to: other_wallet, from: wallet )

		instance.process( other_wallet )

		expect( instance.balance_for(wallet) ).to eq( 80 )
	end


	it "has a way to check the balance of any wallet including pending transactions" do
		other_wallet = instance.create_wallet

		instance.transfer( amount: 100, to: wallet, from: described_class::GENESIS_WALLET )
		instance.transfer( amount: 20, to: wallet, from: described_class::GENESIS_WALLET )
		instance.transfer( amount: 40, to: other_wallet, from: wallet )

		expect( instance.balance_for(wallet, true) ).to eq( 80 )
	end


end

