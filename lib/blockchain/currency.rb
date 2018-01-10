# -*- ruby -*-
# frozen_string_literal: true

require 'i18n'
require 'money'
require 'monetize'
require 'uuid'
require 'set'

require 'blockchain' unless defined?( Blockchain )

I18n.enforce_available_locales = false
I18n.default_locale = :en
I18n.locale = :en

Money::Currency.register( iso_code: 'zmz', subunit_to_unit: 100_000_000, exponent: 8,
                          subunit: 'Zmargle', symbol: '𝓩' , thousands_separator: ',',
                          decimal_mark: '.', symbol_first: false )
Money.add_rate( "USD", "ZMZ", 14_235 )
Money.default_currency = Money::Currency.find( :usd )

def Money( value )
	return value if value.is_a?( Money )
	return Money.new( value, 'zmz' ) if value.is_a?( Numeric )
	return Monetize.parse( value.to_s )
end


# An oversimplified "cryptocurrency" built on top of the Blockchain::Ledger.
class Blockchain::Currency < Blockchain::Ledger

	# The number of "coins" received for mining blocks
	MINING_REWARD = 100_000_000

	# The number of "coins" in the genesis block
	INITIAL_AMOUNT = (2 ** 20) * (10 ** 9)

	# The wallet that contains all unmined currency
	GENESIS_WALLET = "0"


	### Create a new Currency
	def initialize
		@wallets = Set[ "0" ]
		@uuid = UUID.new

		super
	end


	##
	# The Set of all wallets in the currency
	attr_reader :wallets

	##
	# The UUID generator
	attr_reader :uuid


	### Send the specified +amount+ of currency to the given +to+ wallet from the
	### specified +from+ wallet.
	def transfer( amount:, to:, from: )
		self.log.info "%s --{%0.6f𝓩}--> %s" % [ from, amount, to ]
		amount = normalize_amount( amount )

		raise "No such wallet #{to}" unless self.wallets.include?( to )
		raise "No such wallet #{from}" unless self.wallets.include?( from )
		raise "Can't transfer to same wallet #{to}" if to == from
		raise "Wallet #{from} doesn't contain enough to cover #{amount}" unless
			self.wallet_has_at_least?( from, amount )

		self.add_transaction( amount: amount, to: to, from: from )
		self.log.info "transfer complete."
	end


	### Overridden to check for required attributes.
	def add_transaction( **attributes )
		check_for_required_attributes( attributes )
		attributes[:amount] = normalize_amount( attributes[:amount] )
		super
	end


	### Mine the current block on behalf of the specified +wallet+.
	def process( wallet )
		self.add_block do
			self.add_transaction( from: GENESIS_WALLET, to: wallet, amount: MINING_REWARD )
		end
	end


	### Create a new wallet and return its UUID.
	def create_wallet
		id = self.uuid.generate
		self.wallets.add( id )
		return id
	end


	### Return the balance for the specified +wallet+.
	def balance_for( wallet, include_pending_transactions=false )
		self.log.debug "Checking balance for wallet %s" % [ wallet ]

		total = self.chain.inject( 0 ) do |sum, block|
			self.log.debug "Summing from block %d" % [ block.index ]
			sum + block.transactions.inject( 0 ) do |trsum, transaction|
				change = transaction_change_for( wallet, transaction )
				self.log.debug " txn %p: %+d" % [ transaction, change ]
				trsum + change
			end
		end
		self.log.debug "  total from chain: %p" % [ total ]

		if include_pending_transactions
			total += self.current_transactions.inject( 0 ) do |trsum, transaction|
				change = transaction_change_for( wallet, transaction )
				self.log.debug " %+d" % [ change ]
				trsum + change
			end
			self.log.debug "  total after pending transactions: %p" % [ total ]
		end

		return total
	end


	### Return a Hash of the balances for each wallet keyed by its ID.
	def all_wallet_balances
		totals = Hash.new {|h,uuid| h[uuid] = 0 }
		totals[ GENESIS_WALLET ] = INITIAL_AMOUNT

		self.each_block do |block|
			block.transactions.each do |tr|
				totals[ tr[:to] ]   += tr[:amount]
				totals[ tr[:from] ] -= tr[:amount]
			end
		end

		return totals.transform_values {|val| Money.new(val, :zmz) }
	end



	#########
	protected
	#########

	### Add the initial block onto the chain.
	def add_genesis_block
		self.add_transaction( to: GENESIS_WALLET, from: GENESIS_WALLET, amount: INITIAL_AMOUNT )
		super
	end


	### Returns true if the specified +wallet+ has at least +amount+ in it.
	def wallet_has_at_least?( wallet, amount )
		balance = self.balance_for( wallet, true )
		self.log.debug "Balance for wallet %s: %p" % [ wallet, balance ]
		return balance >= amount
	end


	#######
	private
	#######

	### Return the amount of change to the specified +wallet+ represented by the
	### specified +transaction+.
	def transaction_change_for( wallet, transaction )
		transaction = transaction.transform_keys( &:to_sym )

		self.log.debug "Checking txn %p for amount changed for %p" % [ transaction, wallet ]
		if transaction[:to] == wallet
			return +transaction[:amount]
		elsif transaction[:from] == wallet
			return -transaction[:amount]
		else
			0
		end
	end


	### Raise an error if the required +attributes+ are not present.
	def check_for_required_attributes( attributes )
		raise "All transactions require a :to attribute" unless attributes.key?( :to )
		raise "All transactions require a :from attribute" unless attributes.key?( :from )
		raise "All transactions require a :amount attribute" unless attributes.key?( :amount )
	end


	### Turn the +amount+ into a Money object of the coin currency.
	def normalize_amount( amount )
		amount = Money( amount )
		return amount.exchange_to( 'ZMZ' ).fractional
	end

end # class Blockchain::Currency
