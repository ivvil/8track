;;;; 8track.lisp

(in-package #:dev.shft.8track)

(defun watch (asin &key (interval 900) (backoff 3600))
  (loop
		(let ((product (handler-case (product-data asin)
						 (error (c))))))))

(defun main (args)
  )
