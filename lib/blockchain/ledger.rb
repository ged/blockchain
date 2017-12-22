# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'msgpack'
require 'digest'

require 'blockchain' unless defined?( Blockchain )


# Blockchain class
class Blockchain::Ledger
	extend Loggability

	# Loggability API -- log to the blockchain logger
	log_to :blockchain


	# Chain block struct
	Block = Struct.new( :index, :timestamp, :transactions, :proof, :previous_hash )


	### Create a new ledger
	def initialize
		@chain  = []
		@current_transactions = []

		self.add_genesis_block
	end


	##
	# The Array of ordered blocks that make up the chain
	attr_reader :chain

	##
	# Accumulated transactions for each block in the chain
	attr_accessor :current_transactions


	### Append a new Blockchain to the chain with the specified +proof+ and
	### +previous_hash+. If +previous_hash+ is +nil+, it will be automatically
	### calculated using the previous block.
	def add_block( proof:, previous_hash: nil )
		self.log.debug "Adding a block with proof: %p" % [ proof ]

		yield if block_given?

        block = Block.new(
            self.chain.length + 1,
            Time.now.to_f,
            self.current_transactions,
            proof,
            previous_hash || self.hash_of_last_block,
        )

        # Reset the current list of transactions
        self.current_transactions = []
        self.chain.push( block )

		self.log.debug "Added block %p with hash %p" % [ block.index, block.previous_hash ]
        return block
	end


	### Add the initial block onto the chain.
	def add_genesis_block
		self.add_block( proof: 111, previous_hash: 1 )
	end


	### Add a transaction to the block that's currently being worked on.
	def add_transaction( **attributes )
		self.log.debug "Adding transaction %d to block %d" %
			[ self.current_transactions.length + 1, self.chain.length + 1 ]
		self.current_transactions << attributes
	end


	### Return the last Block in the chain.
	def last_block
		return self.chain.last
	end


	### Return the hash of the last block in the chain.
	def hash_of_last_block
		return hash( self.last_block )
	end


	### Check the chain for validity, returning +true+ if it's valid.
	def valid?
		return true unless self.chain.each_cons( 2 ).find do |last_block, block|
			block.previous_hash != hash( last_block ) ||
			!Blockchain::ProofOfWork.valid_proof?( last_block.proof, last_block.previous_hash, block.proof )
		end
	end


	#######
	private
	#######

	### Calculate the cryptographic hash of the specified +block+, which must
	### respond to #to_h.
	def hash( block )
		self.log.debug "hashing: %p" % [ block ]
		encoded = MessagePack.pack( block.to_h.sort )
		return Digest::SHA2.hexdigest( encoded )
	end

end # class Blockchain::Ledger

