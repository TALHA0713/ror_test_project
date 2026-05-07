import activeAdminPlugin from "./app/assets/tailwind/activeadmin_plugin.js";

const activeAdminPath = process.env.ACTIVE_ADMIN_PATH;

const content = [
  "./app/admin/**/*.{arb,erb,html,rb}",
  "./app/views/active_admin/**/*.{arb,erb,html,rb}",
  "./app/views/admin/**/*.{arb,erb,html,rb}",
  "./app/views/layouts/active_admin*.{erb,html}",
  "./app/javascript/**/*.js"
];

if (activeAdminPath) {
  content.push(
    `${activeAdminPath}/vendor/javascript/flowbite.js`,
    `${activeAdminPath}/plugin.js`,
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
  );
}

export default {
  content,
  darkMode: "selector",
  plugins: [
    activeAdminPlugin
  ]
}
