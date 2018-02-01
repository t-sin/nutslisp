# Nuts Lisp - Trivial Lisp-2 Interpreter

For Mark the squirrel.


## Install

```
$ git clone https://github.com/t-sin/nutslisp.git
$ cd nutslisp/
$ nimble build
$ ./nutslisp
```

## Invoking nutslisp from JavaScript

First, you must compile nutslisp into JavaScript code.

```
$ nimble js -o:nutslisp.js src/nutslisp.nim
```

And call `readFromString("(quote blah blah"))` from HTML file.


## License

This program *nutslisp* is licensed under the GNU General Public License Version 3. See [COPYING](COPYING) for details.
