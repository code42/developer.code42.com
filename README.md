# Code42 Developer Portal

To build the site locally, you will need the following:

* [Ruby](https://www.ruby-lang.org/en/)  >= 2.4.1 and < 3.0
* [homebrew](https://brew.sh/) (if using macOS)
* [jq](https://stedolan.github.io/jq/)
* [wget](https://www.gnu.org/software/wget/)
* [api-spec-converter](https://www.npmjs.com/package/api-spec-converter)
* [MarkdownTools2](https://pypi.org/project/MarkdownTools2/)

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

# User Guides

The user guides are separated into their own files for easy navigation and editing.  The `MarkdownTools2` package provides the CLI command `mdmerge` that we use to merge these files into one so that they can be hosted on a single page. 

You can install `MarkdownTools2` with pip:
```bash
pip install MarkdownTools2
```

Use the following command to build the `source/api/user_guides.rmd` file.
```bash
make docs
```

To add a user guide:

1. add it to the `source/api/user-guides` directory.
2. insert it into the proper index within the `make docs` command. (This is the order that the markdown files will be merged.)
3. rebuild the docs via `make docs`.

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
