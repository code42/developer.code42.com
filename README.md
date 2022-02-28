# Code42 Developer Portal

To build the site locally, you will need the following:

* [Ruby](https://www.ruby-lang.org/en/)  >= 2.4.1 and < 3.0
* [homebrew](https://brew.sh/) (if using macOS)
* [jq](https://stedolan.github.io/jq/)
* [wget](https://www.gnu.org/software/wget/)
* [api-spec-converter](https://www.npmjs.com/package/api-spec-converter)

After installing the above, check the links below to finish installing your dependenices:

* [Installing Dependencies on Ubuntu 18.04+](https://github.com/slatedocs/slate/wiki/Using-Slate-Natively#installing-dependencies-on-ubuntu-1804)
* [Installing dependencies on macOS](https://github.com/slatedocs/slate/wiki/Using-Slate-Natively#installing-dependencies-on-macos)

Note that slate is unsupported on Windows.

To build, execute:

```bash
make
```

Once built, the site can be run locally using `middleman`, which is included when installing.

```bash
make serve
```

Then, open your browser to `localhost:4567` to explore the site. Once the server is started, you can edit files and simply refresh the page to see your changes!
