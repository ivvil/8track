;;;; notifications.lisp

(in-package #:dev.shft.8track)

(defclass notification-channel () ())

(defgeneric send (channel message)
  (:documentation "Sends a plaintext MESSAGE to the user through the provided CHANNEL"))

(defgeneric api-url (channel)
  (:documentation "Gets the api url for the CHANNEL message API"))
