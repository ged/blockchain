# -*- ruby -*-
#encoding: utf-8

require 'loggability'

# Blockchain experiments
module Blockchain
	extend Loggability

	# Package version
	VERSION = '0.0.1'

	# Version control revision
	REVISION = %q$Revision$


	log_as :blockchain


	autoload :Block, 'blockchain/block'
	autoload :Currency, 'blockchain/currency'
	autoload :Ledger, 'blockchain/ledger'
	autoload :ProofOfWork, 'blockchain/proof_of_work'

end # module Blockchain


