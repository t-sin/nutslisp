# Nuts Lisp - Trivial Lisp-2 Interpreter

> He doesn't bury nuts he hasn't picked up.
> 
> --- Enjoe TOH, The Squirrel Awakes

**This tiny, very tiny project is stopped**. Because: 

- it is *my first Lisp*
- *but is set the too large goals*
    - The goal is *I want that Nuts Lisp glows up a subset of Common Lisp* ;P

Nuts Lisp has these feature:

- Nuts Lisp is Lisp-2; Nuts Lisp has different namespaces for variables and for functions
- Nuts Lisp has pakagaes
- Nuts Lisp has fulll freatured streams
- Nuts Lisp can evaluate recursive functions! (wow!)

I think I did a good job about the first trial of implementing Lisp.

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
