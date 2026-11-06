# repl-backend-slynk

Sly [Slynk](https://github.com/joaotavora/sly) wire backend for [`repl-protocol`](https://github.com/egao1980/repl-protocol).

```lisp
(asdf:load-system "repl-backend-slynk")
(stack-repl:repl-connect (repl-backend-slynk:make-slynk-backend) :port 4005)   ; attach
(stack-repl:repl-spawn (repl-backend-slynk:make-slynk-backend))                ; fresh image
```

`repl-spawn` loads Slynk in the child with `ql:quickload` (or `asdf:load-system` when Quicklisp is absent) and calls `slynk:start-server`. Tests run the shared `repl-protocol/conformance` suite against a spawned SBCL.

## License

MIT
