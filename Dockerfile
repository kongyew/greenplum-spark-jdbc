# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# User: gpadmin Password: pivotal
# or root/pivotal

FROM pivotaldata/gpdb-base
LABEL name="gpdb-spark"
LABEL description="Example for Greenplum with Spark"

LABEL version=1.1.1

# Install JDK
ENV JAVA_VERSION 8u31
ENV BUILD_VERSION b13

# Upgrading system
#RUN yum -y upgrade
#RUN yum -y install wget
#RUN yum -y install unzip

ENV JAVA_VERSION 1.8.0
RUN yum -y update && yum install -y java-"${JAVA_VERSION}"-openjdk && yum clean all

# Install psql, createDB
RUN     yum install -y postgresql

ENV JAVA_HOME /usr/java/latest

RUN  cd /opt && curl --silent -L -o pgweb_linux_386.zip https://github.com/sosedoff/pgweb/releases/download/v0.9.7/pgweb_linux_386.zip \
        && unzip pgweb_linux_386.zip \
        && mv pgweb_linux_386 pgweb \
        && rm pgweb_linux_386.zip


#Use root
USER root
# Default ports:
# GPDB 5432
# SEGMENT 40000
EXPOSE 9090:9090 5432 5005 5010 9022:22 40000 40001 40002
VOLUME ["/data/"]

# Define default command.
