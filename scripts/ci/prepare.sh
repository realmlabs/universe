
set -e

export ERLANG_VERSION="17.5"
export ELIXIR_VERSION="v1.0.4"

export INSTALL_PATH="$HOME/dependencies"

export ERLANG_PATH="$INSTALL_PATH/otp_src_$ERLANG_VERSION"
export ELIXIR_PATH="$INSTALL_PATH/elixir_$ELIXIR_VERSION"
export GATEWAY_PATH="$INSTALL_PATH/gateway"

mkdir -p $INSTALL_PATH
cd $INSTALL_PATH

# Install erlang
if [ ! -e $ERLANG_PATH/bin/erl ]; then
  curl -O http://www.erlang.org/download/otp_src_$ERLANG_VERSION.tar.gz
  tar xzf otp_src_$ERLANG_VERSION.tar.gz
  cd $ERLANG_PATH
  ./configure --enable-smp-support \
              --enable-m64-build \
              --disable-native-libs \
              --disable-sctp \
              --enable-threads \
              --enable-kernel-poll \
              --disable-hipe \
              --without-javac
  make

  # Symlink to make it easier to setup PATH to run tests
  ln -sf $ERLANG_PATH $INSTALL_PATH/erlang
fi

# Install elixir
export PATH="$ERLANG_PATH/bin:$PATH"

if [ ! -e $ELIXIR_PATH/bin/elixir ]; then
  git clone https://github.com/elixir-lang/elixir $ELIXIR_PATH
  cd $ELIXIR_PATH
  git checkout $ELIXIR_VERSION
  make

  # Symlink to make it easier to setup PATH to run tests
  ln -sf $ELIXIR_PATH $INSTALL_PATH/elixir
fi

if [ ! -e $GATEWAY_PATH/sync_gateway ]; then
  cd $GATEWAY_PATH
  wget http://packages.couchbase.com/builds/mobile/sync_gateway/1.0.4/1.0.4-34/couchbase-sync-gateway-community_1.0.4-34_x86_64.deb
  dpkg -i couchbase-sync-gateway-community_1.0.4-34_x86_64.deb

  # Symlink to make it easier to setup PATH to run tests
  ln -sf $GATEWAY_PATH $INSTALL_PATH/sync_gateway
fi


export PATH="$ERLANG_PATH/bin:$ELIXIR_PATH/bin:$GATEWAY_PATH:$PATH"

# Install package tools
if [ ! -e $HOME/.mix/rebar ]; then
  yes Y | LC_ALL=en_GB.UTF-8 mix local.hex
  yes Y | LC_ALL=en_GB.UTF-8 mix local.rebar
fi

# Fetch and compile dependencies and application code (and include testing tools)
export MIX_ENV="test"
cd $HOME/$CIRCLE_PROJECT_REPONAME
mix do deps.get, deps.compile, compile
