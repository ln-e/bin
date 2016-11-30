# install https://github.com/splitsh/lite

git remove add parsekit-semver git://...
~/bin/splitsh-lite --prefix=src/Parsekit/Component/Semver/ --target=heads/parsekit-semver
git push parsekit-semver parsekit-semver:master
