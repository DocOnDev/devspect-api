(ns devspect-api.core-test
  (:require [clojure.test :refer :all]
            [devspect-api.core :refer :all]))

(deftest test-parse-tracker-xml
  (def tracker-xml (java.io.StringReader. (slurp "pivotal.xml")))

  (testing "Extracts the author name"
    (is (= "James Kirk" (author-name (parse-tracker-xml tracker-xml)))))
  )

