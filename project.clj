(defproject devspect-api "0.1.0-SNAPSHOT"
  :description "DevSpect API"
  :url "http://github.com/seeflanigan/devspect-api"
  :license {:name "MIT"
            :url "http://opensource.org/licenses/MIT"}
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [ring "1.1.8"]
                 [compojure "1.1.5"]
                 [org.clojure/data.xml "0.0.7"]]

  :plugins [[lein-ring "0.8.5"]]

  :ring {:handler devspect-api.core/app})

