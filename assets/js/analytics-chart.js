import Chart from "chart.js"

let AnalyticsChart = {
  chart: null,
  buildChart() {
    let ctx = document.getElementById("analyticsChart");
    let labels = ["sent", "delivered", "undelivered", "clicks"];
   
    let total_sent = parseInt(document.getElementById("total-sent").dataset.totalSent);
    let delivered = parseInt(document.getElementById("deilvered-count").dataset.deliveredCount);
    let undelivered = parseInt(document.getElementById("undelivered-count").dataset.undeliveredCount);
    let clicks = parseInt(document.getElementById("total-clicks").dataset.totalClicks);
    let counts = [total_sent, delivered, undelivered, clicks];
    console.log("Is chart working?");
    this.chart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: labels,
        datasets: [{
          data: counts,
          backgroundColor: [

            'rgba(54, 162, 235, 0.5)',
            'rgba(255, 206, 86, 0.5)',
            'rgba(255, 99, 132, 0.5)',
            'rgba(75, 192, 192, 0.5)'
          ]
        }] 
      },
      options: {
        legend: {
          position: 'bottom',
          fontSize: 13
        }
      }
    });
  
  },

  update(){
    let total_sent = parseInt(document.getElementById("total-sent").dataset.totalSent);
    let delivered = parseInt(document.getElementById("deilvered-count").dataset.deliveredCount);
    let undelivered = parseInt(document.getElementById("undelivered-count").dataset.undeliveredCount);
    let clicks = parseInt(document.getElementById("total-clicks").dataset.totalClicks);
    let counts = [total_sent, delivered, undelivered, clicks];
    
    this.chart.data.datasets[0].data = counts;
    this.chart.update();
    console.log("chart is updating");
  }
}

export default AnalyticsChart