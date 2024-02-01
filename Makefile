bootstrap:
# Initialize submodules
	git submodule update --init
# Initialize sparse checkout in the `tbdex-spec` submodule
	git -C Tests/tbDEXTestVectors/tbdex-spec config core.sparseCheckout true
# Sparse checkout only the `hosted/test-vectors` directory from `tbdex-spec`
	git -C Tests/tbDEXTestVectors/tbdex-spec sparse-checkout set hosted/test-vectors
# Update submodules so they sparse checkout takes effect
	git submodule update

format:
	swift format --in-place --recursive .
