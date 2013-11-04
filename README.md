MaRBL and MaRAL and MaRFL
=========================

I want to write a programming language, or three.

Matty's Really Basic Language
-----------------------------

A simple, useful subset of MaRAL, which I hope to be useful for teaching the basic concepts of programming to beginners.

Matty's Really Awesome Language
-------------------------------

Goals:

* expressive
* intuitive
* object-oriented
  * everything is an object
  * javascript-style function referencing
* ruby-style inheritance

Syntax/general semantics:

* everything is statements
  * curly-braces for nesting statements
  * semi-colons end single statements
  * value of nesting statement is value of last inner statement (empty = null)
  * nesting statements provide scope for local variables
* parentheses are for parameters
* _foo_._bar_ is always method _bar_ on object _foo_
* **TODO** something about sigils for instance (/global?) variables
* **TODO** strings ('', "", ..?)

Keywords:

* class _n_ {} / class{}
* func _n_(){} / func(){}
* alias
* if(){}elseif(){}else{}
* unless(){}else{}
* while(){}
* until(){}
* repeat{}until()
* repeat{}while()
* **TODO** switch/case/..?
* **TODO** return / next/break
* **TODO** raise/rescue/ensure
* **TODO** throw/catch

Matty's Really Functional Language
----------------------------------

Similar to MaRAL, but without classes or variables.

