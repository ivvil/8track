;;;; product.lisp

(in-package #:dev.shft.8track)

(defclass product ()
  ((id
	:initarg :id
	:reader id
	:initform (error "A product id is required"))
   (name
	:initarg :name
	:reader name
	:initform (error "A product name is required")
	:type string)))

(defclass available-product (product)
  ((price
	:initarg :price
	:reader price
	:initform (error "A product price is required")
	:type integer)))
