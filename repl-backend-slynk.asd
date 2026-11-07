(defsystem "repl-backend-slynk"
  :version "0.2.0"
  :description "Sly Slynk wire backend for repl-protocol"
  :author "egao1980"
  :license "MIT"
  :depends-on ((:version "repl-protocol" "0.2.1"))
  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "backend"))
  :in-order-to ((test-op (test-op "repl-backend-slynk/tests"))))

(defsystem "repl-backend-slynk/tests"
  :depends-on ("repl-backend-slynk" "repl-protocol/conformance" "process-backend-uiop" "rove")
  :pathname "tests"
  :serial t
  :components ((:file "package")
               (:file "backend-test"))
  :perform (test-op (o c)
             (unless (symbol-call :rove :run c)
               (error "tests failed for ~A" (component-name c)))))
