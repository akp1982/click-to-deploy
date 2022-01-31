# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default['percona']['version'] = 'latest'
default['percona']['debian']['codename'] = 'buster'
default['percona']['pkg'] = 'lsof psmisc socat libaio1 libdbd-mysql-perl \
  libdbi-perl netcat-openbsd perl-base percona-xtradb-cluster-5.7 \
  percona-xtrabackup-24 debian-keyring'
