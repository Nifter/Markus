require File.join(File.dirname(__FILE__), 'authenticated_controller_test')
require File.join(File.dirname(__FILE__), '..', 'blueprints', 'helper')

class TasControllerTest < AuthenticatedControllerTest

  def setup
    clear_fixtures
  end


  context "No user" do
    should "redirect to the index" do
      get :index
      assert_redirected_to :action => "login", :controller => "main"
    end
  end # -- No user


  context "a TA" do
    setup do
      @ta = Ta.make
    end

    should "not be able to go on :index" do
      get_as @ta, :index
      assert_response :missing
    end

    should "not be able to :edit" do
      get_as @ta, :edit, :id => @ta.id
      assert_response :missing
    end

    should "not be able to :update" do
      put_as @ta, :update, :id => @ta.id
      assert_response :missing
    end

    should "not be able to :create" do
      put_as @ta, :create
      assert_response :missing
    end

  end # -- a TA


  context "An admin" do
    setup do
      @admin = Admin.make
    end

    should "be able to get :index" do
      get_as @admin, :index
      assert_response :success
    end

    should "be able to get :new" do
      get_as @admin, :new
      assert_response :success
    end

    context "with a TA" do
      setup do
        @ta = Ta.make
      end

      should "be able to edit a TA" do
        get_as @admin,
               :edit,
               :id => @ta.id
        assert_response :success
      end

      should "have valid values in database after an upload of a ISO-8859-1 encoded file parsed as ISO-8859-1" do
        post_as @admin,
                :upload_ta_list,
                :userlist => fixture_file_upload('../classlist-csvs/test-students-iso-8859-1.csv'),
                :unicode => nil
        assert_response :redirect
        assert_redirected_to(:controller => "tas", :action => 'index')
        test_student = Ta.find_by_user_name('c2ÈrÉØrr')
        assert_not_nil test_student # student should exist
      end

      should "have invalid values in database after an upload of an ISO-8859-1 encoded file parsed as unicode" do
        post_as @admin,
                :upload_ta_list,
                :userlist => fixture_file_upload('../classlist-csvs/test-students-iso-8859-1.csv'),
                :unicode => '1'
        assert_response :redirect
        assert_redirected_to(:controller => "tas", :action => 'index')
        test_student = Ta.find_by_user_name('c2ÈrÉØrr')
        assert_nil test_student # student should not be found, despite existing in the CSV file
      end

      should "have valid values in database after an upload of a unicode encoded file parsed as unicode" do
        post_as @admin,
                :upload_ta_list,
                :userlist => fixture_file_upload('../classlist-csvs/test-students-utf8.csv'),
                :unicode => '1'
        assert_response :redirect
        assert_redirected_to(:controller => "tas", :action => 'index')
        test_student = Ta.find_by_user_name('c2ÈrÉØrr')
        assert_not_nil test_student # student should exist
      end

      should "have invalid values in database after an upload of a unicode encoded file parsed as ISO-8859-1" do
        post_as @admin,
                :upload_ta_list,
                :userlist => fixture_file_upload('../classlist-csvs/test-students-utf8.csv'),
                :unicode => nil
        assert_response :redirect
        assert_redirected_to(:controller => "tas", :action => 'index')
        test_student = Ta.find_by_user_name('c2ÈrÉØrr')
        assert_nil test_student # student should not be found, despite existing in the CSV file
      end
    end # -- With a TA
  end # -- An admin

end