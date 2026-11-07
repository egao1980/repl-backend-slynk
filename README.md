# repl-backend-slynk

Sly [Slynk](https://github.com/joaotavora/sly) wire backend for [`repl-protocol`](https://github.com/egao1980/repl-protocol).

```lisp
(asdf:load-system "repl-backend-slynk")
(stack-repl:repl-connect (repl-backend-slynk:make-slynk-backend) :port 4005)   ; attach
(stack-repl:repl-spawn (repl-backend-slynk:make-slynk-backend))                ; fresh image
```

`repl-spawn` loads Slynk and its `slynk/mrepl` contrib in the child with `ql:quickload` (or `asdf:load-system` when Quicklisp is absent) and calls `slynk:start-server`.

Beyond the shared Swank-family surface, Slynk supports channels: `repl-open-channel` creates an mrepl (its own thread, package and `#v<entry>:<index>` history; its dedicated output socket is connected for you), `repl-channel-eval`, `repl-channel-inspect`, `repl-close-channel`. Stepping uses `sly-db-step` / `-next` / `-out`. Tests run the shared `repl-protocol/conformance` suite against a spawned SBCL.

## License

MIT
