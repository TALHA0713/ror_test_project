ActiveAdmin.setup do |config|
  config.site_title = "Ticket Tracking"
  config.default_namespace = :admin
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user
  config.logout_link_path = :logout_path
  # config.comments = false
  # config.comments_registration_name = "AdminComment"
  config.namespace :admin do |admin|
    admin.comments = false
    admin.comments_registration_name = "AdminComment"
  end
  config.batch_actions = true
  config.filter_attributes = [ :encrypted_password, :password, :password_confirmation ]
  config.localize_format = :long
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user
end
