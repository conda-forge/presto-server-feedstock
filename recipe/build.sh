#!/bin/bash

set -euxo pipefail

# Don't build docs (requries more Python deps).
sed -i'' -e 's@<module>presto-docs</module>@@g' pom.xml

# Build and install to presto-server/.
./mvnw clean install -DskipTests -T$CPU_COUNT -Dmaven.repo.local=$SRC_DIR/m2

# Collect third-party licenses.
./mvnw org.codehaus.mojo:license-maven-plugin:aggregate-add-third-party -Dmaven.repo.local=$SRC_DIR/m2

# Copy from presto-server/ to $PREFIX/opt/presto-server/ and create a launcher wrapper.
# Presto's 'bin/launcher' will be available under the 'presto-server' executable.
mv presto-server/target/presto-server-*/presto-server-* $PREFIX/opt/presto-server
executable=$PREFIX/bin/presto-server
echo > $executable 'exec "'$PREFIX'/opt/presto-server/bin/launcher" "$@"'
chmod +x $executable

# Free some disk space for the remainder of the build pipeline.
rm -rf $SRC_DIR/m2
