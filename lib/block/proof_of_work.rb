# -*- ruby -*-
# frozen_string_literal: true

require 'digest'

require 'block' unless defined?( Block )


# Proof of work algorithm.
module Block::ProofOfWork


	DIGEST_SIZE = 256


	###############
	module_function
	###############

	def find( last_proof )
		proof = 0

		proof += 1 until Block::ProofOfWork.valid_proof?( last_proof, proof )

		return proof
	end


	def valid_proof?( last_proof, proof )
		digest = Digest::SHA2.new( Block::ProofOfWork::DIGEST_SIZE )
		digest << "%d:%d" % [ last_proof, proof ]

		return digest.hexdigest.end_with?( '0000' )
	end


end # module Block::ProofOfWork

