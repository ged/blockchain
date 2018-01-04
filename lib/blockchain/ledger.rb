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


	### Create a new ledger
	def initialize( pow_strategy=Blockchain::ProofOfWork, block_type=Blockchain::Block )
		@chain                = []
		@current_transactions = []

		@pow_strategy         = pow_strategy
		@block_type           = block_type

		self.log.debug "Created %p ledger with PoW strategy: %p" % [ block_type, pow_strategy ]
		self.freeze

		self.add_genesis_block
	end


	##
	# The Array of ordered blocks that make up the chain
	attr_reader :chain

	##
	# Accumulated transactions for each block in the chain
	attr_accessor :current_transactions

	##
	# The proof of work strategy object
	attr_reader :pow_strategy
	
	##
	# The type of Block to use
	attr_reader :block_type
	

	### Append a new Blockchain to the chain.
	def add_block
		yield if block_given?

        block = self.last_block.create_next( *self.current_transactions )

        self.current_transactions.clear
        self.chain.push( block )

		self.log.debug "Added block %p with hash %p" % [ block.index, block.previous_hash ]
        return block
	end


	### Iterate over the blocks in the ledger's blockchain.
	def each_block( &block )
		return self.chain.enum_for( :each ) unless block
		return self.chain.each( &block )
	end


	### Add the initial block onto the chain.
	def add_genesis_block
		self.log.info "Adding genesis block."
		self.chain << self.block_type.new( self.pow_strategy, self.current_transactions )
		self.current_transactions.clear

		return self.chain.last
	end


	### Add a transaction to the block that's currently being worked on.
	def add_transaction( **attributes )
		self.log.info "Adding transaction %d to block %d" %
			[ self.current_transactions.length + 1, self.chain.length + 1 ]
		self.current_transactions << attributes.transform_keys( &:to_s )
	end


	### Return the last Block in the chain.
	def last_block
		return self.chain.last
	end


	### Check the chain for validity, returning +true+ if it's valid.
	def valid?
		return self.invalid_blocks.empty?
	end


	### Return any blocks in the chain which invalidate it.
	def invalid_blocks
		return self.chain.reject( &:valid? )
	end


end # class Blockchain::Ledger

