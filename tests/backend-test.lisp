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

(defun abort-all (conn)
  (loop for state = (repl-debugger-state conn)
        while state
        do (handler-case
               (repl-invoke-restart conn (let ((r (find-if (lambda (r) (search "ABORT" (string (restart-info-name r)) :test #'char-equal))
                                                 (debugger-state-restarts state))))
                                   (if r (restart-info-index r) 0)))
             (repl-not-in-debugger () (return)))))

(deftest channel-input-after-abort
  ;; Slynk's ABORT sends the channel's prompt, then drops the events already
  ;; queued for the channel: input sent on that prompt must not be lost.
  (process-backend-uiop:use-uiop-process-backend)
  (let* ((conn (repl-spawn (make-slynk-backend)))
         (channel (progn
                    ;; widen the window: the thread is slow to start dropping
                    (repl-eval conn "(defmethod slynk::drop-unprocessed-events :around (c) (sleep 0.3) (call-next-method))")
                    (repl-open-channel conn)))
         (lost 0))
    (unwind-protect
         (dotimes (i 10)
           (ok (typep (repl-channel-eval channel "(error \"boom\")") 'debugger-state))
           (abort-all conn)
           (handler-case
               (unless (equal (eval-result-values (repl-channel-eval channel "(+ 1 1)" :timeout 5)) '("2"))
                 (incf lost))
             (repl-timeout () (incf lost))))
      (ignore-errors (repl-close-channel channel))
      (repl-disconnect conn :kill t))
    (ok (zerop lost) (format nil "~D of 10 evaluations after an abort were lost" lost))))
