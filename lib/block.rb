# -*- ruby -*-
#encoding: utf-8

# Toplevel namespace
module Block

	# Package version
	VERSION = '0.0.1'

	# Version control revision
	REVISION = %q$Revision$


	autoload :Chain, 'block/chain'
	autoload :ProofOfWork, 'block/proof_of_work'

end # module Block


