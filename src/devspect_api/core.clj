(ns devspect-api.core
  (:use compojure.core)
  (:require [compojure.route :as route]
            [compojure.handler :as handler]
            [clojure.data.xml :as xml])
  (:use ring.adapter.jetty))

(defroutes my-routes
  (GET "/" [] "this is compojure")
  (route/not-found "fore oh fore"))

(def app (handler/site my-routes))

(defn parse-tracker-xml [xml] (xml/parse xml))

(defn get-attribute [key ds]
  (first (:content
    (first (filter
      #(= key (:tag %1))
      (tree-seq :content :content ds))))))

(defn author-name [ds] (get-attribute :author ds))
(defn description [ds] (get-attribute :description ds))
(defn occurred-at [ds] (get-attribute :occurred_at ds))
(defn activity-type [ds] (get-attribute :event_type ds))
(defn project-id [ds] (get-attribute :project_id ds))
