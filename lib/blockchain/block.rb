# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'msgpack'
require 'digest'

require 'blockchain' unless defined?( Blockchain )



# Blockchain block class
class Blockchain::Block
	extend Loggability

	log_to :blockchain


	### Create a new block with the specified +transactions+ via the given +pow+
	### strategy and +previous_block+.
	def initialize( pow_strategy, transactions, previous_block=nil )
		@pow_strategy   = pow_strategy
		@previous_block = previous_block

		@timestamp      = Time.now
		@payload        = MessagePack.pack( transactions )
		@payload_hash   = self.calculate_payload_hash

		if previous_block
			@index = previous_block.index + 1
			@previous_hash = previous_block.block_hash
			@proof = self.calculate_proof_of_work
		else
			@index = 0
			@previous_hash = '1'
			@proof = 1
		end

		self.log
		self.freeze
	end


	attr_reader :pow_strategy, :previous_block,
		:index, :timestamp, :payload, :payload_hash, :proof, :previous_hash


	### Return the decoded Array of transactions in this block's payload.
	def transactions
		return MessagePack.unpack( self.payload ).map {|tr| tr.transform_keys(&:to_sym) }
	end


	### Return the cryptographic hash of this Block.
	def block_hash
		digest = Digest::SHA2.new

		digest << '%d' % [ self.index ]
		digest << self.timestamp.strftime( '%s%N' )
		digest << self.payload
		digest << self.payload_hash
		digest << self.proof.to_s
		digest << self.previous_hash
		
		return digest.hexdigest
	end


	### Return +true+ if the specified +previous_block+ is valid.
	def valid?
		unless self.has_valid_payload?
			self.log.error "Corrupted payload in block %d (hash mismatch)" % [ self.index ]
			return false
		end

		return true if self.genesis?

		unless self.previous_hash_valid?
			self.log.error "Hash mismatch in block %d" % [ self.index ]
			return false
		end

		unless self.has_valid_proof?
			self.log.error "Invalid proof-of-work in block %d" % [ self.index ]
			return false
		end

		return true
	end


	### Returns +true+ if the payload's hash is the same as the stored payload hash.
	def has_valid_payload?
		return self.payload_hash == self.calculate_payload_hash
	end


	### Return +true+ if the previous block's hash matches this block's
	### previous_hash.
	def previous_hash_valid?
		return self.previous_hash == self.previous_block.block_hash
	end
	alias_method :has_valid_previous_hash?, :previous_hash_valid?


	### Returns +true+ if the proof in this block is valid.
	def has_valid_proof?
		prev_proof = self.previous_block.proof
		prev_hash = self.previous_hash

		return self.pow_strategy.valid_proof?( prev_proof, prev_hash, self.proof )
	end


	### Create and return the next block in the chain after the receiver for the
	### specified +transactions+.
	def create_next( *transactions )
		return self.class.new( self.pow_strategy, transactions, self )
	end


	### Returns +true+ if the receiver is the genesis block.
	def genesis?
		return self.index.zero?
	end



	### Return a string representation of the Block suitable for debugging.
	def inspect
		return "#<%p:%#0x [%d] %s/%d %0.2fKB payload at %s>" % [
			self.class,
			self.object_id * 2,
			self.index,
			self.previous_hash,
			self.proof,
			self.payload.bytesize / 1024,
			self.timestamp,
		]
	end


	#########
	protected
	#########


	### Return the cryptographic hash of the block's payload.
	def calculate_payload_hash
		return Digest::SHA2.hexdigest( self.payload )
	end


	### Calculate this block's proof of work using its +pow_strategy+.
	def calculate_proof_of_work
		return self.pow_strategy.find( self.previous_block.proof, self.previous_hash )
	end

end # class Block


