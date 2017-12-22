# -*- ruby -*-
# frozen_string_literal: true

require 'bencode'
require 'digest'

require 'block' unless defined?( Block )


# Blockchain class
class Block::Chain
	

	def initialize
		@chain  = []
		@current_transactions = []

		self.add_block( proof: 100, previous_hash: 1 )
	end


	attr_reader :chain

	attr_reader :current_transactions


	### Append a new Block to the chain with the specified proof and
	### +previous_hash+.
	def add_block( proof:, previous_hash: nil )
		yield if block_given?

        block = {
            index: self.chain.length + 1,
            timestamp: Time.now.to_f,
            transactions: self.current_transactions.dup,
            proof: proof,
            previous_hash: previous_hash || self.hash_of_last_block,
        }

        # Reset the current list of transactions
        self.current_transactions.clear
        self.chain.append( block )

        return block
	end


	def add_transaction( sender:, recipient:, amount: )
		self.current_transactions << { sender: sender, recipient: recipient, amount: amount }
	end


	def last_block
		return self.chain.last
	end


	def hash_of_last_block
		return hash( self.last_block )
	end



	#######
	private
	#######

 	def hash( block )
		encoded = BEncode.dump( block )
		return Digest::SHA2.hexdigest( encoded )
	end

end # class Block::Chain

