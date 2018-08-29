// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


import swal from  "./sweetalert2"
window.swal = swal;


// Analytics page
import AnalyticsChart from "./analytics-chart"
let chartElement = document.getElementById("analyticsChart");
window.AnalyticsChart = AnalyticsChart;
chartElement && window.AnalyticsChart.buildChart();

import SubscriberChart from "./subscriber-chart"
let subscriberElement  = document.getElementById("subscriberChart");
window.SubscriberChart = SubscriberChart;
subscriberElement && window.SubscriberChart.buildChart();

// Chart in Dashboard Page 
import DashboardChart from "./dashboard-chart"
let dashboardChart = document.getElementById("dashboardChart");
window.DashboardChart = DashboardChart;
dashboardChart && window.DashboardChart.buildChart();


// Add Contact Phone number mask.
$("#contact-phone-number").mask("(000) 000-0000");
$("#customer-phonenumber").mask("(000) 000-0000");