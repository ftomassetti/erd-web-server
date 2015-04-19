# erd-web-server

A web server to generate ER diagrams.

![](https://raw.githubusercontent.com/ftomassetti/erd-web-server/master/screenshot.png)

The code generating the ER diagram was stolen from the fantastic [erd](https://github.com/BurntSushi/erd) project.
Unfortunately it is an application, not a library and Haskell does not permit to use an application as a dependency
so I just copied the code. Kudos to the original author [Andrew Gallant](http://burntsushi.net/).

Hopefully we could extract the code or erd in a library used by erd and erd-web-server (see [issue on erd](https://github.com/BurntSushi/erd/issues/10))

# Cool, how can I run this stuff?

Run:

```
cabal update
cabal install
erd-web-server -p 8000
# or
dist/build/erd-web-server/erd-web-server -p 8000
```
