# This dockerfile is meant to be personalized, and serves as a template and demonstration.
# Modify it directly, but it is recommended to copy this dockerfile into a new build context (directory),
# modify to taste and modify docker-compose.yml.template to build and run it.

# It is recommended to control docker containers through 'docker-compose' https://docs.docker.com/compose/
# Docker compose depends on a .yml file to control container sets
# rocm-setup.sh can generate a useful docker-compose .yml file
# `docker-compose run --rm <rocm-terminal>`

# If it is desired to run the container manually through the docker command-line, the following is an example
# 'docker run -it --rm -v [host/directory]:[container/directory]:ro <user-name>/<project-name>'.

FROM ubuntu:18.04
# compile for my RX580
ENV HCC_AMDGPU_TARGET=gfx806 
ENV USE_ROCM=1
ENV MAX_JOBS=4
# Initialize the image
# Modify to pre-install dev tools and ROCm packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl gnupg2 && \
  curl -sL http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | apt-key add - && \
  sh -c 'echo deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main > /etc/apt/sources.list.d/rocm.list' && \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  sudo \
  libelf1 \
  build-essential \
  bzip2 \
  ca-certificates \
  cmake \
  ssh \
  apt-utils \
  pkg-config \
  g++-multilib \
  gdb \
  git \
  less \
  libunwind-dev \
  libfftw3-dev \
  libelf-dev \
  libncurses5-dev \
  libomp-dev \
  libpthread-stubs0-dev \
  make \
  miopen-hip \
  python-dev \
  python-future \
  python-yaml \
  python-pip \
  python3-pip \
  python3 \
  vim \
  libssl-dev \
  libboost-dev \
  libboost-system-dev \
  libboost-filesystem-dev \
  libopenblas-dev \
  rpm \
  wget \
  net-tools \
  iputils-ping \
  libnuma-dev \
  rocm-dev \
  rocrand \
  rocblas \
  rocfft \
  hipcub \
  rocthrust \
  hipsparse && \
  curl -sL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
  sh -c 'echo deb [arch=amd64] http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main > /etc/apt/sources.list.d/llvm7.list' && \
  sh -c 'echo deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main >> /etc/apt/sources.list.d/llvm7.list' && \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  clang-7 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# fix capitalization in some cmake files...
RUN sed -i 's/find_dependency(hip)/find_dependency(HIP)/g' /opt/rocm/rocsparse/lib/cmake/rocsparse/rocsparse-config.cmake
RUN sed -i 's/find_dependency(hip)/find_dependency(HIP)/g' /opt/rocm/rocfft/lib/cmake/rocfft/rocfft-config.cmake
RUN sed -i 's/find_dependency(hip)/find_dependency(HIP)/g' /opt/rocm/miopen/lib/cmake/miopen/miopen-config.cmake
RUN sed -i 's/find_dependency(hip)/find_dependency(HIP)/g' /opt/rocm/rocblas/lib/cmake/rocblas/rocblas-config.cmake

# Grant members of 'sudo' group passwordless privileges
# Comment out to require sudo
#COPY sudo-nopasswd /etc/sudoers.d/sudo-nopasswd

# This is meant to be used as an interactive developer container
# Create user rocm-user as member of sudo group
# Append /opt/rocm/bin to the system PATH variable
#RUN useradd --create-home -G sudo --shell /bin/bash rocm-user
#RUN usermod -a -G video rocm-user
#    sed --in-place=.rocm-backup 's|^\(PATH=.*\)"$|\1:/opt/rocm/bin"|' /etc/environment

#USER rocm-user
#WORKDIR /home/rocm-user
WORKDIR /root
ENV PATH="${PATH}:/opt/rocm/bin" HIP_PLATFORM="hcc"

#RUN \
#  curl -O https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh && \
#  bash Anaconda3-5.0.1-Linux-x86_64.sh -b
#  rm Anaconda3-5.0.1-Linux-x86_64.sh

# The following are optional enhancements for the command-line experience
# Uncomment the following to install a pre-configured vim environment based on http://vim.spf13.com/
# 1.  Sets up an enhanced command line dev environment within VIM
# 2.  Aliases GDB to enable TUI mode by default
#RUN curl -sL https://j.mp/spf13-vim3 | bash && \
#    echo "alias gdb='gdb --tui'\n" >> ~/.bashrc

#RUN \
#  bash installers/Anaconda3-5.2.0-Linux-x86_64.sh -b

#ENV PATH="/home/rocm-user/anaconda3/bin:${PATH}" KMTHINLTO="1"
ENV KMTHINLTO="1" LANG="C.UTF-8" LC_ALL="C.UTF-8"

RUN \
  pip3 install setuptools

RUN \
  pip3 install pyyaml

RUN \
  pip3 install numpy scipy

RUN \
  pip3 install typing

RUN \
  pip3 install enum34

RUN \
  pip3 install hypothesis

RUN \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang-7 50 && \
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/clang++-7 50

#RUN \
#  git clone https://github.com/pytorch/vision.git 
# NOTE: Have to perform the following after pytorch is built and installed
#  cd vision && \
#  python setup.py install

# Default to a login shell
CMD ["bash", "-l"]
