

  # def test_cumulative_flow_endpoint
  #   get "/cfd"
  #   assert last_response.ok?

  #   assert_equal CumulativeFlow.report.to_json, last_response.body
  # end

  # # model tests
  # # what an astronomical mess!
  # def test_cumulative_flow_report
  #   # TODO 2013/06/21
  #   # need to test support for multiple dates/keys
  #   # add logic to import process to get accurate start/end dates
  #   # for histories, e.g. when was it accepted as start_date...
  #   counts = {
  #     icebox:    7,
  #     backlog:   14,
  #     started:   2,
  #     finished:  1,
  #     delivered: 1,
  #     accepted:  41,
  #     rejected:  1
  #   }.sort

  #   expected = { "2013-06-20" => Hash[counts] }

  #   assert_equal expected, CumulativeFlow.report
  # end

  # def test_cumulative_flow_to_hash
  #   expected = { foxy: 3 }
  #   assert_equal expected, CumulativeFlow.new(description: "foxy", count: 3).to_hash
  # end


  # def test_closing_history_when_none_exists
  #   assert close_history()
  # end

  # def test_closing_history_when_no_status_change
  #   # have history, no state change
  # end

  # def test_closing_history_when_changing_status
  #   # have history, changing to a new state
  # end

  # def test_close_history_predicate_returns_false_when_history_is_nil
  #   refute close_history?(nil, 1)
  # end

  # def test_close_history_predicate_returns_false_when_status_ids_match
  #   history = StoryHistory.new(status_id: 1)
  #   refute close_history?(history, 1)
  # end

  # def test_close_history_predicate_returns_true_when_status_ids_do_not_match
  #   history = StoryHistory.new(status_id: 1)
  #   assert close_history?(history, 2)
  # end

  # def test_create_history_attrs_makes_a_hash_of_history_attributes
  #   actual = history_attrs_for(1, 2)
  #   assert_equal 1, actual[:story_id]
  #   assert_equal 2, actual[:status_id]
  # end

  # def test_create_history_predicate_returns_false_when_valid_history_exists
  #   h = StoryHistory.new(history_attrs_for(1, 2)).save
  #   refute create_history?(1, 2)
  #   h.delete
  # end

  # def test_create_history_predicate_returns_true_when_no_history_exists
  #   attrs = { story_id: 1, status_id: 2 }
  #   h = StoryHistory.find(attrs)
  #   h && h.delete
  #   assert create_history?(1, 2)
  # end
