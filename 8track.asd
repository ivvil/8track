;;;; 8track.asd

(asdf:defsystem #:8track
  :description "An Amazon product tracker that notifies you when a product is in stock"
  :author "Iván Villagrasa <ivvil412@gmail.com>"
  :license  "GPL-3"
  :version "0.0.1"
  :serial t
  :depends-on (:dexador
			   :plump
			   :lquery
			   :lparallel
			   :serapeum
			   :quri
			   :local-time)
  :components ((:file "package")
			   (:file "product")
			   (:file "amazon")
			   (:file "notifications")
			   (:file "telegram")
               (:file "8track")))
