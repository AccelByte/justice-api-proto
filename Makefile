# Copyright (c) 2022 AccelByte Inc. All Rights Reserved.
# This is licensed software from AccelByte Inc, for limitations
# and restrictions contact your company contract manager.

SHELL := /bin/bash

COMPARE_AGAINST_BRANCH=origin/CG-1226-grpc-plugin-proto-init

breaking:
	docker run -t --rm --volume $$(pwd):/workspace --workdir /workspace bufbuild/buf breaking \
    	--against ".git#branch=$(COMPARE_AGAINST_BRANCH)" \
      	--config '{"version":"v1","breaking":{"use":["FILE"]}}'
