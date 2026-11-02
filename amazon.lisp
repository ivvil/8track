;;;; amazon.lisp

(in-package #:dev.shft.8track)

(defparameter +not-available-text+ " No disponible. ")
(defparameter +base-amazon-product-uri+ (quri:uri "https://www.amazon.es/dp/"))
(defparameter +common-user-agent+ "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36")

(defparameter *amazon-default-backoff-hours* 1)

(deftype amazon-asin ()
  '(string))

(deftype amazon-product-availability ()
  '(member
	:available
	:unavailable))

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

;; TODO Test if this actually works
(-> amazon-blocked-request-p (vector) boolean)
(defun amazon-blocked-request-p (dom)
  "Checks if the request was blocked on the lquery DOM"
  (dom-element-exists (lquery:$ dom "#productTitle")))

(-> check-availability (amazon-asin) amazon-product-availability)
(defun check-availability (asin)
  (let* ((url (amazon-product-url asin))
		 (dom (lquery:$ (initialize (dex:get url
											 :headers `(("User-Agent" . ,+common-user-agent+)))))))
	(when (amazon-blocked-request-p dom)
	  (error "Request was blocked by amazon. Try again"))
	(if (amazon-product-available-p dom)
		:available
		:unavailable)))

