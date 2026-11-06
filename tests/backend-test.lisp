(in-package #:repl-backend-slynk/tests)

(deftest rpc-table
  (let ((conn (make-instance 'slynk-connection :socket nil :stream nil)))
    (ok (equal (wire-symbol-name (repl-protocol:rpc-symbol conn :backtrace)) "BACKTRACE"))
    (ok (equal (wire-symbol-package (repl-protocol:rpc-symbol conn :backtrace)) "SLYNK"))
    (ok (signals (repl-protocol:rpc-symbol conn :no-such-op) 'repl-protocol-error))))

(deftest slynk-conformance
  (process-backend-uiop:use-uiop-process-backend)
  (let ((conn (repl-spawn (make-slynk-backend))))
    (unwind-protect (repl-protocol/conformance:run-conformance conn)
      (repl-disconnect conn :kill t))))
