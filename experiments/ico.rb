#!/usr/bin/env ruby

$LOAD_PATH.unshift( 'lib' )

require 'loggability'
require 'blockchain/currency'
require 'tty/table'
require 'pastel'


def show_currency_state( ledger )
	pastel = Pastel.new

	puts pastel.bold.white( "Currency State" )

	puts pastel.yellow( "Chain" )
	puts pastel.yellow(     " Idx   Time                                       Proof" )
	ledger.each_block do |block|
		puts "%05d  %s              %d" %
			[ block.index, block.timestamp.strftime('%Y-%m-%d %H:%M:%S.%N'), block.proof ]
			block.transactions.each do |tr|
				amount = Money( tr[:amount] )
				puts "    %15s  [%s → %s]" % [ amount.format, tr[:from], tr[:to] ]
			end
	end

	puts
	puts pastel.yellow( "Wallets" )
	wallet_table = build_wallet_table( ledger )
	puts wallet_table.render
	
	puts
end


def build_wallet_table( ledger )
	table = TTY::Table.new( header: ['Wallet', 'Amount'] )
	ledger.all_wallet_balances.each do |uuid, amount|
		table << [ uuid, amount.format ]
	end

	return table
end


def main
	Loggability.level = :debug

	coin = Blockchain::Currency.new
	me = coin.create_wallet
	puts "Created wallet %s" % [ me ]
	other = coin.create_wallet
	puts "Created wallet %s" % [ other ]

	coin.process( me )
	coin.transfer( from: me, to: other, amount: 245 )
	coin.transfer( from: other, to: me, amount: 20 )
	coin.process( me )
	show_currency_state( coin )
end


if __FILE__ == $0
	main()
end

