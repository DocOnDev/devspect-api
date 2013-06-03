(ns devspect-api.core-test
  (:require [clojure.test :refer :all]
            [devspect-api.core :refer :all]))

(deftest test-parse-tracker-xml
  (def tracker-xml (java.io.StringReader. (slurp "pivotal.xml")))
  (def tracker-ds (parse-tracker-xml tracker-xml))

  (testing "Extracts the author name"
    (is (= "James Kirk" (author-name tracker-ds))))

  (testing "Extracts the description"
    (is (= "James Kirk accepted \"More power to shields\"" (description tracker-ds))))

  (testing "Extracts the date"
    (is (= "2009/12/14 14:12:09 PST" (occurred-at tracker-ds))))

  (testing "Extracts the activity type"
    (is (= "story_update" (activity-type tracker-ds))))

  (testing "Extracts the project id"
    (is (= "26" (project-id tracker-ds))))
)

