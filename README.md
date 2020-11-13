# Code42 Developer Portal

*NOTE: This site / repo is a work in progress. The APIs documented by this project are likely to not work and / or change in the future. Do not use or depend on them until this project has officially launched.*

To build, execute:

```bash
./build.sh
```

Once built, the site can be run locally using a local web server serving the current working directory, such as python's built-in http module:

```bash
python -m http.server 1337
```

Then, open your browser to `localhost:1337/publish` (or whatever port you chose) to explore the site (on the live site, `publish` will be excluded from the url).
