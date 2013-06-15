require 'test_helper'

class RedirectionsControllerTest < ActionController::TestCase
  setup do
    @redirection = redirections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:redirections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create redirection" do
    assert_difference('Redirection.count') do
      post :create, redirection: { destination_url: @redirection.destination_url, source_url: @redirection.source_url }
    end

    assert_redirected_to redirection_path(assigns(:redirection))
  end

  test "should show redirection" do
    get :show, id: @redirection
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @redirection
    assert_response :success
  end

  test "should update redirection" do
    patch :update, id: @redirection, redirection: { destination_url: @redirection.destination_url, source_url: @redirection.source_url }
    assert_redirected_to redirection_path(assigns(:redirection))
  end

  test "should destroy redirection" do
    assert_difference('Redirection.count', -1) do
      delete :destroy, id: @redirection
    end

    assert_redirected_to redirections_path
  end
end
