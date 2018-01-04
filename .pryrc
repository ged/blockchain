#!/usr/bin/ruby -*- ruby -*-

$LOAD_PATH.unshift( 'lib' )

require 'i18n'

I18n.enforce_available_locales = false
I18n.default_locale = :en
I18n.locale = :en

begin
	require 'blockchain'
	require 'blockchain/currency'
	Loggability.level = :debug
rescue Exception => e
	$stderr.puts "Ack! Libraries failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end


