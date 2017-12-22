# -*- ruby -*-
# frozen_string_literal: true

require 'uuid'
require 'set'

require 'blockchain' unless defined?( Blockchain )


# An oversimplified cryptocurrency built on top of the Blockchain::Ledger.
class Blockchain::Currency < Blockchain::Ledger

	# The number of significant digits to use when rounding amounts
	SIGNIFICANT_DIGITS = 6

	# The amount to multiply/divide amounts by to integerify them
	ROUNDING_FACTOR = 10 ** SIGNIFICANT_DIGITS

	# The number of "coins" received for mining blocks
	MINING_REWARD = 1 * ROUNDING_FACTOR

	# The number of "coins" in the genesis block
	INITIAL_AMOUNT = 2 ** 20 * ROUNDING_FACTOR


	### Create a new Currency
	def initialize
		@wallets = Set.new

		super
	end


	##
	# The Set of all wallets in the currency
	attr_reader :wallets


	### Send the specified +amount+ of currency to the given +to+ wallet from the
	### specified +from+ wallet.
	def transfer( amount:, to:, from: )
		raise "No such wallet #{to}" unless self.wallets.include?( to )
		raise "No such wallet #{from}" unless self.wallets.include?( from )
		raise "Wallet #{from} doesn't contain enough to cover #{amount}" unless
			self.balance_for( wallet: from ) >= amount

		amount = BigDecimal( amount ).truncate( SIGNIFICANT_DIGITS ) * ROUNDING_FACTOR
		self.add_transaction( amount: amount, to: to, from: from )
	end


	### Mine the current block on behalf of the specified +wallet+.
	def process( wallet: )
		proof = Blockchain::ProofOfWork.find( self.last_block.proof, self.last_block.previous_hash )

		self.add_block( proof: proof ) do
			self.add_transaction( from: "0", to: wallet, amount: MINING_REWARD )
		end
	end


	### Create a new wallet and return its UUID.
	def create_wallet
		id = self.uuid.generate
		self.wallets.add( id )
		return id
	end


	### Return the balance for the specified +wallet+.
	def balance_for( wallet:, pending_block: nil )
		blocks = self.chain
		blocks = blocks + [ pending_block ] if pending_block

		total = blocks.inject( 0 ) do |sum, block|
			sum + block.transactions.inject( 0 ) do |trsum, transaction|
				if transaction[:from] == wallet
					trsum - transaction[:amount]
				elsif transaction[:to] == wallet
					trsum + transaction[:amount]
				else
					0
				end
			end
		end

		return Rational( total, ROUNDING_FACTOR )
	end


	#########
	protected
	#########

	### Add the initial block onto the chain.
	def add_genesis_block
		self.add_block( proof: 111, previous_hash: 1 ) do
			self.add_transaction( to: '0', from: '0', amount: INITIAL_AMOUNT )
		end
	end


	### Return a UUID generator, creating it if necessary.
	def uuid
		@uuid ||= UUID.new
	end

end # class Blockchain::Currency
