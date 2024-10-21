# Retrieve package ID and version from the manifest file
PKG_ID := $(shell yq e ".id" manifest.yaml)
PKG_VERSION := $(shell yq e ".version" manifest.yaml)

# Specify any source files, if needed (e.g., TypeScript files)
TS_FILES := $(shell find ./ -name \*.ts)

# Delete the target of a rule if it has changed and its recipe exits with a nonzero exit status
.DELETE_ON_ERROR:

# Default target
all: verify

# Verify the package
verify: $(PKG_ID).s9pk
	@echo "Verifying package..."
	start-sdk verify $(PKG_ID).s9pk

# Install the package using the command line interface
install:
	@echo "Installing package..."
	start-cli package install $(PKG_ID).s9pk

# Clean up generated files
clean:
	@echo "Cleaning up..."
	rm -f image.tar
	rm -f $(PKG_ID).s9pk
	rm -f scripts/*.js

# Generate the JavaScript bundle from TypeScript files
scripts/embassy.js: $(TS_FILES)
	@echo "Bundling TypeScript files..."
	deno bundle scripts/embassy.ts scripts/embassy.js

# Build the Docker image and output to image.tar
image.tar: Dockerfile docker_entrypoint.sh
	@echo "Building Docker image..."
	docker buildx build --tag start9/$(PKG_ID)/main:$(PKG_VERSION) --platform=linux/arm64 -o type=docker,dest=image.tar .

# Package all components into the .s9pk file
$(PKG_ID).s9pk: manifest.yaml instructions.md icon.png LICENSE scripts/embassy.js image.tar
	@echo "Packaging service into .s9pk file..."
	start-sdk pack

# Help command to display usage
help:
	@echo "Makefile commands:"
	@echo "  all        - Build and verify the package"
	@echo "  verify     - Verify the .s9pk package"
	@echo "  install    - Install the .s9pk package"
	@echo "  clean      - Remove generated files"
	@echo "  help       - Display this help message"
