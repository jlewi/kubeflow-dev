#!/bin/sh
# Script for building github.com/cncf/devstats
set -ex
go get -u github.com/golang/lint/golint
go get golang.org/x/tools/cmd/goimports
go get github.com/jgautheron/goconst/cmd/goconst
go get github.com/jgautheron/usedexports
go get github.com/kisielk/errcheck
go get github.com/influxdata/influxdb/client/v2
go get github.com/lib/pq
go get golang.org/x/text/transform
go get golang.org/x/text/unicode/norm
go get gopkg.in/yaml.v2
go get github.com/google/go-github/github
go get golang.org/x/oauth2
go get github.com/mattn/go-sqlite3