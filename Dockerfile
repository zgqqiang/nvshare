# Copyright (c) 2023 Georgios Alexopoulos
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ---------- 构建阶段 ----------
FROM ubuntu:18.04 AS build

COPY ./src/ /src
WORKDIR /src

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    make \
 && rm -rf /var/lib/apt/lists/*

# 一次 make 出所有产物
RUN make nvshare-scheduler nvsharectl libnvshare.so

# ---------- 运行阶段 ----------
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    pid1 \
 && rm -rf /var/lib/apt/lists/*

# 调度器与命令行工具
COPY --from=build /src/nvshare-scheduler /usr/local/bin/nvshare-scheduler
COPY --from=build /src/nvsharectl        /usr/local/bin/nvsharectl
COPY --from=build /src/libnvshare.so     /usr/local/bin/libnvshare.so

# 投递脚本（和 Dockerfile 同目录）
COPY install-libnvshare.sh /usr/local/bin/install-libnvshare.sh
RUN chmod 0755 /usr/local/bin/install-libnvshare.sh

USER root

# 默认入口：pid1 拉起 nvshare-scheduler
ENTRYPOINT ["pid1", "nvshare-scheduler"]
