(in-package #:repl-backend-slynk)

(defclass slynk-backend (repl-backend) ()
  (:documentation "Sly's Slynk wire."))

(defun make-slynk-backend () (make-instance 'slynk-backend))

(defclass slynk-connection (swank-family-connection) ()
  (:default-initargs :rpc-package "SLYNK"))

(defparameter *slynk-rpcs*
  '((:connection-info . "CONNECTION-INFO")
    (:compile-string . "COMPILE-STRING-FOR-EMACS")
    (:compile-file . "COMPILE-FILE-FOR-EMACS")
    (:backtrace . "BACKTRACE")
    (:frame-locals . "FRAME-LOCALS-AND-CATCH-TAGS")
    (:frame-source-location . "FRAME-SOURCE-LOCATION")
    (:eval-in-frame . "EVAL-STRING-IN-FRAME")
    (:invoke-restart . "INVOKE-NTH-RESTART-FOR-EMACS")
    (:return-from-frame . "SLY-DB-RETURN-FROM-FRAME")
    (:restart-frame . "RESTART-FRAME")
    (:step-into . "SLY-DB-STEP")
    (:step-next . "SLY-DB-NEXT")
    (:step-out . "SLY-DB-OUT")
    (:create-mrepl "SLYNK-MREPL" . "CREATE-MREPL")
    (:inspect-entry "SLYNK-MREPL" . "INSPECT-ENTRY")
    (:init-inspector . "INIT-INSPECTOR")
    (:inspect-nth-part . "INSPECT-NTH-PART")
    (:inspector-call-nth-action . "INSPECTOR-CALL-NTH-ACTION")
    (:inspector-pop . "INSPECTOR-POP")
    (:inspector-next . "INSPECTOR-NEXT")
    (:inspect-frame-var . "INSPECT-FRAME-VAR")
    (:inspect-current-condition . "INSPECT-CURRENT-CONDITION")
    (:describe-symbol . "DESCRIBE-SYMBOL")
    (:documentation-symbol . "DOCUMENTATION-SYMBOL")
    (:operator-arglist . "OPERATOR-ARGLIST")
    (:apropos "SLYNK-APROPOS" . "APROPOS-LIST-FOR-EMACS")
    (:completions "SLYNK-COMPLETION" . "SIMPLE-COMPLETIONS")
    (:macroexpand-1 . "SLYNK-MACROEXPAND-1")
    (:macroexpand-all . "SLYNK-MACROEXPAND-ALL")
    (:xref . "XREF")
    (:find-definitions . "FIND-DEFINITIONS-FOR-EMACS")
    (:list-threads . "LIST-THREADS")
    (:kill-thread . "KILL-NTH-THREAD"))
  "Operation keyword → Slynk function name, or (package . name).")

(defmethod rpc-symbol ((conn slynk-connection) operation)
  (let ((entry (cdr (assoc operation *slynk-rpcs*))))
    (cond ((null entry)
           (error 'repl-protocol-error :message (format nil "Slynk has no RPC for ~S" operation)))
          ((consp entry) (wsym (car entry) (cdr entry)))
          (t (wsym "SLYNK" entry)))))

(defmethod repl-connect ((backend slynk-backend) &key (host "127.0.0.1") port)
  (open-wire-connection 'slynk-connection host port :backend backend))

(defun slynk-loader-forms (port-file)
  "--eval forms that load Slynk and its mrepl contrib (Quicklisp when present,
else ASDF) and start a server writing its port to PORT-FILE."
  (list "(require :asdf)"
        "(if (find-package :ql) (funcall (intern \"QUICKLOAD\" :ql) '(:slynk :slynk/mrepl) :silent t) (progn (asdf:load-system :slynk) (asdf:load-system :slynk/mrepl)))"
        (format nil "(funcall (intern \"START-SERVER\" :slynk) ~S :dont-close t)" port-file)))

(defmethod repl-spawn ((backend slynk-backend) &key (command *default-image-command*) directory env (timeout 180))
  (multiple-value-bind (port process) (spawn-image #'slynk-loader-forms :command command
                                                                        :directory directory :env env
                                                                        :timeout timeout)
    (let ((conn (repl-connect backend :port port)))
      (setf (connection-process conn) process)
      conn)))
