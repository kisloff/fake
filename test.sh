#!/usr/bin/env bash
#take project version from pom
echo 'Version resolving started'

#берем врсию из помника ветки develop
prevProjectVersion=`mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`
echo prevProjectVersion=$prevProjectVersion

#создаем версию велиза, отбрасывая -SNAPSHOT
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion} versions:commit | grep -v '\['
#убрать снапшот просто
#mvn versions:set -DremoveSnapshot
releaseVersion=`mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`


echo releaseVersion=$releaseVersion

#создаем версию новой ветки разработки инкрементом + добавляем SNAPSHOT
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}-SNAPSHOT versions:commit | grep -v '\['
developmentVersion=`mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`
echo developmentVersion=$developmentVersion

#сбрасываем изменения в помнике
git checkout pom.xml

#создать ветку релиза c номером из переменной releaseVersion
git checkout -b release/$releaseVersion develop

#задать версию помника из $releaseVersion(повторить шаг генерации или прописать другим инструментом)
mvn build-helper:parse-version versions:set -DnewVersion=$releaseVersion versions:commit | grep -v '\['

#закоммитить
git commit pom.xml -m "задана новая версия pom для релиза"

#залить релиз в мастер, создать на мастере тег с номером релиза
git merge master && git tag $releaseVersion

#перейти на develop
git checkout develop

#проставить новую версию для develop - из переменной $developmentVersion
mvn build-helper:parse-version versions:set -DnewVersion=$developmentVersion versions:commit | grep -v '\['

#закоммитить
git commit pom.xml -m "задана новая версия pom для разработки"

#pзапушить все изменения + все теги
git push --all && git push --tags



