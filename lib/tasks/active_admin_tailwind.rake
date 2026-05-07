namespace :active_admin do
  desc "Build ActiveAdmin Tailwind CSS"
  task :build_css do
    active_admin_path = Gem.loaded_specs["activeadmin"]&.full_gem_path
    command = [
      "bundle",
      "exec",
      "tailwindcss",
      "-i",
      "app/assets/stylesheets/active_admin.css",
      "-o",
      "app/assets/builds/active_admin.css",
      "--minify"
    ]

    success = system({ "ACTIVE_ADMIN_PATH" => active_admin_path.to_s }, *command)
    unless success
      raise "Failed to build ActiveAdmin CSS"
    end
  end
end

Rake::Task["tailwindcss:build"].enhance(["active_admin:build_css"])
