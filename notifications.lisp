;;;; notifications.lisp

(in-package #:dev.shft.8track)

(defclass notification-channel () ())

(defgeneric api-url (channel)
  (:documentation "Gets the api url for the CHANNEL message API"))

(defgeneric send (channel message)
  (:documentation "Sends a plaintext MESSAGE to the user through the provided CHANNEL"))

(defgeneric send-product-update (channel product)
  (:documentation "Sends a PRODUCT update to the user through the provided CHANNEL"))

(defmethod send-product-update (channel (product product))
  (send channel (format nil "Product ~a (~a) is UNAVAILABLE" (name product) (id product))))

(defmethod send-product-update (channel (product available-product))
  (send channel (format nil "Product ~a (~a) is AVAILABLE. Price: ~a" (name product) (id product) (/ (price product) 100))))

