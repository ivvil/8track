;;;; telegram.lisp

(in-package #:dev.shft.8track)

(defparameter +telegram-api-url+ (quri:uri "https://api.telegram.org"))

(defclass telegram-channel (notification-channel)
  ((token
	:initarg :token
	:reader token
	:initform (error "A telegram bot token is required"))
   (chat-id
	:initarg :chat-id
	:reader chat-id
	:initform (error "A telegram chat id is required"))))

(defmethod api-url ((channel telegram-channel))
  (quri:make-uri :defaults +telegram-api-url+
                 :path (format nil "/bot~a/" (token channel))))

(defmethod send ((channel telegram-channel) message)
  (dex:post (quri:merge-uris
			 "sendMessage"
			 (api-url channel))
			:content `(("chat_id" . ,(chat-id channel))
					   ("text" . ,message))))
