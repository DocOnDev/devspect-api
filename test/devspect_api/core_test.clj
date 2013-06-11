(ns devspect-api.core-test
  (:require [clojure.test :refer :all]
            [devspect-api.core :refer :all]))

(def xml-string (slurp "pivotal.xml"))

(deftest test-parse-tracker-xml
  (def tracker-ds (clojure.data.xml/parse-str xml-string))

  (testing "Extracts the author name"
    (is (= "James Kirk" (author-name tracker-ds))))

  (testing "Extracts the description"
    (is (= "James Kirk accepted \"More power to shields\"" (description tracker-ds))))

  (testing "Extracts the date"
    (is (= #inst "2009-12-14T22:12:09.000000000-00:00" (occurred-at tracker-ds))))

  (testing "Extracts the activity type"
    (is (= "story_update" (activity-type tracker-ds))))

  (testing "Extracts the project id"
    (is (= 26 (project-id tracker-ds))))
)

(defn get-request [resource app & params]
  (app {:request-method :get :uri resource :params (first params)}))

(defn post-request [resource app body & params]
  (app {:request-method :post :uri resource :params (first params) :body body}))

(deftest test-routes
  (is (= 200 (:status (get-request "/" app))))
  (is (= "this is compojure" (:body (get-request "/" app))))
  (is (= 200 (:status (post-request "/pivotal-tracker" app xml-string))))
  (is (= "OK" (:body (post-request "/pivotal-tracker" app xml-string))))
)
