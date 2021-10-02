require "application_system_test_case"

class LandingsTest < ApplicationSystemTestCase
  setup do
    @landing = landings(:one)
  end

  test "visiting the index" do
    visit landings_url
    assert_selector "h1", text: "Landings"
  end

  test "creating a Landing" do
    visit landings_url
    click_on "New Landing"

    click_on "Create Landing"

    assert_text "Landing was successfully created"
    click_on "Back"
  end

  test "updating a Landing" do
    visit landings_url
    click_on "Edit", match: :first

    click_on "Update Landing"

    assert_text "Landing was successfully updated"
    click_on "Back"
  end

  test "destroying a Landing" do
    visit landings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Landing was successfully destroyed"
  end
end
