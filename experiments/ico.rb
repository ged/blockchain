#!/usr/bin/env ruby

require 'bundler/setup'
require 'blockchain'


coin = Blockchain::Coin.new

me = coin.create_wallet
other = coin.create_wallet

coin.process( wallet: me )

puts "Okay, set up. I now have %0.6fÇ after mining one block." % [ coin.balance_for( wallet: me) ]


