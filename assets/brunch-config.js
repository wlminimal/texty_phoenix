exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
        joinTo: 'js/app.js',
      // joinTo: {
      //   'js/landing-page.js' : [
      //     'js/landing/jquery-2.2.4.min.js',
      //     'js/landing/popper.min.js',
      //     'js/landing/bootstrap.min.js',
      //     'js/landing/plugins.js',
      //     'js/landing/owl.carousel.min.js',
      //     'js/landing/slick.min.js',
      //     'js/landing/footer-reveal.min.js',
          
      //     'node_modules/process/browser.js',
      //     'node_modules/phoenix_html/priv/static/phoenix_html.js',
      //     'node_modules/phoenix/priv/static/phoenix.js',
      //     'js/landing/active.js',

      //     'js/app.js'
      //   ],
      //   'js/app.js' : [
      //     'js/jquery.min.js',
      //     'js/bootstrap.min.js',
      //     'js/material.min.js',
      //     'js/materilize.min.js',
      //     'js/perfect-scrollbar.jquery.min.js',
      //     'js/arrive.min.js',
      //     'js/jquery.validate.min.js',
      //     'js/moment.min.js',
      //     'js/chartist.min.js',
      //     'js/jquery.bootstrap-wizard.js',
      //     'js/bootstrap-notify.js',
      //     'js/bootstrap-datetimepicker.js',
      //     'js/jquery-jvectormap.js',
      //     'js/nouislider.min.js',
      //     'js/jquery.select-bootstrap.js',
      //     'js/sweetalert2.js',
      //     'js/jasny-bootstrap.min.js',
      //     'js/fullcalendar.min.js',
      //     'js/jquery.tagsinput.js',
      //     'js/materialize.min.js',
      //     'js/material-dashboard.js',
      //     'node_modules/phoenix_html/priv/static/phoenix_html.js',
      //     'node_modules/moment/moment.js',
      //     'node_modules/chart.js',
      //     'node_modules/phoenix/priv/static/phoenix.js',
      //     'node_modules/process/browser.js',
      //     'node_modules/chart.js/src/charts/*.js',
      //     'node_modules/chart.js/src/controllers/*.js',
      //     'node_modules/chart.js/src/core/*.js',
      //     'node_modules/chart.js/src/elements/*.js',
      //     'node_modules/chart.js/src/helpers/*.js',
      //     'node_modules/chart.js/src/platforms/*.js',
      //     'node_modules/chart.js/src/plugins/*.js',
      //     'node_modules/chart.js/src/scales/*.js',
      //     'node_modules/chart.js/src/chart.js',
      //     'node_modules/chartjs-color/index.js',
      //     'node_modules/color-convert/index.js',
      //     'node_modules/chartjs-color-string/color-string.js',
      //     'node_modules/color-convert/conversions.js',
      //     'node_modules/color-name/index.js',

      //     'js/analytics-chart.js',
      //     'js/dashboard-chart.js',
      //     'js/split-sms.min.js',
      //     // 'js/socket.js',
      //     'js/custom.js',
          
      //     'js/app.js'
      //   ]
      // },
      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //   "js/app.js": /^js/,
      //   "js/vendor.js": /^(?!js)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      order: {
        before: [
          // Dashboard
          'vendor/popper.min.js',
          'vendor/bootstrap.min.js',
          'vendor/material.min.js',
          'vendor/perfect-scrollbar.jquery.min.js',
          'vendor/arrive.min.js',
          'vendor/jquery.validate.min.js',
          'vendor/moment.min.js',
          'vendor/chartist.min.js',
          'vendor/jquery.bootstrap-wizard.js',
          'vendor/bootstrap-notify.js',
          'vendor/bootstrap-datetimepicker.js',
          'vendor/jquery-jvectormap.js',
          'vendor/nouislider.min.js',
          'vendor/jquery.select-bootstrap.js',
          'js/sweetalert2.js',
          'vendor/jasny-bootstrap.min.js',
          'vendor/fullcalendar.min.js',
          'vendor/jquery.tagsinput.js',
          'vendor/material-dashboard.js',


          // Landing page
          'vendor/plugins.js',
          'vendor/slick.min.js',
          'vendor/footer-reveal.min.js',
          'vendor/active.js',
          
          
          'js/analytics-chart.js',
          'js/dashboard-chart.js',

          
          
        ]
      }
    },
    stylesheets: {
      joinTo: {
        'css/landing-page.css': [
          'css/vendor/material-dashboard.css',
          'css/landing/bootstrap.min.css',
          
          'css/landing/animate.css',
          'css/landing/magnific-popup.css',
          'css/landing/owl.carousel.min.css',
          'css/landing/slick.css',
          'css/landing/font-awesome.min.css',
          'css/landing/themify-icons.css',
          'css/landing/ionicons.min.css',
          'css/landing/style.css',
          'css/landing/responsive.css',
          'css/landing/custom.css',
          'css/landing/landing_page.css'
        ],

        'css/app.css' : [
          'css/vendor/bootstrap.min.css',
          'css/vendor/materialize.css',
          'css/vendor/material-dashboard.css',
          'css/404.css',
          'css/menu.css',
          'css/dashboard.css',
          'css/help.css'
        ]
      },
        order: {
        before: [
          '/vendor/bootstrap.min.css',
          // '/vendor/materialize.css',
          '/vendor/material-dashboard.css'
        ]
      }
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["static", "css", "js", "vendor"],
    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      presets: ["es2015", "react", "env", "stage-2"],
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
    }
  },

  npm: {
    enabled: true,
    globals: {
      $: 'jquery',
      jQuery: 'jquery'
    }
  }
};
