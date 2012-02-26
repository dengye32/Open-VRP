;;; Output functions
;;; --------------------------
(in-package :open-vrp.util)

(defgeneric print-routes (solution &optional stream)
  (:documentation "Prints solution given a <problem>/<algo> object. Also prints the total distance when the input is a <problem>/<algo> object."))

(defmethod print-routes ((prob problem) &optional (stream t))
  (format stream "~&---------------")
  (format stream "~&Fitness: ~A" (fitness prob))
  (format stream "~&---------------")
  (dolist (busy-veh (get-busy-vehicles prob))    
    (format stream "~&[~2D]: ~A~%" (vehicle-ID busy-veh) (route-indices busy-veh)))
  (format stream "~&---------------~%"))

(defmethod print-routes ((a algo) &optional (stream t))
  (print-routes (algo-best-sol a) stream))

(defun print-multi-run-stats (algo-objects)
  "Given a list of algo-objects returned by multi-run, print run-stats."
  (let ((results (mapcar #'algo-best-fitness algo-objects)))    
    (format t "~&Runs: ~8a~%Max: ~8a~%Min: ~8a~%Avg: ~8a~%Std: ~8a~%"
	    (length results) (get-max results) (get-min results) (mean results) (standard-deviation results))))

;; ---------------------------

;; Object printing methods
;; ---------------------------

(defun print-vrp-object (object &optional (stream t))
  "Given object, will print it's object's slots and values"
  (format stream "~&--------------")
  (format stream "~A object details:" (class-of object))
  (format stream "--------------~%~%")
  (dolist (slot (class-slots (class-of object)))
    (let ((slot-name (slot-definition-name slot)))
      (when (and
	     (slot-boundp object (slot-definition-name slot))
	     (not (or
		   (equal slot-name (intern "NETWORK" (find-package 'open-vrp.classes)))
		   (equal slot-name (intern "DIST-ARRAY" (find-package 'open-vrp.classes)))
		   (equal slot-name (intern "FLEET" (find-package 'open-vrp.classes))))))
	(format stream "~&Slot: ~18a Value: ~a~%" slot-name (slot-value object slot-name)))))
  (format stream "------------------------------------~%~%"))

;; -------------------------

;; Timestamp printing
;; -------------------------
(defun print-timestamp (&optional (stream t))
  "Prints timestamp to stream, source from cl-cookbook."
  (let ((days '("Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")))
  (multiple-value-bind (second minute hour date month year day-of-week dst-p tz)
      (get-decoded-time)
    (declare (ignore dst-p))
    (format stream "~&It is now ~2,'0d:~2,'0d:~2,'0d of ~a, ~d/~2,'0d/~d (GMT~@d)"
	    hour minute second (nth day-of-week days) month date year (- tz)))))

;; -------------------------

;; with-log-file macro
;; -------------------------
(defmacro with-log-or-print ((stream prob &optional (appendp T)) &body body)
  "A wrapper on top of with-open-file, where we use the filepath stored in the :log-file slot of a problem object. When it is nil, use the T stream. Optional parameter appendp can be set to NIL in order to :supersede if file exists. By default appends."
  (with-gensyms (func)
    `(flet ((,func (,stream)
	      ,@body))
       (aif (problem-log-file ,prob)
	    (with-open-file (,stream (namestring it) :direction :output
				     :if-exists (if ,appendp :append :supersede))
	      (,func ,stream))
	    (,func t)))))
	      
	  
			 