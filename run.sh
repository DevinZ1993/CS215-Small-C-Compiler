#! /bin/bash

set -e

PACK=com.gmail.devinz1993.smallc
CLASS=bin:lib/JFlex.jar:lib/java_cup_11a.jar
RUN="java -classpath ${CLASS} ${PACK}.Compiler"

${RUN} test
${RUN} test0
${RUN} test1
${RUN} test2
${RUN} test3
${RUN} test4
${RUN} test5
${RUN} test6
${RUN} test7
${RUN} test8
${RUN} test9
