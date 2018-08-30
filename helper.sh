#!/usr/bin/env bash
#вариант 1
#интерактивная штука выдает ответы на выражения. Нужно просто получать ответ без интерактива
#mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version

#вот оно!!!
#mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['
echo projectVersion=`mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`

#вариант 2
#этот вариант выводит версию проекта неинтерактивно
#set -o errexit
#
#MVN_VERSION=$(mvn -q \
#    -Dexec.executable="echo" \
#    -Dexec.args='${project.version}' \
#    --non-recursive \
#    org.codehaus.mojo:exec-maven-plugin:1.3.1:exec)
#
#echo $MVN_VERSION

#вариант 3 жосский всариант со сборкрй и коммитом новой версии. Упростить и использовать
#mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion} versions:commit

mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion} #versions:commit
echo newVersion=`mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`
