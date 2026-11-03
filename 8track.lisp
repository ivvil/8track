;;;; 8track.lisp

(in-package #:dev.shft.8track)

(defparameter *maximum-backoff-seconds* 7200)
(defparameter *minimum-backoff-seconds* 900)

(defun random-backoff (attempt &key (maximum-backoff-seconds *maximum-backoff-seconds*) (minimum-backoff-seconds *minimum-backoff-seconds*))
  (assert (and (plusp maximum-backoff-seconds) (plusp minimum-backoff-seconds) (<= minimum-backoff-seconds maximum-backoff-seconds)))
  (let ((limit (min maximum-backoff-seconds (* minimum-backoff-seconds (expt 2 attempt)))))
	(+ minimum-backoff-seconds (random (- limit minimum-backoff-seconds)))))

(defun watch (asin channel &key (interval 900) (maximum-backoff-seconds *maximum-backoff-seconds*) (minimum-backoff-seconds *minimum-backoff-seconds*))
  (loop for attempt from 0
		do
		   (let ((product
				   (handler-bind				
					   ((amazon-blocked-request
						  (lambda (c)
							(declare (ignore c))
							(incf attempt)
							(invoke-restart 'wait-and-rerun-request (random-backoff attempt
																			   :maximum-backoff-seconds maximum-backoff-seconds
																			   :minimum-backoff-seconds minimum-backoff-seconds))))
						(error
						  (lambda (c)
							(declare (ignore c))
							(invoke-restart 'wait-default-and-rerun-request))))
					 (product-data asin))))
			 (send-product-update channel product)
			 (sleep interval))))

(defun main (args)
  )
