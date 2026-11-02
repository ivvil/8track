;;;; amazon.lisp

(in-package #:dev.shft.8track)

(defparameter +base-amazon-product-uri+ (quri:uri "https://www.amazon.es/dp/"))
(defparameter +common-user-agent+ "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36")

(defparameter *amazon-default-backoff-time* 1800)

(deftype amazon-asin ()
  '(string))

(define-condition amazon-blocked-request (error)
  ((request-time
	 :initform (local-time:now)
	 :reader request-time)
   (product-asin
	:initarg asin
	:reader product-asin
	:initform (error "An asin is required")))
  (:report (lambda (condition stream)
			 (format stream
					 "Product request blocked by amazon. Usually happens because you ran too many requests. Request time: ~a Product: ~a"
					 (request-time condition)
					 (product-asin condition)))))

(defclass amazon-product (product) ())

(defclass available-amazon-product (available-product amazon-product) ())

(defgeneric product-available (product))

(defmethod product-available ((product amazon-product))
  nil)

(defmethod product-available ((product available-amazon-product))
  t)

(-> amazon-product-url (amazon-asin) quri:uri)
(defun amazon-product-url (asin)
  "Generates the full amazon URL for the product idetified by the ASIN"
  (quri:merge-uris asin
				   +base-amazon-product-uri+))

(defun dom-element-exists (dom)
  (uiop:emptyp dom))

;; TODO Revise availability detection logic
(-> amazon-product-available-p (vector) boolean)
(defun amazon-product-available-p (dom)
  "Checks the availability of a product based on an lquery DOM"
  (dom-element-exists (lquery:$ dom "#outOfStockBuyBox_feature_div")))

(-> amazon-product-name (vector) string)
(defun amazon-product-name (dom)
  "Gets the product name of a product based on an lquery DOM"
  (string-trim " " (lquery-funcs:text (lquery:$1 dom "#productTitle"))))

(-> amazon-product-price (vector) integer)
(defun amazon-product-price (dom)
  "Gets the price of a product in cents based on an lquery DOM"
  (let ((whole (parse-integer (string-trim "," (lquery-funcs:text (lquery:$1 dom ".a-price-whole")))))
		(fraction (parse-integer (lquery-funcs:text (lquery:$1 dom ".a-price-fraction")))))
	(+ (* 100 whole) fraction)))

;; TODO Test if this actually works
(-> amazon-blocked-request-p (vector) boolean)
(defun amazon-blocked-request-p (dom)
  "Checks if the request was blocked on the lquery DOM"
  (dom-element-exists (lquery:$ dom "#productTitle")))

(defun prompt-new-value (prompt)
  (format *query-io* prompt)
  (force-output *query-io*)
  (list (read *query-io*)))

(-> product-request (amazon-asin) vector)
(defun product-request (asin)
  (restart-case
	  (let* ((url (amazon-product-url asin))
			 (dom (lquery:$ (initialize (dex:get url
												 :headers `(("User-Agent" . ,+common-user-agent+)))))))
		(when (amazon-blocked-request-p dom)
		  (error 'amazon-blocked-request :asin asin))
		dom)
	(wait-and-rerun-request (time-in-seconds)
	  :report "Enter time to wait"
	  :interactive (lambda () (prompt-new-value "Please enter time to wait in seconds: "))

	  (sleep time-in-seconds)
	  (product-request asin))))

(-> product-data (amazon-asin) (or amazon-product available-amazon-product))
(defun product-data (asin)
  (let* ((dom (product-request asin))
		 (name (amazon-product-name dom)))
	(if (amazon-product-available-p dom)
		(make-instance 'available-amazon-product
					   :id asin
					   :name name
					   :price (amazon-product-price dom))
		(make-instance 'amazon-product
					   :id asin
					   :name name))))

