require "application_system_test_case"

class QuestionStatesTest < ApplicationSystemTestCase
  setup do
    @question_state = question_states(:one)
  end

  test "visiting the index" do
    visit question_states_url
    assert_selector "h1", text: "Question States"
  end

  test "creating a Question state" do
    visit question_states_url
    click_on "New Question State"

    click_on "Create Question state"

    assert_text "Question state was successfully created"
    click_on "Back"
  end

  test "updating a Question state" do
    visit question_states_url
    click_on "Edit", match: :first

    click_on "Update Question state"

    assert_text "Question state was successfully updated"
    click_on "Back"
  end

  test "destroying a Question state" do
    visit question_states_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Question state was successfully destroyed"
  end
end
