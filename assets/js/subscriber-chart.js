import Chart from "chart.js"

let SubscriberChart = {
  chart: null,
  buildChart() {
    let ctx = document.getElementById("subscriberChart");
    let labels = ["Subscriber", "Unsubscriber"];

    let allContact = parseInt(document.getElementById("all-contact").value);
    let unsubscriber = parseInt(document.getElementById("unsubscriber").value);

    let counts = [allContact, unsubscriber];
    console.log("Is chart working?");
    this.chart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: labels,
        datasets: [{
          data: counts,
          backgroundColor: [

            'rgba(93, 80, 223, 0.5)',
            'rgba(216, 27, 96, 0.5)'
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

  }
}

export default SubscriberChart