# Code42 Developer Portal

To build the site locally, you will need the following:

* [Ruby](https://www.ruby-lang.org/en/)  >= 2.4.1 and < 3.0
* [homebrew](https://brew.sh/) (if using macOS)
* [jq](https://stedolan.github.io/jq/)
* [wget](https://www.gnu.org/software/wget/)
* [api-spec-converter](https://www.npmjs.com/package/api-spec-converter)

# Installing dependencies

We are using Slate to build the documentation, so the dependencies for build can be installed by following their documentation.
It is reproduced here with the additional steps needed for our other dependencies.

```
gem install bundler:2.1.4
bundle install
npm install api-spec-converter
```

Bundler documentation is handy if you run into issues: [Bundler troubleshooting page](https://bundler.io/doc/troubleshooting.html)

Slate documentation if the above is not successful:

* [Installing Dependencies on Ubuntu 18.04+](https://github.com/slatedocs/slate/wiki/Using-Slate-Natively#installing-dependencies-on-ubuntu-1804)
* [Installing dependencies on macOS](https://github.com/slatedocs/slate/wiki/Using-Slate-Natively#installing-dependencies-on-macos)

Note that Slate is unsupported on Windows.

# Build

To build, execute:

```bash
make
```

Once built, the site can be run locally using `middleman`, which is included when installing.

```bash
make serve
```

Then, open your browser to `localhost:4567` to explore the site. Once the server is started, you can edit files and simply refresh the page to see your changes!
