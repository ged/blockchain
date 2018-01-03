# -*- ruby -*-
# frozen_string_literal: true

require 'digest'

require 'blockchain' unless defined?( Blockchain )


# Proof of work algorithm.
module Blockchain::ProofOfWork


	DIGEST_SIZE = 256


	###############
	module_function
	###############

	### Return a proof given the +last_proof+ and the +last_hash+.
	def find( last_proof, last_hash )
		proof = 0

		proof += 1 until Blockchain::ProofOfWork.valid_proof?( last_proof, last_hash, proof )

		return proof
	end


	### Return +true+ if the specified +proof+ is valid given the +last_proof+ and
	### +last_hash+.
	def valid_proof?( last_proof, last_hash, proof )
		digest = Digest::SHA2.new( Blockchain::ProofOfWork::DIGEST_SIZE )
		digest << "%d:%s:%d" % [ last_proof, last_hash, proof ]

		return digest.hexdigest.end_with?( '0000' )
	end

end # module Blockchain::ProofOfWork

