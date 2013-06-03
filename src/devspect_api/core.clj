(ns devspect-api.core
  (:use compojure.core)
  (:require [compojure.route :as route]
            [compojure.handler :as handler])
  (:use ring.adapter.jetty))

(defroutes my-routes
  (GET "/" [] "this is compojure")
  (route/not-found "four oh four"))

(def app (handler/site my-routes))
;;
;;(def pivotal-xml (java.io.StringReader. (slurp "pivotal.xml")))
;;
;;(defn parse-xml []
;;  (let [pivotal-xml (java.io.StringReader. (slurp "pivotal.xml"))]
;;    (print (xml/parse pivotal-xml))))
